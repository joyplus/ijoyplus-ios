package com.joyplus.joylink;

import java.io.File;
import java.util.ArrayList;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.util.Log;
import android.view.Gravity;
import android.widget.Toast;

import com.androidquery.callback.BitmapAjaxCallback;
import com.androidquery.util.AQUtility;
import com.dlcs.dlna.Mrcp;
import com.dlcs.dlna.Stack.MediaRenderer;
import com.joyplus.joylink.Adapters.Tab1_Music_ListData;
import com.joyplus.joylink.weibo.net.Weibo;
import com.joyplus.joylink.weibo.net.WeiboDialogListener;
import com.wind.s1mobile.common.AppDataList;
import com.wind.s1mobile.receiver.TcpServiceThread;
import com.wind.s1mobile.send.Remote;

public class App extends Application {
	private final String TAG = "App";

	private static App instance;
	private Weibo Weibo; // 用于weibodiallog2中
	private String url = ""; // 用于weibodiallog2中
	private WeiboDialogListener WeiboDialogListener;// weibo监听器，用于weibodiallog2中
	private Remote mRemote;
	private TcpServiceThread mTcpServiceThread;
	public DataSaved dataSaved;
	// dlna
	private Mrcp mMrcp = null;
	private MediaRenderer mMediaRenderer = null;
	private ArrayList<MediaRenderer> mDmrCache = null;
	private AppDataList OtherAppData = null;

	private ArrayList<Tab1_Music_ListData> musicDataPage2 = null;
	private ArrayList<Tab1_Music_ListData> musicDataPage1 = null;

	private String packegeName = null;
	
	private String currentUrl = null;

	public String getCurrentUrl() {
		return currentUrl;
	}

	public void setCurrentUrl(String currentUrl) {
		this.currentUrl = currentUrl;
	}

	public String getMyPackegeName() {
		return packegeName;
	}

	public void setMyPackegeName(String packegeName) {
		this.packegeName = packegeName;
	}

	public ArrayList<Tab1_Music_ListData> getMusicDataPage1() {
		return musicDataPage1;
	}

	public void setMusicDataPage1(ArrayList<Tab1_Music_ListData> musicData) {
		this.musicDataPage1 = musicData;
	}

	public ArrayList<Tab1_Music_ListData> getMusicDataPage2() {
		return musicDataPage2;
	}

	public void setMusicDataPage2(ArrayList<Tab1_Music_ListData> musicData) {
		this.musicDataPage2 = musicData;
	}

	public Remote getmRemote() {
		return mRemote;
	}

	public void setmRemote(Remote mRemote) {
		this.mRemote = mRemote;
	}

	public TcpServiceThread getmTcpServiceThread() {
		return mTcpServiceThread;
	}

	public void setmTcpServiceThread(TcpServiceThread mTcpServiceThread) {
		this.mTcpServiceThread = mTcpServiceThread;
	}

	public AppDataList getOtherAppData() {
		return OtherAppData;
	}

	public void setOtherAppData(AppDataList otherAppData) {
		OtherAppData = otherAppData;
	}

	public DataSaved getDataSaved() {
		return dataSaved;
	}

	public void setDataSaved(DataSaved dataSaved) {
		this.dataSaved = dataSaved;
	}

	public ArrayList<MediaRenderer> getmDmrCache() {
		return mDmrCache;
	}

	public void setmDmrCache(ArrayList<MediaRenderer> mDmrCache) {
		this.mDmrCache = mDmrCache;
	}

	public MediaRenderer getmMediaRenderer() {
		return mMediaRenderer;
	}

	public void setmMediaRenderer(MediaRenderer mMediaRenderer) {
		this.mMediaRenderer = mMediaRenderer;
	}

	public Mrcp getmMrcp() {
		return mMrcp;
	}

	public void setmMrcp(Mrcp mMrcp) {
		this.mMrcp = mMrcp;
	}

	@Override
	public void onCreate() {

		super.onCreate();
		File cacheDir = new File(Constant.PATH);
		AQUtility.setCacheDir(cacheDir);
		instance = this;

	}

	/**
	 * Called when the overall system is running low on memory
	 */
	@Override
	public void onLowMemory() {
		super.onLowMemory();
		BitmapAjaxCallback.clearCache();
		Log.w(TAG, "System is running low on memory");

	}

	/**
	 * @return the main context of the App
	 */
	public static Context getAppContext() {
		return instance;
	}

	/**
	 * @return the main resources from the App
	 */
	public static Resources getAppResources() {
		return instance.getResources();
	}

	public void setWeibo(Weibo Weibo) {
		this.Weibo = Weibo;
	}

	public Weibo getWeibo() {
		return Weibo;
	}

	public void seturl(String url) {
		this.url = url;
	}

	public String geturl() {
		return url;
	}

	public WeiboDialogListener getWeiboDialogListener() {
		return WeiboDialogListener;
	}

	public void setWeiboDialogListener(WeiboDialogListener WeiboDialogListener) {
		this.WeiboDialogListener = WeiboDialogListener;
	}

	public void SaveServiceData(String where, String Data) {
		SharedPreferences.Editor sharedatab = getSharedPreferences(
				"ServiceData", 0).edit();
		sharedatab.putString(where, Data);
		sharedatab.commit();
	}

	public void DeleteServiceData(String where) {
		SharedPreferences.Editor sharedatab = getSharedPreferences(
				"ServiceData", 0).edit();
		sharedatab.remove(where);
		sharedatab.commit();
	}

	public String GetServiceData(String where) {
		SharedPreferences sharedata = getSharedPreferences("ServiceData", 0);
		return sharedata.getString(where, null);
	}

	public void MyToast(Context context, CharSequence text) {
		try {
			Toast m_toast = Toast.makeText(context, text, Toast.LENGTH_SHORT);
			m_toast.setGravity(Gravity.CENTER, m_toast.getXOffset() / 2,
					m_toast.getYOffset() / 2);
			m_toast.show();
		} catch (Exception e) {
			Log.e("APP", "Failed:", e);
		}
	}

}
