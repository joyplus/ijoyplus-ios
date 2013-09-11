package com.joyplus.joylink;

import android.os.Environment;

public class Constant {

	public static String PATH = Environment.getExternalStorageDirectory()
			+ "/joy/joylink/image_cache/";
	public static String PATH_HEAD = Environment.getExternalStorageDirectory()
			+ "/joy/joylink/admin/";
	public static String PATH_XML = Environment.getExternalStorageDirectory()
			+ "/joy/joylink/";

	// 我们的sina账号
	public static String SINA_CONSUMER_KEY = "1490285522";
	public static String SINA_CONSUMER_SECRET = "f9ebc3ca95991b6dfce2c1608687e92b";
	public static String TECENTAPPID = "100317415";
	public static String SINA_REDIRECTURL = "https://api.weibo.com/oauth2/default.html";

	public static String DISPLAY = "1080*720";

	public static final String[] ignore_ssids = { "CMCC", "CMCC-AUTO",
			"ChinaNet", "ChinaUnicom" };

	public final static int CONNECT_AP = 30001;
	public final static int VALID_WIFI_PWD_ACTION = 30002;
	public final static int VALID_WIFI_PWD_ACTION_STOP = 30003;

	public final static int SCAN_WIFI_MAIN_FIRST_LOAD = 30004;

	public final static int CONNECT_AP_ON_MAIN = 30005;

	public final static int SEARCH_AP_SUCC = 30010;

	public final static int VALID_CONN_AP_ACTION = 30006;
	public final static int VALID_CONN_AP_ACTION_STOP = 30007;

	public final static int VALID_CONN_WIFI_ACTION = 30008;
	public final static int VALID_CONN_WIFI_ACTION_STOP = 30009;

	public final static String SERVICE_DATA_WIFI_SSID_PWD_KEY_PREFIX = "WIFI_SSID_PWD_KEY_";

	public final static String AP_MODLE_IP = "192.168.43.1";
	public final static String SSID_PREFIX = "JoyPlus TV";

	public final static int MSG_DMR_CHANGED = 0;
	public final static int MSG_PUSH_LOCAL_FILE = 1;
	public final static int MSG_PUSH_INTERNET_MEDIA = 2;
	public final static int MSG_MONITOR_DMR = 3;
	public final static int MSG_STATE_UPDATE = 4;
	public final static int MSG_MEDIA_INFO_UPDATE = 5;
	public final static int MSG_POSITION_UPDATE = 6;
	public final static int MSG_VOLUME_UPDATE = 7;
	public final static int MSG_MUTE_UPDATE = 8;
	public final static int MSG_ALLOWED_ACTIONS_UPDATE = 9;
	public final static int MSG_GET_POSITION_TIMER = 10;
	public final static int MSG_ACTION_RESULT = 11;

	public final static int MSG_DMRCHANGED = 12;

	public final static int MSG_UPDATEDATA = 30;
	public final static int MSG_UPDATEDATA_OK = 31;

	public final static int MSG_DEVICE_NOTCONNECTED = 101;
	public final static int MSG_DEVICE_CONNECTED = 102;
	public final static int MSG_DEVICE_QUIT = 103;

	public final static String MSG_KEY_ID_TITLE = "MSG_KEY_ID_TITLE";
	public final static String MSG_KEY_ID_STATE = "MSG_KEY_ID_STATE";
	public final static String MSG_KEY_ID_ALLOWED_ACTION = "MSG_KEY_ID_ALLOWED_ACTION";
	public final static String MSG_KEY_ID_VOLUME = "MSG_KEY_ID_VOLUME";
	public final static String MSG_KEY_ID_MUTE = "MSG_KEY_ID_MUTE";
	public final static String MSG_KEY_ID_POSITION = "MSG_KEY_ID_POSITION";
	public final static String MSG_KEY_ID_DURATION = "MSG_KEY_ID_DURATION";
	public final static String MSG_KEY_ID_MIME_TYPE = "MSG_KEY_ID_MIME_TYPE";
	public final static String MSG_KEY_ID_ACTION_NAME = "MSG_KEY_ID_ACTION_NAME";
	public final static String MSG_KEY_ID_ACTION_RESULT = "MSG_KEY_ID_ACTION_RESULT";

}
