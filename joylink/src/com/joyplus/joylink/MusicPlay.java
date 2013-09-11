package com.joyplus.joylink;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import android.app.ActionBar;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ServiceConnection;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.dlcs.dlna.Stack.MediaRenderer;
import com.joyplus.joylink.Adapters.Tab1_Music_ListData;
import com.joyplus.joylink.Dlna.DlnaMusicPlay;
import com.joyplus.joylink.Dlna.DlnaSelectDevice;
import com.joyplus.joylink.Utils.JoylinkUtils;
import com.umeng.analytics.MobclickAgent;

public class MusicPlay extends Activity implements OnClickListener {
	private String TAG = "Tab1_Photo";
	private App app;
	private AQuery aq;
	private boolean isPlaying;
	private SeekBar sb;
	private int Duration;
	private Handler handler = null;

	private MediaPlayer mp = new MediaPlayer();

	private ArrayList<Tab1_Music_ListData> musics_array = null;
	private int current_item = 0;
	// private ServiceToken mToken;

	private DlnaSelectDevice mMyService;
	private ImageButton mButtonDlna;
	private ImageButton mButtonBack;

	private ServiceConnection mServiceConnection = new ServiceConnection() {
		public void onServiceConnected(ComponentName name, IBinder service) {
			// TODO Auto-generated method stub
			mMyService = ((DlnaSelectDevice.MyBinder) service).getService();
		}

		public void onServiceDisconnected(ComponentName name) {
			// TODO Auto-generated method stub

		}
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.music_play);
		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_detail);

		app = (App) getApplication();
		aq = new AQuery(this);
		Intent i = new Intent();
		i.setClass(this, DlnaSelectDevice.class);
		bindService(i, mServiceConnection, BIND_AUTO_CREATE);

		isPlaying = false;
		handler = new Handler();

		Intent intent = getIntent();
		current_item = intent.getIntExtra("CURRENT", 0);
		musics_array = intent.getParcelableArrayListExtra("MUSICARRAY");

		 TextView mTextView = (TextView) getActionBar().getCustomView()
		 .findViewById(R.id.actionBarTitle);
		 mTextView.setText("正在播放");
//		 mTextView.setText(musics_array.get(current_item).title);
		 
		mButtonBack = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mButtonBack.setOnClickListener(this);

		mButtonDlna = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mButtonDlna.setOnClickListener(this);

		// aq.id(R.id.textView1).text(musics_array.get(current_item).title);
		// aq.id(R.id.textView2).text(musics_array.get(current_item).artist);
		// aq.id(R.id.textView3).text(musics_array.get(current_item).album);
		// aq.id(R.id.button2).background(R.drawable.music_play_pause);
		sb = (SeekBar) findViewById(R.id.seekBar1);
		sb.setOnSeekBarChangeListener(sbLis);
		
		
		playMusic();

	}

	@Override
	public void onClick(View view) {
		if (view == mButtonDlna) {
			OnClickTopRight();
		} else if (view == mButtonBack)
			finish();
	}

	public void OnClickTopRight() {
		mp.pause();
		isPlaying = false;
		handler.post(updatesb);
		aq.id(R.id.button2).background(R.drawable.music_play_play);

		ArrayList<MediaRenderer> mDmrCache = mMyService.getDmrCache();
		if (mDmrCache.size() > 0) {
			CharSequence[] items = new String[mDmrCache.size()];
			for (int i = 0; i < mDmrCache.size(); i++)
				items[i] = mDmrCache.get(i).friendlyName;

			if (mDmrCache.size() == 1) {
				MediaRenderer mMediaRenderer = mDmrCache.get(0);
				mMyService.SetCurrentDevice( 1);
				if (mMediaRenderer != null && mDmrCache != null) {
					gotoDlnaMusicPlay();
				}
			} else {
				AlertDialog.Builder builder = new AlertDialog.Builder(this);
				builder.setTitle("请选择你的设备：");
				builder.setItems(items, new DialogInterface.OnClickListener() {
					public void onClick(DialogInterface dialog, int item) {
						// MediaRenderer mMediaRenderer =
						// mMyService.getMediaRenderer();
						ArrayList<MediaRenderer> mDmrCache = mMyService
								.getDmrCache();
						MediaRenderer mMediaRenderer = mDmrCache.get(item);
						mMyService.SetCurrentDevice(item + 1);
						if (mMediaRenderer != null && mDmrCache != null) {
							// app.setmMediaRenderer(mDmrCache.get(0));
							gotoDlnaMusicPlay();
						}
						// Do something with the selection
					}
				});
				AlertDialog alert = builder.create();
				alert.show();
			}
		} else {
			app.MyToast(this, "正在搜索设备 ...");
		}

	}

	private void gotoDlnaMusicPlay() {
		app.dataSaved.setCurrentPlayItem(current_item);
		Intent intent = new Intent(this, DlnaMusicPlay.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);

		intent.putExtra("CURRENT", current_item);
		intent.putParcelableArrayListExtra("MUSICARRAY", musics_array);
		try {
			startActivity(intent);
			finish();
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call DlnaPhotoSlideShow failed", ex);
		}
	}

	public void OnClickNext(View v) {
		nextMusic();

	}

	public void OnClickResume(View v) {
		if (mp != null) {
			if (!isPlaying) {
				mp.start();
				isPlaying = true;
				handler.post(updatesb);
				aq.id(R.id.button2).background(R.drawable.music_play_pause);
			} else {
				mp.pause();
				isPlaying = false;
				handler.post(updatesb);
				aq.id(R.id.button2).background(R.drawable.music_play_play);
			}
		}

	}

	public void OnClickPre(View v) {
		preMusic();

	}

	private void playMusic() {
		try {
			isPlaying = true;
			aq.id(R.id.textView1).text(musics_array.get(current_item).title);
			
			aq.id(R.id.textView2).text(musics_array.get(current_item).artist);
			aq.id(R.id.textView3).text(musics_array.get(current_item).album);
			if (musics_array.get(current_item).album_art != null) {
				File file = new File(musics_array.get(current_item).album_art);
				if (file.exists()) {
					aq.id(R.id.imageView1).image(file, 638);
				}
			}
			aq.id(R.id.button2).background(R.drawable.music_play_pause);
			mp.reset();

			mp.setDataSource(musics_array.get(current_item)._data);

			mp.prepare();

			mp.start();
			Duration = mp.getDuration();
			aq.id(R.id.textViewTime1).text("00:00");
			aq.id(R.id.textViewTime2).text(JoylinkUtils.formatDuration(Duration));
			sb.setMax(Duration);
			handler.post(updatesb);
			// Setup listener so next song starts automatically

			mp.setOnCompletionListener(new OnCompletionListener() {

				public void onCompletion(MediaPlayer arg0) {

					nextMusic();

				}

			});

		} catch (IOException e) {

			Log.v(getString(R.string.app_name), e.getMessage());

		}
	}

	private void nextMusic() {
		if (mp != null && isPlaying)
			mp.stop();
		if (++current_item >= musics_array.size()) {
			// Last song, just reset currentPosition
			current_item = 0;
		}
		app.dataSaved.setCurrentPlayItem(current_item);
		playMusic();

	}

	private void preMusic() {
		if (mp != null && isPlaying)
			mp.stop();

		if (--current_item <= 0) {
			// Last song, just reset currentPosition
			current_item = 0;
		}
		app.dataSaved.setCurrentPlayItem(current_item);
		playMusic();
		// Play next song
	}

	@Override
	protected void onDestroy() {
		if (aq != null)
			aq.dismiss();
		if (mp != null) {
			mp.stop();
			mp.release();
		}
		// if (mToken != null) {
		// MusicUtils.unbindFromService(mToken);
		// }
		handler.removeCallbacks(updatesb);
		unbindService(mServiceConnection);
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

	Runnable updatesb = new Runnable() {

		@Override
		public void run() {
			// TODO Auto-generated method stub
			int m_p = mp.getCurrentPosition();
			sb.setProgress(m_p);
			handler.postDelayed(updatesb, 1000);
			aq.id(R.id.textViewTime1).text(JoylinkUtils.formatDuration(m_p));
			// 每秒钟更新一次
		}

	};
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
			mp.seekTo(sb.getProgress());
			// SeekBar确定位置后，跳到指定位置
		}

	};

	// private ServiceConnection autoshuffle = new ServiceConnection() {
	// public void onServiceConnected(ComponentName classname, IBinder obj) {
	// // we need to be able to bind again, so unbind
	// try {
	// unbindService(this);
	// } catch (IllegalArgumentException e) {
	// }
	// IMediaPlaybackService serv = IMediaPlaybackService.Stub.asInterface(obj);
	// if (serv != null) {
	// try {
	// serv.setShuffleMode(MediaPlaybackService.SHUFFLE_AUTO);
	// } catch (RemoteException ex) {
	// }
	// }
	// }
	//
	// public void onServiceDisconnected(ComponentName classname) {
	// }
	// };
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// add here.
		if (resultCode == 102) {
			gotoDlnaMusicPlay();
		}
		super.onActivityResult(requestCode, resultCode, data);
	}

}
