package com.joyplus.joylink;

import java.util.ArrayList;

import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.FragmentTransaction;
import android.text.Selection;
import android.text.Spannable;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.Toast;

import com.joyplus.joylink.Dlna.DlnaSelectDevice;
import com.joyplus.joylink.wind.JoyDevice;
import com.joyplus.joylink.wind.WifiUtils;
import com.slidingmenu.lib.SlidingMenu;
import com.slidingmenu.lib.app.SlidingFragmentActivity;
import com.wind.s1mobile.common.Protocol.ControlEvent;
import com.wind.s1mobile.common.S1Constant;
import com.wind.s1mobile.common.Utils;
import com.wind.s1mobile.common.packet.BrowserInfo;
import com.wind.s1mobile.common.packet.ControlEventPacket;
import com.wind.s1mobile.common.packet.SystemInfo;
import com.wind.s1mobile.receiver.ConnectionCheckThread;
import com.wind.s1mobile.receiver.ReceiverServerThead;
import com.wind.s1mobile.send.Remote;

public abstract class BaseActivity extends SlidingFragmentActivity implements
		View.OnClickListener {
	private App app;
	private String TAG = "BaseActivity";
	private String mTitle;
	protected MenuFragment mFrag;
	private SlidingMenu sm;

	private Remote mRemote;
	private Thread receiverServerThread;
	private Thread disConnectServerThread;
	// private ArrayList<SystemInfo> serverList;
	protected ArrayList<JoyDevice> serverList1;
	private boolean isTimeout = true;
	private ProgressDialog mProgressDialog;
	private CharSequence[] searchDeviceName;
	private String inputServerIP;
	private int screenWidth;
	private int screenHeight;
	private Utils mUtils;
	private boolean isConnected = false;

	// private Button homeButton;
	// private Button mouseButton;
	// private Button remoteControlButton;
	// private Button SettingButton;

	final Handler mSyncHandler = new Handler() {
		public void handleMessage(android.os.Message msg) {
			int what = msg.what;

			System.out.println("mSyncHandler->what:" + what);
			// if (what == ControlEvent.SYNC_EDITORINFO.getId()) {
			// showInputFunction(msg);
			// } else
			if (what == ControlEvent.SYNC_SERVER_INFO_FOR_SEARCH.getId()) {
				syncServerInfo(msg);
			} else if (what == ControlEvent.SYNC_SERVER_INFO_FOR_CONNECT
					.getId()) {
				syncServerInfo(msg);
			}
		};
	};
	final Handler mLoadingHandler = new Handler() {
		@Override
		public void handleMessage(Message msg) {

			if (msg.what == Constant.SEARCH_AP_SUCC) {
				Log.i("Main", "search Server Succ");
				isTimeout = false;
			} else if (msg.what == Constant.CONNECT_AP_ON_MAIN) {

			} else if (msg.what == S1Constant.HANDLER_MESSAGE_SERACH_START) {
				mProgressDialog = ProgressDialog.show(BaseActivity.this,
						"正在搜索设备", "请稍等...", true, true);
				mRemote.searchServer();
			} else if (msg.what == S1Constant.HANDLER_MESSAGE_SERACH_AGAIN) {
				mRemote.searchServer();
			} else if (msg.what == S1Constant.HANDLER_MESSAGE_SERACH_STOP) {
				mProgressDialog.dismiss();
				int serverListSize = serverList1.size();
				if (serverListSize == 0) {
					if (!isFinishing())
						showDialog(S1Constant.DIALOG_NOT_FOUNT_SERVER);
				} else {
					searchDeviceName = new CharSequence[serverListSize];
					for (int i = 0; i < serverListSize; i++) {
						searchDeviceName[i] = serverList1.get(i).getWifiSSID();
						// searchDeviceName[i] = serverList1.get(i)
						// .getServerWifiAddress();
					}
					if (searchDeviceName.length == 1) {
						saveServer(0);
					} else {
						if (!isFinishing())
							showDialog(S1Constant.DIALOG_SHOW_RESULT);
					}

				}
			}
		}
	};

	public BroadcastReceiver disServer = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {

			String action = intent.getAction();

			if (action.equals(S1Constant.ACTION_SEND_CLIENT_NOTCONNECTED)) {
				// aq.id(R.id.textView1).text("点击选择设备");
				isConnected = false;
				ConnectFailed();
				if (disConnectServerThread != null) {
					((ConnectionCheckThread) disConnectServerThread).close();
					disConnectServerThread = null;
				}
				clearWifiServer();
				showDialog(Constant.MSG_DEVICE_NOTCONNECTED);

			}
		}
	};

	public BaseActivity(String mTitle) {
		this.mTitle = mTitle;
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setTitle(mTitle);

		// set the Behind View
		setBehindContentView(R.layout.menu_frame);
		if (savedInstanceState == null) {
			FragmentTransaction t = this.getSupportFragmentManager()
					.beginTransaction();
			mFrag = new MenuFragment();
			t.replace(R.id.menu_frame, mFrag);
			t.commit();
		} else {
			mFrag = (MenuFragment) this.getSupportFragmentManager()
					.findFragmentById(R.id.menu_frame);
		}

		WindowManager windowManager = getWindowManager();
		Display display = windowManager.getDefaultDisplay();

		// customize the SlidingMenu
		sm = getSlidingMenu();
		sm.setShadowWidthRes(R.dimen.shadow_width);
		sm.setShadowDrawable(R.drawable.shadow);
		sm.setBehindOffsetRes(R.dimen.slidingmenu_offset);
		sm.setFadeDegree(0.35f);
		sm.setTouchModeAbove(SlidingMenu.TOUCHMODE_MARGIN);
		sm.setBehindWidth(display.getWidth() / 3);

		getActionBar().setDisplayHomeAsUpEnabled(true);
		setSlidingActionBarEnabled(true);
		sm.setMode(SlidingMenu.RIGHT);
		sm.setShadowDrawable(R.drawable.shadowright);

		// this.homeButton = (Button) sm.findViewById(R.id.Button1);
		// this.homeButton.setOnClickListener(this);
		//
		// this.remoteControlButton = (Button) sm.findViewById(R.id.Button2);
		// this.remoteControlButton.setOnClickListener(this);
		//
		// this.mouseButton = (Button) sm.findViewById(R.id.Button3);
		// this.mouseButton.setOnClickListener(this);
		//
		// this.SettingButton = (Button) sm.findViewById(R.id.Button4);
		// this.SettingButton.setOnClickListener(this);

		app = (App) getApplication();
		mRemote = app.getmRemote();


	}
	
	public void FirstRun(){
		if (mRemote == null) { // 判断是否首次运行
			mRemote = new Remote(this);
			mUtils = new Utils(this);

			if (receiverServerThread == null) {
				receiverServerThread = new ReceiverServerThead(this,
						mSyncHandler);
				receiverServerThread.start();
			}
			serverList1 = new ArrayList<JoyDevice>();
			searchServer();
			IntentFilter counterActionFilter = new IntentFilter(
					S1Constant.ACTION_SEND_CLIENT_NOTCONNECTED);
			registerReceiver(disServer, counterActionFilter);
		}
	}
	public void Quit(){
		try {
			if (receiverServerThread != null) {
				((ReceiverServerThead) receiverServerThread).close();
				receiverServerThread = null;
			}
			if (disConnectServerThread != null) {
				((ConnectionCheckThread) disConnectServerThread).close();
				disConnectServerThread = null;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		mRemote = null;
		unregisterReceiver(disServer);
	}
	@Override
	public void onClick(View view) {
		sm.toggle();
	}

	public void ChangeTouchModeNone() {
		sm.setTouchModeAbove(SlidingMenu.TOUCHMODE_NONE);
	}

	public void OnClickHome(Context mContext) {

		sm.toggle();
		Intent intent = new Intent(mContext, Tab1.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call Tab1 failed", ex);
		}

	}

	public void OnClickRemoteControl(Context mContext) {

		sm.toggle();
		Intent intent = new Intent(mContext, ControlKey.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call ControlKey failed", ex);
		}

	}

	public void OnClickRemoteMouse(Context mContext) {

		sm.toggle();
		Intent intent = new Intent(mContext, ControlMouse.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call ControlMouse failed", ex);
		}

	}

	public void OnClickSetting(Context mContext) {

		sm.toggle();
		Intent intent = new Intent(mContext, Setting.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call Setting failed", ex);
		}

	}

	public void OnClickSlidingMenu() {
		sm.toggle();
	}

	public void searchServer() {

		// serverList = new ArrayList<SystemInfo>();
		
		startAccessServerThread(S1Constant.ACCESS_SERVER_TYPE_SEARCH);
		// createGestureListener();
	}

	public boolean isConnected(){
		return isConnected;
	}
	public void startAccessServerThread(final int type) {
		isTimeout = true;
		new Thread() {
			public void run() {
				try {
					if (type == S1Constant.ACCESS_SERVER_TYPE_SEARCH) {
						if (isTimeout) {
							sendMessage(S1Constant.HANDLER_MESSAGE_SERACH_START);
							Thread.sleep(1000);
						}

						if (isTimeout) {
							sendMessage(S1Constant.HANDLER_MESSAGE_SERACH_AGAIN);
							Thread.sleep(1000);
						}

						// if (!isTimeout) {
						// sendMessage(S1Constant.HANDLER_MESSAGE_SERACH_AGAIN);
						// Thread.sleep(1000);
						// }

						if (isTimeout) {
							sendMessage(S1Constant.HANDLER_MESSAGE_SERACH_STOP);
						}
					} else if (type == S1Constant.ACCESS_SERVER_TYPE_CONNECT) {
						if (isTimeout) {
							sendMessage(S1Constant.HANDLER_MESSAGE_CONNECT_ONLY);
							Thread.sleep(1500);
						}

						if (isTimeout) {
							sendMessage(S1Constant.HANDLER_MESSAGE_CONNECT_FAILE);
						}
					} else if (type == S1Constant.ACCESS_SERVER_TYPE_CHECK_CONNECT) {
						if (isTimeout) {
							sendMessage(S1Constant.HANDLER_MESSAGE_CHECK_CONNECT);
							Thread.sleep(5000);
						}

						if (isTimeout) {
							sendMessage(S1Constant.HANDLER_MESSAGE_CONNECT_FAILE);
						}
					}

				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		}.start();
	}

	private void sendMessage(int info) {
		Message message = Message.obtain();
		message.what = info;
		mLoadingHandler.sendMessage(message);
	}

	public void connectServer(String serverIPAddress) {
		ControlEventPacket controlEventPacket = new ControlEventPacket();
		SystemInfo systemInfo = new SystemInfo();
		systemInfo.setServerWifiAddress(serverIPAddress);
		systemInfo.setScreenWidth(screenWidth);
		systemInfo.setScreenHeight(screenHeight);
		controlEventPacket.setSystemInfo(systemInfo);
		controlEventPacket.setControlEvent(ControlEvent.CONNECT_SERVER);

		sendTouchEvent(controlEventPacket);

		// createGestureListener();
	}

	public void sendTouchEvent(ControlEventPacket mouseEventPacket) {
		if (mRemote != null) 
			mRemote.queuePacket(mouseEventPacket);
	}

	public void sendKeyCode(int keycode) {
		SystemInfo systemInfo = new SystemInfo();
		systemInfo.setKeycode(keycode);
		ControlEventPacket packet = new ControlEventPacket(
				ControlEvent.SEND_KEY_CODE);
		packet.setSystemInfo(systemInfo);
		if (mRemote != null) 
			mRemote.queuePacket(packet);
	}

	public void waitForMouseMove() {
		if (mRemote != null) 
			mRemote.waitForMouseMove();
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();

	}

	public void clearWifiServer() {
		// ArrayList<JoyDevice> temp = new ArrayList<JoyDevice>();
		// int listSize = serverList.size();
		// for (int i = 0; i < listSize; i++) {
		// if (serverList.get(i).getType() == JoyDevice.MODEL_AP) {
		// temp.add(serverList.get(i));
		// }
		// }
		// return temp;
		if (serverList1 != null)
			serverList1.clear();
	}

	public void delServerInfo(SystemInfo mSystemInfo) {
		if (mSystemInfo != null) {
			if (mSystemInfo.getServerWifiAddress().equals(Constant.AP_MODLE_IP)) {
				clearWifiServer();
			} else {
				for (int i = 0; i < serverList1.size(); i++) {
					if (serverList1.get(i).getWifiSSID()
							.equals(mSystemInfo.getDeviceName())) {
						serverList1.remove(i);
						return;
					}
				}
			}
		}

	}

	public void syncServerInfo(Message msg) {
		// System.out.println("syncServerInfo:" + msg.obj.toString());
		// String[] receiveInfo = msg.obj.toString().split(":");
		//

		SystemInfo tsystemInfo = (SystemInfo) msg.obj;
		JoyDevice systemInfo = new JoyDevice();

		if (msg.what == ControlEvent.SYNC_SERVER_INFO_FOR_SEARCH.getId()) {
			if (tsystemInfo != null) {
				if (tsystemInfo.getServerWifiAddress().equals(
						Constant.AP_MODLE_IP)) {
					clearWifiServer();
				}
				JoyDevice device = WifiUtils.getDeviceInList(serverList1,
						tsystemInfo.getDeviceName());
				Log.i("BaseActivity-->syncServerInfo",tsystemInfo.getDeviceName());
				if (device == null) {
					systemInfo.setServerWifiAddress(tsystemInfo
							.getServerWifiAddress());
					systemInfo.setScreenWidth(tsystemInfo.getScreenWidth());
					systemInfo.setScreenHeight(tsystemInfo.getScreenHeight());
					systemInfo.setType(JoyDevice.MODEL_WIFI);
					systemInfo.setWifiSSID(tsystemInfo.getDeviceName());
					//
					S1Constant.SERVER_SCREEN_WIDTH = systemInfo
							.getScreenWidth();
					S1Constant.SERVER_SCREEN_HEIGHT = systemInfo
							.getScreenHeight();
					serverList1.add(systemInfo);
				} else {
					if (tsystemInfo.getServerWifiAddress().equals(
							Constant.AP_MODLE_IP)) {
						device.setServerWifiAddress(tsystemInfo
								.getServerWifiAddress());
						device.setScreenWidth(tsystemInfo.getScreenWidth());
						device.setScreenHeight(tsystemInfo.getScreenHeight());
						S1Constant.SERVER_SCREEN_WIDTH = systemInfo
								.getScreenWidth();
						S1Constant.SERVER_SCREEN_HEIGHT = systemInfo
								.getScreenHeight();
					}
				}
				Log.i("Main", "search Server Succ");
				isTimeout = false;
				mProgressDialog.dismiss();
				int serverListSize = serverList1.size();
				if (serverListSize > 0) {
					searchDeviceName = new CharSequence[serverListSize];
					for (int i = 0; i < serverListSize; i++) {
						searchDeviceName[i] = serverList1.get(i).getWifiSSID();
						// searchDeviceName[i] =
						// serverList1.get(i).getServerWifiAddress();
					}
					if (searchDeviceName.length == 1) {
						saveServer(0);
					} else {
						if (!isFinishing())
							showDialog(S1Constant.DIALOG_SHOW_RESULT);
					}

				}
			}

		} else if (msg.what == ControlEvent.SYNC_SERVER_INFO_FOR_CONNECT
				.getId()) {
			if (tsystemInfo != null) {
				// sendMessage(S1Constant.HANDLER_MESSAGE_CONNECT_SUCCESS);
			} else {
				// sendMessage(S1Constant.HANDLER_MESSAGE_CONNECT_FAILE);
			}
		}
	}

	private void saveServer(int which) {
		String serverInfo = serverList1.get(which).getServerWifiAddress();
		// System.out.println("serverInfo:" + serverInfo);
		if (mRemote != null && serverInfo != null) {
			isConnected = true;
			app.setmRemote(mRemote);
			S1Constant.SERVER_ADDRESS = serverInfo;
			mRemote.setRemoteServerAddress(serverInfo);

			ConnectOK(serverList1.get(which).getWifiSSID());

			// aq.id(R.id.textView1).text(serverList1.get(which).getWifiSSID());
			Toast.makeText(this, "连接成功!", Toast.LENGTH_SHORT).show();
			// 连接成功后去检测是否断开
			if (disConnectServerThread == null) {
				disConnectServerThread = new ConnectionCheckThread(this,
						mRemote);
				disConnectServerThread.start();
			}
		}
	}

	@Override
	protected Dialog onCreateDialog(int id) {
		Dialog dialog = null;
		switch (id) {
		case S1Constant.DIALOG_SHOW_RESULT:
			Builder builder = new android.app.AlertDialog.Builder(this);
			builder.setTitle("可用设备");
			builder.setItems(searchDeviceName, new OnClickListener() {
				public void onClick(DialogInterface dialog, int which) {
					saveServer(which);

				}
			})
					.setCancelable(true)
					.setNegativeButton(getString(R.string.info_setup_enter_ip),
							new DialogInterface.OnClickListener() {

								@Override
								public void onClick(DialogInterface dialog,
										int whichButton) {
									showDialog(S1Constant.DIALOG_INPUT_SERVER_ADDRESS);
								}
							}).setCancelable(true);
			dialog = builder.create();
			break;
		case S1Constant.DIALOG_NOT_FOUNT_SERVER:
			new AlertDialog.Builder(BaseActivity.this)
					.setTitle(getString(R.string.info_setup_title))
					.setMessage(getString(R.string.info_setup_message))
					.setPositiveButton(
							getString(R.string.info_setup_connect_server),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,
										int whichButton) {
									startAccessServerThread(S1Constant.ACCESS_SERVER_TYPE_SEARCH);
								}
							})
					.setNeutralButton(getString(R.string.info_setup_enter_ip),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,
										int whichButton) {
									showDialog(S1Constant.DIALOG_INPUT_SERVER_ADDRESS);
								}
							})
					.setNegativeButton(getString(R.string.info_setup_exit),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,
										int whichButton) {
									finish();
								}
							}).setCancelable(true).show();

			break;

		case S1Constant.DIALOG_INPUT_SERVER_ADDRESS:
			final EditText editText = new EditText(this);
			String localIP = mUtils.getWiFiIpAddress();
			if (localIP != null && localIP.trim() != "") {
				localIP = localIP.substring(0, localIP.lastIndexOf(".") + 1);
				editText.setText(localIP);
				Spannable spanText = (Spannable) editText.getText();
				Selection.setSelection(spanText, spanText.length());
			}

			new AlertDialog.Builder(this)
					.setTitle(getString(R.string.info_setup_add_Server))
					.setView(editText)
					.setPositiveButton(getString(R.string.info_setup_ok),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									String inputServerIP = editText.getText()
											.toString();
									// startTouchpad();
									if (Utils.isRightIP(inputServerIP)) {
										setInputServerIP(inputServerIP);
										startAccessServerThread(S1Constant.ACCESS_SERVER_TYPE_CONNECT);

									} else {
										Toast.makeText(getBaseContext(),
												"IP 错误!", Toast.LENGTH_SHORT)
												.show();
										showDialog(S1Constant.DIALOG_INPUT_SERVER_ADDRESS);
									}
								}
							})
					.setNegativeButton(R.string.info_setup_cancel,
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,
										int which) {
									showDialog(S1Constant.DIALOG_NOT_FOUNT_SERVER);
								}
							}).setCancelable(true).show();
			break;
		case Constant.MSG_DEVICE_NOTCONNECTED:
			new AlertDialog.Builder(BaseActivity.this)
					.setTitle("设备断开")
					.setIcon(R.drawable.tab1_close)
					.setMessage("要重新搜索设备吗？")
					.setPositiveButton(
							getString(R.string.info_setup_connect_server),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,
										int whichButton) {
									startAccessServerThread(S1Constant.ACCESS_SERVER_TYPE_SEARCH);
								}
							})
					.setNeutralButton(getString(R.string.info_setup_enter_ip),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,
										int whichButton) {
									showDialog(S1Constant.DIALOG_INPUT_SERVER_ADDRESS);
								}
							})
					.setNegativeButton(getString(R.string.info_setup_exit),
							new DialogInterface.OnClickListener() {
								@Override
								public void onClick(DialogInterface dialog,
										int whichButton) {
									finish();
								}
							}).setCancelable(true).show();
			break;
		}

		return dialog;
	}

	private void setInputServerIP(String inputServerIP) {
		this.inputServerIP = inputServerIP;
	}

	public String getRemoteServerAddress() {
		return mRemote.getRemoteServerAddress();
	}

	public Remote getRemote() {
		return mRemote;
	}

	public void sendURL(String url) {
		ControlEventPacket controlEventPacket = new ControlEventPacket(
				ControlEvent.BROWSER_REQUEST_URL);
		BrowserInfo browserInfo = new BrowserInfo();
		browserInfo.setUrl(url);
		controlEventPacket.setBrowserInfo(browserInfo);

		controlEventPacket.setControlEvent(ControlEvent.BROWSER_REQUEST_URL);
		if (mRemote != null) 
			mRemote.queuePacket(controlEventPacket);
	}

	abstract void ConnectOK(String name);

	abstract void ConnectFailed();

}
