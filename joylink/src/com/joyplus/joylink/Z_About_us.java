package com.joyplus.joylink;

import android.app.ActionBar;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageButton;
import android.widget.TextView;

import com.umeng.analytics.MobclickAgent;

public class Z_About_us extends BaseActivity implements View.OnClickListener {
	private String TAG = "About_us";
	private ImageButton mSlidingMenuButton;
	private ImageButton mSlidingMenuButtonL;

	public Z_About_us() {
		super("");
		// TODO Auto-generated constructor stub
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.z_about_us);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_list);
		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		mTextView.setText("关于我们");
		mSlidingMenuButtonL = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mSlidingMenuButtonL.setOnClickListener(this);
		mSlidingMenuButton = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mSlidingMenuButton.setOnClickListener(this);
	}

	public void OnClickTopLeft(View v) {

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

	@Override
	void ConnectOK(String name) {
		// TODO Auto-generated method stub

	}

	@Override
	void ConnectFailed() {
		// TODO Auto-generated method stub

	}

}