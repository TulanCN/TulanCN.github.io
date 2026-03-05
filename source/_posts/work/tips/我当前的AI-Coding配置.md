---
title: 我当前的AI Coding配置
description: 记录下自己的AI Coding配置。
categories:
  - 工作
tags:
  - AI Coding
date: 2026-03-04 20:09:47
---

当前我主要使用的编码工具是Claude Code，IDE是VS Code，使用的语音输入工具是智谱AI输入法。

我先介绍目前使用的几个Claude Code插件，然后讲解下一些最佳实践。

## 工具

### superpower

这是一个Claude Code插件，建议是从官方仓库将这个marketplace clone下来。

https://github.com/obra/superpowers

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

### playwright cli

微软官方提供了一个命令行工具，能够让agent去访问浏览器进行操作。

他使用了一套经典的skills加CLI架构，对比MCP，这套架构会更加节省上下文。

https://github.com/microsoft/playwright-cli

### find skills

这是一个用来找skills的skill。

https://skills.sh/

### context7

特别好用的一个mcp服务器，能查找各种框架的最新文档，避免模型的知识过时。

https://github.com/upstash/context7

### new-api

我本地搭建的一个网关，用来对接各种模型。

我把Claude Code接到了我本地的new-api上，这样/model 命令就能在kimi、glm等模型间切换了。

https://github.com/QuantumNous/new-api

### Claude Code Marketplace

Claude Code内置的Marketplace，可添加各种github仓库作为插件的来源。

自带了一个官方仓库，官方负责维护，有些官方写的插件，同时会定期把一些比较好用的第三方插件整合到官方仓库里。

官方仓库的插件基本上都是开箱即用的。

```
/plugins
```

### frontend-design

用于前端设计的skill，避免生成紫色渐变的经典AI配色前端。

通过Marketplace添加。

建议在命令中带上frontend-design的字眼，提高激活skill的概率。

### claude-md-management

包含了两个维护CLAUDE.md的skills。

一个是增强当前的CLAUDE.md文件。

一个是总结当前对话中可学习的点，把坑和解决方案写到CLAUDE.md中作为持久化记忆。

可在官方仓库内安装，通过斜杠命令触发使用。

### code-simplifier

Claude Code自带的一个subagent，能自动审查代码，简化代码中的冗余实现。建议在写完一个功能后调用。

可在官方仓库内安装。

输入类似这样的提示词：

> 用code-simplifier简化下这次改动的代码。

### skill-creator

Claude Code自带的skills，能构建新的skills。

当你通过Claude Code调通了某个场景的时候，可以说：

> 把我们这次的工作内容总结为一个skills吧。

然后就会激活这个skills，把这次工作的内容总结为一个skills，后续工作时可以激活使用。

## 实践

### skills不激活怎么办

skills是通过关键字激活的，当你使用英语的时候，提到某些字眼它就会自动激活。但是如果提示词就是中文的，那么激活的概率就会小很多。

解决方案：

1. 主动提及skills的名字。比如前端工作，主动提frontend-design，一般就能激活对应的skills了，你会看到Claude Code显示loading skill。
2. 用斜杠命令把skill封装进去。
3. 提示词里提一句，用skill来xxx。

### e2e测试闭环

常见的Coding场景是：AI写代码->等待->手动测试，发现错误，复制粘贴到输入框->AI写代码->等待……

人在其中的作用，就是充当测试工具，把AI写的代码跑一跑，再看看有没有什么明显的错误，有的话把错误描述给AI，让它继续改。

这流程会非常慢，而人在其中的作用也很有限。

所以搭建e2e的闭环测试很有必要。

关键在于人需要复制错误信息提供给AI，我们希望这一步能省略掉。因此就需要搭建一个本地可运行的测试环境。

我们需要告知AI，我的后台启动在哪里、日志输出在哪里，然后让它通过playwright cli去前端模拟人工操作点击几下。如果出现了错误，它就能自己去看代码，排查问题了。

它会一直循环修改和测试，直到它觉得没问题了，再由人来验收。

这建议是用多模态的模型（ 比如kimi-k2.5）来进行e2e测试，这样Agent可以截图看到前端的页面，方便进行样式问题的排查。

提示词里可以加上：

> 你必须提供验证成功的截图给我。

还有种情况是本地无法运行项目，因为有太多的外部依赖。

那就需要写一些mock服务了，用FastAPI快速写一些mock服务模拟其他的外部项目，保证自己本地能运行e2e测试。

### 维护CLAUDE.md

Claude Code会将CLAUDE.md文件自动加载到上下文中，我们需要日常维护好这个文件，这个文件的定位是memory。

一些项目规范、文件索引等信息都应该写到CLAUDE.md中。

可以安装CLAUDE.md的更新插件，用斜杠命令来随时更新这个文件。

我个人的一个实践是，当有多个项目需要协同工作，请把其他项目的本地路径也一并写到这个文件里，这样Claude Code就能同时去更新多个仓库的代码了。

### 先计划后实施

Claude Code提供了plan模式，通过shift + tab可切换过去。

plan模式不允许直接写代码，会先进行计划。先计划后实施是非常有必要的，复杂需求我们并不知道AI在实际执行的时候可能会犯什么错，先让它进行一次计划，告知我们它打算怎么进行实现，确认一些实现细节，能提升我们对生成结果的把控。

有了AI Coding工具后，写代码是最快的一步，规划和测试才是更花时间的地方。

先进行详细的规划和讨论，再一次生成完整代码，要比每次都写代码然后微调的效果要好得多。

### WebSearch

使用国产模型进行编码的时候，常遇到的问题是模型不会主动去使用WebSearch工具。

当模型遇到问题，并且一直无法解决的时候，大概率是其知识储备已经不足以解决这一问题了。

这时候中断执行过程，输入提示词：

> 你去网上找一下有没有类似的解决方案

模型就会去使用WebSearch工具进行搜索，大部分时候能直接搜索到解决方案，也就能解决当前的问题了。

智谱的Coding plan有送一些工具使用的次数，智谱搜索的资料来源质量相对较高，使用效果是不错的。

### Hooks

Claude Code支持在某些操作前后配置hook，执行shell命令。

我是用这个功能写了个通知，当Claude Code执行完任务后，会有个通知弹窗。

开发方式很简单，输入以下提示词：

> 我要开发一个hooks，在你执行完任务后，我希望你能通知我一下

### 选择自己用起来最顺手的工具

插件很多，但从没有任何插件是**必须**使用的。

结合自身的情况选用合适的插件是最好的。
