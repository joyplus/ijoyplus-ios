package com.joyplus.joylink.Dlna;

import java.util.ArrayList;

import android.app.ActionBar;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ImageButton;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.SeekBar.OnSeekBarChangeListener;

import com.androidquery.AQuery;
import com.dlcs.dlna.Mrcp;
import com.dlcs.dlna.Stack.MediaRenderer;
import com.dlcs.dlna.Util;
import com.dlcs.dlna.Util.MediaInfo;
import com.joyplus.joylink.App;
import com.joyplus.joylink.Constant;
import com.joyplus.joylink.ControlMouse;
import com.joyplus.joylink.MusicPlay;
import com.joyplus.joylink.R;
import com.joyplus.joylink.Setting;
import com.joyplus.joylink.Adapters.Tab1_Music_ListData;
import com.joyplus.joylink.Dlna.DlnaSelectDevice.ServiceClient;
import com.umeng.analytics.MobclickAgent;

public class DlnaMusicPlay extends Activity implements ServiceClient ,OnClickListener{
	private String TAG = "DlnaMusicPlay";
	private App app;
	private AQuery aq;
	private boolean isPlaying;
	private SeekBar sb;
	private int Duration;
	// private Handler handler = null;

	private MediaPlayer mp = new MediaPlayer();
	// private StackAgent mStackAgent = null;

	private ArrayList<Tab1_Music_ListData> music_array = null;
	private int current_item = 0;
	private int current_mediaRenderer = 0;
	private ArrayList<MediaRenderer> mDmrCache = new ArrayList<MediaRenderer>();
	private MediaRenderer mMediaRenderer = null;
	private Mrcp mMrcp = null;

	private boolean mIsControllingDmr = false;
	private boolean isQuit = false;

	private DlnaServiceConnection mServiceConnection = new DlnaServiceConnection();
	private DlnaSelectDevice mMyService = null;
	private ImageButton mButtonDlna;
	private ImageButton mButtonBack;

	class DlnaServiceConnection implements ServiceConnection {

		public void onServiceConnected(ComponentName name, IBinder service) {
			mMyService = ((DlnaSelectDevice.MyBinder) service).getService();

			mMyService.setServiceClient(DlnaMusicPlay.this);

			Message msg = Message.obtain();
			msg.what = Constant.MSG_DMRCHANGED;
			mHandler.sendMessage(msg);

		}

		public void onServiceDisconnected(ComponentName name) {
			mMyService.setServiceClient(null);
			mMyService = null;

		}
	}

	public BroadcastReceiver volumeReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {

			String action = intent.getAction();

			if (action.equals("android.media.VOLUME_CHANGED_ACTION")) {
				int index = intent.getIntExtra(
						"android.media.EXTRA_VOLUME_STREAM_VALUE", 0);
				if (isPlaying)
					SetVolume(index * 14);
			}
		}
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.dlna_music_play);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_detail);

		app = (App) getApplication();
		aq = new AQuery(this);
		isPlaying = false;
		// handler = new Handler();
		bindService(new Intent(this, DlnaSelectDevice.class),
				mServiceConnection, BIND_AUTO_CREATE);

		Intent intent = getIntent();
		current_item = intent.getIntExtra("CURRENT", 0);
		music_array = intent.getParcelableArrayListExtra("MUSICARRAY");

		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		
//		mTextView.setText(music_array.get(current_item).title);
		mTextView.setText("正在播放");

		
		mButtonBack = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mButtonBack.setOnClickListener(this);

		mButtonDlna = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mButtonDlna.setBackgroundResource(R.drawable.airplay_on);
		mButtonDlna.setOnClickListener(this);

		aq.id(R.id.textView1).text(music_array.get(current_item).title);
		aq.id(R.id.button2).background(R.drawable.music_play_pause);
		sb = (SeekBar) findViewById(R.id.seekBar1);
		sb.setOnSeekBarChangeListener(sbLis);

		IntentFilter counterActionFilter = new IntentFilter(
				"android.media.VOLUME_CHANGED_ACTION");
		registerReceiver(volumeReceiver, counterActionFilter);
		// playMusic();

	}
	@Override
	public void onClick(View view) {
		if (view == mButtonDlna) {
			OnClickTopRight();
		}else if(view == mButtonBack)
			finish();
	}

	public void OnClickTopRight() {
		isQuit = true;
		aq.id(R.id.progressBar1).visible();
		mMrcp.MediaStop(mMediaRenderer.uuid, null);

	}

	public void OnClickNext(View v) {
		nextMusic();

	}

	public void OnClickResume(View v) {
		// if (mp != null) {
		// if (!isPlaying) {
		// mp.start();
		// isPlaying = true;
		// handler.post(updatesb);
		// aq.id(R.id.button2)
		// .background(R.drawable.music_play_pause);
		// } else {
		// mp.pause();
		// isPlaying = false;
		// handler.post(updatesb);
		// aq.id(R.id.button2).background(R.drawable.music_play_play);
		// }
		// }
		if (mMediaRenderer != null) {
			if (!isPlaying) {

				int ret = mMrcp.MediaPlay(mMediaRenderer.uuid, null);
				if (ret == 0) {
					/* To reduce the buffering time, stop monitoring */
					StopMonitoring();
				}
				// aq.id(R.id.button2).background(R.drawable.music_play_pause);

			} else {
				isPlaying = false;

				int ret = mMrcp.MediaPause(mMediaRenderer.uuid, null);
				// mIsControllingDmr = false;

				aq.id(R.id.button2).background(R.drawable.music_play_play);

			}
		}

	}

	public void OnClickPre(View v) {
		preMusic();

	}

	//
	// private void playMusic() {
	// try {
	// isPlaying = true;
	// aq.id(R.id.textView1).text(music_array.get(current_item).title);
	// aq.id(R.id.button2).background(R.drawable.music_play_pause);
	// mp.reset();
	//
	// mp.setDataSource(music_array.get(current_item)._data);
	//
	// mp.prepare();
	//
	// mp.start();
	// Duration = mp.getDuration();
	// aq.id(R.id.textViewTime1).text("00:00");
	// aq.id(R.id.textViewTime2).text(Utils.formatDuration(Duration));
	// sb.setMax(Duration);
	// handler.post(updatesb);
	// // Setup listener so next song starts automatically
	//
	// mp.setOnCompletionListener(new OnCompletionListener() {
	//
	// public void onCompletion(MediaPlayer arg0) {
	//
	// nextMusic();
	//
	// }
	//
	// });
	//
	// } catch (IOException e) {
	//
	// Log.v(getString(R.string.app_name), e.getMessage());
	//
	// }
	// }

	private void nextMusic() {
		// if (mp != null && isPlaying)
		// mp.stop();
		if (++current_item >= music_array.size()) {
			// Last song, just reset currentPosition
			current_item = 0;
		}
		aq.id(R.id.textView1).text(music_array.get(current_item).title);
		// playMusic();
		// if(isPlaying)
		aq.id(R.id.progressBar1).visible();
		mMrcp.MediaStop(mMediaRenderer.uuid, null);

	}

	private void preMusic() {
		// if (mp != null && isPlaying)
		// mp.stop();

		if (--current_item <= 0) {
			// Last song, just reset currentPosition
			current_item = 0;
		}
		aq.id(R.id.textView1).text(music_array.get(current_item).title);
		// if(isPlaying)
		aq.id(R.id.progressBar1).visible();
		mMrcp.MediaStop(mMediaRenderer.uuid, null);
		// playMusic();
		// Play next song
	}

	@Override
	public void onDestroy() {
		if (aq != null)
			aq.dismiss();
		if (mp != null) {
			mp.stop();
			mp.release();
		}
		mMyService.setServiceClient(null);
		mMyService = null;
		unregisterReceiver(volumeReceiver);
		unbindService(mServiceConnection);
		// mMrcp.Stop();
		// Stack.Finalize();
		// if(isPlaying)
		// mStackAgent.MediaStop(mWorkingDmr.uuid, null);
		// StopMonitoring();
		// mIsControllingDmr = false;
		// if(mStackAgent != null){
		// mStackAgent.StopMrcp();
		// mStackAgent.Destroy();
		// }
		// handler.removeCallbacks(updatesb);
		super.onDestroy();
	}

	@Override
	public void onResume() {
		super.onResume();
		MobclickAgent.onResume(this);
	}

	@Override
	public void onPause() {
		StopMonitoring();
		// mIsControllingDmr = false;
		// mMrcp.Stop();
		super.onPause();
		MobclickAgent.onPause(this);
	}

	@Override
	protected void onStart() {
		super.onStart();
	}

	// Runnable updatesb = new Runnable() {
	//
	// @Override
	// public void run() {
	// // TODO Auto-generated method stub
	// int m_p = mp.getCurrentPosition();
	// sb.setProgress(m_p);
	// handler.postDelayed(updatesb, 1000);
	// aq.id(R.id.textViewTime1).text(Utils.formatDuration(m_p));
	// // 每秒钟更新一次
	// }
	//
	// };
	private OnSeekBarChangeListener sbLis = new OnSeekBarChangeListener() {

		@Override
		public void onProgressChanged(SeekBar seekBar, int progress,
				boolean fromUser) {
			// TODO Auto-generated method stub
		}

		@Override
		public void onStartTrackingTouch(SeekBar seekBar) {
			// TODO Auto-generated method stub

		}

		@Override
		public void onStopTrackingTouch(SeekBar seekBar) {
			// TODO Auto-generated method stub
			if (mMediaRenderer != null && mMrcp != null) {
				long position = sb.getProgress();
				String str = "";
				str += Util.Second2Time((int) position);
				mMrcp.MediaSeekTime(mMediaRenderer.uuid, str, null);
			}
			// mp.seekTo(sb.getProgress());
			// SeekBar确定位置后，跳到指定位置
		}

	};
	// private void initDLNA(){
	// mStackAgent = StackAgent.CreateInstance(this);
	// int ret = mStackAgent.StartMrcp(true);
	// }
	//
	// private void StartMonitoring()
	// {
	// if (!mHandler.hasMessages(MSG_MONITOR_DMR))
	// {
	// mHandler.sendEmptyMessage(MSG_MONITOR_DMR);
	// }
	// if (!mHandler.hasMessages(MSG_GET_POSITION_TIMER))
	// {
	// mHandler.sendEmptyMessage(MSG_GET_POSITION_TIMER);
	// }
	// }
	// private void StopMonitoring()
	// {
	// mHandler.removeMessages(MSG_MONITOR_DMR);
	// mHandler.removeMessages(MSG_GET_POSITION_TIMER);
	// }

	final Handler mHandler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			Bundle data = msg.getData();
			switch (msg.what) {
			case Constant.MSG_DMRCHANGED:
				mMrcp = mMyService.getmMrcp();
				mMediaRenderer = mMyService.getMediaRenderer();
				aq.id(R.id.progressBar1).visible();
				mMrcp.MediaStop(mMediaRenderer.uuid, null);
				// mMrcp.SetListener(this);
				break;
			case Constant.MSG_DMR_CHANGED: {

				break;
			}
			case Constant.MSG_PUSH_LOCAL_FILE: {
				// exitMainScreen();
				mIsControllingDmr = true;
				StartMonitoring();
				break;
			}
			case Constant.MSG_PUSH_INTERNET_MEDIA: {
				// exitMainScreen();
				mIsControllingDmr = true;
				StartMonitoring();
				break;
			}
			case Constant.MSG_MONITOR_DMR: {
				if (mMediaRenderer != null && mIsControllingDmr) {
					mMrcp.GetCurrentTransportActions(mMediaRenderer.uuid, null);
					mMrcp.GetMediaInfo(mMediaRenderer.uuid, null);
					mMrcp.GetTransportInfo(mMediaRenderer.uuid, null);
					mMrcp.GetVolume(mMediaRenderer.uuid, null);
					mMrcp.GetMute(mMediaRenderer.uuid, null);

					mHandler.sendEmptyMessageDelayed(Constant.MSG_MONITOR_DMR,
							2000);
				}
				break;
			}

			case Constant.MSG_GET_POSITION_TIMER: {
				if (mMediaRenderer != null && mIsControllingDmr) {
					mMrcp.GetPositionInfo(mMediaRenderer.uuid, null);

					mHandler.sendEmptyMessageDelayed(
							Constant.MSG_GET_POSITION_TIMER, 800);
				}
				break;
			}

			case Constant.MSG_MEDIA_INFO_UPDATE: {
				if (data == null) {
					break;
				}
				String title = data.getString(Constant.MSG_KEY_ID_TITLE);
				String mimetype = data.getString(Constant.MSG_KEY_ID_MIME_TYPE);
				// mTextViewMediaTitle.setText(title);
				// mTextViewMediaMimeType.setText(mimetype);
				break;
			}

			case Constant.MSG_STATE_UPDATE: {
				if (data == null) {
					break;
				}
				String state = data.getString(Constant.MSG_KEY_ID_STATE);
				if (state.equalsIgnoreCase("PAUSED_PLAYBACK")
						|| state.equalsIgnoreCase("STOPPED"))
					aq.id(R.id.button2).background(
							R.drawable.music_play_play);
				if (state.equalsIgnoreCase("PLAYING"))
					aq.id(R.id.button2).background(
							R.drawable.music_play_pause);
				// mTextViewPlayState.setText(state);
				break;
			}

			case Constant.MSG_POSITION_UPDATE: {
				if (data == null) {
					break;
				}

				int position = data.getInt(Constant.MSG_KEY_ID_POSITION);
				int duration = music_array.get(current_item).duration / 1000;
				// int duration = data.getInt(Constant.MSG_KEY_ID_DURATION);
				// mCurDuration = duration;

				// String strPosition = "";
				// strPosition += Util.Second2Time(position);
				// strPosition += "/";
				// strPosition += Util.Second2Time(duration);

				aq.id(R.id.textViewTime1).text(Util.Second2Time(position));
				sb.setMax(duration);
				sb.setProgress(position);
				aq.id(R.id.textViewTime2).text(Util.Second2Time(duration));
				if (duration - position <= 1) {
					nextMusic();
				}
				// sb.setMax(duration);
				// mTextViewPosition.setText(strPosition);
				// mSeekBar.setMax(duration);
				// mSeekBar.setProgress(position);
				break;
			}

			case Constant.MSG_VOLUME_UPDATE: {
				if (data == null) {
					break;
				}
				int volume = data.getInt(Constant.MSG_KEY_ID_VOLUME);
				String strVol = "";
				strVol += volume;
				// mTextViewVolume.setText(strVol);
				// mVolumeBar.setMax(100);
				// mVolumeBar.setProgress(volume);
				break;
			}

			case Constant.MSG_MUTE_UPDATE: {
				if (data == null) {
					break;
				}
				boolean mute = data.getBoolean(Constant.MSG_KEY_ID_MUTE);
				// mToggleButtonMute.setChecked(mute);
				break;
			}

			case Constant.MSG_ALLOWED_ACTIONS_UPDATE: {
				if (data == null) {
					break;
				}
				String actions = data
						.getString(Constant.MSG_KEY_ID_ALLOWED_ACTION);
				// mTextViewAllowAction.setText(actions);
				break;
			}

			case Constant.MSG_ACTION_RESULT: {
				if (data == null || mMediaRenderer == null) {
					break;
				}

				String actionName = data
						.getString(Constant.MSG_KEY_ID_ACTION_NAME);
				int errorCode = data.getInt(Constant.MSG_KEY_ID_ACTION_RESULT);

				if (actionName == "SetAVTransportUri") {
					if (errorCode == 0) {
						int ret = mMrcp.MediaPlay(mMediaRenderer.uuid, null);
						if (ret == 0) {
							/* To reduce the buffering time, stop monitoring */
							StopMonitoring();
						}
					}
				}
				if (actionName == "Play") {
					/* Resume monitoring */
					StartMonitoring();
					mIsControllingDmr = true;
					isPlaying = true;
					// int duration = music_array.get(current_item).duration;
					// sb.setMax( duration);
					// aq.id(R.id.textViewTime2).text(Utils.formatDuration(duration));

				} else if (actionName == "Stop") {
					isPlaying = false;
					aq.id(R.id.progressBar1).gone();
					if (isQuit) {
						mMyService.SetCurrentDevice(0);
						Intent intent = new Intent(DlnaMusicPlay.this,
								MusicPlay.class);
						intent.putExtra("CURRENT", current_item);
						intent.putParcelableArrayListExtra("MUSICARRAY",
								music_array);
						try {
							startActivity(intent);
							finish();
							break;
						} catch (ActivityNotFoundException ex) {
							Log.e(TAG, "Call Tab1_Photo failed", ex);
						}
					} else {
						String str = music_array.get(current_item)._data;

						PushLocalFile(mMediaRenderer.uuid,
								music_array.get(current_item)._data, null);
					}

				}
				break;
			}
			default:
				break;
			}
			super.handleMessage(msg);
		}
	};

	// public void enterDmrControlScreen()
	// {
	// mIsControllingDmr = true;
	// StartMonitoring();
	// }
	private void StartMonitoring() {
		if (!mHandler.hasMessages(Constant.MSG_MONITOR_DMR)) {
			mHandler.sendEmptyMessage(Constant.MSG_MONITOR_DMR);
		}
		if (!mHandler.hasMessages(Constant.MSG_GET_POSITION_TIMER)) {
			mHandler.sendEmptyMessage(Constant.MSG_GET_POSITION_TIMER);
		}
	}

	private void StopMonitoring() {
		mHandler.removeMessages(Constant.MSG_MONITOR_DMR);
		mHandler.removeMessages(Constant.MSG_GET_POSITION_TIMER);
	}

	public void onMediaInfoUpdate(String title, String mimeType) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		Bundle data = new Bundle();
		data.putString(Constant.MSG_KEY_ID_TITLE, title);
		data.putString(Constant.MSG_KEY_ID_MIME_TYPE, mimeType);
		msg.setData(data);
		msg.what = Constant.MSG_MEDIA_INFO_UPDATE;
		mHandler.sendMessage(msg);
	}

	public void onVolumeUpdate(int volume) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		Bundle data = new Bundle();
		data.putInt(Constant.MSG_KEY_ID_VOLUME, volume);
		msg.setData(data);
		msg.what = Constant.MSG_VOLUME_UPDATE;
		mHandler.sendMessage(msg);
	}

	public void onDmrChanged(ArrayList<MediaRenderer> dmrCache) {
		// TODO Auto-generated method stub
		if (dmrCache == null || isPlaying)
			return;

		Message msg = Message.obtain();
		msg.what = Constant.MSG_DMR_CHANGED;
		mHandler.sendMessage(msg);
	}

	public void onAllowedActionsUpdate(String actions) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		Bundle data = new Bundle();
		data.putString(Constant.MSG_KEY_ID_ALLOWED_ACTION, actions);
		msg.setData(data);
		msg.what = Constant.MSG_ALLOWED_ACTIONS_UPDATE;
		mHandler.sendMessage(msg);
	}

	public void onActionResult(String actionName, int res) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		Bundle data = new Bundle();
		data.putString(Constant.MSG_KEY_ID_ACTION_NAME, actionName);
		data.putInt(Constant.MSG_KEY_ID_ACTION_RESULT, res);
		// data.putInt(Constant.MSG_KEY_ID_CURRENT_ITEM, current_item);
		msg.setData(data);
		msg.what = Constant.MSG_ACTION_RESULT;
		mHandler.sendMessage(msg);
	}

	public void onPostionInfoUpdate(int position, int duration) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		Bundle data = new Bundle();
		data.putInt(Constant.MSG_KEY_ID_POSITION, position);
		data.putInt(Constant.MSG_KEY_ID_DURATION, duration);
		msg.setData(data);
		msg.what = Constant.MSG_POSITION_UPDATE;
		mHandler.sendMessage(msg);
	}

	public void onPlaybackStateUpdate(String state) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		Bundle data = new Bundle();
		data.putString(Constant.MSG_KEY_ID_STATE, state);
		msg.setData(data);
		msg.what = Constant.MSG_STATE_UPDATE;
		mHandler.sendMessage(msg);
	}

	public void onMuteUpdate(boolean muteState) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		Bundle data = new Bundle();
		data.putBoolean(Constant.MSG_KEY_ID_MUTE, muteState);
		msg.setData(data);
		msg.what = Constant.MSG_MUTE_UPDATE;
		mHandler.sendMessage(msg);
	}

	public int PushLocalFile(String uuid, String filePath, int ticket[]) {
		int ret = -1;
		MediaInfo info = new MediaInfo();
		info.size = music_array.get(current_item)._size;
		info.duration = music_array.get(current_item).duration;
		info.mimeType = music_array.get(current_item).mime_type;
		info.title = music_array.get(current_item).title;
		info.date = music_array.get(current_item).date_modified;
		info.artist = music_array.get(current_item).artist;
		info.album = music_array.get(current_item).album;

		String uri = Util.EncodeUri(music_array.get(current_item)._data);

		String metadata = Util.EncodeMetadata(uri, info);
		ret = mMrcp.SetAVTransportUri(uuid, uri, metadata, ticket);
		return ret;
	}

	private int SetVolume(int mVolume) {
		int ret = -1;
		ret = mMrcp.SetVolume(mMediaRenderer.uuid, mVolume, null);
		return ret;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// add here.
		super.onActivityResult(requestCode, resultCode, data);
	}

}
