package com.joyplus.joylink;

import android.app.ActionBar;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.SeekBar;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.umeng.analytics.MobclickAgent;
import com.wind.s1mobile.common.Protocol.ControlEvent;
import com.wind.s1mobile.common.S1Constant;
import com.wind.s1mobile.common.ScreenSettingInfo;
import com.wind.s1mobile.common.packet.ControlEventPacket;
import com.wind.s1mobile.receiver.TcpServiceThread;

public class Z_Screen extends BaseActivity implements View.OnClickListener {
	public Z_Screen() {
		super("屏幕调整");
		// TODO Auto-generated constructor stub
	}

	private String TAG = "Z_Screen";
	private App app;
	private AQuery aq;

	private TcpServiceThread mTcpServiceThread;
	private Thread thread;
	private SeekBar mseekBar;

	private CharSequence[] ModeEntryValues = null;
	private Button mGetScale;
	private Button mGetMode;
	private String mIndexScreenSettingInfo = null;
	private ScreenSettingInfo mAllScreenSettingInfo = null;
	private ImageButton mSlidingMenuButton;
	private ImageButton mSlidingMenuButtonL;

	public BroadcastReceiver controlReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {

			String action = intent.getAction();

			if (action.equals(S1Constant.ACTION_RECEIVER_SCREEN_MODE_INFO)) {
				mAllScreenSettingInfo = (ScreenSettingInfo) intent
						.getSerializableExtra(S1Constant.INTENT_BUNDLE_SCREEN_MODE_INFO);
				loadData(mAllScreenSettingInfo);
			}
		}
	};

	public Handler mSyncHandler = new Handler() {
		public void handleMessage(android.os.Message msg) {

			int what = msg.what;
			System.out.println("SYNC_SCREEN_SCALE_INFO->msg:" + what
					+ "ControlEvent.SYNC_SCREEN_SCALE_INFO.getId():"
					+ ControlEvent.SYNC_SCREEN_SCALE_INFO.getId());
			if (what == ControlEvent.SYNC_EDITORINFO.getId()) {
			} else if (what == ControlEvent.SYNC_SERVER_INFO_FOR_SEARCH.getId()
					|| what == ControlEvent.SYNC_SERVER_INFO_FOR_CONNECT
							.getId()) {

			} else if (what == ControlEvent.SYNC_SCREEN_SCALE_INFO.getId()) {

				mAllScreenSettingInfo = (ScreenSettingInfo) msg.obj;
				int max = 100 - mAllScreenSettingInfo.getMinScaleValue();
				System.out.println("SYNC_SCREEN_SCALE_INFO->getProgress():"
						+ mAllScreenSettingInfo.getProgress());
				mseekBar.setProgress(mAllScreenSettingInfo.getProgress());
			} else if (what == ControlEvent.SYNC_SCREEN_MODE_INFO.getId()) {

				mAllScreenSettingInfo = (ScreenSettingInfo) msg.obj;
				int length = mAllScreenSettingInfo.getIfaceValue().length;
				System.out.println("SYNC_MODE_INFO:"
						+ mAllScreenSettingInfo.getIfaceValue()[0] + "length:"
						+ mAllScreenSettingInfo.getIfaceValue().length + "\n"
						+ mAllScreenSettingInfo.getIfaceEntries()[0]);

				// loadData(mAllScreenSettingInfo);
			}
		}

	};

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.z_screen);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_list);
		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		mTextView.setText("屏幕调整");
		mSlidingMenuButtonL = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mSlidingMenuButtonL.setOnClickListener(this);
		mSlidingMenuButton = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mSlidingMenuButton.setOnClickListener(this);

		app = (App) getApplication();

		// 动态注册广播消息
		IntentFilter counterActionFilter = new IntentFilter(
				S1Constant.ACTION_RECEIVER_SCREEN_MODE_INFO);
		registerReceiver(controlReceiver, counterActionFilter);

		mseekBar = (SeekBar) findViewById(R.id.seekBar1);
		mseekBar.setMax(10);
		mseekBar.setProgress(9);
		mseekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {

			@Override
			public void onStopTrackingTouch(SeekBar seekBar) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onStartTrackingTouch(SeekBar seekBar) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onProgressChanged(SeekBar seekBar, int progress,
					boolean fromUser) {
				setScreenScale(progress);
			}
		});

		mTcpServiceThread = app.getmTcpServiceThread();
		RequestScreenModeInfo();
		RequestScreenScaleInfo();

	}

	private void loadData(ScreenSettingInfo mScreenSettingInfo) {
		mIndexScreenSettingInfo = mScreenSettingInfo.getmMainMode_last();

		LinearLayout mList = (LinearLayout) Z_Screen.this
				.findViewById(R.id.listView1);
		// mList.removeAllViews();
		for (int i = 0; i < mScreenSettingInfo.getIfaceValue().length; i++) {
			String[] m_str = mScreenSettingInfo.getIfaceValue()[i].toString()
					.split("-");
			View view1 = getLayoutInflater().inflate(
					R.layout.z_screen_list_item, null);
			LinearLayout.LayoutParams parms1 = new LinearLayout.LayoutParams(
					LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
			aq = new AQuery(view1);
			aq.id(R.id.modelistValue).text(m_str[1]);
			aq.id(R.id.textView1).text(m_str[0]);
			if (mIndexScreenSettingInfo != null
					&& mScreenSettingInfo.getIfaceValue()[i].toString()
							.equalsIgnoreCase(mIndexScreenSettingInfo)) {
				RadioButton radioButton1 = (RadioButton) view1
						.findViewById(R.id.radioButton1);
				radioButton1.toggle();
			}
			aq.id(R.id.radioButton1).getView().setTag(i + "");

			mList.addView(view1, parms1);
			aq.dismiss();

			System.out.println(mScreenSettingInfo.getIfaceValue()[i]);
		}

	};

	@Override
	public void onClick(View view) {
		if (view == mSlidingMenuButton) {
			getSlidingMenu().toggle();
		} else if (view == mSlidingMenuButtonL)
			finish();
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

	public void OnClickHDMI(View v) {
		int index = Integer.parseInt(v.getTag().toString());
		mIndexScreenSettingInfo = mAllScreenSettingInfo.getIfaceValue()[index]
				.toString();
		mAllScreenSettingInfo.setCurrentModeValue(mAllScreenSettingInfo
				.getIfaceValue()[index].toString());
		mAllScreenSettingInfo.setmMainMode_last(mAllScreenSettingInfo
				.getIfaceValue()[index].toString());

		LinearLayout mList = (LinearLayout) findViewById(R.id.listView1);
		mList.removeAllViews();
		loadData(mAllScreenSettingInfo);
		SetScreenMode(index);
	}

	/**
	 * send request to Server to set Scale the Scale value set by
	 * setCurrentModeValue();
	 */

	private void SetScreenMode(int position) {
		// zScreenData m_zScreenData = mData.get(position);
		// mIndexScreenSettingInfo = m_zScreenData.allstr;
		// mAdapter.notifyDataSetChanged();

		//
		if (mAllScreenSettingInfo.getIfaceValue().length > position) {
			ControlEventPacket controlEventPacket = new ControlEventPacket();
			controlEventPacket.setControlEvent(ControlEvent.SET_SCREEN_MODE);
			ScreenSettingInfo ssi = new ScreenSettingInfo();
			CharSequence[] cs = new CharSequence[1];
			cs[0] = mAllScreenSettingInfo.getIfaceValue()[position].toString();
			ssi.setIfaceValue(cs);
			ssi.setCurrentModeValue(mAllScreenSettingInfo.getIfaceValue()[position]
					.toString());
			controlEventPacket.setScreenSettingInfo(ssi);
			sendTouchEvent(controlEventPacket);
		}
	}

	/**
	 * send request to Server to set Scale the Scale value set by
	 * setScaleValue();
	 */

	private void setScreenScale(int progress) {
		mseekBar.setProgress(progress);
		ControlEventPacket controlEventPacket = new ControlEventPacket();
		controlEventPacket.setControlEvent(ControlEvent.SET_SCREEN_SCALE);
		ScreenSettingInfo ssi = new ScreenSettingInfo();
		ssi.setScaleValue(90 + progress);
		ssi.setProgress(progress);
		controlEventPacket.setScreenSettingInfo(ssi);
		sendTouchEvent(controlEventPacket);
	}

	/**
	 * send request to Server to get current Scale
	 */
	private void RequestScreenScaleInfo() {

		if (mTcpServiceThread == null && thread == null) {
			mTcpServiceThread = new TcpServiceThread(this, mSyncHandler);
			app.setmTcpServiceThread(mTcpServiceThread);
			thread = new Thread(mTcpServiceThread);
			thread.start();
		}

		ControlEventPacket controlEventPacket = new ControlEventPacket();
		controlEventPacket.setControlEvent(ControlEvent.SYNC_SCREEN_SCALE_INFO);
		sendTouchEvent(controlEventPacket);
	}

	/**
	 * send request to Server to get ModeList info;
	 */
	private void RequestScreenModeInfo() {
		if (mTcpServiceThread == null && thread == null) {
			mTcpServiceThread = new TcpServiceThread(this, mSyncHandler);
			app.setmTcpServiceThread(mTcpServiceThread);
			thread = new Thread(mTcpServiceThread);
			thread.start();
		}

		System.out.println("RequestScreenModeInfo()");
		ControlEventPacket controlEventPacket = new ControlEventPacket();
		controlEventPacket.setControlEvent(ControlEvent.SYNC_SCREEN_MODE_INFO);
		sendTouchEvent(controlEventPacket);
	}

	@Override
	protected void onDestroy() {
		if (aq != null)
			aq.dismiss();
		unregisterReceiver(controlReceiver);

		if (thread != null) {
			thread.interrupt();
			thread = null;
		}

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
	protected void onStart() {
		super.onStart();
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
