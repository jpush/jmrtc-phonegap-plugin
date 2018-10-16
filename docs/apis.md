

[Common API](#common-api)
- [initEngine](#initengine)
- [releaseEngine](#releaseengine)
- [startCallUsers](#startcallusers)
- [accept](#accept)
- [hangup](#hangup)
- [refuse](#refuse)
- [inviteUsers](#inviteusers)
- [isMuted](#ismuted)
- [setIsMuted](#setismuted)
- [isSpeakerphoneEnabled](#isspeakerphoneenabled)
- [setIsSpeakerphoneEnabled](#setIsspeakerphoneenabled)

[Event](#event)

- [CallOutgoing](#calloutgoing)
- [CallReceiveInvite](#callreceiveinvite)
- [CallConnecting](#callconnecting)
- [CallConnected](#callconnected)
- [CallMemberJoin](#callmemberjoin)
- [CallDisconnect](#calldisconnect)
- [CallMemberLeave](#callmemberleave)
- [CallOtherUserInvited](#callotheruserinvited)
- [CallError](#callerror)



[Model](model)

- [Session](session)

## Common API

### initEngine

初始化音频引擎，需要初始化成功回调后只能执行音频相关操作。

```javascript
window.JMRTC.initEngine(() => {
  // 音频引擎初始化成功，想在可以做音频相关操作。
}, (error) => {
  
})
```

### releaseEngine

释放音频引擎.

```
window.JMRTC.releaseEngine()
```

### startCallUsers

发起一个通话(音频)。

```javascript
const params = {
	usernames: [string],  // 要呼叫的用户名
}

window.JMRTC.startCallUsers(params, () => {
  
}, (err) => {
  
})
```

### accept

接收通话邀请。

```javascript
window.JMRTC.accept(() => {
	// success
}, () => {
	// fail
})
```

### hangup

挂断当前通话

```javascript
window.JMRTC.hangup(() => {
	// success
}, () => {
	// fail
})
```

### refuse

拒绝通话邀请

```javascript
window.JMRTC.refuse(() => {
	// success
}, () => {
	// fail
})
```

### inviteUsers

邀请其他用户加入通话。

```javascript
const params = { usernames: [String] } 
window.JMRTC.inviteUsers(params, () => {
  
}, () => {
  
})
```

### isMuted

获取静音状态。

```javascript
window.JMRTC.isMuted((boolean) => { })
```

### setIsMuted

设置静音状态。

```javascript
window.JMRTC.setIsMuted({muted: true})
```

### isSpeakerphoneEnabled

获取扬声器状态。

```javascript
window.JMRTC.isSpeakerphoneEnabled((boolean) => { })
```

### setIsSpeakerphoneEnabled

设置扬声器状态

```javascript
window.JMRTC.setIsSpeakerphoneEnabled({speakerphoneEnabled: true})
```

## Event

### CallOutgoing

通话邀请已发出

```javascript
const handler = (session) => {
	
}

//添加监听
window.JMRTC.addCallOutgoingListener(handler)
// 移除监听
window.JMRTC.removeCallOutgoingListener(handler)
```



### CallReceiveInvite

收到通话邀请

```javascript
const handler = (session) => {
	
}

//添加监听
window.JMRTC.addCallReceiveInviteListener(handler)
// 移除监听
window.JMRTC.removeCallReceiveInviteListener(handler)
```

### CallConnecting

通话正在连接

```javascript
const handler = (session) => {
	
}

//添加监听
window.JMRTC.addCallConnectingListener(handler)
// 移除监听
window.JMRTC.removeCallConnectingListener(handler)
```
### CallConnected

通话连接已建立

```javascript
const handler = (session) => {
	
}

//添加监听
window.JMRTC.addCallConnectedListener(handler)
// 移除监听
window.JMRTC.removeCallConnectedListener(handler)
```
### CallMemberJoin

有用户加入通话

```javascript
const handler = (userInfo) => {
	
}

//添加监听
window.JMRTC.addCallMemberJoinListener(handler)
// 移除监听
window.JMRTC.removeCallMemberJoinListener(handler)
```
### CallDisconnect

通话断开

```javascript
const handler = (res) => {
	// res =  {session: Session, reason: 'refuse' | 'hangup' | 'cancel' | 'busy' | 'networkError'}
}

//添加监听
window.JMRTC.addCallDisconnectListener(handler)
// 移除监听
window.JMRTC.removeCallDisconnectListener(handler)
```
### CallMemberLeave

有用户离开

```javascript
const handler = (res) => {
	// res = {user: userInfo, reason: 'refuse' | 'hangup' | 'cancel' | 'busy' | 'networkError'}
}

//添加监听
window.JMRTC.addCallMemberLeaveListener(handler)
// 移除监听
window.JMRTC.removeCallMemberLeaveListener(handler)
```
### CallOtherUserInvited

通话过程中，有其他用户被邀请

```javascript
const handler = (res) => {
	// res = {invitedUsers: userInfo, fromUser: userInfo}
}

//添加监听
window.JMRTC.addCallOtherUserInvitedListener(handler)
// 移除监听
window.JMRTC.removeCallOtherUserInvitedListener(handler)
```
### CallError

通话过程中发生错误

```javascript
const handler = (session) => {
	
}

//添加监听
window.JMRTC.addCallErrorListener(handler)
// 移除监听
window.JMRTC.removeCallErrorListener(handler)
```

## Model

### Session

```json
userModel = {
	type: 'user',
	username: string,           // 用户名
	appKey: string,             // 用户所属应用的 appKey，可与 username 共同作为用户的唯一标识
	nickname: string,           // 昵称
	gender: string,             // 'male' / 'female' / 'unknown'
	avatarThumbPath: string,    // 头像的缩略图地址
	birthday: number,           // 日期的毫秒数
	region: string,             // 地区
	signature: string,          // 个性签名
	address: string,            // 具体地址
	noteName: string,           // 备注名
	noteText: string,           // 备注信息
	isNoDisturb: boolean,       // 是否免打扰
	isInBlackList: boolean,     // 是否在黑名单中
	isFriend:boolean            // 是否为好友
}
session = {
 	channelId: string,
	mediaType: "voice",
	inviter: userModel,
	invitingMembers: [userModel],
	joinedMembers: [userModel],
	startTime: number
}
```
