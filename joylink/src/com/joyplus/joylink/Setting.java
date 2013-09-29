package com.joyplus.joylink;

import android.app.ActionBar;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.os.Bundle;
import android.preference.Preference;
import android.preference.PreferenceActivity;
import android.preference.PreferenceScreen;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;

import com.androidquery.AQuery;
import com.umeng.analytics.MobclickAgent;
import com.umeng.fb.NotificationType;
import com.umeng.fb.UMFeedbackService;

public class Setting extends PreferenceActivity implements View.OnClickListener {

	private String TAG = "Setting";
	private App app;
	private AQuery aq;
	private String uid = null;
	private String token = null;
	private String expires_in = null;
	private ImageButton mButtonDlna;
	private ImageButton mButtonBack;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// Load the preferences from an XML resource
		addPreferencesFromResource(R.xml.settings);
		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_detail);

		app = (App) getApplication();
		aq = new AQuery(this);

		aq.id(R.id.actionBarTitle).text("设置");
		mButtonBack = (ImageButton) getActionBar().getCustomView().findViewById(
				R.id.slidingMenuButtonL);
		mButtonBack.setOnClickListener(this);

		mButtonDlna = (ImageButton) getActionBar().getCustomView().findViewById(
				R.id.slidingMenuButton1);
		mButtonDlna.setVisibility(View.GONE);

		UMFeedbackService.enableNewReplyNotification(this,
				NotificationType.AlertDialog);
	}

	@Override
	public boolean onPreferenceTreeClick(PreferenceScreen screen,
			Preference pref) {
		Class<?> cls = null;
		String title = pref.getTitle().toString();
		if (title.equals("意见建议")) {
			UMFeedbackService.setGoBackButtonVisible();
			UMFeedbackService.openUmengFeedbackSDK(this);
			return true;
		} else if (title.equals("调整屏幕")) {
			cls = Z_Screen.class;
		} else if (title.equals("关于我们")) {
			cls = Z_About_us.class;
		} else if (title.equals("常见问题")) {
			cls = Z_Usage.class;
		}else if (title.equals("触控设置")) {
			cls = ControlSetting.class;
		}
		Intent intent = new Intent(this, cls);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e("Setting", "Call cls failed", ex);
		}
		return true;
	}

	@Override
	public void onClick(View view) {
		if (view == mButtonBack) {
			finish();
		}
	}

	public void OnClickSlidingMenu(View v) {
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

	public void OnClickTopLeft(View v) {

	}

	public void OnClickMianZhe(View v) {
		Intent intent = new Intent(this, Z_About_mianzhe.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e("Setting", "Call OnClickMianZhe failed", ex);
		}

	}

	public void OnClickChangeView(View v) {
		Intent intent = new Intent(this, Z_Screen.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e("Setting", "Call Z_Screen failed", ex);
		}

	}

	public void OnClickAbout(View v) {
		Intent intent = new Intent(this, Z_About_us.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e("Setting", "Call Z_About_us failed", ex);
		}

	}

	public void OnClickSug(View v) {
		// Intent intent = new Intent(this, Z_Sug.class);
		// try {
		// startActivity(intent);
		// } catch (ActivityNotFoundException ex) {
		// Log.e("Setting", "Call Z_Sug failed", ex);
		// }
		UMFeedbackService.setGoBackButtonVisible();
		UMFeedbackService.openUmengFeedbackSDK(this);

	}

	public void OnClickUse(View v) {
		Intent intent = new Intent(this, Z_Usage.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e("Setting", "Call Z_Useage failed", ex);
		}

	}

}
