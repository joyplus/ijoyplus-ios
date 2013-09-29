package com.joyplus.joylink.Dlna;

import java.lang.ref.WeakReference;
import java.util.ArrayList;

import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;
import android.util.Log;

import com.dlcs.dlna.IMrcpListener;
import com.dlcs.dlna.Mrcp;
import com.dlcs.dlna.Stack;
import com.dlcs.dlna.Stack.InitParam;
import com.dlcs.dlna.Stack.MediaRenderer;
import com.dlcs.dlna.Util;
import com.dlcs.dlna.Util.MediaInfo;

//30s
public class DlnaSelectDevice extends Service implements IMrcpListener {
	private String TAG = "DlnaSelectDevice";
	private MyBinder mBinder = new MyBinder();
	private WeakReference<ServiceClient> mClient;

	private ArrayList<MediaRenderer> mDmrCache = new ArrayList<MediaRenderer>();
	private Mrcp mMrcp = null;
	private int CURRENTDEVICE = 0;

	private boolean mIsControllingDmr = false;
	// private DLNAMain mDLNA= null;

	static {
		try {
			System.loadLibrary("dlcs_dlna");
		} catch (Exception e) {
			System.out.println(e);
			throw new IllegalStateException();
		}
	}

	@Override
	public void onMediaRendererAdded(MediaRenderer mediaRenderer/**
	 * <[in] added
	 * render data
	 */
	) {
		Log.d(TAG, "DMR Added:" + mediaRenderer.friendlyName);

		if (mDmrCache == null)
			mDmrCache = new ArrayList<MediaRenderer>();
		if (mDmrCache.size() == 0) {
			MediaRenderer dmr = new MediaRenderer();
			dmr.friendlyName = mediaRenderer.friendlyName;
			dmr.uuid = mediaRenderer.uuid;
			/* TODO: Copy other members of MediaRenderer here */
			mDmrCache.add(dmr);
			if (mClient != null)
				mClient.get().onDmrChanged(mDmrCache);

			int ret = mMrcp.GetProtocolInfo(mediaRenderer.uuid, null);
		} else {
			// 不要重复添加已知的设备
			for (int i = 0; i < mDmrCache.size(); i++) {
				if (mediaRenderer.uuid == mDmrCache.get(i).uuid) {
					// need update
					mDmrCache.remove(i);
				}
			}
			MediaRenderer dmr = new MediaRenderer();
			dmr.friendlyName = mediaRenderer.friendlyName;
			dmr.uuid = mediaRenderer.uuid;
			/* TODO: Copy other members of MediaRenderer here */
			mDmrCache.add(0, dmr);
			if (mClient != null)
				mClient.get().onDmrChanged(mDmrCache);

			int ret = mMrcp.GetProtocolInfo(mediaRenderer.uuid, null);
		}

	}

	@Override
	public void onMediaRendererRemoved(String uuid) {
		Log.d(TAG, "DMR Removed: uuid: " + uuid);
		for (int i = 0; i < mDmrCache.size(); i++) {
			MediaRenderer mr = mDmrCache.get(i);
			if (mr.uuid == uuid) {

				Log.d(TAG, "Remove DMR from cache:");
				Log.d(TAG, "uuid: " + mr.uuid);
				Log.d(TAG, "friendlyName: " + mr.friendlyName);
				mDmrCache.remove(i);
				if (mClient != null)
					mClient.get().onDmrChanged(mDmrCache);
				break;
			}
		}
	}

	@Override
	public void onGetCurrentTransportActions(String uuid/**
	 * <[in] current render
	 * uuid
	 */
	, int ticket, int errorCode/** <[in] action result errorCode */
	, String allowedActions/** <[in] allowed actions */
	) {
		if (errorCode == 0) {
			Log.d(TAG, "GetCurrentTransportActions Success");
			Log.d(TAG, "Allowed actions are " + allowedActions);
			if (mClient != null)
				mClient.get().onAllowedActionsUpdate(allowedActions);
		} else {
			Log.e(TAG, "onGetCurrentTransportActions Error, error code is "
					+ errorCode);
		}
	}

	@Override
	public void onSetAVTransportUri(String uuid/** <[in] current render uuid */
	, int ticket, int errorCode/** <[in] action result errorCode */
	) {
		if (errorCode == 0) {
			Log.d(TAG, "SetAVTransportUri Success");
		} else {
			Log.e(TAG, "SetAVTransportUri Error, error code is " + errorCode);
		}
		if (mClient != null)
			mClient.get().onActionResult("SetAVTransportUri", errorCode);
	}

	@Override
	public void onMediaPlay(String uuid/** <[in] current render uuid */
	, int ticket, int errorCode/** <[in] action result errorCode */
	) {
		if (errorCode == 0) {
			Log.d(TAG, "Play Success");
		} else {
			Log.e(TAG, "Play Error, error code is " + errorCode);
		}
		if (mClient != null)
			mClient.get().onActionResult("Play", errorCode);
	}

	@Override
	public void onMediaPause(String uuid/** <[in] current render uuid */
	, int ticket, int errorCode/** <[in] action result errorCode */
	) {
		if (errorCode == 0) {
			Log.d(TAG, "Pause Success");
		} else {
			Log.e(TAG, "Pause Error, error code is " + errorCode);
		}
		if (mClient != null)
			mClient.get().onActionResult("Pause", errorCode);
	}

	@Override
	public void onMediaStop(String uuid/** <[in] current render uuid */
	, int ticket, int errorCode/** <[in] action result errorCode */
	) {
		if (errorCode == 0) {
			Log.d(TAG, "Stop Success");
		} else {
			Log.e(TAG, "Stop Error, error code is " + errorCode);
		}
		if (mClient != null)
			mClient.get().onActionResult("Stop", errorCode);
	}

	@Override
	public void onMediaSeek(String uuid/** <[in] current render uuid */
	, int ticket, int errorCode/** <[in] action result errorCode */
	) {
		if (errorCode == 0) {
			Log.d(TAG, "Seek Success");
		} else {
			Log.e(TAG, "Seek Error, error code is " + errorCode);
		}
		if (mClient != null)
			mClient.get().onActionResult("Seek", errorCode);
	}

	@Override
	public void onGetPositionInfo(String uuid/** <[in] current render uuid */
	, int ticket, int errorCode/** <[in] action result errorCode */
	, ResultOnGetPositionInfo result/** <[in] get info data */
	) {
		if (errorCode == 0) {
			Log.d(TAG, "GetPositionInfo Success, Current time position is "
					+ result.relCount + ", Duration is " + result.trackDuration);
			if (mClient != null)
				mClient.get().onPostionInfoUpdate(
						Util.Time2Second(result.relTime),
						Util.Time2Second(result.trackDuration));
		} else {
			Log.e(TAG, "GetPositionInfo Error, error code is " + errorCode);
		}
	}

	@Override
	public void onGetMediaInfo(String uuid/** <[in] current render uuid */
	, int ticket, int errorCode/** <[in] action result errorCode */
	, ResultOnGetMediaInfo result/** <[in] get info data */
	)

	{
		if (errorCode == 0) {
			Log.d(TAG, "GetMediaInfo Success");
			Log.d(TAG, "MediaInfo currentUri is " + result.currentUri);
			Log.d(TAG, "MediaInfo metadata is " + result.currentUriMetadata);
			Log.d(TAG, "MediaInfo duration is " + result.mediaDuration);
			MediaInfo media = Util.DecodeMetadata(result.currentUriMetadata,
					result.currentUri);
			if (media != null && mClient != null) {
				mClient.get().onMediaInfoUpdate(media.title, media.mimeType);
			} else {
				Log.e(TAG, "onGetMediaInfo decode metadata failed");
			}
		} else {
			Log.e(TAG, "GetMediaInfo Error, error code is " + errorCode);
		}
	}

	@Override
	public void onGetTransportInfo(String uuid/** <[in] current render uuid */
	, int ticket, int errorCode/** <[in] action result errorCode */
	, ResultOnGetTransportInfo result/** <[in] get info data */
	) {
		if (errorCode == 0) {
			Log.d(TAG, "GetTransportInfo Success");
			Log.d(TAG, "TransportInfo playback state is "
					+ result.currentTransportState);
			Log.d(TAG, "TransportInfo dmr status is "
					+ result.currentTransportStatus);
			Log.d(TAG, "TransportInfo current play speed is "
					+ result.currentSpeed);
			if (mClient != null)
				mClient.get().onPlaybackStateUpdate(
						result.currentTransportState);
		} else {
			Log.e(TAG, "GetTransportInfo Error, error code is " + errorCode);
		}
	}

	@Override
	public void onSetVolume(String uuid/** <[in] current render uuid */
	, int ticket, int errorCode/** <[in] action result errorCode */
	) {
		if (errorCode == 0) {
			Log.d(TAG, "SetVolume Success");
		} else {
			Log.e(TAG, "SetVolume Error, error code is " + errorCode);
		}
		if (mClient != null)
			mClient.get().onActionResult("SetVolume", errorCode);
	}

	@Override
	public void onGetVolume(String uuid/** <[in] current render uuid */
	, int ticket, int errorCode/** <[in] action result errorCode */
	, int currentVolume/** <[in] current volume data */
	) {
		if (errorCode == 0) {
			Log.d(TAG, "GetVolume Success");
			Log.d(TAG, "Current Volume is " + currentVolume);
			if (mClient != null)
				mClient.get().onVolumeUpdate(currentVolume);
		} else {
			Log.e(TAG, "GetVolume Error, error code is " + errorCode);
		}
	}

	@Override
	public void onSetMute(String uuid/** <[in] current render uuid */
	, int ticket, int errorCode/** <[in] action result errorCode */
	)

	{
		if (errorCode == 0) {
			Log.d(TAG, "SetMute Success");
			if (mClient != null)
				mClient.get().onActionResult("SetMute", errorCode);
		} else {
			Log.e(TAG, "SetMute Error, error code is " + errorCode);
		}
	}

	@Override
	public void onGetMute(String uuid/** <[in] current render uuid */
	, int ticket, int errorCode/** <[in] action result errorCode */
	, boolean currentMute/** <[in] mute data */
	) {
		if (errorCode == 0) {
			Log.d(TAG, "GetMute Success");
			if (currentMute) {
				Log.d(TAG, "Current Mute state is on");
			} else {
				Log.d(TAG, "Current Mute state is off");
			}
			if (mClient != null)
				mClient.get().onMuteUpdate(currentMute);
		} else {
			Log.e(TAG, "GetMute Error, error code is " + errorCode);
		}
	}

	@Override
	public void onGetProtocolInfo(String uuid/** <[in] current render uuid */
	, int ticket, int errorCode/** <[in] action result errorCode */
	, ResultOnGetProtocolInfo result/** <[in] get info data */
	) {
		// if (errorCode == 0) {
		// Log.d(TAG, "GetProtocolInfo Success");
		// int size = result.sinkValues.length;
		// if (size > 0) {
		// Log.d(TAG, "Sink protocolInfo list:");
		// for (int i = 0; i < size; i++) {
		// Log.d(TAG, result.sinkValues[i]);
		// }
		// } else {
		// Log.d(TAG, "Sink protocolInfo list is none");
		// }
		// } else {
		// Log.e(TAG, "GetProtocolInfo Error, error code is " + errorCode);
		// }
	}

	@Override
	public IBinder onBind(Intent intent) {
		Log.e(TAG, "start IBinder~~~");

		return mBinder;
	}

	@Override
	public void onCreate() {
		Log.e(TAG, "start onCreate~~~");
		int ret = 0;
		InitParam param = new InitParam();
		param.logLevel = Stack.LOG_LEVEL_ERROR;
		ret = Stack.Initialize(param);

		mMrcp = new Mrcp();
		mDmrCache = new ArrayList<MediaRenderer>();

		ret = mMrcp.Start(true);
		mMrcp.SetListener(this);
		super.onCreate();
	}

	@Override
	public void onDestroy() {
		mMrcp.Stop();
		Stack.Finalize();
		super.onDestroy();
	}

	@Override
	public void onStart(Intent intent, int startId) {
		Log.e(TAG, "start onStart~~~");

		super.onStart(intent, startId);
	}

	@Override
	public boolean onUnbind(Intent intent) {
		Log.e(TAG, "start onUnbind~~~");
		return super.onUnbind(intent);
	}

	// //这里我写了一个获取当前时间的函数，不过没有格式化就先这么着吧
	// public String getSystemTime(){
	//
	// Time t = new Time();
	// t.setToNow();
	// return t.toString();
	// }
	public MediaRenderer getMediaRenderer() {
		MediaRenderer mr = null;
		if (CURRENTDEVICE != 0 && mDmrCache != null && mDmrCache.size() > 0)
			mr = mDmrCache.get(CURRENTDEVICE - 1);
		return mr;
	}

	public void SetCurrentDevice(int i) {
		CURRENTDEVICE = i;
	}

	public ArrayList<MediaRenderer> getDmrCache() {
		return mDmrCache;
	}

	public Mrcp getmMrcp() {
		return mMrcp;
	}

	public class MyBinder extends Binder {
		public DlnaSelectDevice getService() {
			return DlnaSelectDevice.this;
		}
	}

	public interface ServiceClient {
		void onMediaInfoUpdate(String title, String mimeType);

		void onVolumeUpdate(int volume);

		void onDmrChanged(ArrayList<MediaRenderer> dmrCache);

		void onAllowedActionsUpdate(String actions);

		void onActionResult(String actionName, int res);

		void onPostionInfoUpdate(int position, int duration);

		void onPlaybackStateUpdate(String state);

		void onMuteUpdate(boolean muteState);
	}

	public void setServiceClient(ServiceClient client) {
		if (client == null) {
			mClient = null;
			return;
		}

		mClient = new WeakReference<ServiceClient>(client);
	}

}
