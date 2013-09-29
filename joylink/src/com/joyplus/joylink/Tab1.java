package com.joyplus.joylink;

import java.io.File;

import android.app.ActionBar;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore.Video;
import android.provider.MediaStore.Video.VideoColumns;
import android.util.Log;
import android.view.Display;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageButton;

import com.androidquery.AQuery;
import com.joyplus.joylink.Dlna.DlnaSelectDevice;
import com.joyplus.joylink.Utils.BitmapUtils;
import com.joyplus.joylink.Utils.JoylinkUtils;
import com.umeng.analytics.MobclickAgent;
import com.umeng.update.UmengUpdateAgent;
import com.wind.s1mobile.common.AppInfoData;
import com.wind.s1mobile.common.Protocol.ControlEvent;
import com.wind.s1mobile.common.S1Constant;
import com.wind.s1mobile.common.packet.ControlEventPacket;

public class Tab1 extends BaseActivity implements View.OnClickListener {
	private String TAG = "Tab1";
	public static Object SPLASH_LOCK = new Object();

	private static final Uri mWatchUriVideo = Video.Media.EXTERNAL_CONTENT_URI;
	private App app;
	private AQuery aq;

	private MenuFragment mContent;
	// private SlidingMenu sm;
	private ImageButton mSlidingMenuButton;

	public Tab1() {
		super("悦享家");
		// TODO Auto-generated constructor stub
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setSlidingActionBarEnabled(true);
		WindowManager windowManager = getWindowManager();
		Display display = windowManager.getDefaultDisplay();
		// if (display.getWidth() >= 720 && display.getHeight() >= 1280)
		Constant.DISPLAY = display.getHeight() + "*" + display.getWidth();
		// else
		// Constant.DISPLAY = "800*480";

		if (Constant.DISPLAY.equalsIgnoreCase("800*480"))
			setContentView(R.layout.tab1_480);
		else
			setContentView(R.layout.tab1);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout);
		mSlidingMenuButton = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mSlidingMenuButton.setOnClickListener(this);

		app = (App) getApplication();
		aq = new AQuery(this);
		
		super.FirstRun();
		
		Intent i = new Intent();
		i.setClass(this, DlnaSelectDevice.class);
		startService(i);
		
		UmengUpdateAgent.setUpdateOnlyWifi(false);
		UmengUpdateAgent.setOnDownloadListener(null);
		UmengUpdateAgent.update(this);

	}

	@Override
	public void onClick(View view) {
		if (view == mSlidingMenuButton) {
			getSlidingMenu().toggle();
		}
	}

	public void OnClickSlidingMenu(View v) {
		getSlidingMenu().toggle();
	}

	public void OnClickHome(View v) {
		getSlidingMenu().toggle();
	}

	public void OnClickRemoteMouse(View v) {
		getSlidingMenu().toggle();
		Intent intent = new Intent(this, ControlMouse.class);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call ControlMouse failed", ex);
		}

	}

	public void OnClickRemoteControl(View v) {
		getSlidingMenu().toggle();
		Intent intent = new Intent(this, ControlKey.class);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call Tab2 failed", ex);
		}

	}

	public void OnClickSetting(View v) {
		getSlidingMenu().toggle();
		Intent intent = new Intent(this, Setting.class);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call Setting failed", ex);
		}

	}

	public void OnClickB1(View v) {
		Intent intent = new Intent(this, Tab1_Photo.class);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call Tab1_Photo failed", ex);
		}
	}

	public void OnClickB2(View v) {
		Intent intent = new Intent(this, Tab1_Music.class);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call Tab1_Music failed", ex);
		}
	}

	public void OnClickB3(View v) {
		Intent intent = new Intent(this, Tab1_Video.class);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call Tab1_Video failed", ex);
		}
	}

	public void OnClickB4(View v) {

		if(!isConnected()){
			searchServer();
			return;
		}
		// 悦视频
		ControlEventPacket controlEventPacket = new ControlEventPacket();
		controlEventPacket
				.setControlEvent(ControlEvent.OPEN_LAUNCHER_ITEM_INFO);
		AppInfoData appData = new AppInfoData();

		appData.packegeName = "com.joyplus.tv";
		appData.className = "com.joyplus.tv.Main";

		KillApp(appData.packegeName);

		controlEventPacket.setAppsItemInfo(appData);
		super.sendTouchEvent(controlEventPacket);

		Intent intent = new Intent(this, ControlKey.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call ControlKey failed", ex);
		}
	}

	public void OnClickB5(View v) {
		if(!isConnected()){
			searchServer();
			return;
		}
		// 电视直播
		ControlEventPacket controlEventPacket = new ControlEventPacket();
		controlEventPacket
				.setControlEvent(ControlEvent.OPEN_LAUNCHER_ITEM_INFO);
		AppInfoData appData = new AppInfoData();

		appData.packegeName = "xlcao.sohutv4";
		appData.className = "xlcao.sohutv4.ui.MeleTVMainActivity";

		KillApp(appData.packegeName);

		controlEventPacket.setAppsItemInfo(appData);
		sendTouchEvent(controlEventPacket);

		Intent intent = new Intent(this, ControlKey.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call ControlKey failed", ex);
		}

	}

	public void OnClickB6(View v) {
		if(!isConnected()){
			searchServer();
			return;
		}
		Intent intent = new Intent(this, OtherApp.class);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call OtherApp failed", ex);
		}
	}

	public void OnClickResearch(View v) {
		serverList1.clear();
		super.startAccessServerThread(S1Constant.ACCESS_SERVER_TYPE_SEARCH);
	}

	@Override
	public boolean dispatchKeyEvent(KeyEvent event) {

		if (event.getKeyCode() == KeyEvent.KEYCODE_BACK) {
			if (event.getAction() == KeyEvent.ACTION_DOWN
					&& event.getRepeatCount() == 0) {
				AlertDialog.Builder builder = new AlertDialog.Builder(this);
				builder.setTitle(getResources().getString(R.string.tishi));
				builder.setMessage(
						getResources().getString(R.string.shifoutuichu))
						.setPositiveButton(
								getResources().getString(R.string.queding),
								new DialogInterface.OnClickListener() {
									public void onClick(DialogInterface dialog,
											int which) {
										Quit();
									}
								})
						.setNegativeButton(
								getResources().getString(R.string.quxiao),
								new DialogInterface.OnClickListener() {
									public void onClick(DialogInterface dialog,
											int which) {

									}
								});
				builder.show();
				return true;
			}
		}
		return super.dispatchKeyEvent(event);
	}

	public void Quit() {
		super.Quit();
		finish();
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();

		Intent i = new Intent();
		i.setClass(this, DlnaSelectDevice.class);
		stopService(i);
		if (aq != null)
			aq.dismiss();

		// finish();
		// Intent intent = new Intent(Intent.ACTION_MAIN);
		// intent.addCategory(Intent.CATEGORY_HOME);
		//
		// intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		// this.startActivity(intent);
		System.exit(0);

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

	// Rescan the sdcard after copy the file
	private void rescanSdcard() throws Exception {
		Intent scanIntent = new Intent(
				Intent.ACTION_MEDIA_MOUNTED,
				Uri.parse("file://" + Environment.getExternalStorageDirectory()));
		Log.v(TAG, "start the intent");
		IntentFilter intentFilter = new IntentFilter(
				Intent.ACTION_MEDIA_SCANNER_STARTED);
		intentFilter.addDataScheme("file");
		sendBroadcast(new Intent(
				Intent.ACTION_MEDIA_MOUNTED,
				Uri.parse("file://" + Environment.getExternalStorageDirectory())));
	}

	private void scanningVideo() {
		new Thread() {
			public void run() {
				String[] mediaColumns = new String[] { VideoColumns._ID,
						VideoColumns.DATA, VideoColumns.BUCKET_ID };
				Cursor cursor = getContentResolver().query(mWatchUriVideo,
						mediaColumns, // Which
						// columns
						// to
						// return
						null, // Return all rows
						null, null);
				String OLD_String = null;
				while (cursor != null && cursor.moveToNext()) {
					if (OLD_String == null)
						OLD_String = Integer.toString(cursor.getInt(2)) + "|";

					if (OLD_String.indexOf(Integer.toString(cursor.getInt(2))
							+ "|") == -1) {
						OLD_String = OLD_String
								+ Integer.toString(cursor.getInt(2)) + "|";

						File file = new File(Constant.PATH
								+ JoylinkUtils.getCacheFileName(cursor
										.getString(1)));
						if (!file.exists())
							BitmapUtils.createVideoThumbnailtoSD(cursor
									.getString(1));
					}
				}
			}
		}.start();

		try {
			rescanSdcard();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		synchronized (SPLASH_LOCK) {
			SPLASH_LOCK.notifyAll();
		}
	}

	private void KillApp(String newApkName) {
		// TODO Auto-generated constructor stub
		if (app.getMyPackegeName() != null
				&& app.getMyPackegeName().length() > 0) {

			ControlEventPacket controlEventPacket = new ControlEventPacket();
			controlEventPacket.setControlEvent(ControlEvent.PAUSE_MUSIC);
			
			AppInfoData appData = new AppInfoData();
			appData.packegeName = app.getMyPackegeName();
			
			controlEventPacket.setAppsItemInfo(appData);
			sendTouchEvent(controlEventPacket);
			
			controlEventPacket.setControlEvent(ControlEvent.CLOSE_APK);
			controlEventPacket.setAppsItemInfo(appData);
			sendTouchEvent(controlEventPacket);
			
			
		}
		app.setMyPackegeName(newApkName);

	}

	@Override
	public void ConnectOK(String name) {
		// TODO Auto-generated method stub
		aq.id(R.id.textView1).text(name);
	}

	@Override
	public void ConnectFailed() {
		// TODO Auto-generated method stub
		aq.id(R.id.textView1).text("点击选择设备");
	}

}
