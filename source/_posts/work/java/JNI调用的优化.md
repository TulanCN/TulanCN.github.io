---
title: JNI调用的优化
date: 2023-12-19 17:55:26
description: 在今年11月，我接到一个封装JNI的task。这次对接的是C++实现的内存数据库，性能要求实在太高了，只能采取一些不同寻常的方式来做JNI层调用优化。这里记录一下我的优化思路。
categories:
- 工作
tags:
 - 性能调优
---



## 传统的优化方式

首先，我这里给出JNI的官方手册：https://docs.oracle.com/javase/8/docs/technotes/guides/jni/spec/jniTOC.html

Java本身已经提供了相当数量的接口用于JNI开发，一般来说是够用了。但在低时延或频繁调用的场景，JNI层的性能损耗还是不能忽视的。

在传统的优化方式中，最常提到的就是缓存方法ID、字段ID和类。通过`GetFieldID`或`GetMethodID`获取到的指针（或者说句柄），在JVM的全生命周期都是可用的，因此完全可以把它们缓存起来。每次调用时如果都去获取一遍，会有相当大的性能损耗。

```
int sumValues2(JNIEnv∗ env, jobject obj, jobject allValues){
   // 这些都可以缓存
   jclass cls = (∗env)‑>GetObjectClass(env,allValues);
   jfieldID a = (∗env)‑>GetFieldID(env, cls, "a", "I");
   jfieldID b = (∗env)‑>GetFieldID(env, cls, "b", "I");
   jfieldID c = (∗env)‑>GetFieldID(env, cls, "c", "I");
   jfieldID d = (∗env)‑>GetFieldID(env, cls, "d", "I");
   jfieldID e = (∗env)‑>GetFieldID(env, cls, "e", "I");
   jfieldID f = (∗env)‑>GetFieldID(env, cls, "f", "I");
   // 调用时如果是通过缓存的句柄来调用，就不用每次都get一遍句柄，可以大大提升性能
   jint avalue = (∗env)‑>GetIntField(env, allValues, a);
   jint bvalue = (∗env)‑>GetIntField(env, allValues, b);
   jint cvalue = (∗env)‑>GetIntField(env, allValues, c);
   jint dvalue = (∗env)‑>GetIntField(env, allValues, d);
   jint evalue = (∗env)‑>GetIntField(env, allValues, e);
   jint fvalue = (∗env)‑>GetIntField(env, allValues, f);
   return avalue + bvalue + cvalue + dvalue + evalue + fvalue
}
```

至于其他的方式，基本没有像缓存句柄这样显著的提升了。这些优化方式可以在百度中搜索IBM+最佳实践的关键字找到。原文链接的话在这：https://developer.ibm.com/articles/j-jni/

## 新的优化方式

上述的文章是2009年发表，至今（2023年）已经过去了14年。时代在进步，经过这么多年的实践和探索，在性能调优这方面，大家有了新的思路和手段。

这里我不得不提一句，FastJSON2给了我很大的帮助，在阅读其源码的过程中，我也尝试着把它的一些优秀实现迁移到我的工作项目中来。

### 使用Unsafe构建结构体

某些情况下，可以通过构建结构体来与JNI层通讯。需要强调的是，这种操作在大部分时候都不会有很好的效果。

只有少数场合——尤其是想复用一个已经存在的C++程序的能力时，才可能有些用处。

通过构建结构体，最大的好处是，使得JNI接口可以传递指针了。

举例：

```
/**
 * 查询
 *
 * @param record      结构体指针
 * @return 查询结果
 */
public native long select(long record);
```

上面这个接口，我们通过传递了一个结构体指针。

查询条件我们写到这个结构体里，C++拿着结构体中的条件数据去查询，查完了再把结果写到原来的结构体内，最后Java解析这个结构体，封装为Java对象传回上层。

上面这事说起来简单，但其实已经经过了Java对象到结构体，结构体再转回Java对象的序列化和反序列化两个处理。

通过传递指针，可以让C++的JNI这一层变得非常简单，很多时候都是透传，直接去调用原生的接口了。

实际写代码的时候，这部分逻辑会变得相当抽象，下面给个示例的硬编码代码：

```
long pointer = UNSAFE.allocateMemory(32);
// pointer是内存块的起始地址
long offset = pointer;
// 正常模式、备用模式(只读方式) 4
UNSAFE.putInt(offset, instance.getRunType());
offset += 4;
// 补齐 8
offset += 4;
// 内存数据库大小 16
UNSAFE.putLong(offset, instance.getDbSize());
offset += 8;
// 内存数据库事务日志大小 24
UNSAFE.putLong(offset, instance.getRedoLogSize());
offset += 8;
// 内存数据库事务日志文件数量 28
UNSAFE.putInt(offset, instance.getRedoLogNum());
offset += 4;
// 补齐 32
offset += 4;
```

还得考虑内存对齐，编码体验确实不太好，但确实性能上是满足了现在的需求。

基于这种逻辑，我实现了一种通用的结构体创建方式，但是很遗憾由于保密协议我不能在此分享。

性能上来说：硬编码>通用。

因为内存数据库存储的数据行是由Java对象转换过来的，所以必须有一种通用的结构体转换方式，这写的时候还是废了我不少功夫的。

### 字符串序列化优化

正常在JNI层，如果需要使用Java传递的字符串，我们会使用以下的方式：

```
#include <jni.h>
#include <string>

extern "C" JNIEXPORT void JNICALL
Java_MyJNIClass_nativeDoSomething(JNIEnv *env, jobject obj, jstring str) {
    const char *data = env->GetStringUTFChars(str, NULL);
    // 使用data处理Java字符串
    // ...
    env->ReleaseStringUTFChars(str, data);
}
```

实际测试之后，发现这个GetStringUTFChars方法还是有些性能损耗的。

那么，有没有办法避免这种字符串转码的性能损耗呢？答案是肯定的。

还是利用Unsafe的能力，我们在Java中可以做到内存拷贝。

通过直接把String中的char数组内存拷贝到一个固定的内存块上，我们就可以避免序列化，直接把数据传递给了JNI层。

甚至，如果可以保证JNI层不会修改字符串的数据，我们可以再次优化，直接将char数组的指针传给C++程序。

以下是代码示例：

```
		/**
     * 存入字符串
     *
     * @param pointer 指针
     * @param size    长度
     * @param value  字符串
     */
    public static void putString(long pointer, long size, String value) {
        // size必须为偶数
        char[] valueChars = StringOptimizer.getCharArray(value);
        long length = (long) valueChars.length << 1;
        if (length > size) {
            UNSAFE.copyMemory(valueChars, Unsafe.ARRAY_CHAR_BASE_OFFSET, null, pointer, size);
        } else {
            char[] chars = new char[(int) size >> 1];
            System.arraycopy(valueChars, 0, chars, 0, valueChars.length);
            UNSAFE.copyMemory(chars, Unsafe.ARRAY_CHAR_BASE_OFFSET, null, pointer, size);
        }
    }
```

解释一下，StringOptimizer是一个工具类，使用Unsafe类去直接获取字符串中的char数组。由于java9对String字符串有重写，需要在启动时就进行判断jdk版本，不同版本会有不同的实现。为了方便使用，这里单独抽了一个工具类出来。

另外，由于Unsafe工具类申请的内存可能含有脏数据，需要申请者手动置0或者覆盖。由于字符串的长度可能小于申请的内存块，所以先拷贝到一个长度与内存块相同的char数组中，再把这个char数据内存拷贝到内存块中，这样就避免了手动置0的操作。

字符串在Java中的使用实在是过于频繁了，毕竟好用嘛。在C++中字符串用起来比Java要麻烦很多，这也导致在JNI优化的时候，字符串不得不单独拎出来优化。

## 总结

在特定场景下，使用Unsafe能显著提高Java程序与C++的交互性能。

但我觉得更重要的是，使用Unsafe使得Java具有了直接去操作内存的能力，这就解放了JNI调用的束缚，可以直接通过指针的方式来交互。这在异构系统的层次划分和接口设计上是会有相当大的影响的。
