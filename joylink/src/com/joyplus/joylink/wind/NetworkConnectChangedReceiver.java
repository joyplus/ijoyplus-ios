package com.joyplus.joylink.wind;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.NetworkInfo.State;
import android.net.wifi.WifiManager;
import android.os.Parcelable;
import android.util.Log;

public class NetworkConnectChangedReceiver extends BroadcastReceiver {

	@Override  
    public void onReceive(Context context, Intent intent) {  
    if (WifiManager.WIFI_STATE_CHANGED_ACTION.equals(intent.getAction())) {//这个监听wifi的打开与关闭，与wifi的连接无关  
            int wifiState = intent.getIntExtra(WifiManager.EXTRA_WIFI_STATE, 0);   
           Log.e("WIFI状态", "wifiState"+wifiState);  
            switch (wifiState) {   
            case WifiManager.WIFI_STATE_DISABLED:   
                break;   
            case WifiManager.WIFI_STATE_DISABLING:   
                break;   
           //  
            }   
        }  
    // 这个监听wifi的连接状态即是否连上了一个有效无线路由，当上边广播的状态是WifiManager.WIFI_STATE_DISABLING，和WIFI_STATE_DISABLED的时候，根本不会接到这个广播。  
    // 在上边广播接到广播是WifiManager.WIFI_STATE_ENABLED状态的同时也会接到这个广播，当然刚打开wifi肯定还没有连接到有效的无线  
    if (WifiManager.NETWORK_STATE_CHANGED_ACTION.equals(intent.getAction())) {  
            Parcelable parcelableExtra = intent.getParcelableExtra(WifiManager.EXTRA_NETWORK_INFO);    
            if (null != parcelableExtra) {    
                NetworkInfo networkInfo = (NetworkInfo) parcelableExtra;    
                State state = networkInfo.getState();  
                boolean isConnected = state==State.CONNECTED;//当然，这边可以更精确的确定状态  
               Log.e(this.getClass().getSimpleName(), "isConnected"+isConnected);  
                if(isConnected){  
                	
                }else{  
                      
                }  
            }    
        }  
    //这个监听网络连接的设置，包括wifi和移动数据的打开和关闭。.   
        //最好用的还是这个监听。wifi如果打开，关闭，以及连接上可用的连接都会接到监听。见log  
        // 这个广播的最大弊端是比上边两个广播的反应要慢，如果只是要监听wifi，我觉得还是用上边两个配合比较合适  
    if(ConnectivityManager.CONNECTIVITY_ACTION.equals(intent.getAction())){  
        NetworkInfo info = intent.getParcelableExtra(ConnectivityManager.EXTRA_NETWORK_INFO);  
        if (info != null) {  
           Log.e("CONNECTIVITY_ACTION", "info.getTypeName()"+info.getTypeName());  
           Log.e("CONNECTIVITY_ACTION", "getSubtypeName()"+info.getSubtypeName());  
           Log.e("CONNECTIVITY_ACTION", "getState()"+info.getState());  
           Log.e("CONNECTIVITY_ACTION",  
                                "getDetailedState()"+info.getDetailedState().name());  
           Log.e("CONNECTIVITY_ACTION", "getDetailedState()"+info.getExtraInfo());  
           Log.e("CONNECTIVITY_ACTION", "getType()"+info.getType());  
        }   
    }  
      
 }


}
