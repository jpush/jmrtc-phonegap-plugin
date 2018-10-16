var exec = require('cordova/exec')

var PLUGIN_NAME = 'JMRTCPlugin'


var EventHandlers = {
    onCallOutgoing: [],
    onCallReceiveInvite: [],
    onCallConnected: [],
    onCallMemberJoin: [],
    onCallDisconnect: [],
    onCallMemberLeave: [],
    onCallOtherUserInvited: [],
    onCallError: [],
  }

var JMRTCPlugin = {
    
    /**
     * 初始化音视频引擎，初始化完成会回调 cb 函数。
     * @param {Function} success = (res) => { }
     * @param {Function} fail = (error) => { }
     */
    init: function() {
      var success = function(result) {
        if (!EventHandlers.hasOwnProperty(result.eventName)) {
          return;
        }
  
        for (var index in EventHandlers[result.eventName]) {
          EventHandlers[result.eventName][index].apply(undefined, [result.value]);
        }
      };
      
      exec(success, null, PLUGIN_NAME, "init", []);
    },
    /**
     * 初始化音视频引擎，初始化完成会回调 cb 函数。
     * @param {Function} success = (res) => { }
     * @param {Function} fail = (error) => { }
     */
    initEngine: function(success, fail) {
        exec(success, fail, PLUGIN_NAME, "initEngine", []);
    },

    /**
     * 释放实时音视频引擎
     */
    releaseEngine: function() {
        exec(null, null, PLUGIN_NAME, "releaseEngine", []);
    },
    
    /**
     * @abstract 发起一个通话
     * @param params = {usernames: [String]} 
     * @param success = () => {} 成功回调
     * @param fail = () => {} 失败回调
     */
    startCallUsers: function(params, success, fail) {
        exec(success, fail, PLUGIN_NAME, "startCallUsers", [params]);
    },


// 实例方法
  /**
   * @abstract 接听来电
   * @param success = () => {} 成功回调
   * @param fail = () => {} 失败回调
   */
  accept: function(success, fail) {
    exec(success, fail, PLUGIN_NAME, "accept", []);
  },

  /**
   * @abstract 挂断通话
   * @param success = () => {} 成功回调
   * @param fail = () => {} 失败回调
   */
  hangup: function(success, fail) {
    exec(success, fail, PLUGIN_NAME, "hangup", []);
  },

  /**
   * @abstract 拒绝通话
   * @param success = () => {} 成功回调
   * @param fail = () => {} 失败回调
   */
  refuse: function(success, fail) {
    exec(success, fail, PLUGIN_NAME, "refuse", []);
  },

  /**
   * @abstract 邀请其他用户加入通话
   * @param params = {usernames: [String]} 
   * @param success = () => {} 成功回调
   * @param fail = () => {} 失败回调
   */
  inviteUsers: function(params, success, fail) {
    exec(success, fail, PLUGIN_NAME, "inviteUsers", [params]);
  },
  /**
   * 
   * @param {Function} callback = (boolean) => {}
   */
  isMuted: function(callback) {
    
    exec(callback, null, PLUGIN_NAME, "isMuted", []);
  },

  setIsMuted: function(params) {
    exec(null, null, PLUGIN_NAME, "setIsMuted", [params]);
  },


  /**
   * @param {Function} callback = (boolean) => {}
   */
  isSpeakerphoneEnabled: function(callback) {
    exec(callback, null, PLUGIN_NAME, "isSpeakerphoneEnabled", []);
    
  },

  setIsSpeakerphoneEnabled: function(params) {
    exec(null, null, PLUGIN_NAME, "setIsSpeakerphoneEnabled", [params]);
  },

//  事件
  addCallOutgoingListener: function(callback) {
    EventHandlers.onCallOutgoing.push(callback);
  },
  removeCallOutgoingListener: function(callback) {
    var handlerIndex = EventHandlers.onCallOutgoing.indexOf(callback);
    if (handlerIndex >= 0) {
      EventHandlers.onCallOutgoing.splice(handlerIndex, 1);
    }
  },

  addCallReceiveInviteListener: function(callback) {
    EventHandlers.onCallReceiveInvite.push(callback);
  },
  removeCallReceiveInviteListener: function(callback) {
    var handlerIndex = EventHandlers.onCallReceiveInvite.indexOf(callback);
    if (handlerIndex >= 0) {
      EventHandlers.onCallReceiveInvite.splice(handlerIndex, 1);
    }
  },

  addCallConnectingListener: function(callback) {
    //   TODO:
    EventHandlers.onCallConnected.push(callback);
  },
  removeCallConnectingListener: function(callback) {
    //   TODO:
    
  },

  addCallConnectedListener: function(callback) {
    EventHandlers.onCallConnected.push(callback);
  },
  removeCallConnectedListener: function(callback) {
    var handlerIndex = EventHandlers.onCallConnected.indexOf(callback);
    if (handlerIndex >= 0) {
      EventHandlers.onCallConnected.splice(handlerIndex, 1);
    }
  },

  addCallMemberJoinListener: function(callback) {
    EventHandlers.onCallMemberJoin.push(callback);
  },
  removeCallMemberJoinListener: function(callback) {
    var handlerIndex = EventHandlers.onCallMemberJoin.indexOf(callback);
    if (handlerIndex >= 0) {
      EventHandlers.onCallMemberJoin.splice(handlerIndex, 1);
    }
  },

  addCallDisconnectListener: function(callback) {
    EventHandlers.onCallDisconnect.push(callback);
  },
  removeCallDisconnectListener: function(callback) {
    var handlerIndex = EventHandlers.onCallDisconnect.indexOf(callback);
    if (handlerIndex >= 0) {
      EventHandlers.onCallDisconnect.splice(handlerIndex, 1);
    }
  },

  addCallMemberLeaveListener: function(callback) {
    EventHandlers.onCallMemberLeave.push(callback);
  },
  removeCallMemberLeaveListener: function(callback) {
    var handlerIndex = EventHandlers.onCallMemberLeave.indexOf(callback);
    if (handlerIndex >= 0) {
      EventHandlers.onCallMemberLeave.splice(handlerIndex, 1);
    }
  },

  addCallOtherUserInvitedListener: function(callback) {
    EventHandlers.onCallOtherUserInvited.push(callback);
  },
  removeCallOtherUserInvitedListener: function(callback) {
    var handlerIndex = EventHandlers.onCallOtherUserInvited.indexOf(callback);
    if (handlerIndex >= 0) {
      EventHandlers.onCallOtherUserInvited.splice(handlerIndex, 1);
    }
  },

  addCallErrorListener: function(callback) {
    EventHandlers.onCallError.push(callback);
  },
  removeCallErrorListener: function(callback) {
    var handlerIndex = EventHandlers.onCallError.indexOf(callback);
    if (handlerIndex >= 0) {
      EventHandlers.onCallError.splice(handlerIndex, 1);
    }
  }
}

module.exports = JMRTCPlugin