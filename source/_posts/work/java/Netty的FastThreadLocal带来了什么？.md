---
title: Netty的FastThreadLocal带来了什么？
date: 2024-09-13 14:49:51
description: 在之前的工作中，每次和人吹牛逼我都会提到：Netty的FastThreadLocal是一个最基础最核心的技术。为什么这么说呢，这次我专门开一个篇章来聊聊。
categories:
- 工作
tags:
 - 工作总结
---



## 和Netty的缘分

要聊能力前，先聊聊我和Netty的缘分。

最初接触Netty，是在一个和它完全不相关的项目。需求是要基于C++同事提供的网络通讯中间件写一个Java的网络通讯框架，有人实现了第一版，随后就由我接手了这框架。

在那个时候就有人告诉我，整个系统链路的性能瓶颈是在这个网络通讯框架上。

不过在当时也是才疏学浅，一开始定位方向就错了。我在那时候是觉得这框架卡在了服务端的处理上，使用了BIO而不是NIO的方式进行通讯，造成大量的线程空转，以致于拉低了吞吐量。

接着就开始研究NIO，也就自然而然地学习了Reactor，以及Netty。

得益于公司提供的极客时间企业会员，我在极客时间上把Netty的课程学了一遍，然后就慢慢了解了Netty的使用方式以及一些实现细节。

但学完之后却是完全没用上。直到后来做行情客户端、做公司业务协议的服务器时，才用上这部分知识。

最后，更是把Netty的能力拆分，用到了我自己写的交易框架上。

## FastThreadLocal快在哪？

聊一个技术，总是得聊聊实现。

先说结论：`FastThreadLocal`比起JDK自带的`ThreadLocal`，少了一次Hash的计算，这就是它快的地方。

然后再来聊聊其中的实现。

JDK自带的`ThreadLocal`，为了做线程隔离，是在每个线程中都创建了一个Hash表。

这个Hash表的Key是`ThreadLocal`对象，Value是具体的值。

它的get()过程是这样的：

```
1、Thread.currentThread()获取到当前线程
2、从Thread对象的hash表中获取当前ThreadLocal对应的Object并返回
```

在从hash表获取Object的过程中，不可避免会有一次hash计算。

而`FastThreadLocal`则不一样。Netty创建了一个`FastThreadLocalThread`，继承JDK的`Thread`类，使用一个`Object[]`替换了其中的Hash表。

核心思路就是，创建`FastThreadLocal`对象时，给其分配一个全局的ID（或者说index）。
这样的话，它的get()过程就可以优化为：

```
1、Thread.currentThread()获取到当前线程
2、检查当前线程是不是FastThreadLocalThread，是的话走fastGet();否则走JDK原生的get()
3、fastGet()会从FastThreadLocalThread的Object[]，通过创建FastThreadLocal获得的全局ID，直接用数组随机访问的方式获取值
```

从结果上看，一个hash表取值的过程就优化为了数组随机访问，这就是最大的提升。

## 带来了什么？

终于讲到重点了。
FastThreadLocal把访问线程本地变量的时间，从一次hash计算的时间优化到了一次数组随机访问的时间。从时间上看，大约是4-10ns的操作优化为了小于1ns的操作。

这带来了一些影响：
1、线程级别的资源，可以自行回收而不依赖JVM的GC。比如Netty中有一个工具类，存储着ArrayList和StringBuilder之类的对象，这些对象都存放于FastThreadLocal中。每次使用时，不需要new，而是从工具类中获取当前线程之前使用过的对象，使用完毕后手动清空这些对象即可。
2、在1的基础上，构建了Recycler，以及ObjectPool。这些是Netty中Pooled的Buffer的最核心实现。

也就是说，线程级别的资源访问成本变低了，而线程数量又可控的情况下，我们可以把某些资源每个线程都分配一个。

同时，在线程自己的视角，所有的资源都只被当前线程使用，线程安全，不需要做任何并发安全的编码，有效提升性能。

虽然运行时的内存占用上去了，但是不会有更多的垃圾对象产生，这就让JVM的GC压力变得特别小。

## 感想

Netty不愧是Java编程的教科书，这个FastThreadLocal在我看来，几乎是Java编程思想的集大成之作，完美发挥了Java的长处，尽可能避免了其短处。
我虽然工作中已经有使用Netty，但我觉得更底层的细节其实我还是不太清楚。
不谈FastThreadLocal，Netty还有很多优秀的实现值得参考，比如它的'0拷贝'、堆外内存的池化和回收机制。这值得我继续深入研究。
