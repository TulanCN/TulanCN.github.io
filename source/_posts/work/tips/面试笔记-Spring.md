---
title: 面试笔记-Spring
date: 2024-10-16 11:43:17
description: 这里记录一下面试的准备过程中关于Spring的笔记。问Java不问Spring简直不可能好吧。
categories:
- 工作
tags:
 - 面试
---



## Spring篇

Spring是一个Java开发框架，主要是解决企业级开发的一些痛点。一开始可能主要是用于Web应用的开发，但目前实践中它已经在国内Java后端开发这方面一统江湖。

它把各种业务逻辑都抽象封装为Bean，Spring负责项目启动时把这些Bean创建出来，进行业务开发的时候只需要通过Spring提供的API或其他方式，获取到对应的Bean就可以执行各种复杂业务操作。

### 为什么是Spring

轻量。

IOC，控制反转。业务开发不用关注对象创建之类的事情，只需要编码，并给出依赖，框架会自动帮你找到对应的实现类。

AOP，面向切面编程。

事务管理。

异常处理。

### Autowired和Resource的区别

Autowired是Spring提供的注解，Resource是javax的注解。Spring是支持了javax提供的标准注解，是标准的一个实现。

假如换了框架（一般不会），Autowired必定不可用，Resource可能还能用。

Autowired默认按照type类装配，默认要求对象必须存在且唯一。可以用Qualifier来指定BeanName。

Resource注解提供了type和name两个注解字段。name的优先级高于type。

### 依赖注入的方式

构造器、setter、接口。反射注入

### Spring MVC

Spring MVC是Spring的一个模块，针对web应用的场景。

V不是普遍意义上的前端，而是用jsp或其他方式渲染的一个页面。

M是逻辑层，做计算和数据库操作。C是控制层，负责接收网络请求。

Spring在Servlet的基础上实现，定义了一个统一的请求接收入口：DispatcherServlet。DispatcherServlet会根据url和请求类型分发请求到用户编码的Controller中，然后执行用户的逻辑。

常用注解：@RequestMapping、@RequestBody、@ResponseBody

### AOP

把一些业务无关，在系统层面共通的逻辑封装起来，从而减少代码冗余，有利于代码的扩展性和维护性。比如参数校验、日志采集、权限控制。

Spring的AOP是基于动态代理实现的。对于已经实现了接口的，用JDK动态代理，创建一个接口的实现类然后代理。没有实现的，用CGlib，创建一个类的子类然后代理。

也可以用AspectJ实现自己的AOP逻辑。

Spring的AOP属于运行时增强，AspectJ的AOP是编译时增强。AspectJ是字节码操作，性能稍高。

### 关注点和横切关注点

关注点是某个特定的业务功能，横切关注点是多个业务都会用到的系统功能，比如日志、参数校验、权限。

### 什么是通知advice

方法执行前和后要做的逻辑处理。

before

after

after-returning

after-throwing

around

这个结果处理和Spring WebFlux中的回调很像。

### IOC

控制反转，把创建对象的权利移交给框架。

对象不需要程序自己去new，而是通过依赖注入从框架中获取。

IOC让组件保持松散的耦合，从而创造了可以进行AOP编程的余地。

### Spring Bean生命周期

Servlet：实例化、初始化、接收请求、销毁。

Bean：

1、配置扫描，创建BeanDefinition，构建BeanFactory。

2、实例化：启动时的第一步。当BeanFactory被请求一个未实例化的Bean时，会调用createBean方法实例化一个Bean。

3、依赖注入：实例化之后的对象在BeanWrapper中，Spring通过BeanDefinition的配置进行依赖注入。这里会先找这个Bean的依赖所对应的BeanFactory，然后提供一个实例化Bean进行依赖注入。

4、处理Aware接口：BeanNameAware、BeanFactoryAware、ApplicationContextAware

5、BeanPostProcessor的postProcessBeforeInitialization方法

6、InitializingBean的afterPropertiesSet

7、BeanPostProcessor的postProcessAfterInitialization方法

8、scope为singleton的缓存在容器，prototype的返回最开始请求的客户端。

9、销毁，调用DisposableBean的afterPropertiesSet

### Bean的作用域

1、singleton：单例

2、prototype：每个Bean一个实例

3、request：每个网络请求一个实例

4、session：每个session一个实例

5、globe-session

### Spring的设计模式

简单工厂模式：Bean的创建

单例模式：单例的Bean

代理模式：AOP的实现

适配器：Adapter，Spring中以Adapter结尾的一般都是适配器模式。比如AdvisorAdapter

观察者模式：Spring事件

模版模式：JdbcTemplate

### ApplicationContext和BeanFactory

BeanFactory是基础接口，只提供最基础的Bean管理功能，在spring-beans包中。

ApplicationContext继承了BeanFactory，并且扩展了事务管理、国际化、AOP。

BeanFactory是延迟加载，而ApplicationContext是启动时实例化所有的Bean。

### Spring的单例Bean是线程安全的吗

是否线程安全和单例无关。Spring本身没有对Bean做任何并发的保护，这也不是Spring应该关心的东西。是否线程安全由开发者来保证。

### 循环依赖怎么解决

三级缓存

第一级缓存是初始化完成的Bean；第二级是完成了实例化，但是没有完成依赖注入的Bean；第三级是没实例化的Bean，存放其BeanFactory。

假设有两个Bean A、B，AB循环依赖

1、Bean都是由BeanFactory创建，A的BeanFactory会先实例化A，放入二级缓存，随后进行依赖注入。

2、A的BeanFactory通过依赖找到了B，先从一级缓存找，一路找到三级缓存，最后找到了B的BeanFactory。这时候B没有创建，所以用B的BeanFactory创建B。BeanFactory会先创建一个B的实例，这样在二级缓存就有了一个B的实例，然后进行依赖注入。

3、B在依赖注入的时候会在二级缓存找到A，这时会直接获取A的实例注入B，这样就完成B的依赖注入。B完成创建后放入一级缓存，然后把B通过BeanFactory的方法返回给A，A就可以继续进行依赖注入。

### Spring事务隔离级别

同数据库的级别：读未提交、读已提交、可重复读、串行化

### Spring事务传播级别

PROPAGATION_REQUIRED：有事务就加入，没有就创建

PROPAGATION_SUPPORTS：有就加入，没有就不加事务

PROPAGATION_MANDATORY：有就加入，没有就抛异常

PROPAGATION_REQUIRES_NEW：永远创建一个新的事务执行

PROPAGATION_NOT_SUPPORTED：永远不以事务执行

PROPAGATION_NEVER：有事务就抛异常

PROPAGATION_NESTED：有事务就创建嵌套事务，没有就创建

### Spring事务实现

编程式事务、声明式事务。

PlatformTransactionManager中定义了事务的开始、提交、回滚等操作。不同数据库会有不同实现。

### Spring事务管理优点

抽象了统一的接口。支持声明式事务管理。

可以和Spring多数据源结合。

### 事务三要素

数据源：事务的真正处理者。

事务管理器：处理事务的打开、提交、回滚。

事务应用和配置：表明哪些方法参与事务，事务的隔离级别，传播级别，超时时间。

### 事务注解的本质

@Transactional仅仅是一些元数据，这里通过AOP的方式，将元信息传递事务管理器，事务管理器再提交给数据源实现具体的事务。

其实就相当于在方法前后加了一些事务的代码。

## Spring Boot篇

### 为什么是Spring Boot

独立运行：内嵌了tomcat、Jetty。不需要打成war包部署到容器。可以打成独立的Jar包运行。

配置简化，自动装配：能根据当前路径下的类、jar来自动配置bean。

无代码生成：配置过程中没有代码生成，没有xml配置文件，都是基于条件注解完成。

监控：默认就提供了很多监控端点。

Spring Boot大量使用了注解来驱动开发。

### 核心注解

```
@SpringBootApplication
@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan
```

### 如何理解starters

一个把所有依赖都集成在一起的依赖包，简化引入的成本。

### 如何在启动时执行一些特殊的逻辑

ApplicationRunner，CommandLineRunner。

ApplicationRunner有一个实现，是在启动时把程序的pid打印到一个文件中，方便运维。

### 监视器 actuator

actuator会对外暴露一些端点，可以通过配置的方式管理这些端点（endpoint）。这是能让用户来访问和监控程序当前的运行状态。配合运维平台使用。

### 异常处理

ControllerAdvice，可以用来处理所有的异常，封装为统一的异常信息返回。

### 配置加载顺序

Spring Boot的配置加载顺序和其优先级一致。

1、命令行，--大于-D

2、Java系统属性，System.getProperties。

3、环境变量

4、yml文件

5、默认配置

### application和bootstrap文件

老版本Spring Cloud Alibaba的Nacos只能使用bootstrap文件，后面版本修改了。

### 自动装配

自动装配就是把第三方的Bean装载到Spring的容器里。以前是需要开发人员写xml才能把这些Bean装载到容器的。

原理：第三方组件定义了Configuration类，在其中声明了需要装载的Bean对象，同时也在这个类里定义了一些自动装配的规则。Spring在启动时通过META-INF/spring.factories文件找到对应的配置类，然后对这些配置类进行动态加载。

## Spring Cloud篇

### 为什么是Spring Cloud

是用于构建分布式应用的开源框架。基于Spring Boot，提供与外部系统集成的能力。国内有很多二开的框架，比如Spring Cloud Alibaba，TSF，Spring Cloud Huawei。

### 什么是微服务

一种架构。将单一功能的应用程序划分为一组小的服务，每个服务独立运行，服务之间相互协调、配合，最终实现一个业务功能。

服务之间使用轻量级的通讯机制（通常是http，但是dubbo之类的也可以）。

需要有一个中心来集中化管理这些服务。

### 服务熔断和降级

分布式的场景下，某个服务出现异常，当检测到这种情况后，可以切断对该服务的调用。等到服务正常以后，再恢复服务。这就是熔断。

降级是是指服务熔断以后，如果还有对该服务的调用，直接失败。

### eureka zookeeper nacos

Eureka的高可用机制比较完善，可以保证服务随时可用。

zookeeper对于多节点的数据一致性处理比较完善，可以用于主从选举。zk其实为了分布式协调而设计的，比如分布式锁、选举都可以用zk来做。

nacos提供了可视化界面，同时支持服务注册发现和配置下发，一个人干了两个人的活。

### Spring Boot Spring Cloud

Spring Boot是专注于开发单个微服务。

Spring Cloud是关注分布式系统的，分布式系统可以是多个Spring Boot开发的微服务的集合，Spring Cloud用于提供微服务之间调用、微服务的配置获取、服务注册、路由等。

### 负载均衡

某个服务可能有多个实例，调用该服务时，每个请求会分发到不同的实例处理，有助于提高服务的吞吐量。

### Feign

Feign是一个HTTP请求客户端，提供了声明式的调用方式。主要是通过JDK动态代理实现。它整合了负载均衡的能力（Spring Cloud LoadBalance）

