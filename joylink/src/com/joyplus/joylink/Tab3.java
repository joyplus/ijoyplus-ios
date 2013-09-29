package com.joyplus.joylink;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

import com.androidquery.AQuery;
import com.umeng.analytics.MobclickAgent;

public class Tab3 extends Activity {
	private String TAG = "Tab3";
	private App app;
	private AQuery aq;


	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.tab3);
		app = (App) getApplication();
		aq = new AQuery(this);

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
}
