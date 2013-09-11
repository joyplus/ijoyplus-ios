package com.joyplus.joylink.wind;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.net.InetAddress;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import android.content.ContentResolver;
import android.content.Context;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiManager;

import com.wind.s1mobile.common.Protocol.ControlEvent;
import com.wind.s1mobile.common.S1Constant;
import com.wind.s1mobile.common.WifiConnectManager;
import com.wind.s1mobile.common.packet.ControlEventPacket;
import com.wind.s1mobile.common.packet.SystemInfo;
import com.wind.s1mobile.send.Remote;

public class WifiUtils {
   public static  void connectWIFI(Context object,String ssid,String pwd,int type){
   	    WifiConnectManager wifiAdmin = new WifiConnectManager(object);
		wifiAdmin.openWifi();
		wifiAdmin.addNetwork(wifiAdmin.CreateWifiInfo(ssid,pwd,type));
   }
   
   public static void ConnectionClientWifi(Remote mRemote,String wifiName,String wifiPassword,int wifiType) {
		ControlEventPacket controlEventPacket = new ControlEventPacket();
		controlEventPacket.setControlEvent(ControlEvent.SEND_WIFI_INFO);
		controlEventPacket.setWifiName(wifiName);
		controlEventPacket.setWifiPassword(wifiPassword);
		controlEventPacket.setWifiType(wifiType);
		mRemote.queuePacket(controlEventPacket);
	}
   
   public static void connectDeviceServer(String ip){
	    ControlEventPacket controlEventPacket = new ControlEventPacket();
		SystemInfo systemInfo = new SystemInfo();
		systemInfo.setServerWifiAddress(ip);
		controlEventPacket.setSystemInfo(systemInfo);
		controlEventPacket.setControlEvent(ControlEvent.CONNECT_SERVER);
   }
   
   public static JoyDevice getDeviceInList(ArrayList<JoyDevice> serverList,
			String wifiIPAddress) {
		int listSize = serverList.size();
		for (int i = 0; i < listSize; i++) {			
			if ( serverList.get(i).getWifiSSID().equals(wifiIPAddress)) {
				return serverList.get(i);
			}
		}
		return null;
	}
   
   
   public static String getIp(int i){
	   return (i & 0xFF ) + "." + 
			    ((i >> 8 ) & 0xFF) + "." + 
			    ((i >> 16 ) & 0xFF) + "." + 
			    ( i >> 24 & 0xFF) ; 

   }
   
public static  int getWifiSecurityLevel(String capabilities){
	   if(capabilities !=null){
		   capabilities=capabilities.toUpperCase();
			if(capabilities.indexOf("WPA") !=-1){
				return S1Constant.WIFI_CONNECT_WIFICIPHER_WPA;
			}else if(capabilities.indexOf("WEP") !=-1){
				return S1Constant.WIFI_CONNECT_WIFICIPHER_WEP;
			}else {
				return S1Constant.WIFI_CONNECT_WIFICIPHER_NOPASS;
			}
		}
	   return S1Constant.WIFI_CONNECT_WIFICIPHER_WPA;
   }
   
   public static ArrayList<JoyDevice> clearWifiServer(ArrayList<JoyDevice> serverList){
	   ArrayList<JoyDevice> temp = new ArrayList<JoyDevice>();
	   int listSize = serverList.size();
	   for (int i = 0; i < listSize; i++) {						
			if ( serverList.get(i).getType() == JoyDevice.MODEL_AP) {
				temp.add(serverList.get(i));
			}
		}
	   return temp;
   } 
   
   public static void setWIFIStaticIP(String ssid,WifiManager wifiManager,ContentResolver contentResovler){
	   try{
		   int version = getAndroidSDKVersion();	
		   Random r = new Random();
		   r.setSeed(253);
		   int ip=r.nextInt();  
		   if(ip>253){
			   ip=2;
		   }
		   if(version >10){
			   WifiConfiguration conf = getWifiConf(ssid,wifiManager);
			   if(conf!=null){			   
			        setIpAssignment("STATIC", conf); //or "DHCP" for dynamic setting
			        setIpAddress(InetAddress.getByName("192.168.43."+ip), 24, conf);
			        if(version<14){
			          setGateway3(InetAddress.getByName("192.168.43.1"), conf);
			        }else {
			          setGateway4(InetAddress.getByName("192.168.43.1"), conf);
			        }
			        setDNS(InetAddress.getByName("192.168.0.254"), conf);
			        wifiManager.updateNetwork(conf); //apply the setting			    
			   }
		   }else {
			   android.provider.Settings.System.putString(contentResovler, android.provider.Settings.System.WIFI_USE_STATIC_IP, "1");        
			   android.provider.Settings.System.putString(contentResovler, android.provider.Settings.System.WIFI_STATIC_IP, "192.168.43."+ip);
			   android.provider.Settings.System.putString(contentResovler, android.provider.Settings.System.WIFI_STATIC_NETMASK, "255.255.255.0");
			   android.provider.Settings.System.putString(contentResovler, android.provider.Settings.System.WIFI_STATIC_DNS1, "192.168.0.254");
			   android.provider.Settings.System.putString(contentResovler, android.provider.Settings.System.WIFI_STATIC_GATEWAY, "192.168.43.1");
		   }	   
	   }catch(Exception e){
	        e.printStackTrace();
	    }
   }
   
   public static int getAndroidSDKVersion() { 
	   int version=0; 
	   try { 
	     version = Integer.valueOf(android.os.Build.VERSION.SDK); 
	   } catch (Exception e) { 
	  
	   } 
	   return version; 
	   }


   
   public static void setGateway3(InetAddress gateway, WifiConfiguration wifiConf)
	        throws SecurityException, IllegalArgumentException, NoSuchFieldException, IllegalAccessException, 
	        ClassNotFoundException, NoSuchMethodException, InstantiationException, InvocationTargetException{
	            Object linkProperties = getField(wifiConf, "linkProperties");
	            if(linkProperties == null)return;
	            ArrayList mGateways = (ArrayList)getDeclaredField(linkProperties, "mGateways");
	            mGateways.clear();
	            mGateways.add(gateway);
 }
   
   public static void setIpAssignment(String assign , WifiConfiguration wifiConf)
		    throws SecurityException, IllegalArgumentException, NoSuchFieldException, IllegalAccessException{
		        setEnumField(wifiConf, assign, "ipAssignment");     
		    }

		    public static void setIpAddress(InetAddress addr, int prefixLength, WifiConfiguration wifiConf)
		    throws SecurityException, IllegalArgumentException, NoSuchFieldException, IllegalAccessException,
		    NoSuchMethodException, ClassNotFoundException, InstantiationException, InvocationTargetException{
		        Object linkProperties = getField(wifiConf, "linkProperties");
		        if(linkProperties == null)return;
		        Class laClass = Class.forName("android.net.LinkAddress");
		        Constructor laConstructor = laClass.getConstructor(new Class[]{InetAddress.class, int.class});
		        Object linkAddress = laConstructor.newInstance(addr, prefixLength);

		        ArrayList mLinkAddresses = (ArrayList)getDeclaredField(linkProperties, "mLinkAddresses");
		        mLinkAddresses.clear();
		        mLinkAddresses.add(linkAddress);        
		    }

		    public static void setGateway4(InetAddress gateway, WifiConfiguration wifiConf)
		    throws SecurityException, IllegalArgumentException, NoSuchFieldException, IllegalAccessException, 
		    ClassNotFoundException, NoSuchMethodException, InstantiationException, InvocationTargetException{
		        Object linkProperties = getField(wifiConf, "linkProperties");
		        if(linkProperties == null)return;
		        Class routeInfoClass = Class.forName("android.net.RouteInfo");
		        Constructor routeInfoConstructor = routeInfoClass.getConstructor(new Class[]{InetAddress.class});
		        Object routeInfo = routeInfoConstructor.newInstance(gateway);

		        ArrayList mRoutes = (ArrayList)getDeclaredField(linkProperties, "mRoutes");
		        mRoutes.clear();
		        mRoutes.add(routeInfo);
		    }

		    public static void setDNS(InetAddress dns, WifiConfiguration wifiConf)
		    throws SecurityException, IllegalArgumentException, NoSuchFieldException, IllegalAccessException{
		        Object linkProperties = getField(wifiConf, "linkProperties");
		        if(linkProperties == null)return;

		        ArrayList<InetAddress> mDnses = (ArrayList<InetAddress>)getDeclaredField(linkProperties, "mDnses");
		        mDnses.clear(); //or add a new dns address , here I just want to replace DNS1
		        mDnses.add(dns); 
		    }

		    public static Object getField(Object obj, String name)
		    throws SecurityException, NoSuchFieldException, IllegalArgumentException, IllegalAccessException{
		        Field f = obj.getClass().getField(name);
		        Object out = f.get(obj);
		        return out;
		    }

		    public static Object getDeclaredField(Object obj, String name)
		    throws SecurityException, NoSuchFieldException,
		    IllegalArgumentException, IllegalAccessException {
		        Field f = obj.getClass().getDeclaredField(name);
		        f.setAccessible(true);
		        Object out = f.get(obj);
		        return out;
		    }  

		    public static void setEnumField(Object obj, String value, String name)
		    throws SecurityException, NoSuchFieldException, IllegalArgumentException, IllegalAccessException{
		        Field f = obj.getClass().getField(name);
		        f.set(obj, Enum.valueOf((Class<Enum>) f.getType(), value));
		    }
   
   public static WifiConfiguration  getWifiConf(String ssid,WifiManager wifiManager){
       List<WifiConfiguration> configuredNetworks = wifiManager.getConfiguredNetworks(); 
       if(configuredNetworks !=null && configuredNetworks.size()>0){
	       for (WifiConfiguration conf : configuredNetworks){
	           if (conf.SSID.equals(ssid)){
	              return conf;             
	           }
	       }
       }
	   return null;
   }

}
