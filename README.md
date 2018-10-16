## 安装

```shell
cordova plugin add jmrtc-phonegap-plugin // 暂时只支持 iOS
```

## 配置

### iOS 手动配置部分

> **注意**：需要先确保自己工程中 `Info.plist` 包含 Microphone  权限。

- 设置后台模式，之后需要点开后台音频功能：在 TARGETS -> Capabilities -> Background Modes 里选择 Audio, AirPlay, and Picture in Picture。


- 选择主工程 target -> Build Settings -> Enable Bitcode 设置为 No。

## Usage

```javascript
// 建议在 init 方法之前调用 add***Listener 方法，对事件进行监听（例如：监听语言通话请求）
window.JMRTC.init();
window.JMRTC.initEngine(function () {
	setStatus("SDK初始化成功");
	},
	function () {
	setStatus("SDK初始化失败");
});
// 成功 initEngine 后可以调用 startCallUsers api 发起语言通话请求
```



## APIs

[API](docs/apis.md)