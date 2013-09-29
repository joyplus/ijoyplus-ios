package com.joyplus.joylink.wind;

import com.wind.s1mobile.common.S1Constant;

public class JoyDevice {

	private int type; // AP or WIFI

	public final static int MODEL_AP = 1;
	public final static int MODEL_WIFI = 2;
	private float screenWidth;
	private float screenHeight;
	private String serverWifiAddress;
	private String wifiSSID;
	private String wifiPassword;
	private int wifiSecurityType;
	private int frequency;
	private int level;
	private String capabilities;
	private int describeContents;
	private int securityLevel = 3;

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public float getScreenWidth() {
		return screenWidth;
	}

	public void setScreenWidth(float screenWidth) {
		this.screenWidth = screenWidth;
	}

	public float getScreenHeight() {
		return screenHeight;
	}

	public void setScreenHeight(float screenHeight) {
		this.screenHeight = screenHeight;
	}

	public String getServerWifiAddress() {
		return serverWifiAddress;
	}

	public void setServerWifiAddress(String serverWifiAddress) {
		this.serverWifiAddress = serverWifiAddress;
	}

	public String getWifiSSID() {
		return wifiSSID;
	}

	public void setWifiSSID(String wifiSSID) {
		this.wifiSSID = wifiSSID;
	}

	public String getWifiPassword() {
		return wifiPassword;
	}

	public void setWifiPassword(String wifiPassword) {
		this.wifiPassword = wifiPassword;
	}

	public int getWifiSecurityType() {
		return wifiSecurityType;
	}

	public void setWifiSecurityType(int wifiSecurityType) {
		this.wifiSecurityType = wifiSecurityType;
	}

	public int getSecurityLevel() {
		return securityLevel;
	}

	public void setSecurityLevel(int securityLevel) {
		this.securityLevel = securityLevel;
	}

	public int getDescribeContents() {
		return describeContents;
	}

	public void setDescribeContents(int describeContents) {
		this.describeContents = describeContents;
	}

	public String getCapabilities() {
		return capabilities;
	}

	public void setCapabilities(String capabilities) {
		this.capabilities = capabilities;
		if (capabilities != null) {
			if (this.capabilities.toUpperCase().indexOf("WPA") != -1) {
				this.securityLevel = S1Constant.WIFI_CONNECT_WIFICIPHER_WPA;
			} else if (this.capabilities.toUpperCase().indexOf("WEP") != -1) {
				this.securityLevel = S1Constant.WIFI_CONNECT_WIFICIPHER_WEP;
			} else {
				this.securityLevel = S1Constant.WIFI_CONNECT_WIFICIPHER_NOPASS;
			}
		}
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public int getFrequency() {
		return frequency;
	}

	public void setFrequency(int frequency) {
		this.frequency = frequency;
	}
}
