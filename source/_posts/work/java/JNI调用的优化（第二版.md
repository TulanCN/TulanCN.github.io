---
title: JNI调用的优化（第二版)
date: 2024-08-08 10:28:13
description: 这一次验证了critical native调用。
categories:
- 工作
tags:
 - 性能调优
---



源头是这篇博客：http://blog.hakugyokurou.net/?p=1758

讲到了最正式的文档也就是bug系统中的一条记录：https://bugs.openjdk.org/browse/JDK-7013347

另外在stackoverflow上有人爆料了这个能力：https://stackoverflow.com/questions/36298111/is-it-possible-to-use-sun-misc-unsafe-to-call-c-functions-without-jni/36309652#36309652

处于验证的目的，我写了jmh对其进行测试。

不过测试结果倒是有提升，但也仅仅是20ns。

聊胜于无，就目前的场景（单次调用800ns）来看，并没有必要做这个优化。

带来的不稳定因素反而是更大的问题。
