# Fiora 第三方客户端


[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

一款多人在线的 IM 聊天室，起源于 [fiora](https://fiora.suisuijiang.com/) , 起初只是一个玩笑，说是要做一个 基于 Flutter 的APP，然后就开始做了。


### 主要功能!

  - 登录/注销， 
  - 获取会话列表，
  - 获取聊天信息，
  - 发送消息
  - 下拉加载历史消息


### 正在做的：
  - 自定义表情框
  - 输入框支持自定义图片
  - 输入框支持@人
  - 集成 网易云音乐 播放器(灵感来源于其他人的开源项目，然后我想，是否可以在聊天的状态下，也能够拥有一个播放器)


项目的所有功能皆属于实验阶段，会大量重写，以此达到比预期更好的效果，很多功能并不完善，且目前想深挖比较核心的功能，目前这并不是一个完整的项目，60%的代码都处于随时修改的状态。
比较糟糕的是，目前还没有引入 单元测试。

### 插件
```
 flutter_screenutil:    自适应UI
 provider：             Flutter官方推荐的状态管理
 socket_io_client：     socketio dart的client 实现
 cached_network_image： 缓存图片
 url_launcher：         url弹出web页面
```

License
----

MIT
