---
title: 用浏览器发送POST请求
date: 2023-09-27 15:25:40
description: 一个没什么卵用的小技巧，用chorme等浏览器发送POST请求
categories:
- 工作
tags:
 - 优秀实践
---



## 场景

在封闭环境、虚拟机等场景下，我们拿到的环境没法安装postman。

为了解决这问题，可以直接使用浏览器来发送这类请求。

## 方式

打开浏览器的console，写入js代码

```javascript
var myHeaders = new Headers();
myHeaders.append("Content-Type", "application/json");

var raw = JSON.stringify({
  "id": "999999999"
});

var requestOptions = {
  method: 'POST',
  headers: myHeaders,
  body: raw,
  redirect: 'follow'
};

fetch("http://127.0.0.1:8101/del-condition", requestOptions)
  .then(response => response.text())
  .then(result => console.log(result))
  .catch(error => console.log('error', error));
```

表现如下：

![image-20230927153017161](%E7%94%A8%E6%B5%8F%E8%A7%88%E5%99%A8%E5%8F%91%E9%80%81POST%E8%AF%B7%E6%B1%82/image-20230927153017161.png)

完事。
