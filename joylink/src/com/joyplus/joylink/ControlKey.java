package com.joyplus.joylink;

import android.app.ActionBar;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.umeng.analytics.MobclickAgent;
import com.wind.s1mobile.common.Protocol.ControlEvent;
import com.wind.s1mobile.common.Utils;
import com.wind.s1mobile.common.packet.ControlEventPacket;

public class ControlKey extends BaseActivity implements View.OnClickListener {

	private String TAG = "Tab2_Key";
	private App app;
	private AQuery aq;

	private ImageButton home;
	private ImageButton menu;
	private Button back;
	private ImageButton tp;
	private Button volumeDown;
	private Button volumeMute;
	private Button volumeUp;
	private Button up;
	private Button down;
	private Button left;
	private Button right;
	private Button center;
	private Button rewind;
	private Button playOrpause;
	private Utils mUtils;
	private boolean SHOWKEYBOARD = false;
	private ImageButton mSlidingMenuButton;

	public ControlKey() {
		super("ControlKey");
		// TODO Auto-generated constructor stub
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		if (Constant.DISPLAY.equalsIgnoreCase("800*480"))
			setContentView(R.layout.control_key_480);
		else
			setContentView(R.layout.control_key);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout);
		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		mTextView.setText("遥控器");
		mSlidingMenuButton = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mSlidingMenuButton.setOnClickListener(this);

		app = (App) getApplication();
		aq = new AQuery(this);

		this.home = (ImageButton) findViewById(R.id.Button1);
		this.home.setOnClickListener(this);

		this.menu = (ImageButton) findViewById(R.id.Button3);
		this.menu.setOnClickListener(this);

		this.volumeUp = (Button) findViewById(R.id.Button6);
		this.volumeUp.setOnClickListener(this);

		this.volumeMute = (Button) findViewById(R.id.Button5);
		this.volumeMute.setOnClickListener(this);

		this.volumeDown = (Button) findViewById(R.id.Button4);
		this.volumeDown.setOnClickListener(this);

		this.center = (Button) findViewById(R.id.Button9);
		this.center.setOnClickListener(this);

		this.right = (Button) findViewById(R.id.Button8);
		this.right.setOnClickListener(this);

		this.down = (Button) findViewById(R.id.Button11);
		this.down.setOnClickListener(this);

		this.left = (Button) findViewById(R.id.Button10);
		this.left.setOnClickListener(this);

		this.up = (Button) findViewById(R.id.Button7);
		this.up.setOnClickListener(this);

		// this.keyboard = (Button) findViewById(R.id.Button2);
		// this.keyboard.setOnClickListener(this);
		//
		// this.rewind = (Button) findViewById(R.id.Button13);
		// this.rewind.setOnClickListener(this);
		//
		// this.playOrpause = (Button) findViewById(R.id.Button14);
		// this.playOrpause.setOnClickListener(this);

		this.back = (Button) findViewById(R.id.Button12);
		this.back.setOnClickListener(this);

		this.tp = (ImageButton) findViewById(R.id.Button13);
		this.tp.setOnClickListener(this);
	}

	@Override
	public void onClick(View view) {
		if (view == home) {
			sendKeyCode(KeyEvent.KEYCODE_HOME);
		} else if (view == menu) {
			sendKeyCode(KeyEvent.KEYCODE_MENU);
		} else if (view == back) {
			sendKeyCode(KeyEvent.KEYCODE_BACK);
		} else if (view == volumeDown) {
			sendKeyCode(KeyEvent.KEYCODE_VOLUME_DOWN);
		} else if (view == volumeMute) {
			sendKeyCode(KeyEvent.KEYCODE_VOLUME_MUTE);
		} else if (view == volumeUp) {
			sendKeyCode(KeyEvent.KEYCODE_VOLUME_UP);
		} else if (view == up) {
			sendKeyCode(KeyEvent.KEYCODE_DPAD_UP);
		} else if (view == down) {
			sendKeyCode(KeyEvent.KEYCODE_DPAD_DOWN);
		} else if (view == left) {
			sendKeyCode(KeyEvent.KEYCODE_DPAD_LEFT);
		} else if (view == right) {
			sendKeyCode(KeyEvent.KEYCODE_DPAD_RIGHT);
		} else if (view == center) {
//			sendKeyCode(KeyEvent.KEYCODE_ENTER);
			sendKeyCode(KeyEvent.KEYCODE_DPAD_CENTER);
			// } else if(view == forward){
			// sendTouchEvent(new
			// ControlEventPacket(ControlEvent.SEND_KEY_MEDIA_FAST_FORWARD));
		} else if (view == rewind) {
			sendTouchEvent(new ControlEventPacket(
					ControlEvent.SEND_KEY_MEDIA_REWIND));
		} else if (view == playOrpause) {
			sendKeyCode(85);
		} else if (view == mSlidingMenuButton) {
			getSlidingMenu().toggle();
		} else if (view == tp) {
			OnClickTP();
		}
	}

	@Override
	public boolean dispatchKeyEvent(KeyEvent event) {
		if (event.getAction() != KeyEvent.ACTION_UP) {// 不响应按键抬起时的动作
			if (SHOWKEYBOARD) {
				if (event.getRepeatCount() > 0) {
					return true;
				}
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

	public void OnClickTP() {
		Intent intent = new Intent(this, ControlTouchpad.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
			finish();
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call ControlTouchpad failed", ex);
		}

	}

	public void OnClickSlidingMenu(View v) {
		getSlidingMenu().toggle();
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

	public void OnClickTopLeft(View v) {

	}

	public void OnClickTopRight(View v) {

	}

	@Override
	protected void onDestroy() {
		if (aq != null)
			aq.dismiss();
		super.onDestroy();
	}

	@Override
	public void onResume() {
		super.onResume();
		MobclickAgent.onResume(this);
	}

	@Override
	public void onPause() {
		super.onPause();
		MobclickAgent.onPause(this);
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
