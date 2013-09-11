package com.joyplus.joylink;

import android.app.Activity;
import android.graphics.Rect;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;

import com.androidquery.AQuery;
import com.umeng.analytics.MobclickAgent;

public class SelectDevice extends Activity  {
	private String TAG = "SelectDevice";
	private App app;
	private AQuery aq;


	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);  
		setContentView(R.layout.select_devices);
		
		app = (App) getApplication();
		aq = new AQuery(this);

	}
	public void OnClickBox(View v) {
			//DLNA add here
		if(aq.id(R.id.checkBox1).getCheckBox().isChecked())
			app.SaveServiceData("PLAYWITH", "box");
		setResult(101);
		finish();
	}
	
	@Override
	public boolean dispatchTouchEvent(MotionEvent ev) {
	    Rect dialogBounds = new Rect();
	    getWindow().getDecorView().getHitRect(dialogBounds);

	    if (!dialogBounds.contains((int) ev.getX(), (int) ev.getY())) {
	        // Tapped outside so we finish the activity
	        this.finish();
	    }
	    return super.dispatchTouchEvent(ev);
	}
	public void OnClickDevice(View v) {
		if(aq.id(R.id.checkBox1).getCheckBox().isChecked())
			app.SaveServiceData("PLAYWITH", "device");
		setResult(102);
		finish();
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
	protected void onStart() {
		super.onStart();
	}

}
