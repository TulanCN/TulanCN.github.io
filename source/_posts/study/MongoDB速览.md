---
title: MongoDB速览
description: 新工作需要预研MongoDB，快速记录下了解到的信息。
categories:
  - 工作、生活、学习、其他
tags:
  - 技术协议
date: 2025-06-25 09:29:45
---

MongoDB是一个NoSQL数据库，并非如同传统数据库一样使用结构化的表来存储数据，在性能上有一定优势。

## 存储格式

MongoDB 采用数据库（Database）、集合（Collection）和文档（Document）的三层结构：

- **数据库（Database）**：多个集合的逻辑分组，每个数据库有独立的权限控制和物理文件。
- **集合（Collection）**：一组相关文档的集合，类似关系型数据库中的表，但集合内文档可具有不同结构。
- **文档（Document）**：数据的基本存储单位，由键值对组成，类似 JSON 对象，但支持更多数据类型（如日期、二进制数据）。

用MySQL中的概念来对应：

| MySQL        | MongoDB    |
| ------------ | ---------- |
| Schema（库） | Database   |
| Table（表）  | Collection |
| Record（行） | Document   |

与关系型数据库结构化的数据不同，MongoDB中的Document是一种更加灵活的结构，类似JSON。

- **数据模型**：以 BSON 文档形式存储半结构化 / 非结构化数据，支持嵌套字段（如对话中的消息列表、用户元数据），模式灵活（无需预定义表结构）。
- **存储优势**：适合存储格式多变的聊天记录（如文本、多媒体附件、JSON 格式的对话元数据），支持高效的文档级读写。
- **典型场景**：存储用户对话的原始数据，如`{user_id: "u123", messages: [{role: "user", content: "...", timestamp: ...}, ...]}`。

## 查询

MongoDB允许用户创建过滤器（Filter）进行查询，更新和删除。支持等于、小于、包含等运算符。

- **基础查询**：支持丰富的文档查询（如按用户 ID、时间范围、消息类型过滤），内置`$text`索引支持简单文本搜索，但分词能力较弱（需配合第三方插件如 MongoDB Atlas Search）。
- **复杂查询**：聚合管道（`$lookup`、`$match`等）适合统计分析（如用户对话频次、消息长度分布），但全文搜索性能不如专业搜索引擎。

示例代码：

```Java
// 创建MongoDB客户端连接
mongoClient = MongoClients.create(CONNECTION_STRING);

// 获取数据库（如果不存在会自动创建）
MongoDatabase database = mongoClient.getDatabase(DATABASE_NAME);

// 获取集合（如果不存在会自动创建）
MongoCollection<Document> collection = database.getCollection(COLLECTION_NAME);

// 查询所有文档
System.out.println("所有用户:");
try (MongoCursor<Document> cursor = collection.find().iterator()) {
    while (cursor.hasNext()) {
        Document doc = cursor.next();
        System.out.println("  " + doc.toJson());
    }
}

// 条件查询
System.out.println("\n年龄大于27的用户:");
for (Document doc : collection.find(new Document("age", new Document("$gt", 27)))) {
    System.out.println("  姓名: " + doc.getString("name") + 
                     ", 年龄: " + doc.getInteger("age") + 
                     ", 城市: " + doc.getString("city"));
}

// 查询单个文档
Document user = collection.find(new Document("name", "张三")).first();
if (user != null) {
    System.out.println("\n找到用户张三: " + user.toJson());
}

// 统计文档数量
long count = collection.countDocuments();
```

## 更新

MongoDB提供了`$push`操作符，可以直接在数组的末尾追加新的内容。

```Java
// 更新单个文档
Document filter = new Document("name", "张三");
Document update = new Document("$set", new Document("age", 26).append("email", "zhangsan_new@example.com"));
collection.updateOne(filter, update);

// 更新多个文档
Document multiFilter = new Document("age", new Document("$gte", 30));
Document multiUpdate = new Document("$set", new Document("status", "高级用户"));
long modifiedCount = collection.updateMany(multiFilter, multiUpdate).getModifiedCount();
```

## 安装

MongoDB有官方提供的云服务Atlas，除此之外还有社区版本可自行安装在本地环境中。

## 分片与高可用

MongoDB可设置分片键，集群模式下可分片存储数据。支持高可用，可添加分片的副本，分片自动进行主从复制。新增分片时可自动迁移数据。

## 其他关注点

MongoDB并非强一致性数据库，集群模式仅保证最终一致性。主从间数据同步可能有延迟。

MongoDB在单表查询上基本可以做到与关系型数据库的功能完全一致，但它不提供连表查询的能力。

MongoDB的没有事务的概念，但提供了乐观锁和表锁来做并发控制。

## 自测结果

测试使用JMH。连接本地的MongoDB，无网络开销。

创建10000条数据，进行各类操作的压测。测试条件与实际环境的差异较大，仅用于比较MongoDB中各类操作的相对速度差异。

```
Benchmark                                          Mode  Cnt      Score       Error  Units
MongoDBBenchmark.aggregateConversationPatterns    thrpt    3    01.234 ±    37.890  ops/s
MongoDBBenchmark.aggregateUserStats               thrpt    3   1406.205 ±   212.137  ops/s
MongoDBBenchmark.findByComplexQuery               thrpt    3   2480.271 ±   752.953  ops/s
MongoDBBenchmark.findById                         thrpt    3  19871.945 ±   745.196  ops/s
MongoDBBenchmark.findByUserId                     thrpt    3   7179.610 ±   322.021  ops/s
MongoDBBenchmark.findConversationsWithKeyword     thrpt    3  10134.823 ±  1724.197  ops/s
MongoDBBenchmark.insertSingleMemory               thrpt    3  21558.957 ±  1471.634  ops/s
MongoDBBenchmark.pullConversationTurn             thrpt    3  18906.034 ±  1834.565  ops/s
MongoDBBenchmark.pushMultipleConversationTurns    thrpt    3   3232.437 ± 21046.933  ops/s
MongoDBBenchmark.pushNewConversationTurn          thrpt    3   6643.531 ± 21310.978  ops/s
MongoDBBenchmark.updateMemoryMetadata             thrpt    3  19002.191 ±  1145.903  ops/s
MongoDBBenchmark.updateMultipleMemoriesBySession  thrpt    3   6960.245 ±  1844.975  ops/s
```

聚合查询对话中的关键词的效率较低，仅211 ops/s。

其他操作大多使用主键进行更新、查询和删除，效率较高。

测试过程中push操作的几次迭代的ops分别为10000，8000, 6000，4000。

可见push随着操作次数的增多，性能逐渐下降，**push操作变为瓶颈**，在测试结果中体现为误差较大。

MongoDB在5.0之后提供了**Time Series Collection**，但需要集群模式下才能使用，目前无法进一步验证。

本地demo测试的结果有失真，但测试过程中确实不再观察到性能逐渐下降的情况：

```
Benchmark                                                    Mode  Cnt      Score      Error  Units
MongoDBTimeSeriesBenchmark.aggregateConversationsByHourTS   thrpt    3    437.986 ±   32.994  ops/s
MongoDBTimeSeriesBenchmark.aggregateUserActivityTS          thrpt    3     84.750 ±    7.145  ops/s
MongoDBTimeSeriesBenchmark.batchInsertConversationsTS       thrpt    3    500.700 ±  867.575  ops/s
MongoDBTimeSeriesBenchmark.findByTimeRangeTS                thrpt    3    317.839 ±  454.249  ops/s
MongoDBTimeSeriesBenchmark.findConversationsByMemoryIdTS    thrpt    3   4928.739 ± 1019.191  ops/s
MongoDBTimeSeriesBenchmark.insertSingleConversationRegular  thrpt    3  23881.689 ± 3528.365  ops/s
MongoDBTimeSeriesBenchmark.insertSingleConversationTS       thrpt    3   6425.600 ± 4511.080  ops/s
MongoDBTimeSeriesBenchmark.simulatedPushOperationRegular    thrpt    3  23796.839 ± 1890.437  ops/s
```

## 集群部署

官方部署文档：https://www.mongodb.com/zh-cn/docs/manual/tutorial/deploy-shard-cluster/#std-label-sharding-procedure-setup

身份验证文档：https://www.mongodb.com/zh-cn/docs/manual/tutorial/deploy-sharded-cluster-with-keyfile-access-control/

### 部署说明

本次选用Mongodb的分片部署，使用密钥文件进行身份验证。

MongoDB的分片集群有三类子集群：Shard、Mongos、Config。

这三个程序其实都是MongoDB，只不过是以不同的模式启动。

![image-20250704104015740](MongoDB%E9%80%9F%E8%A7%88/image-20250704104015740.png)

#### Shard分片

Shard为分片集群，存储实际的数据。

每个分片都需要做主备，组成副本集，主备节点间数据相同。

假设有两个分片，每个分片有一主两备，则最后共计有6个分片的实例。

开发测试环境可使用单个实例组成副本集。

#### Mongos路由节点

Mongos为路由节点。

所有操作都打到Mongos节点，Mongos负责转发请求至对应的分片节点查询数据。

Mongos没有主备的概念，可随意添加或删除。

#### Config配置节点

Config为配置节点，用于对Mongos节点间同步路由信息，需要做主备。

开发测试环境可使用单个节点。

### 安装Docker

本文档中使用Docker安装MongoDB的各个实例，这里对Docker的安装不多赘述。

### 密钥生成

生成一次，在同个集群内共用，复制后要继续设置文件的权限，太开放了也会导致起不来。

生成密钥的命令，并修改其权限，其中`/opt/mongo-keyfile`为文件路径：

```
openssl rand -base64 756 > /opt/mongo-keyfile

chmod 400 /opt/mongo-keyfile
chown 101:101 /opt/mongo-keyfile
```

复制到其他服务器后，设置文件权限，命令同上：

```
chmod 400 /opt/mongo-keyfile
chown 101:101 /opt/mongo-keyfile
```

### 系统参数设置

启用 THP（主机）

```
echo “always” | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
echo "defer+madvise" | sudo tee /sys/kernel/mm/transparent_hugepage/defrag
```

设置 khugepaged 参数（主机）

```
echo 0 | sudo tee /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none
```

持久化配置（主机）

```
sudo tee /etc/rc.local << EOF
#!/bin/sh -e
echo "defer+madvise" > /sys/kernel/mm/transparent_hugepage/defrag
echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none
exit 0
```

输入EOF退出。

```
sudo chmod +x /etc/rc.local
```

永久修改max_map_count

```
echo "vm.max_map_count=1677720" | sudo tee /etc/sysctl.d/99-mongodb.conf
```

应用配置

```
sudo sysctl --system
```

### 启动config

创建docker卷用于持久化mongodb的数据。

```
docker volume create mongodb-data
```

放置密钥文件后，使用docker命令将其映射至镜像内部，并在启动命令上使用该密钥。启动命令为：

```
#!/bin/bash
docker run --name mongodb-config-1 \
-p 26000:27019 -v mongodb-data:/data/db \
-v /opt/mongo-keyfile:/data/keyfile \
-d mongodb/mongodb-community-server:latest \
--keyFile /data/keyfile \
--configsvr \
--replSet configReplSet \
--bind_ip 0.0.0.0
```

其中 `/opt/mongo-keyfile`为宿主机的密钥文件路径，`--configsvr`是以config节点的模式启动MongoDB。

如果有多个config实例，则先启动多个实例后再进入下一步。

部署其他实例先也要调整系统参数和复制密钥文件，并且要修改密钥文件的权限，否则会启动失败。

注意，多个实例的`--replSet configReplSet`必须相同，密钥文件必须相同，否则在下一步初始化时会出错。

### 初始化config

进入其中一个config实例的镜像内部，开始后续操作：

```
docker exec -it mongodb-config-1 bash
```

使用mongosh连接启动的MongoDB：

```
mongosh --host localhost --port 27019
```

连接后，输入以下命令组成config副本集，保证最外层的`_id`与启动命令中的`--replSet`对应：

```
rs.initiate(
 {
  _id: "configReplSet",
  configsvr: true,
  members: [
   { _id : 0, host : "192.168.0.31:26000" }
  ]
 }
)
```

假设有多个config实例，则在以上命令中的members数组内加入其他的config节点信息。示例：

```
rs.initiate(
 {
  _id: "configReplSet",
  configsvr: true,
  members: [
   { _id : 0, host : "192.168.0.31:26000" },
   { _id : 1, host : "192.168.0.32:26000" },
   { _id : 2, host : "192.168.0.33:26000" }
  ]
 }
)
```

以上的初始化命令仅需要在某个实例执行一次即可，不需要在所有config实例上都执行一遍。

举例，有三个Config实例C1、C2、C3，则仅需要在C1上进行一次初始化即可。

### 创建管理员

继续在mongosh界面操作，创建config集群的管理员账户。

```
admin = db.getSiblingDB("admin")
admin.createUser(
 	{
    user: "mongoadmin",
    pwd: "@Scg0830", 
    roles: [ 
    	{ role: "userAdminAnyDatabase", db: "admin" },
    	{ role: 'readWriteAnyDatabase', db: 'admin' },
    	{ "role" : "clusterAdmin", "db" : "admin" },
      ]
  }
)
```

后续连接时都需要验证用户名和密码，命令如下：

```
mongosh -u mongoadmin -p @Scg0830 --authenticationDatabase "admin" --port 27019
```

### 启动分片

先在分片节点上调整系统参数和放置密钥文件，然后再进行后续操作。

创建docker卷：

```
docker volume create mongodb-data
```

启动命令，与config的启动命令类似：

```
#!/bin/bash
docker run --name mongodb-shard-1 \
-p 28000:27018 -v mongodb-data:/data/db \
-v /opt/mongo-keyfile:/data/keyfile \
-d mongodb/mongodb-community-server:latest \
--keyFile /data/keyfile \
--shardsvr \
--replSet shardReplSet1 \
--bind_ip 0.0.0.0
```

如果要启动同个分片的副本（备份），要保证启动命令中的`--replSet`相同，同个分片的多个副本使用相同的副本集名称。

如果要启动多个分片，修改启动命令中的`--replSet`，当前的副本集名称为shardReplSet1，可以修改为shardReplSet2或其他的名称。

每个分片实例启动前务必修改系统参数和复制密钥文件，并修改密钥文件的权限，否则无法启动。

### 初始化分片

对于每一个分片的副本集，都需要初始化，以便让所有的副本集能互相建立连接。

首先进入其中一个实例的docker内部：

```
docker exec -it mongodb-shard-1 bash
```

启动mongosh，连接镜像内的分片实例：

```
mongosh --port 27018
```

输入以下命令初始化，保证最外层的`_id`与启动命令中的`--replSet`对应：

```
rs.initiate(
 {
  _id : "shardReplSet",
  members: [
   { _id : 0, host : "192.168.0.85:28000" }
  ]
 }
)
```

如果有多个副本，则在members中添加其他的副本。示例：

```
rs.initiate(
 {
  _id : "shardReplSet",
  members: [
   { _id : 0, host : "192.168.0.85:28000" },
   { _id : 1, host : "192.168.0.86:28000" },
   { _id : 2, host : "192.168.0.87:28000" }
  ]
 }
)
```

注意，同一个分片的副本集，仅需要初始化一次。

不同分片则需要每个分片都初始化一次。

举例，有两个分片A和B，每个分片内有三个副本（A1、A2、A3、B1、B2、B3）组成副本集。则在A1上对A1、A2、A3进行初始化，在B1上对B1、B2、B3进行初始化。

### 安装mongos

使用yum安装mongos。

先添加仓库，创建文件：

```
touch /etc/yum.repos.d/mongodb-org-8.0.repo
```

然后在文件中添加以下内容并保存。

```
[mongodb-org-8.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/8.0/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-8.0.asc
```

使用yum安装：

```
yum install -y mongodb-org-mongos
```

### 启动mongos

先创建日志文件夹：

```
mkdir /var/log
mkdir /var/log/mongodb
```

复制密钥文件，并设置文件的权限，然后启动mongos：

```
mongos --keyFile /opt/mongo-keyfile --configdb configReplSet/192.168.0.31:26000 --bind_ip 0.0.0.0 --logpath "/var/log/mongodb/mongos.log" --fork --port 27000
```

注意，启动命令中会连接config集群，必须保证`--configdb`与config节点的副本集名称相同，IP一致。

### 添加分片

如果本机没有mongosh，则先安装：

```
sudo yum install -y mongodb-mongosh
```

使用分片管理员的角色登录mongos，账号密码与在config集群上创建的一致。

```
mongosh -u mongoadmin -p @Scg0830 --authenticationDatabase "admin" --port 27000
```

添加分片：

```
sh.addShard( "shardReplSet/192.168.0.85:28000")
```

分片有多个副本，则使用逗号分隔：

```
sh.addShard( "shardReplSet/192.168.0.85:28000,192.168.0.86:28000,192.168.0.87:28000")
```

重复以上步骤把所有的分片都添加至mongos。

以上的分片信息会传至config节点并同步到所有的mongos中，后续有新的mongos加入也不需要重新添加分片信息。

