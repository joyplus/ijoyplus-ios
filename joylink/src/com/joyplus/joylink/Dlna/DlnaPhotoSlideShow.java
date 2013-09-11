package com.joyplus.joylink.Dlna;

import java.io.File;
import java.util.ArrayList;

import android.app.ActionBar;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.ImageView.ScaleType;

import com.androidquery.AQuery;
import com.dlcs.dlna.Mrcp;
import com.dlcs.dlna.Stack.MediaRenderer;
import com.dlcs.dlna.Util;
import com.dlcs.dlna.Util.MediaInfo;
import com.joyplus.joylink.App;
import com.joyplus.joylink.Constant;
import com.joyplus.joylink.ControlMouse;
import com.joyplus.joylink.PhotoSlideShow;
import com.joyplus.joylink.R;
import com.joyplus.joylink.Setting;
import com.joyplus.joylink.Adapters.Tab1_Photo_GridData;
import com.joyplus.joylink.Dlna.DlnaSelectDevice.ServiceClient;

public class DlnaPhotoSlideShow extends FragmentActivity implements
		ServiceClient,OnClickListener {
	private String TAG = "DlnaPhotoSlideShow";

	private AQuery aq;
	private App app;

	private SectionsPagerAdapter mSectionsPagerAdapter;
	private ViewPager mViewPager;

	private ArrayList<Tab1_Photo_GridData> images_array = null;
	private int current_item = 0;

	private ArrayList<MediaRenderer> mDmrCache = new ArrayList<MediaRenderer>();
	private MediaRenderer mMediaRenderer = null;
	private Mrcp mMrcp = null;

	private boolean mIsControllingDmr = false;
	private boolean isQuit = false;

	private DlnaServiceConnection mServiceConnection = new DlnaServiceConnection();
	private DlnaSelectDevice mMyService = null;
	// private DLNAMain mDLNA= null;
	private ImageButton mButtonDlna;
	private ImageButton mButtonBack;

	class DlnaServiceConnection implements ServiceConnection {

		public void onServiceConnected(ComponentName name, IBinder service) {
			mMyService = ((DlnaSelectDevice.MyBinder) service).getService();

			mMyService.setServiceClient(DlnaPhotoSlideShow.this);

			Message msg = Message.obtain();
			msg.what = Constant.MSG_DMRCHANGED;
			mHandler.sendMessage(msg);

		}

		public void onServiceDisconnected(ComponentName name) {
			mMyService.setServiceClient(null);
			mMyService = null;

		}
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.dlna_photo_slideshow);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_detail);

		app = (App) getApplication();
		aq = new AQuery(this);

		bindService(new Intent(this, DlnaSelectDevice.class),
				mServiceConnection, BIND_AUTO_CREATE);

		Intent intent = getIntent();
		current_item = intent.getIntExtra("CURRENT", 0);
		images_array = intent.getParcelableArrayListExtra("IMAGEARRAY");

		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		
		mTextView.setText(images_array.get(current_item).title);
		mButtonBack = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mButtonBack.setOnClickListener(this);

		mButtonDlna = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mButtonDlna.setBackgroundResource(R.drawable.airplay_on);
		mButtonDlna.setOnClickListener(this);
		aq.id(R.id.progressBar1).gone();
		mSectionsPagerAdapter = new SectionsPagerAdapter(
				getSupportFragmentManager());

		// Set up the ViewPager with the sections adapter.
		mViewPager = (ViewPager) findViewById(R.id.viewPager1);
		mViewPager.setAdapter(mSectionsPagerAdapter);
		mViewPager.setOnPageChangeListener(new MyPageChangeListener());

		int ret = 0;

	}

	private class MyPageChangeListener implements OnPageChangeListener {

		/**
		 * This method will be invoked when a new page becomes selected.
		 * position: Position index of the new selected page.
		 */
		public void onPageSelected(int position) {
			current_item = position;
			aq.id(R.id.progressBar1).visible();
			mMrcp.MediaStop(mMediaRenderer.uuid, null);
		}

		public void onPageScrollStateChanged(int arg0) {

		}

		public void onPageScrolled(int arg0, float arg1, int arg2) {

		}
	}

	@Override
	public void onClick(View view) {
		if (view == mButtonDlna) {
			OnClickTopRight();
		}else if(view == mButtonBack)
			finish();
	}
	
	@Override
	protected void onDestroy() {
		if (aq != null)
			aq.dismiss();
		mMyService.setServiceClient(null);
		mMyService = null;
		unbindService(mServiceConnection);
		StopMonitoring();
		super.onDestroy();
	}

	@Override
	public void onPause() {
		StopMonitoring();
		super.onPause();
	}

	@Override
	public void onResume() {
		super.onResume();
	}

	public void OnClickTopLeft(View v) {
	}

	public void OnClickTopRight() {
		isQuit = true;
		aq.id(R.id.progressBar1).visible();
		mMrcp.MediaStop(mMediaRenderer.uuid, null);

	}

	public class SectionsPagerAdapter extends FragmentPagerAdapter {

		public SectionsPagerAdapter(FragmentManager fm) {
			super(fm);
		}

		@Override
		public Fragment getItem(int position) {
			// getItem is called to instantiate the fragment for the given page.
			// Return a DummySectionFragment (defined as a static inner class
			// below) with the page number as its lone argument.
			Fragment fragment = new DummySectionFragment();
			Bundle args = new Bundle();
			// args.putInt(DummySectionFragment.ARG_SECTION_NUMBER, position +
			// 1);

			args.putString(DummySectionFragment.ARG_SECTION_NUMBER,
					images_array.get(position)._data);
			args.putInt("width", images_array.get(position).width);
			args.putInt("height", images_array.get(position).height);
			fragment.setArguments(args);

			return fragment;
		}

		@Override
		public int getCount() {
			// Show 3 total pages.
			return images_array.size();
		}

		@Override
		public CharSequence getPageTitle(int position) {
			return null;
		}
	}

	/**
	 * A dummy fragment representing a section of the app, but that simply
	 * displays dummy text.
	 */
	public static class DummySectionFragment extends Fragment {
		/**
		 * The fragment argument representing the section number for this
		 * fragment.
		 */
		public static final String ARG_SECTION_NUMBER = "section_number";

		public DummySectionFragment() {
		}

		@Override
		public View onCreateView(LayoutInflater inflater, ViewGroup container,
				Bundle savedInstanceState) {
			// Create a new TextView and set its text to the fragment's section
			// number argument value.
			DisplayMetrics dm = new DisplayMetrics();
			getActivity().getWindowManager().getDefaultDisplay().getMetrics(dm);

			ImageView mImageView = new ImageView(getActivity());
			File file1 = new File(getArguments().getString(ARG_SECTION_NUMBER));
			AQuery aq2 = new AQuery(mImageView);
			if (file1.exists()) {
				aq2.image(file1, 0);
				if (getArguments().getInt("width") > dm.widthPixels
						|| getArguments().getInt("height") > (dm.heightPixels-150))
					// mImageView.setScaleType(ScaleType.FIT_XY);
					mImageView.setScaleType(ScaleType.CENTER_INSIDE);
				else
					mImageView.setScaleType(ScaleType.CENTER);
				aq2.dismiss();
			}
			return mImageView;
		}
	}

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
				mViewPager.setCurrentItem(current_item);
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

					mHandler.sendEmptyMessageDelayed(Constant.MSG_MONITOR_DMR,
							2000);
				}
				break;
			}

			case Constant.MSG_GET_POSITION_TIMER: {
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
				// if (state.equalsIgnoreCase("PAUSED_PLAYBACK")
				//
				// if (state.equalsIgnoreCase("PLAYING"))

				// mTextViewPlayState.setText(state);
				break;
			}

			case Constant.MSG_POSITION_UPDATE: {
				break;
			}

			case Constant.MSG_VOLUME_UPDATE: {
				break;
			}

			case Constant.MSG_MUTE_UPDATE: {
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
						aq.id(R.id.progressBar1).gone();
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
					// aq.id(R.id.progressBar1).gone();
					mIsControllingDmr = true;
				} else if (actionName == "Stop") {

					// aq.id(R.id.progressBar1).gone();
					if (isQuit) {
						isQuit = false;
						
						mMyService.SetCurrentDevice(0);
						app.dataSaved.setCurrentPlayItem(current_item);
						Intent intent = new Intent(DlnaPhotoSlideShow.this,
								PhotoSlideShow.class);
						intent.putExtra("CURRENT", current_item);
						intent.putParcelableArrayListExtra("IMAGEARRAY",
								images_array);
						try {
							startActivity(intent);
							finish();
							super.handleMessage(msg);
						} catch (ActivityNotFoundException ex) {
							Log.e(TAG, "Call PhotoSlideShow failed", ex);
						}
					} else
						PushLocalFile(mMediaRenderer.uuid, null);
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

	@Override
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

	@Override
	public void onVolumeUpdate(int volume) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		Bundle data = new Bundle();
		data.putInt(Constant.MSG_KEY_ID_VOLUME, volume);
		msg.setData(data);
		msg.what = Constant.MSG_VOLUME_UPDATE;
		mHandler.sendMessage(msg);
	}

	@Override
	public void onDmrChanged(ArrayList<MediaRenderer> dmrCache) {
		// TODO Auto-generated method stub
		if (dmrCache == null)
			return;

		Message msg = Message.obtain();
		msg.what = Constant.MSG_DMR_CHANGED;
		mHandler.sendMessage(msg);
	}

	@Override
	public void onAllowedActionsUpdate(String actions) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		Bundle data = new Bundle();
		data.putString(Constant.MSG_KEY_ID_ALLOWED_ACTION, actions);
		msg.setData(data);
		msg.what = Constant.MSG_ALLOWED_ACTIONS_UPDATE;
		mHandler.sendMessage(msg);
	}

	@Override
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

	@Override
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

	@Override
	public void onPlaybackStateUpdate(String state) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		Bundle data = new Bundle();
		data.putString(Constant.MSG_KEY_ID_STATE, state);
		msg.setData(data);
		msg.what = Constant.MSG_STATE_UPDATE;
		mHandler.sendMessage(msg);
	}

	@Override
	public void onMuteUpdate(boolean muteState) {
		// TODO Auto-generated method stub
		Message msg = Message.obtain();
		Bundle data = new Bundle();
		data.putBoolean(Constant.MSG_KEY_ID_MUTE, muteState);
		msg.setData(data);
		msg.what = Constant.MSG_MUTE_UPDATE;
		mHandler.sendMessage(msg);
	}

	public int PushLocalFile(String uuid, int ticket[]) {
		int ret = -1;

		MediaInfo info = new MediaInfo();
		info.size = Long.parseLong(images_array.get(current_item)._size);
		info.mimeType = images_array.get(current_item).mime_type;
		info.title = images_array.get(current_item).title;
		info.date = images_array.get(current_item).date_modified;

		String uri = Util.EncodeUri(images_array.get(current_item)._data);
		/*
		 * due to joy plus don't support video/mp2ts, if modifying the mime-type
		 * to video/vnd.dlna.mpeg-tts, joy plus play the ts file correctly.
		 */
		// if (filePath.endsWith(".ts") || mediaInfo.mimeType == "video/mp2ts")
		// {
		// mediaInfo.mimeType = "video/vnd.dlna.mpeg-tts";
		// }
		String metadata = Util.EncodeMetadata(uri, info);
		ret = mMrcp.SetAVTransportUri(uuid, uri, metadata, ticket);
		return ret;
	}
}