---
title: 在Java程序使用Grpc protobuf的动态加载及类型反射
date: 2023-05-31 15:41:05
description: 对于各个公司负责的基础技术框架部门，接入gRPC往往是一个老大难问题。我也遇到了同样的问题。很遗憾，在查阅资料的过程中，我发现中文博客中极少有gRPC反射（更确切的说是Protobuf反射）的资料。而反射恰恰是解决框架对gRPC兼容的一种手段。
categories:
- 工作
tags:
 - gRPC
---


## 准备工作

在阅读下面的文章之前，读者需要懂得gRPC的服务端、调用端的基本使用方式。否则可能无法理解文章中出现的部分概念。

## 区分Protobuf和gRPC

我发现很多人会把Protobuf和gRPC混为一谈，这是不对的。

我这里直接引用Protobuf官网文档中的一段话来说明：

> The most straightforward RPC system to use with protocol buffers is [gRPC](https://grpc.io/): a language- and platform-neutral open source RPC system developed at Google. gRPC works particularly well with protocol buffers and lets you generate the relevant RPC code directly from your `.proto` files using a special protocol buffer compiler plugin.
>
> If you don’t want to use gRPC, it’s also possible to use protocol buffers with your own RPC implementation. You can find out more about this in the [Proto2 Language Guide](https://protobuf.dev/programming-guides/proto#services).
>
> There are also a number of ongoing third-party projects to develop RPC implementations for Protocol Buffers. For a list of links to projects we know about, see the [third-party add-ons wiki page](https://github.com/protocolbuffers/protobuf/blob/master/docs/third_party.md).

gRPC是一种RPC通讯的方式，而Protobuf是一种用于序列化和反序列化结构化数据的二进制编码格式。gRPC在通讯时将传输的数据转变为Protobuf格式。

如果不使用gRPC，完全可以基于Protobuf的api实现一套自己的RPC通讯框架。

## Protobuf的Descriptor

在百度中查询关于gRPC反射的资料，得到的信息大多牛头不对马嘴。但是查询Protobuf的反射，则可以获得一些案例。

这其实也说明了Protobuf和gRPC并不是同一个玩意儿。



Protobuf封装了Descriptor对象，提供了反射构建Protobuf消息对象的能力。所有Protobuf消息对象都要实现Message接口。

但是Descriptor对象的来源还是proto文件，为了使用反射的能力，我们需要一种特殊的二进制文件。

可以通过在maven编译插件中添加如下配置来生成这种二进制文件：

```
<build>
    <plugins>
        <plugin>
            <groupId>org.xolstice.maven.plugins</groupId>
            <artifactId>protobuf-maven-plugin</artifactId>
            <version>${protobuf.plugin.version}</version>
            <configuration>
                <protocArtifact>com.google.protobuf:protoc:${protoc.version}:exe:${os.detected.classifier}
                </protocArtifact>
                <pluginId>grpc-java</pluginId>
                <pluginArtifact>io.grpc:protoc-gen-grpc-java:${grpc.version}:exe:${os.detected.classifier}
                </pluginArtifact>
                <writeDescriptorSet>true</writeDescriptorSet>
                <descriptorSetOutputDirectory>src/main/resources/desc</descriptorSetOutputDirectory>
                <descriptorSetFileName>descriptor.pb</descriptorSetFileName>
                <descriptorSetClassifier>descriptor</descriptorSetClassifier>
                <clearOutputDirectory>false</clearOutputDirectory>
            </configuration>
            <executions>
                <execution>
                    <goals>
                        <goal>compile</goal>
                        <goal>compile-custom</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>

    <extensions>
        <extension>
            <groupId>kr.motd.maven</groupId>
            <!--引入操作系统os设置的属性插件,否则${os.detected.classifier} 操作系统版本会找不到 -->
            <artifactId>os-maven-plugin</artifactId>
            <version>${os.plugin.version}</version>
        </extension>
    </extensions>
</build>
```

在protobuf的maven编译插件中添加了生成`descriptor.pb`文件的配置，这个文件中包含了所有proto文件中的信息。



然后，我们开始加载这份文件，这里使用的是Protobuf的api：

```
PathMatchingResourcePatternResolver resourceLoader = new PathMatchingResourcePatternResolver();
Resource[] descriptorFiles = new Resource[0];
try {
    descriptorFiles = resourceLoader.getResources("classpath*:**/*.pb");

    if (descriptorFiles.length == 0) {
        logger.info("No pb file found!");
        return;
    }
    for (Resource descriptorFile : descriptorFiles) {
        logger.log(Level.INFO, "正在加载pb文件: " + descriptorFile.getURL());
        // 使用Protobuf提供的api，加载文件
        DescriptorProtos.FileDescriptorSet fileSet =
            DescriptorProtos.FileDescriptorSet.parseFrom(descriptorFile.getInputStream());
    }
} catch (IOException e) {
    throw new RuntimeException(e);
}
```



待续...

