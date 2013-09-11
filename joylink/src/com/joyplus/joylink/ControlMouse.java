package com.joyplus.joylink;

import java.util.ArrayList;

import android.app.ActionBar;
import android.app.ProgressDialog;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.os.Message;
import android.util.Log;
import android.view.Display;
import android.view.GestureDetector;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.CheckBox;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.wind.s1mobile.common.Protocol.ControlEvent;
import com.wind.s1mobile.common.S1Constant;
import com.wind.s1mobile.common.Utils;
import com.wind.s1mobile.common.WifiConnectManager;
import com.wind.s1mobile.common.packet.ControlEventPacket;
import com.wind.s1mobile.common.packet.SystemInfo;
import com.wind.s1mobile.receiver.ReceiverService;

public class ControlMouse extends BaseActivity implements View.OnTouchListener,
		View.OnClickListener {

	private String TAG = "MouseMode";
	private App app;
	private GestureDetector gestureDetector = null;
	private boolean isBeginScroll = false;
	public static int mTouchState = S1Constant.TOUCH_STATE_REST;
	private int mTouchSlop = 16;
	private float spanX;
	private float spanY;

	private LinearLayout touchPadView;
	private LinearLayout upAndDownScrollView;
	private LinearLayout leftAndRightScrollView;
	private LinearLayout noTouchView;
	private RelativeLayout touchpad_bottom_area;
	private RelativeLayout toolsArea;
	private ControlEventPacket mControlEventPacket;
	private float mLastMotionX;
	private float mLastMotionY;
	private long currentTimeMillis;
	private boolean isDown = false;
	private boolean isTouch = false;
	private Utils mUtils;
	private Thread receiverServerThread;
	public static int screenWidth;
	public static int screenHeight;
	private int toolsBarHeight = 160;
	private long exitTime = 0;
	private ArrayList<SystemInfo> serverList;
	private ProgressDialog mProgressDialog;
	private boolean isTimeout = true;
	private CharSequence[] searchResult;
	// private SensorManager mSensorManager;
	// private WakeLock mWakeLock;
	// ControlGSensor mControlGSensor;
	private float mFirstMotionX;
	private float mFirstMotionY;
	private float mSecondMotionX;
	private float mSecondMotionY;
	private boolean isPointerDown = false;
	private float scaleX;
	private float scaleY;
	private float serverScreenWidth = S1Constant.SERVER_SCREEN_WIDTH;
	private float serverScreenHeight = S1Constant.SERVER_SCREEN_HEIGHT;
	private boolean isSetRequestedOrientation = false;
	private static String inputServerIP;
	private boolean isChecked = true;
	private CheckBox mCheckBox4 = null;
	private ImageButton mSlidingMenuButton;
	private boolean SHOWKEYBOARD = false;

	public ControlMouse() {
		super("ControlMouse");
		// TODO Auto-generated constructor stub
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		app = (App) getApplicationContext();
		// requestWindowFeature(Window.FEATURE_NO_TITLE);
		// getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LOW_PROFILE);
		// getWindow().getDecorView().setSystemUiVisibility(View.STATUS_BAR_HIDDEN);
		setContentView(R.layout.activity_mouse_mode);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout);
		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		mTextView.setText("鼠标");
		mSlidingMenuButton = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mSlidingMenuButton.setOnClickListener(this);

		setProgressBarVisibility(false);
		System.out.println("MouseMode onCreate()");

		// getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);

		// getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE
		// | WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);
		// System.out.println("Touchpad onCreate");
		Intent intent = new Intent(ControlMouse.this, ReceiverService.class);
		startService(intent);
		mUtils = new Utils(this);
		mUtils.getWiFiIpAddress();
		setScreenSize();
		this.touchPadView = (LinearLayout) findViewById(R.id.touchpad_bg);
		this.touchPadView.setOnTouchListener(this);
		this.upAndDownScrollView = (LinearLayout) findViewById(R.id.scrollUpAndDown_bg);
		this.upAndDownScrollView.setOnTouchListener(this);
		this.leftAndRightScrollView = (LinearLayout) findViewById(R.id.scroll_left_and_right_bg);
		this.leftAndRightScrollView.setOnTouchListener(this);
		this.noTouchView = (LinearLayout) findViewById(R.id.no_touch_bg);
		this.noTouchView.setOnTouchListener(this);

		this.touchpad_bottom_area = (RelativeLayout) findViewById(R.id.touchpad_bottom_area);

		setLayoutSize();
		mControlEventPacket = new ControlEventPacket();

		// getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE
		// | WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN);

		super.ChangeTouchModeNone();
		// showAlertDialog();

		// inputMessage.setOnClickListener(this);
		// inputMessage.setOnEditorActionListener(this);

		if (!isSetRequestedOrientation) {
			// receiverServerThread = new Thread(new ReceiverServerThead(this,
			// mSyncHandler));
			// receiverServerThread.start();
			createGestureListener();
			// searchServer();
		}

	}

	@Override
	public void onClick(View view) {
		if (view == mSlidingMenuButton) {
			getSlidingMenu().toggle();
		}
	}

	public void OnClickSlidingMenu(View v) {
		super.OnClickSlidingMenu();
	}

	public void OnClickHome(View v) {
		super.OnClickHome(this);
	}

	public void OnClickRemoteMouse(View v) {
		super.OnClickRemoteMouse(this);

	}

	public void OnClickRemoteControl(View v) {
		super.OnClickRemoteControl(this);
	}

	public void OnClickSetting(View v) {
		super.OnClickSetting(this);

	}

	@SuppressWarnings("deprecation")
	private void createGestureListener() {
		gestureDetector = new GestureDetector(gestureListener);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// getMenuInflater().inflate(R.menu.activity_touchpad, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		return true;
	}

	@Override
	public boolean onTouch(View v, MotionEvent event) {

		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			setTouchMode(v);
			break;
		case MotionEvent.ACTION_MOVE:
			break;
		case MotionEvent.ACTION_UP:
			break;
		}

		return false;
	}

	// @Override
	// public boolean onTouch(View v, MotionEvent event) {
	//
	// switch (event.getAction()) {
	// case MotionEvent.ACTION_DOWN:
	// MODE = 1;
	// setTouchMode(v);
	// break;
	// case MotionEvent.ACTION_MOVE:
	// if (MODE >= 2) {
	// float newDist = spacing(event);
	// if (newDist > oldDist) {
	// zoomOut();
	// }
	// if (newDist < oldDist) {
	// zoomIn();
	// }
	// break;
	// }
	// break;
	// case MotionEvent.ACTION_UP:
	// MODE = 0;
	// break;
	// case MotionEvent.ACTION_POINTER_UP:
	// MODE -= 1;
	// break;
	// case MotionEvent.ACTION_POINTER_DOWN:
	// MODE -= 1;
	// break;
	// }
	//
	// return false;
	// }
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		// System.out.println("onTouchEvent");
		int pointerId = (event.getAction() & MotionEvent.ACTION_POINTER_ID_MASK) >> MotionEvent.ACTION_POINTER_ID_SHIFT;
		int pointerCount = event.getPointerCount();
		long moveTimeSpan;
		try {
			switch (event.getAction() & MotionEvent.ACTION_MASK) {
			case MotionEvent.ACTION_DOWN:
				// System.out.println("onTouchEvent()->ACTION_DOWN");
				// checkSocketConnect();

				mLastMotionX = event.getX();
				mLastMotionY = event.getY();
				currentTimeMillis = System.currentTimeMillis();
				sendTouchEvent(new ControlEventPacket(ControlEvent.MOUSE_MODE));
				isPointerDown = false;
				isDown = true;
				isTouch = true;
				isBeginScroll = false;
				break;

			case MotionEvent.ACTION_MOVE:
				if (pointerCount == 1) {
					if (!isPointerDown) {
						// System.out.println("onTouchEvent()->ACTION_MOVE");
						float eventX = event.getX();
						float deltaX = mLastMotionX - eventX;
						mLastMotionX = eventX;
						moveTimeSpan = (System.currentTimeMillis() - currentTimeMillis);

						float eventY = event.getY();
						float deltaY = mLastMotionY - eventY;
						mLastMotionY = eventY;
						executeTouchAction(moveTimeSpan, deltaX, deltaY);
						super.waitForMouseMove();
					}
				} else if (pointerCount > 1) {
					float eventX = event.getX(event
							.getPointerId(pointerCount - 2));
					float deltaX = mFirstMotionX - eventX;
					mFirstMotionX = eventX;

					float eventY = event.getY(event
							.getPointerId(pointerCount - 2));
					float deltaY = mFirstMotionY - eventY;
					mFirstMotionY = eventY;

					// dump here.....
					float eventSX = event.getX(event
							.getPointerId(pointerCount - 1));
					float deltaSX = mSecondMotionX - eventSX;
					mSecondMotionX = eventSX;

					float eventSY = event.getY(event
							.getPointerId(pointerCount - 1));
					float deltaSY = mSecondMotionY - eventSY;
					mSecondMotionY = eventSY;
					if (mFirstMotionX > (mFirstMotionX + mSecondMotionX) / 2) {
						mControlEventPacket.setTouchInfo(
								ControlEvent.MOUSE_MODE_DOUBLE_MOVE, deltaX
										* scaleX, deltaY * scaleY);
						mControlEventPacket.setPointer2X(deltaSX * scaleX);
						mControlEventPacket.setPointer2Y(deltaSY * scaleY);
					} else {
						mControlEventPacket.setTouchInfo(
								ControlEvent.MOUSE_MODE_DOUBLE_MOVE,
								-(deltaX * scaleX), -(deltaY * scaleY));
						mControlEventPacket.setPointer2X(-(deltaSX * scaleX));
						mControlEventPacket.setPointer2Y(-(deltaSY * scaleY));
					}
					sendTouchEvent(mControlEventPacket);
				}
				break;
			case MotionEvent.ACTION_UP:
				// System.out.println("onTouchEvent()->ACTION_UP");
				if (isPointerDown) {
					sendTouchEvent(new ControlEventPacket(
							ControlEvent.MOUSE_MODE_ACTION_UP));
					isPointerDown = false;
				}
				isDown = false;
				spanX = 0;
				spanY = 0;
				sendTouchEvent(new ControlEventPacket(
						ControlEvent.LEFT_MOUSE_UP));
				break;
			case MotionEvent.ACTION_POINTER_DOWN:
				isPointerDown = true;
				mFirstMotionX = event
						.getX(event.getPointerId(pointerCount - 2));
				mFirstMotionY = event
						.getY(event.getPointerId(pointerCount - 2));

				mSecondMotionX = event.getX(event
						.getPointerId(pointerCount - 1));
				mSecondMotionY = event.getY(event
						.getPointerId(pointerCount - 1));
				sendTouchEvent(new ControlEventPacket(
						ControlEvent.MOUSE_MODE_POINTER_DOWN));

				break;
			case MotionEvent.ACTION_POINTER_UP:
				sendTouchEvent(new ControlEventPacket(
						ControlEvent.MOUSE_MODE_POINTER_UP));
				break;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return gestureDetector.onTouchEvent(event);
	}

	GestureDetector.OnGestureListener gestureListener = new GestureDetector.SimpleOnGestureListener() {
		public boolean onDown(MotionEvent e) {
			return false;
		}

		public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX,
				float velocityY) {
			return false;
		}

		public void onLongPress(MotionEvent e) {
			super.onLongPress(e);
		}

		public boolean onScroll(MotionEvent e1, MotionEvent e2,
				float distanceX, float distanceY) {
			return true;
		}

		public void onShowPress(MotionEvent e) {
		}

		public boolean onSingleTapUp(MotionEvent e) {
			if (mTouchState == S1Constant.TOUCH_STATE_MOUSE) {
				sendTouchEvent(new ControlEventPacket(ControlEvent.SINGLE_CLICK));
			}
			return true;
		}

		@Override
		public boolean onDoubleTap(MotionEvent e) {
			return true;
		}
	};

	private void setTouchMode(View v) {
		if (v == this.touchPadView) {
			mTouchState = S1Constant.TOUCH_STATE_MOUSE;
		} else if (v == this.upAndDownScrollView) {
			mTouchState = S1Constant.TOUCH_STATE_UP_AND_DOWN_SCROLL;
		} else if (v == this.leftAndRightScrollView) {
			mTouchState = S1Constant.TOUCH_STATE_LEFT_AND_RIGHT_SCROLL;
		} else {
			mTouchState = S1Constant.TOUCH_STATE_NO_TOUCH;
		}
	}

	private void executeTouchAction(long moveTimeSpan, float deltaX,
			float deltaY) {
		String prefsName = getPackageName() + "_preferences"; // [PACKAGE_NAME]_preferences
		SharedPreferences prefs = getSharedPreferences(prefsName,
				Context.MODE_PRIVATE);
		int mouseSpeed = prefs.getInt("mouseSpeed", 2);
		deltaX = -(deltaX * mouseSpeed);
		deltaY = -(deltaY * mouseSpeed);
		spanX += Math.abs(deltaX);
		spanY += Math.abs(deltaY);

		boolean isXMoved = spanX > mTouchSlop;
		boolean isYMoved = spanY > mTouchSlop;

		if (mTouchState == S1Constant.TOUCH_STATE_LEFT_AND_RIGHT_SCROLL) {
			if (isDown) {
				sendTouchEvent(new ControlEventPacket(
						ControlEvent.LEFT_AND_RIGHT_SCROLL_MODE));
				sendTouchEvent(new ControlEventPacket(
						ControlEvent.LEFT_MOUSE_DOWN));
				isDown = false;
			} else {
				mControlEventPacket.setTouchInfo(ControlEvent.TP_MODE_DRAG,
						deltaX, 0);
				sendTouchEvent(mControlEventPacket);
			}

		} else if (mTouchState == S1Constant.TOUCH_STATE_UP_AND_DOWN_SCROLL) {
			if (isDown) {
				sendTouchEvent(new ControlEventPacket(
						ControlEvent.UP_AND_DOWN_SCROLL_MODE));
				sendTouchEvent(new ControlEventPacket(
						ControlEvent.LEFT_MOUSE_DOWN));
				isDown = false;
			} else {
				sendTouchEvent(new ControlEventPacket(ControlEvent.MOVE_DRAG));
			}

			mControlEventPacket.setTouchInfo(ControlEvent.TP_MODE_DRAG, 0,
					deltaY);

			sendTouchEvent(mControlEventPacket);

		} else if (mTouchState == S1Constant.TOUCH_STATE_NO_TOUCH) {
			// do nothing
		} else if (mTouchState == S1Constant.TOUCH_STATE_MOUSE) {
			if (isTouch) {
				sendTouchEvent(new ControlEventPacket(ControlEvent.MOUSE_MODE));
				isTouch = false;
			}
			boolean isOnlyMoveMouseIcon = true;

			if (moveTimeSpan < 300) {
				if (isXMoved || isYMoved) {
					isBeginScroll = true;
					isDown = false;
				}
			} else {
				if (!isBeginScroll) {
					if (!isPointerDown) {
						if (isDown) {
							mUtils.Vibrate(25);

							sendTouchEvent(new ControlEventPacket(
									ControlEvent.LEFT_MOUSE_DOWN));
							isDown = false;
						}
					}
					isOnlyMoveMouseIcon = false;
				}
			}

			if (isOnlyMoveMouseIcon) {
				mControlEventPacket.setTouchInfo(
						ControlEvent.ONLY_MOVE_MOUSE_ICON, deltaX, deltaY);
				sendTouchEvent(mControlEventPacket);
			} else {
				mControlEventPacket.setTouchInfo(ControlEvent.TP_MODE_DRAG,
						deltaX, deltaY);
				sendTouchEvent(mControlEventPacket);
			}
		}
	}

	public void OnClickTopLeft(View v) {

	}

	public void OnClickTopRight(View v) {
		Intent intent = new Intent(this, ControlTouchpad.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
			finish();
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call Main failed", ex);
		}
	}

	@Override
	public boolean dispatchKeyEvent(KeyEvent event) {
		if (event.getAction() != KeyEvent.ACTION_UP) {// 不响应按键抬起时的动作
			if (SHOWKEYBOARD) {
				if (event.getKeyCode() == KeyEvent.KEYCODE_UNKNOWN) {
					ControlEventPacket controlEventPacket = new ControlEventPacket(
							ControlEvent.SEND_INPUT_MSG);
					controlEventPacket.setInputMessage(event.getCharacters());
					sendTouchEvent(controlEventPacket);
					// } else if (event.getKeyCode() == KeyEvent.KEYCODE_ENTER){
					// sendTouchEvent(new
					// ControlEventPacket(ControlEvent.SINGLE_CLICK));
				} else
					sendKeyCode(event.getKeyCode());
				return true;
			}
			if (event.getKeyCode() == KeyEvent.KEYCODE_BACK
					&& event.getRepeatCount() == 0) {
				sendKeyCode(KeyEvent.KEYCODE_BACK);
				finish();

				return true;
			}
		}
		return super.dispatchKeyEvent(event);
	}

	@Override
	protected void onDestroy() {
		if (receiverServerThread != null) {
			receiverServerThread.interrupt();
			receiverServerThread = null;
		}
		super.onDestroy();
	}

	@SuppressWarnings("deprecation")
	private void setScreenSize() {
		WindowManager windowManager = getWindowManager();
		Display display = windowManager.getDefaultDisplay();
		screenWidth = display.getWidth();
		screenHeight = display.getHeight();

		if (screenWidth == 600 && screenHeight == 976) {

			setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
			isSetRequestedOrientation = true;
		}

		// System.out.println("setScreenSize()->screenWidth:" + screenWidth +
		// " screenHeight:" + screenHeight);
	}

	private void setLayoutSize() {
		// System.out.println("setLayoutSize():" + screenWidth + ":" +
		// screenHeight);

		if (screenWidth == 480 && screenHeight == 800) {
			toolsBarHeight = 80;
		} else if (screenWidth == 320 && screenHeight == 480) {
			toolsBarHeight = 53;
		} else if (screenWidth == 1024 && screenHeight == 552) {
			toolsBarHeight = 53;
		}

		screenHeight = screenHeight - toolsBarHeight;
		setScaleXY(screenWidth, screenHeight);
	}

	private boolean isAlreadyInList(ArrayList<SystemInfo> serverList,
			String wifiIPAddress) {
		boolean isExists = false;
		int listSize = serverList.size();
		for (int i = 0; i < listSize; i++) {
			if (serverList.get(i).getServerWifiAddress().equals(wifiIPAddress)) {
				isExists = true;
				break;
			}
		}
		return isExists;
	}

	private void sendMessage(int info) {
		Message message = Message.obtain();
		message.what = info;
		mLoadingHandler.sendMessage(message);
	}

	@Override
	protected void onResume() {
		// TODO Auto-generated method stub
		ControlGSensor mControlGSensor = new ControlGSensor(getRemote());
		mControlGSensor.mSensorMode = this.getResources().getConfiguration().orientation;
		// ControlGSensor.mSensorMode =
		// this.getResources().getConfiguration().orientation;
		super.onResume();
	}

	private void checkSocketConnect() {
		if (inputServerIP == null || "".equals(inputServerIP)) {
			ControlMouse.inputServerIP = super.getRemoteServerAddress();
		}
		startAccessServerThread(S1Constant.ACCESS_SERVER_TYPE_CHECK_CONNECT);
	}

	// @Override
	// public void onCheckedChanged(CompoundButton buttonView, boolean
	// isChecked) {
	// if (buttonView == keyboardButton) {
	//
	// if (isChecked) {
	// setIputMessageVisibility(true);
	// } else {
	// setIputMessageVisibility(false);
	// }
	// }
	// }

	private void setScaleXY(float touchAreaWidth, float touchAreaHeight) {
		scaleX = (float) serverScreenWidth / touchAreaWidth;
		scaleY = (float) serverScreenHeight / touchAreaHeight;
		System.out.println("scaleXY:" + scaleX + ":" + scaleY);
	}

	private void ConnectionServerAP() {
		WifiConnectManager wifiAdmin = new WifiConnectManager(this);
		wifiAdmin.openWifi();
		wifiAdmin.addNetwork(wifiAdmin.CreateWifiInfo("Android", "12345678",
				S1Constant.WIFI_CONNECT_WIFICIPHER_WPA));
	}

	// @Override
	// public void onClick(View view) {
	// if (view == sendMessageButton) {
	// ControlEventPacket controlEventPacket = new
	// ControlEventPacket(ControlEvent.SEND_INPUT_MSG);
	// controlEventPacket.setInputMessage(this.inputMessage.getText().toString());
	// sendTouchEvent(controlEventPacket);
	// // mRemote.sendInputMessage(controlEventPacket);
	// this.inputMessage.setText("");
	// // System.out.println("Touchpad-> onClick()--sendMessageButton");
	// } else if (view == delMessageButton) {
	// // System.out.println("delMessageButton");
	// sendTouchEvent(new ControlEventPacket(ControlEvent.DEL_INPUT_MSG));
	// } else if (view == touchpadButton) {
	// startActivity(new Intent(this, TouchpadMode.class));
	// } else if (view == toolHomeButton) {
	// sendTouchEvent(new ControlEventPacket(ControlEvent.SEND_KEY_HOME));
	// } else if (view == toolBackButton) {
	// sendTouchEvent(new ControlEventPacket(ControlEvent.SEND_KEY_BACK));
	// } else if (view == toolMenuButton) {
	// sendTouchEvent(new ControlEventPacket(ControlEvent.SEND_KEY_MENU));
	// } else if (view == toolSettingsButton) {
	// // Intent startSettings = new Intent(this, SettingListActivity.class);
	// // startSettings.putExtra(S1Constant.INTENT_EXTRA_CONFIGURATION,
	// this.getResources().getConfiguration().orientation);
	// // startActivity(startSettings);
	// } else if (view == toolRecentButton) {
	// sendTouchEvent(new ControlEventPacket(ControlEvent.SEND_KEY_TASK));
	// } else if (view == toolConnect) {
	// ConnectionServerAP();
	// }
	// }
	public void OnClickB1(View v) {
		sendKeyCode(KeyEvent.KEYCODE_HOME);
	}

	public void OnClickB2(View v) {
		if (!SHOWKEYBOARD)
			showSoftKeyboard();
		else
			hideSoftKeyboard(v);
	}

	public void OnClickB3(View v) {
		Intent intent = new Intent(this, ControlTouchpad.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
			finish();
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call ControlTouchpad failed", ex);
		}
	}

	public void OnClickB4(View v) {
		sendKeyCode(KeyEvent.KEYCODE_MENU);
		// if (isChecked) {
		// isChecked = false;
		// setIputMessageVisibility(true);
		// } else {
		// isChecked = true;
		// setIputMessageVisibility(false);
		// }
	}

	public void OnClickB5(View v) {
		sendKeyCode(KeyEvent.KEYCODE_BACK);
	}

	public void OnClickBSDel(View v) {
		sendTouchEvent(new ControlEventPacket(ControlEvent.DEL_INPUT_MSG));
	}

	public void OnClickBSSend(View v) {
	}

	public void showSoftKeyboard() {
		SHOWKEYBOARD = true;
		InputMethodManager m = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		m.toggleSoftInput(0, InputMethodManager.HIDE_NOT_ALWAYS);
	}

	public void hideSoftKeyboard(View view) {
		SHOWKEYBOARD = false;
		InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
	}

	@Override
	void ConnectOK(String name) {
		// TODO Auto-generated method stub

	}

	@Override
	void ConnectFailed() {
		// TODO Auto-generated method stub

	}

}
