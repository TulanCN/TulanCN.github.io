---
title: Unsafe的使用记录
date: 2024-01-07 11:15:32
description: 在项目中使用了Unsafe作为一些高性能中间件的底层实现，这里做个记录。
categories:
- 工作
tags:
 - 性能调优
---



## 什么是Unsafe

`sun.misc.Unsafe`是sun包下的一个类。它的类注释如下：

```
/**
 * A collection of methods for performing low-level, unsafe operations.
 * Although the class and all methods are public, use of this class is
 * limited because only trusted code can obtain instances of it.
 *
 * @author John R. Rose
 * @see #getUnsafe
 */
public final class Unsafe {
```

可见，这个类过于底层，至少Java的开发者本身是不希望其他人使用这个类的。

为何如此？

我想，最大的原因，就是Java本身是一种内存安全的语言。由于JVM的兜底机制，Java程序很少出现程序崩溃之类的问题。但是Unsafe提供的方法不同，正如其类名所述，它的方法都是“Unsafe”的，使用不当可能会导致程序崩溃。

可事实上，Unsafe更像是一个语言开发者留给自己的后门，看JDK中的源码，我们不难发现它其实被Jdk中的包广泛使用。更有甚者，在很多知名开源项目中，也会利用Unsafe类的能力来提高程序的性能。

## 使用Unsafe

在程序中使用Unsafe，目前只能通过反射的方式来获取。这是因为Unsafe类添加了`@CallerSensitive`注解，只有特定类加载器加载的类可以使用。

```
		@CallerSensitive
    public static Unsafe getUnsafe() {
        Class<?> caller = Reflection.getCallerClass();
        if (!VM.isSystemDomainLoader(caller.getClassLoader()))
            throw new SecurityException("Unsafe");
        return theUnsafe;
    }
```

但是也不麻烦，我们可以使用如下代码获取到

```
    private static final Unsafe UNSAFE = reflectGetUnsafe();

    private static Unsafe reflectGetUnsafe() {
        try {
            Field field = Unsafe.class.getDeclaredField("theUnsafe");
            field.setAccessible(true);
            return (Unsafe) field.get(null);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
```

不过一定要注意，不同版本的Unsafe类有不同的实现！使用前还是要谨慎。

## 内存操作

要说Unsafe提供最大的能力，就是内存操作了。

C++程序中，我们可以申请一段内存，然后往里边设置数据，再把内存的指针传递给其他方法使用，最后释放内存。

这种操作在Java中，对应的就是创建一个对象，然后往对象里设置值，把对象传递给其他类的方法使用，最后交由JVM回收对象。

显然，Java是不能直接操作内存的，但是通过Unsafe类，我们可以做到这种能力。但同时，这也意味着内存管理的职责从JVM转移到了程序员自身，如果申请了内存没有释放，就会造成内存泄漏（OOM）。

那么我们看一下实际怎么操作内存：

```
// 使用unsafe分配内存
long addr = UNSAFE.allocateMemory(4);
// 往内存块设置一个int类型数据
UNSAFE.putInt(addr, 18);
// 从内存块获取一个int类型数据
UNSAFE.getInt(addr);
// 调整大小
UNSAFE.reallocateMemory(8)
// 释放内存
UNSAFE.freeMemory(addr);
```

这种操作，几乎和C++程序是一致的了。

设置数据和获取数据的操作在Unsafe类中每种基础类型都已提供对应方法，这里就不再赘述。

当然还有最关键的copyMemory方法，可以从Java的数组对象之间，或者Java的数组对象与内存块之间拷贝数据。

不过需要注意的是：从内存块到Bean对象的拷贝是不被允许的。

```

    /**
     * Sets all bytes in a given block of memory to a copy of another
     * block.
     *
     * <p>This method determines each block's base address by means of two parameters,
     * and so it provides (in effect) a <em>double-register</em> addressing mode,
     * as discussed in {@link #getInt(Object,long)}.  When the object reference is null,
     * the offset supplies an absolute base address.
     *
     * <p>The transfers are in coherent (atomic) units of a size determined
     * by the address and length parameters.  If the effective addresses and
     * length are all even modulo 8, the transfer takes place in 'long' units.
     * If the effective addresses and length are (resp.) even modulo 4 or 2,
     * the transfer takes place in units of 'int' or 'short'.
     *
     * @since 1.7
     */
    public native void copyMemory(Object srcBase, long srcOffset,
                                  Object destBase, long destOffset,
                                  long bytes);
```

## 对象操作

接着是对象操作，使用反射和Unsafe，可以极快地获取对象中的字段信息。

不过需要注意，这种操作会绕过字段的各种限制，相当于是直接从对象的内存块上取数据。这种操作很方便，但完全违反了面向对象的原则。

首先来看一个Java对象的内存结构：

```
 OFFSET  SIZE               TYPE DESCRIPTION                               VALUE
      0     4                    (object header)                           01 00 00 00 
      4     4                    (object header)                           00 00 00 00 
      8     4                    (object header)                           18 0a 06 00 
     12     4                int User.age                                  0
     16     4   java.lang.String User.name                                 null
     20     4   java.lang.String User.name1                                null
     24     4   java.lang.String User.name2                                null
     28     4   java.lang.String User.name3                                null
     32     4   java.lang.String User.name4                                null
     36     4   java.lang.String User.name5                                null
     40     4   java.lang.String User.name6                                null
     44     4   java.lang.String User.name7                                null
     48     4   java.lang.String User.name8                                null
     52     4   java.lang.String User.name9                                null
     56     4   java.lang.String User.name10                               null
     60     4   java.lang.String User.name11                               null
     64     4   java.lang.String User.name12                               null
     68     4   java.lang.String User.name13                               null
     72     4   java.lang.String User.name14                               null
     76     4   java.lang.String User.name15                               null
     80     4   java.lang.String User.name16                               null
     84     4   java.lang.String User.name17                               null
     88     4   java.lang.String User.name18                               null
     92     4                    (loss due to the next object alignment)
```

一个Java对象，有12字节长的对象头。基础类型会直接存放在对象中，引用类型存放的是对象的引用（4字节）。

基础类型在各种处理上都有明显的优势，这里也可以理解为什么性能敏感的项目并不推荐使用包装类型。包装类型在对象中的存储方式就是引用类型，和String、BigDecimal是一样的，在存取效率和使用效率上会有明显的差异。

Unsafe提供的第一种能力，就是直接通过offset的方式，从对象中获取数据。

下面看下代码：

```
public static void main(String[] args) throws NoSuchFieldException {
        User user = new User();
        // 使用unsafe的api获取字段的偏移量，需要通过反射来获取字段的Field对象
        Field age = User.class.getDeclaredField("age");
        long ageAddr = UNSAFE.objectFieldOffset(age);
        // 设置时把对象的偏移量传入
        UNSAFE.putInt(user, ageAddr, 10);
        // 取出时也是通过偏移量
        UNSAFE.getInt(user, ageAddr);
    }
```

上面的代码中，类型操作是个重点。如果使用错误的api来获取对象数据，很可能出现程序崩溃的异常！这也是为什么这个类称之为Unsafe的原因，使用不当极有可能导致程序崩溃。正常的Java程序是内存安全的。

上述方法在获取和设置对象的字段信息时，绕过了方法区和对象的字段范围限制。显然，这也脱离了面向对象的思维。

另外，还提供了绕过构造器创建对象的方法。原理上就是直接划分一个对应大小内存块。这里就不多提了。

## CAS操作

CAS操作不多解释，Java的Concurrent包下的AtomicInteger这些原子操作都是通过Unsafe的CAS相关API进行操作。ConcurrentHashMap也是使用到了此类操作。

下面简单看一个api：

```
    /**
     * Atomically update Java variable to <tt>x</tt> if it is currently
     * holding <tt>expected</tt>.
     * @return <tt>true</tt> if successful
     */
    public final native boolean compareAndSwapObject(Object o, long offset,
                                                     Object expected,
                                                     Object x);
```

比较并替换，设置之前比较数据是否是和预期是一致的，设置之后比较数据是否和设置的数据是一致的。

这种方式能在无锁的情况下进行并发操作，性能会非常高。

类似的还有比较并递增，但是它的实现会有些区别：

```
    /**
     * Atomically adds the given value to the current value of a field
     * or array element within the given object <code>o</code>
     * at the given <code>offset</code>.
     *
     * @param o object/array to update the field/element in
     * @param offset field/element offset
     * @param delta the value to add
     * @return the previous value
     * @since 1.8
     */
    public final int getAndAddInt(Object o, long offset, int delta) {
        int v;
        do {
            v = getIntVolatile(o, offset);
        } while (!compareAndSwapInt(o, offset, v, v + delta));
        return v;
    }
```

可以看到是个do while的循环，实现了一个自旋操作来保证数据的递增操作是原子的。这就是AtomicInteger中所使用的方法。

## 版本支持

还是要额外提一下关于Unsafe的版本支持问题。

其实随着JDK版本的更新，确实有部分方法被取消了。但同时，有更多的方法被添加到了Unsafe类中。

目前测试了Unsafe的jdk17和21版本，这两个版本都可以正常使用Unsafe。而本文提到的这些api，在这两个高级版本中都是可以正常使用，并且不需要其他任何配置或代码改动的。

## 总结

本文简单说明了Unsafe的内存操作、对象操作和CAS操作。其实Unsafe的api中还包含了关于对于静态字段的处理、线程的操作（比如park），这些操作实际很少使用，目前就先不提。

目前在工作中，使用到的主要还是内存和对象的操作，用来提升序列化和反序列化的速度。

Unsafe说是不安全操作，但其实在JDK中是广泛使用。如果希望提升程序的性能，该用就用，毕竟Java开源生态中有大把大把的开源软件也在使用这个类。
