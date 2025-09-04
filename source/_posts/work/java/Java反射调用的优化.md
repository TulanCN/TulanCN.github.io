---
title: Java反射调用的优化
date: 2023-05-04 10:44:04
description: effective java中曾言，避免反射的最好方式是定义接口。但反射是orm框架中不得不使用的能力，这次对反射的操作做了一次性能优化。
categories:
- 工作
tags:
 - 性能调优
---



## 场景

在公司内部的缓存框架中，需要实现类似数据库的能力：比如主键、索引，还有条件查询等。

这些能力不可避免的需要从一个对象中，通过反射的方式来取参数的值。且目前没有办法通过定义接口的方式来优化。

## 实现

以前的方式大多是建立Method对象的缓存，但是在查阅资料之后，我使用了一个新的方式。

这里我先给出一个原本的实现: 

```
    private static final Map<String, Method> methodsCache = new ConcurrentHashMap<>(256);

		/**
     * 获取Object对象中指定属性的值。
     * @param instance instance
     * @param fieldName fieldName
     * @return Object
     */
    public static Object getFieldValue(Class<?> clazz, Object instance, String fieldName) {
        Method method = findMethod(clazz, fieldName);
        if (!Objects.isNull(method)) {
            try {
                return method.invoke(instance);
            } catch (IllegalAccessException | InvocationTargetException e) {
                throw new RuntimeException(e);
            }
        }
        return null;
    }
    
    private static Method findMethod(Class<?> clazz, String fieldName) {
        String methodName = "get" + changeFirstCharacterCase(fieldName, true);
        // 优先从缓存获取
        Method method = methodsCache.get(clazz.getName() + "#" + methodName);
        if (!Objects.isNull(method)) {
            return method;
        }
        // 缓存中未找到，从clazz中获取
        try {
            method =  clazz.getMethod(methodName);
            methodsCache.put(clazz.getName() + "#" + methodName, method);
            return method;
        } catch (NoSuchMethodException e) {
            logger.error("在{}中未找到名为{}的方法名。", clazz.getName(), methodName);
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
        }
        return null;
    }

```

这逻辑不难理解，缓存了Method对象，避免每次都要进行查找。一般来说这可以很大程度的提升性能。

不过我随后进行了jmh的测试，发现了一些问题。

| Benchmark    | Mode | Cnt  | Score   | Score     | Units |
| ------------ | ---- | ---- | ------- | --------- | ----- |
| testNormal   | avgt | 10   | 0.338   | ±   0.003 | ns/op |
| testRef      | avgt | 10   | 4.423   | ±   0.174 | ns/op |
| testRefBuild | avgt | 10   | 181.405 | ±  21.063 | ns/op |

表格中，第一行数据是通过get方法取值；第二行是通过从缓存中获取Method然后调用取值；第三行是构建Method方法并取值。

不难看出：哪怕是通过缓存的方式来取值，也会导致性能下降大约十倍。



在查阅资料时，我发现了这篇文章：

[1]: https://dzone.com/articles/java-reflection-but-faster	"java-reflection-but-faster"

这里提供了一个思路：通过LambdaMetafactory构建lambda表达式，在构建的lambda表达式中调用对应的方法。

最后的实现如下

```

/**
 * 对象访问器
 *
 * @author daizheli
 * @since 4.2.0 2023/4/13 
 */
public class ObjGetter {

    private final Function getterFunction;

    public ObjGetter(Method method) {
        MethodHandles.Lookup lookup = MethodHandles.lookup();
        try {
            MethodHandle methodHandle = lookup.unreflect(method);
            CallSite site = LambdaMetafactory.metafactory(lookup, "apply", MethodType.methodType(Function.class),
                MethodType.methodType(Object.class, Object.class), methodHandle, methodHandle.type());
            getterFunction = (Function) site.getTarget().invokeExact();
        } catch (Throwable e) {
            throw new RuntimeException(e);
        }
    }

    public Object executeGetter(Object bean) {
        return getterFunction.apply(bean);
    }

}
```

```

/**
 * 对象设置器
 *
 * @author daizheli
 * @since 4.2.0 2023/4/13 
 */
public class ObjSetter {

    private final BiConsumer function;

    public ObjSetter(Method method) {
        MethodHandles.Lookup lookup = MethodHandles.lookup();
        try {
            MethodHandle methodHandle = lookup.unreflect(method);
            CallSite site = LambdaMetafactory.metafactory(lookup, "accept", MethodType.methodType(BiConsumer.class),
                MethodType.methodType(void.class, Object.class, Object.class), methodHandle, methodHandle.type());
            function = (BiConsumer) site.getTarget().invokeExact();
        } catch (Throwable e) {
            throw new RuntimeException(e);
        }
    }

    public void executeSetter(Object bean, Object value) {
        function.accept(bean, value);
    }

}
```

也跑了一下jmh，测试结果是

```
Benchmark                           Mode  Cnt      Score     Error  Units
ObjGetterBatchTest.testLambda       avgt   10      0.692 ±   0.037  ns/op
ObjGetterBatchTest.testLambdaBuild  avgt   10  25439.081 ± 956.824  ns/op
ObjGetterBatchTest.testNormal       avgt   10      0.338 ±   0.003  ns/op
ObjGetterBatchTest.testRef          avgt   10      4.423 ±   0.174  ns/op
ObjGetterBatchTest.testRefBuild     avgt   10    181.405 ±  21.063  ns/op
```

构建的速度有明显下降，但是每次调用的速度也有明显的提升。

在我们内部的场景下，会有启动时从数据库加载数据创建索引的步骤，因此启动时就会构建好这部分缓存，从而提高运行时的速度。

## 总结

每次反射都去查询Method是不可接受的。在缓存的基础上，通过MethodHandles其实可以提高一部分调用的性能。

但是综合考虑之后，还是使用LambdaMetafactory在运行时构建lambda表达式更适合当前的场景。

可惜的是LambdaMetafactory的案例和解析在中文网站上几乎找不到，哪怕是英文资料也很少。

