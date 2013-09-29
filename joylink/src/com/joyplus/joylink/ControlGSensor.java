package com.joyplus.joylink;

import android.content.res.Configuration;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.view.Display;

import com.wind.s1mobile.common.Protocol.ControlEvent;
import com.wind.s1mobile.common.packet.ControlEventPacket;
import com.wind.s1mobile.common.packet.SensorPacket;
import com.wind.s1mobile.send.Remote;


class ControlGSensor implements SensorEventListener {

	private static ControlGSensor instance;
	private Display mDisplay;
	private Remote mRemote;
	public static int mSensorMode;
	private int mSensorModeType;

	ControlGSensor(Remote mRemote) {

		this.mRemote = mRemote;
	}

//	public static ControlGSensor getInstance() {
//		if (instance == null) {
//			instance = new ControlGSensor();
//		}
//		return instance;
//	}

	@Override
	public void onAccuracyChanged(Sensor sensor, int accuracy) {
		// TODO Auto-generated method stub
	}

	@Override
	public void onSensorChanged(SensorEvent sensorEvent) {
		float mSensorX = 0;
		float mSensorY = 0;
		mSensorX = sensorEvent.values[0];
		mSensorY = sensorEvent.values[1];

		if (mSensorMode == Configuration.ORIENTATION_LANDSCAPE) {
			if (mSensorModeType == 0) {
				sensorEvent.values[0] = -mSensorY;
				sensorEvent.values[1] = mSensorX;
			} else if (mSensorModeType == 1) {
				sensorEvent.values[0] = mSensorX;
				sensorEvent.values[1] = mSensorY;
			}
		} else if (mSensorMode == Configuration.ORIENTATION_PORTRAIT) {
			if (mSensorModeType == 0) {
				sensorEvent.values[0] = mSensorX;
				sensorEvent.values[1] = mSensorY;
			} else if (mSensorModeType == 1) {
				sensorEvent.values[0] = mSensorY;
				sensorEvent.values[1] = -mSensorX;
			}
		}

		SensorPacket sensorPacket = new SensorPacket(sensorEvent.sensor.getType(), sensorEvent.values);
		mRemote.queuePacket(new ControlEventPacket(ControlEvent.SENSOR_TYPE, sensorPacket));
	}

	public void setConfig(Display display, int sensorMode) {
		mDisplay = display;
		mSensorMode = sensorMode;
	}

	public int getmSensorModeType() {
		return mSensorModeType;
	}

	public void setmSensorModeType(int sensorModeType) {
		System.out.println("setmSensorModeType:" + sensorModeType);
		this.mSensorModeType = sensorModeType;
	}

}
