package com.joyplus.joylink.wind;

import android.os.Handler;
import android.os.Message;

import com.joyplus.joylink.App;

public interface RemoteReceiveMsgHandle {

	public App getApp();
	public void setApp(App app) ;
	public Handler getmLoadingHandler();

	public void setmLoadingHandler(Handler mLoadingHandler) ;
	public void syncServerInfo(Message msg) ;
}
