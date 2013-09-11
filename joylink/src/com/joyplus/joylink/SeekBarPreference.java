package com.joyplus.joylink;

import android.app.AlertDialog.Builder;
import android.content.Context;
import android.preference.DialogPreference;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.SeekBar;

import com.wind.s1mobile.common.S1Constant;

public class SeekBarPreference extends DialogPreference {

	private Context context;
	private SeekBar sensitivityLevel = null;
	private LinearLayout layout = null;
	private String title;
	public ControlSetting mSettings;

	public SeekBarPreference(Context context, AttributeSet attrs) {

		super(context, attrs);
		this.context = context;
		persistInt(10);
		title = getDialogTitle().toString();
	}

	public void setSettings(ControlSetting settings) {
		mSettings = settings;
	}

	protected void onPrepareDialogBuilder(Builder builder) {
		// Log.i("jinlujiao", "onPrepareDialogBuilder:"+mRate);
		// ��Ӳ���
		System.out.println("onPrepareDialogBuilder()");
		layout = new LinearLayout(context);
		layout.setLayoutParams(new LinearLayout.LayoutParams(
				LinearLayout.LayoutParams.FILL_PARENT,
				LinearLayout.LayoutParams.WRAP_CONTENT)); // ��������
		layout.setMinimumWidth(400); // ���ֵ���С���
		layout.setPadding(20, 20, 20, 20); // �������ҵ�Padding
		// ���SeekBar
		sensitivityLevel = new SeekBar(context);
		sensitivityLevel.setLayoutParams(new ViewGroup.LayoutParams(
				ViewGroup.LayoutParams.FILL_PARENT,
				ViewGroup.LayoutParams.WRAP_CONTENT)); // SeekBar�Ĳ�������
		// String mode ="@"+String.valueOf(R.string.mouseSpeed);
		String mode = context.getString(R.string.mouseSpeed);
		// if ("Mouse Speed".equals(title)) {
		if (mode.equals(title)) {
			System.out.println("modetitle():"
					+ getPersistedInt(S1Constant.MOUSE_SPEED_DEFAULT));
			sensitivityLevel.setMax(S1Constant.MOUSE_SPEED_MAX); // ���ֵ
			sensitivityLevel
					.setProgress(getPersistedInt(S1Constant.MOUSE_SPEED_DEFAULT)); // ����Ĭ��ֵ
		} else {
			System.out.println("!modetitle():"
					+ getPersistedInt(S1Constant.SENSOR_SPEED_DEFAULT));
			sensitivityLevel.setMax(S1Constant.SENSOR_SPEED_MAX); // ���ֵ

			sensitivityLevel
					.setProgress(getPersistedInt(S1Constant.SENSOR_SPEED_DEFAULT)); // ����Ĭ��ֵ
		}
		System.out.println("getProgress():" + sensitivityLevel.getProgress());
		// Log.i("jinlujiao",
		// "onPrepareDialogBuilde--setSeekBarProgressr:"+mRate);
		layout.addView(sensitivityLevel); // ��SeekBar�ӵ� layout�Ĳ�����
		builder.setView(layout);
	}

	protected void onDialogClosed(boolean positiveResult) {
		if (positiveResult) {
			String mode = context.getString(R.string.mouseSpeed);
			persistInt(sensitivityLevel.getProgress()); // ����SeekBar��ֵ
			if (!mode.equals(title)) {
				// if (!"Mouse Speed".equals(title)) {
				mSettings.onSensorSpeedChange(S1Constant.SENSOR_SPEED_MAX
						- sensitivityLevel.getProgress());
			}
			// Log.i("jinlujiao",
			// "onDialogClosed:"+sensitivityLevel.getProgress());
		}
		super.onDialogClosed(positiveResult);

	}

}
