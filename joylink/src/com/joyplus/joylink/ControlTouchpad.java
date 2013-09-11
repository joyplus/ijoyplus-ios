package com.joyplus.joylink;

import java.util.Timer;
import java.util.TimerTask;

import android.app.ActionBar;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Display;
import android.view.GestureDetector;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.wind.s1mobile.common.Protocol.ControlEvent;
import com.wind.s1mobile.common.S1Constant;
import com.wind.s1mobile.common.Utils;
import com.wind.s1mobile.common.packet.ControlEventPacket;
import com.wind.s1mobile.common.packet.SystemInfo;
import com.wind.s1mobile.receiver.TcpServiceThread;
import com.wind.s1mobile.send.Remote;

public class ControlTouchpad extends Activity implements View.OnTouchListener,
		View.OnClickListener {
	// public ControlTouchpad() {
	// super("ControlTouchpad");
	// // TODO Auto-generated constructor stub
	// }

	private String TAG = "ControlTouchpad";
	private App app;
	View mContentView = null;
	private GestureDetector gestureDetector = null;
	public static Remote mRemote;
	public static Context mContext;
	private float screenWidth;
	private float screenHeight;
	private float scaleX;
	private float scaleY;
	// public static byte[] imageByte;

	// public static Bitmap mShotScreenBitmap;
	private LinearLayout mShotScreenView;
	private LinearLayout mTPModeLayout;

	private float mLastMotionX;
	private float mLastMotionY;
	private ControlEventPacket mControlEventPacket;
	// private Thread mTcpServiceThread;
	private TcpServiceThread mTcpServiceThread;
	private Thread thread;
	private Utils mUtils;
	private float serverScreenWidth = 1280;
	private float serverScreenHeight = 720;
	// private Button mouseButton;
	// private ToggleButton autoShotScreenButton;
	// private Button manualShotScreenButton;
	//
	// private Button settingButton;
	// private Button cleanScreenButton;
	// private Button toolHomeButton;
	// private Button toolBackButton;
	// private Button toolRecentButton;
	// private Button toolMenuButton;
	private Timer sendShotScreenTimer;
	private SendShotScreenTask sendShotScreenTask;
	// private RelativeLayout touchpadToolsArea;
	private int toolsBarHeight = 30 * 2 + 133;
	private int toolsBarWidth = 76 + 127 + 20;
	// private HorizontalScrollView toolsAreaScroll;
	private ControlGSensor mControlGSensor;
	private boolean isChecked;
	private boolean SHOWKEYBOARD = false;
	private ImageButton mSlidingMenuButtonL;
	private ImageButton mTPButton1;
	private ImageButton mTPButton2;
	private ImageButton mTPButton3;

	public Handler mSyncHandler = new Handler() {
		public void handleMessage(android.os.Message msg) {
			int what = msg.what;
			if (what == ControlEvent.SCREEN_SHOT.getId()) {
				// syncServerInfo(msg);
				System.out.println("SYNC_SCREEN_SCALE_INFO:");
				Bitmap mShotScreenBitmap = (Bitmap) Utils
						.Bytes2Bimap((byte[]) msg.obj);
				// bindShotScreen(mShotScreenBitmap);
			}
		};
	};

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_touchpad_mode);
		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_tp);
		mSlidingMenuButtonL = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mSlidingMenuButtonL.setOnClickListener(this);
		mTPButton1 = (ImageButton) getActionBar().getCustomView().findViewById(
				R.id.TPMenuButton1);
		mTPButton1.setOnClickListener(this);
		mTPButton2 = (ImageButton) getActionBar().getCustomView().findViewById(
				R.id.TPMenuButton2);
		mTPButton2.setOnClickListener(this);
		mTPButton3 = (ImageButton) getActionBar().getCustomView().findViewById(
				R.id.TPMenuButton3);
		mTPButton3.setOnClickListener(this);

		app = (App) getApplicationContext();

		mControlGSensor = new ControlGSensor(app.getmRemote());
		// ControlGSensor.mSensorMode =
		// this.getResources().getConfiguration().orientation;
		mControlGSensor.mSensorMode = this.getResources().getConfiguration().orientation;

		mShotScreenView = (LinearLayout) findViewById(R.id.shotScreenView);
		mShotScreenView.setOnTouchListener(this);
		mTPModeLayout = (LinearLayout) findViewById(R.id.tpModeLayout);

		mControlEventPacket = new ControlEventPacket();
		IntentFilter intentFilter = new IntentFilter();
		intentFilter.addAction(S1Constant.ACTION_RECEIVER_SHOTSCREEN);
		registerReceiver(mReceiver, intentFilter);
		// mRemote = MouseMode.mRemote;
		mRemote = app.getmRemote();
		mContext = getBaseContext();
		mUtils = new Utils(mContext);

		isChecked = false;
		setLayoutSize();

	}

	@Override
	public void onClick(View view) {
		if (view == mTPButton1) {
			OnClick7(view);
		} else if (view == mTPButton2) {
			OnClick8(view);
		} else if (view == mTPButton3) {
			OnClick10(view);
		} else if (view == mSlidingMenuButtonL) {
			finish();
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// getMenuInflater().inflate(R.menu.activity_tp_mode_screen, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {

		return true;
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
		}
		return super.dispatchKeyEvent(event);
	}

	private void sendKeyCode(int keycode) {
		SystemInfo systemInfo = new SystemInfo();
		systemInfo.setKeycode(keycode);
		ControlEventPacket packet = new ControlEventPacket(
				ControlEvent.SEND_KEY_CODE);
		packet.setSystemInfo(systemInfo);
		mRemote.queuePacket(packet);
	}

	@Override
	public boolean dispatchTrackballEvent(MotionEvent ev) {
		// TODO Auto-generated method stub
		return super.dispatchTrackballEvent(ev);
	}

	private void sendTouchEvent(ControlEventPacket mouseEventPacket) {
		mRemote.queuePacket(mouseEventPacket);
	}

	public void bindShotScreen(Bitmap bitmap) {
		System.out.println("bingScreenShot()->bitmap:" + bitmap);
		// System.out.println("1");
		if (bitmap != null) {
			System.out.println("2");
			float[] finalSize = Utils.getImageSize(screenWidth, screenHeight,
					bitmap);
			float finalWidth = finalSize[0];
			float finalHeight = finalSize[1];
			setScaleXY(finalWidth, finalHeight);

			if (finalWidth == screenWidth && finalHeight < screenHeight) {
				mTPModeLayout.setGravity(Gravity.CENTER_VERTICAL);
			} else if (finalHeight == screenHeight && finalWidth < screenWidth) {
				mTPModeLayout.setGravity(Gravity.CENTER_HORIZONTAL);
			}
			this.mShotScreenView
					.setLayoutParams(new RelativeLayout.LayoutParams(Math
							.round(finalWidth), Math.round(finalHeight)));
			this.mShotScreenView.setBackgroundDrawable(new BitmapDrawable(
					bitmap));

			findViewById(R.id.textViewJP).setVisibility(View.GONE);
		}
	}

	private BroadcastReceiver mReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			String action = intent.getAction();

			if (action.equals(S1Constant.ACTION_RECEIVER_SHOTSCREEN)) {

				Object object = (Object) intent
						.getSerializableExtra(S1Constant.INTENT_EXTRA_SHOTSCREEN);
				Bitmap mShotScreenBitmap = (Bitmap) Utils
						.Bytes2Bimap((byte[]) object);
				bindShotScreen(mShotScreenBitmap);

			} else {
			}
		}
	};

	@Override
	public boolean onTouch(View v, MotionEvent event) {
		int pointerId = (event.getAction() & MotionEvent.ACTION_POINTER_ID_MASK) >> MotionEvent.ACTION_POINTER_ID_SHIFT;
		// System.out.println("pointerId:" + pointerId);
		int pointerCount = event.getPointerCount();
		try {
			switch (event.getAction() & MotionEvent.ACTION_MASK) {
			case MotionEvent.ACTION_DOWN:
				mLastMotionX = event.getX();
				mLastMotionY = event.getY();
				mControlEventPacket.setTouchInfo(
						ControlEvent.TP_MODE_LEFT_MOUSE_DOWN, event.getX()
								* scaleX, event.getY() * scaleY);
				sendTouchEvent(mControlEventPacket);

				break;
			case MotionEvent.ACTION_MOVE:
				if (pointerCount == 1) {
					float eventX = event.getX();
					float eventY = event.getY();

					float deltaX = mLastMotionX - eventX;
					mLastMotionX = eventX;

					float deltaY = mLastMotionY - eventY;
					mLastMotionY = eventY;

					mControlEventPacket.setTouchInfo(ControlEvent.TP_MODE_DRAG,
							-(deltaX * scaleX), -(deltaY * scaleY));
					sendTouchEvent(mControlEventPacket);
					// System.out.print("pointerCount==1:" + eventX + ":" +
					// eventY);
				} else if (pointerCount > 1) {
					float eventX = event.getX(event
							.getPointerId(pointerCount - 2));
					float eventY = event.getY(event
							.getPointerId(pointerCount - 2));

					float eventSX = event.getX(event
							.getPointerId(pointerCount - 1));
					float eventSY = event.getY(event
							.getPointerId(pointerCount - 1));
					mControlEventPacket.setTouchInfo(
							ControlEvent.TP_MODE_DRAG_RIGHT, eventX * scaleX,
							eventY * scaleY);
					mControlEventPacket.setPointer2X(eventSX * scaleX);
					mControlEventPacket.setPointer2Y(eventSY * scaleY);
					sendTouchEvent(mControlEventPacket);
					// System.out.print("pointerCount==2:"+eventSX+":"+eventSY);
				}
				break;
			case MotionEvent.ACTION_UP:
				mLastMotionX = event.getX(pointerId);
				mLastMotionY = event.getY(pointerId);
				mControlEventPacket.setTouchInfo(
						ControlEvent.TP_MODE_LEFT_MOUSE_UP, mLastMotionX
								* scaleX, mLastMotionY * scaleY);
				sendTouchEvent(mControlEventPacket);
				break;

			case MotionEvent.ACTION_POINTER_DOWN:
				float eventX = event.getX(event.getPointerId(pointerCount - 2));
				float eventY = event.getY(event.getPointerId(pointerCount - 2));

				float eventSX = event
						.getX(event.getPointerId(pointerCount - 1));
				float eventSY = event
						.getY(event.getPointerId(pointerCount - 1));
				mControlEventPacket.setTouchInfo(
						ControlEvent.TP_MODE_RIGHT_MOUSE_DOWN, eventX * scaleX,
						eventY * scaleY);
				mControlEventPacket.setPointer2X(eventSX * scaleX);
				mControlEventPacket.setPointer2Y(eventSY * scaleY);
				sendTouchEvent(mControlEventPacket);
				// System.out.print("pointerCount==2:"+eventSX+":"+eventSY);

				break;
			case MotionEvent.ACTION_POINTER_UP:
				float eventX1 = event
						.getX(event.getPointerId(pointerCount - 2));
				float eventY1 = event
						.getY(event.getPointerId(pointerCount - 2));

				float eventSX1 = event.getX(event
						.getPointerId(pointerCount - 1));
				float eventSY1 = event.getY(event
						.getPointerId(pointerCount - 1));
				mControlEventPacket.setTouchInfo(
						ControlEvent.TP_MODE_RIGHT_MOUSE_UP, eventX1 * scaleX,
						eventY1 * scaleY);
				mControlEventPacket.setPointer2X(eventSX1 * scaleX);
				mControlEventPacket.setPointer2Y(eventSY1 * scaleY);
				sendTouchEvent(mControlEventPacket);
				// System.out.print("pointerCount==2:"+eventSX1+":"+eventSY1);

				break;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return true;
	}

	private void setScaleXY(float touchAreaWidth, float touchAreaHeight) {
		scaleX = (float) serverScreenWidth / touchAreaWidth;
		scaleY = (float) serverScreenHeight / touchAreaHeight;
		// System.out.println("scaleXY:" + scaleX + ":" + scaleY);
	}

	private void setScreenSize() {
		WindowManager windowManager = getWindowManager();
		Display display = windowManager.getDefaultDisplay();
		screenWidth = display.getWidth() - toolsBarWidth;
		// System.out.println("setScreenSize()1" + screenWidth + ":" +
		// screenHeight);
		// if (screenWidth == 1024 && screenHeight == 552) {
		screenHeight = display.getHeight() - toolsBarHeight;
		// } else {
		// screenHeight = display.getHeight();
		// }
		// System.out.println("setScreenSize()->serverScreenWidth:"+serverScreenWidth+"serverScreenHeight:"
		// +serverScreenHeight+ "screenWidth:"+screenWidth + "screenHeight:" +
		// screenHeight);

		setScaleXY(screenWidth, screenHeight);
	}

	@Override
	protected void onResume() {
		mControlGSensor.mSensorMode = this.getResources().getConfiguration().orientation;
		// ControlGSensor.mSensorMode =
		// this.getResources().getConfiguration().orientation;
		super.onResume();
	}

	private void cleanScreen() {
		mShotScreenView.setBackgroundDrawable(null);
	}

	private void sendShotScreen() {

		// System.out.println("sendShotScreen()");
		mTcpServiceThread = app.getmTcpServiceThread();
		if (mTcpServiceThread == null) {
			mTcpServiceThread = new TcpServiceThread(this, mSyncHandler);
			app.setmTcpServiceThread(mTcpServiceThread);
			thread = new Thread(mTcpServiceThread);
			thread.start();
		}

		// setScreenSize(toolsBarHeight);
		ControlEventPacket controlEventPacket = new ControlEventPacket();
		controlEventPacket.setControlEvent(ControlEvent.SCREEN_SHOT);
		SystemInfo systemInfo = new SystemInfo();
		// System.out.println("sendShotScreen() screenWidth:" + screenWidth +
		// " screenHeight:" + screenHeight);
		systemInfo.setScreenWidth(screenWidth);
		systemInfo.setScreenHeight(screenHeight);
		systemInfo.setServerWifiAddress(mUtils.getWiFiIpAddress());
		controlEventPacket.setSystemInfo(systemInfo);

		sendTouchEvent(controlEventPacket);
	}

	private Handler sendShotScreenHandler = new Handler() {
		public void handleMessage(android.os.Message msg) {
			if (msg.what == 1) {
				sendShotScreen();
			}
		};
	};

	class SendShotScreenTask extends TimerTask {
		@Override
		public void run() {
			Message message = new Message();
			message.what = 1;
			sendShotScreenHandler.sendMessage(message);
		}
	}

	// @Override
	// public void onCheckedChanged(CompoundButton buttonView, boolean
	// isChecked) {
	//
	// if (buttonView == autoShotScreenButton) {
	//
	// if (isChecked) {
	// startSendShotScreenTimer();
	//
	// } else {
	// stopSendShotScreenTimer();
	// }
	// }
	// }

	private void startSendShotScreenTimer() {
		sendShotScreenTimer = new Timer();
		if (sendShotScreenTask != null) {
			sendShotScreenTask.cancel();
		}
		sendShotScreenTask = new SendShotScreenTask();
		sendShotScreenTimer.schedule(sendShotScreenTask, 0, 5000);
	}

	private void stopSendShotScreenTimer() {

		// autoShotScreenButton.setChecked(false);
		if (sendShotScreenTimer != null) {
			sendShotScreenTimer.cancel();
		}
	}

	private void setLayoutSize() {
		// LinearLayout mLinearLayout = (LinearLayout)
		// findViewById(R.id.touchpad_tools_area);

		// toolsBarHeight = 25*2 + 47;// mLinearLayout.getMeasuredHeight();
		// mLinearLayout.getMeasuredHeight();
		setScreenSize();
	}

	@Override
	protected void onRestart() {
		// TODO Auto-generated method stub
		System.out.println("onRestart()");
		super.onRestart();
	}

	@Override
	protected void onStart() {
		System.out.println("onStart()");
		super.onStart();
	}

	@Override
	protected void onPause() {
		System.out.println("onPause()");
		stopSendShotScreenTimer();
		super.onPause();
	}

	@Override
	protected void onStop() {
		System.out.println("onStop()");
		stopSendShotScreenTimer();
		super.onStop();
	}

	@Override
	protected void onDestroy() {
		System.out.println("onDestroy()");
		stopSendShotScreenTimer();
		unregisterReceiver(mReceiver);
		if (thread != null) {
			thread.interrupt();
			thread = null;
		}
		super.onDestroy();
	}

	public void OnClick1(View v) {

	}

	// @Override
	// public void onClick(View view) {
	// if (view == mouseButton) {
	// this.finish();
	// } else if (view == manualShotScreenButton) {
	// stopSendShotScreenTimer();
	// sendShotScreen();
	// } else if (view == settingButton) {
	// // Intent startSettings = new Intent(this, SettingListActivity.class);
	// // startSettings.putExtra(S1Constant.INTENT_EXTRA_CONFIGURATION,
	// this.getResources().getConfiguration().orientation);
	// // startActivity(startSettings);
	// } else if (view == cleanScreenButton) {
	// cleanScreen();
	// } else if (view == toolHomeButton) {
	// sendTouchEvent(new ControlEventPacket(ControlEvent.SEND_KEY_HOME));
	// } else if (view == toolBackButton) {
	// sendTouchEvent(new ControlEventPacket(ControlEvent.SEND_KEY_BACK));
	// } else if (view == toolRecentButton) {
	// sendTouchEvent(new ControlEventPacket(ControlEvent.SEND_KEY_TASK));
	// } else if (view == toolMenuButton) {
	// sendTouchEvent(new ControlEventPacket(ControlEvent.SEND_KEY_MENU));
	// }
	// }
	public void OnClick2(View v) {
		sendTouchEvent(new ControlEventPacket(ControlEvent.SEND_KEY_MENU));

	}

	public void OnClick3(View v) {
		sendTouchEvent(new ControlEventPacket(ControlEvent.SEND_KEY_HOME));
	}

	public void OnClick4(View v) {
		sendTouchEvent(new ControlEventPacket(ControlEvent.SEND_KEY_BACK));
	}

	public void OnClick5(View v) {

	}

	public void OnClick6(View v) {
		if (isChecked) {
			isChecked = false;
			startSendShotScreenTimer();

		} else {
			isChecked = true;
			stopSendShotScreenTimer();
		}
	}

	public void OnClick7(View v) {
		findViewById(R.id.textViewJP).setVisibility(View.VISIBLE);

		LinearLayout mLinearLayout = (LinearLayout) findViewById(R.id.shotScreenView);
		setScaleXY(mLinearLayout.getMeasuredWidth(),
				mLinearLayout.getMeasuredHeight());
		stopSendShotScreenTimer();
		sendShotScreen();
	}

	public void OnClick8(View v) {
		cleanScreen();
	}

	public void OnClick9(View v) {
		Intent intent = new Intent(this, ControlMouse.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
			finish();
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call ControlMouse failed", ex);
		}
	}

	public void OnClick10(View v) {
		Intent startSettings = new Intent(this, ControlSetting.class);
		startSettings.putExtra(S1Constant.INTENT_EXTRA_CONFIGURATION, this
				.getResources().getConfiguration().orientation);
		startActivity(startSettings);

	}

	public void OnClickKeyboard(View view) {
		if (!SHOWKEYBOARD)
			showSoftKeyboard();
		else
			hideSoftKeyboard(view);
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

	public class MyLayout extends LinearLayout {

		public MyLayout(Context context) {
			super(context);
			// TODO Auto-generated constructor stub
		}

		@Override
		public void onSizeChanged(int w, int h, int oldw, int oldh) {
			super.onSizeChanged(w, h, oldw, oldh);

		}

	}

}
