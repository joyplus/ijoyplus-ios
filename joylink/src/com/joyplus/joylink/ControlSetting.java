package com.joyplus.joylink;

import android.app.ActionBar;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.preference.CheckBoxPreference;
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceChangeListener;
import android.preference.Preference.OnPreferenceClickListener;
import android.preference.PreferenceActivity;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageButton;
import android.widget.TextView;

import com.wind.s1mobile.common.S1Constant;

public class ControlSetting extends PreferenceActivity implements
		View.OnClickListener {
	// implements OnSharedPreferenceChangeListener{
	private App app;
	private CheckBoxPreference sensorMode;
	private SeekBarPreference sensorSpeed;
	private ListPreference changeSensor;
	public int mRate = 180000;
	public int mMax = 200000;
	private SensorManager mSensorManager;
	private WakeLock mWakeLock;
	ControlGSensor mControlGSensor;
	private Intent intent;
	private int seneorMode;
	public Display mDisplay;
	private ImageButton mSlidingMenuButton;
	private ImageButton mSlidingMenuButtonL;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		addPreferencesFromResource(R.xml.preference);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_list);
		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		mTextView.setText("设置");
		mSlidingMenuButtonL = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mSlidingMenuButtonL.setOnClickListener(this);
		mSlidingMenuButton = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mSlidingMenuButton.setVisibility(View.INVISIBLE);

		app = (App) getApplicationContext();

		PreferenceManager manager = getPreferenceManager();
		changeSensor = (ListPreference) manager.findPreference("changeSensor");

		mSensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);

		// mControlGSensor = ControlGSensor.getInstance();
		mControlGSensor = new ControlGSensor(app.getmRemote());

		sensorMode = (CheckBoxPreference) findPreference("sensorMode");
		sensorSpeed = (SeekBarPreference) findPreference("sensorSpeed");

		sensorSpeed.setSettings(this);
		intent = this.getIntent();
		seneorMode = intent.getIntExtra(S1Constant.INTENT_EXTRA_CONFIGURATION,
				-1);
		mDisplay = ((WindowManager) getSystemService(WINDOW_SERVICE))
				.getDefaultDisplay();
		mControlGSensor.setConfig(mDisplay, seneorMode);

		System.out.println("intent type :" + seneorMode);
		if (seneorMode == Configuration.ORIENTATION_LANDSCAPE) {
			setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
		} else {
			setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
		}

		sensorMode
				.setOnPreferenceClickListener(new OnPreferenceClickListener() {
					@Override
					public boolean onPreferenceClick(Preference preference) {
						SensorMode();
						return false;
					}
				});

		changeSensor
				.setOnPreferenceChangeListener(new OnPreferenceChangeListener() {

					@Override
					public boolean onPreferenceChange(Preference preference,
							Object newValue) {

						// seneorModeType =
						// Integer.valueOf(newValue.toString());
						mControlGSensor.setmSensorModeType(Integer
								.valueOf(newValue.toString()));
						// System.out.println("setOnPreferenceChangeListener:newValue:"+newValue);
						// if (Integer.valueOf(newValue.toString()) == 0) {
						// System.out.println("aa");
						// ControlGSensor.mSensorMode =
						// Configuration.ORIENTATION_LANDSCAPE;
						// } else {
						// System.out.println("bb");
						// ControlGSensor.mSensorMode =
						// Configuration.ORIENTATION_PORTRAIT;
						// }

						// ControlGSensor.mSensorMode = 3;
						return true;
					}
				});

	}

	@Override
	public void onClick(View view) {
		if (view == mSlidingMenuButtonL)
			finish();
	}

	private void SensorMode() {
		String prefsName = getPackageName() + "_preferences"; // [PACKAGE_NAME]_preferences
		SharedPreferences prefs = getSharedPreferences(prefsName,
				Context.MODE_PRIVATE);
		boolean sensorSettings = prefs.getBoolean("sensorMode", true);
		if (sensorSettings) {
			openSensorMode();
		} else {
			closeSensorMode();
		}
	}

	public void openSensorMode() {
		changeSensor.setEnabled(true);
		sensorSpeed.setEnabled(true);
		Log.i("jinlujiao", "SensorMode==openSensorMode:");
		String prefsName = getPackageName() + "_preferences"; // [PACKAGE_NAME]_preferences
		SharedPreferences prefs = getSharedPreferences(prefsName,
				Context.MODE_PRIVATE);
		int sensorSpeed = prefs.getInt("sensorSpeed", 180000);
		mSensorManager.registerListener(mControlGSensor,
				mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER),
				S1Constant.SENSOR_SPEED_MAX - sensorSpeed);
		PowerManager powerManager = (PowerManager) getBaseContext()
				.getSystemService(Context.POWER_SERVICE);
		mWakeLock = powerManager.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK,
				"SettingListActivity");
		mWakeLock.acquire();
	}

	private void closeSensorMode() {
		changeSensor.setEnabled(false);
		sensorSpeed.setEnabled(false);
		Log.i("jinlujiao", "SensorMode==closeSensorMode:");
		mSensorManager.unregisterListener(mControlGSensor);
		if (mWakeLock != null) {
			mWakeLock.release();
			mWakeLock = null;
		}
	}

	@Override
	protected void onDestroy() {
		// closeSensorMode();
		// mSensorManager.unregisterListener(this);
		super.onDestroy();
	}

	public void onSensorSpeedChange(int rate) {

		mSensorManager.unregisterListener(mControlGSensor);
		Log.i("jinlujiao", "newValue:" + rate);
		mSensorManager.registerListener(mControlGSensor,
				mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER),
				rate);
	}

	@Override
	protected void onResume() {
		Log.i("jinlujiao", "SensorMode==onResume:");
		String prefsName = getPackageName() + "_preferences"; // [PACKAGE_NAME]_preferences
		SharedPreferences prefs = getSharedPreferences(prefsName,
				Context.MODE_PRIVATE);
		boolean sensorSettings = prefs.getBoolean("sensorMode", true);
		if (sensorSettings) {
			openSensorMode();
		} else {
			closeSensorMode();
		}
		// int sensorValue=prefs.getInt("sensor", 0);
		// if(sensorValue==0){
		// sensor.setEntries(0);
		// }else{
		// sensor.setEntries(1);
		// }
		// Log.i("jinlujiao", "newValue"+newValue);
		super.onResume();
	}

}
