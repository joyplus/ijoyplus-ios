package com.joyplus.joylink;

import java.util.ArrayList;

import android.app.ActionBar;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.IBinder;
import android.provider.MediaStore.Audio;
import android.provider.MediaStore.Files;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.dlcs.dlna.Stack.MediaRenderer;
import com.joyplus.joylink.Adapters.Tab1_Music_DetailListAdapter;
import com.joyplus.joylink.Adapters.Tab1_Music_ListData;
import com.joyplus.joylink.Dlna.DlnaMusicPlay;
import com.joyplus.joylink.Dlna.DlnaSelectDevice;
import com.umeng.analytics.MobclickAgent;

public class Tab1_Music_File extends BaseActivity implements
		android.widget.AdapterView.OnItemClickListener {
	public Tab1_Music_File() {
		super("音乐文件夹");
		// TODO Auto-generated constructor stub
	}

	private String TAG = "Tab1_Music_File";
	private App app;
	private AQuery aq;

	private ArrayList<Tab1_Music_ListData> dataStruct;
	private ListView ItemsListView;
	private Tab1_Music_DetailListAdapter Tab3Adapter;
	private String DIR = null;

	private static final String EXTERNAL_MEDIA = "external";
	private static final Uri mBaseUri = Files.getContentUri(EXTERNAL_MEDIA);
	private static final Uri mWatchUriAudio = Audio.Media.EXTERNAL_CONTENT_URI;

	private DlnaSelectDevice mMyService;
	private ImageButton mSlidingMenuButton;
	private ImageButton mSlidingMenuButtonL;

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
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.tab1_music_file);
		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_list);

		app = (App) getApplication();
		aq = new AQuery(this);

		ItemsListView = (ListView) findViewById(R.id.listView1);
		ItemsListView.setOnItemClickListener(this);
		ItemsListView.setSelector(new ColorDrawable(Color.TRANSPARENT));

		Intent intent = getIntent();

		intent.setClass(this, DlnaSelectDevice.class);
		bindService(intent, mServiceConnection, BIND_AUTO_CREATE);

		DIR = intent.getStringExtra("DIR");

		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		mTextView.setText(DIR);
		mSlidingMenuButtonL = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mSlidingMenuButtonL.setOnClickListener(this);

		mSlidingMenuButton = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mSlidingMenuButton.setOnClickListener(this);

		if (DIR != null && DIR.length() > 0) {

			aq.id(R.id.textView1).text(DIR);
			GetMusicData();
		}

	}

	@Override
	public void onClick(View view) {
		if (view == mSlidingMenuButton) {
			getSlidingMenu().toggle();
		} else if (view == mSlidingMenuButtonL)
			finish();
	}

	public void OnClickSlidingMenu(View v) {
		getSlidingMenu().toggle();
	}

	public void OnClickHome(View v) {
		super.OnClickHome(this);
	}

	public void OnClickRemoteMouse(View v) {
		super.OnClickRemoteMouse(this);

	}

	public void OnClickRemoteControl(View v) {
		super.OnClickRemoteControl(this);
	}

	public void OnClickSetting(View v) {
		super.OnClickSetting(this);

	}

	@Override
	protected void onDestroy() {
		if (aq != null)
			aq.dismiss();
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

	// listview的点击事件接口函数
	public void onItemClick(AdapterView adapterview, View view, int i, long l) {
		Tab1_Music_ListData m_Tab1_Music_ListData = (Tab1_Music_ListData) ItemsListView
				.getItemAtPosition(i);
		if (m_Tab1_Music_ListData != null) {
			// save it
			DataSaved mDataSaved = new DataSaved(3);
			mDataSaved.setMusic_array(dataStruct);
			mDataSaved.setCurrentPlayItem(i);
			app.setDataSaved(mDataSaved);

			MediaRenderer mMediaRenderer = mMyService.getMediaRenderer();
			ArrayList<MediaRenderer> mDmrCache = mMyService.getDmrCache();

			if (mMediaRenderer != null && mDmrCache != null
					&& mDmrCache.size() > 0) {
				Intent intent = new Intent(this, DlnaMusicPlay.class);
				intent.putExtra("CURRENT", i);
				intent.putParcelableArrayListExtra("MUSICARRAY", dataStruct);

				try {
					startActivity(intent);
					finish();
				} catch (ActivityNotFoundException ex) {
					Log.e(TAG, "Call DlnaMusicPlay failed", ex);
				}
			} else {
				Intent intent = new Intent(this, MusicPlay.class);
				intent.putExtra("CURRENT", i);
				intent.putParcelableArrayListExtra("MUSICARRAY", dataStruct);
				try {
					startActivity(intent);
				} catch (ActivityNotFoundException ex) {
					Log.e(TAG, "Call Tab1_Photo failed", ex);
				}
			}
		} else {
			app.MyToast(this, "m_Tab1_Music_ListData is empty.");
		}
	}

	private void GetMusicData() {
		dataStruct = new ArrayList();
		// Tab3Adapter = new Tab1_Music_DetailListAdapter(this, dataStruct);
		//
		// ItemsListView.setAdapter(Tab3Adapter);
		// ItemsListView.setOnItemClickListener(this);

		LoadMusicFromApp();
		NotifyDataAnalysisFinished();
		if (dataStruct.size() == 0)
			aq.id(R.id.listView1).gone();

	}

	public void NotifyDataAnalysisFinished() {
		if (dataStruct != null && ItemsListView != null) {
			Tab1_Music_DetailListAdapter listviewdetailadapter = getAdapter();
			ItemsListView.setAdapter(listviewdetailadapter);
		} else {
			app.MyToast(this, "ItemsListView empty.");
		}
	}

	private Tab1_Music_DetailListAdapter getAdapter() {
		if (Tab3Adapter == null) {
			ArrayList arraylist = dataStruct;
			Tab1_Music_DetailListAdapter listviewdetailadapter = new Tab1_Music_DetailListAdapter(
					this, arraylist);
			Tab3Adapter = listviewdetailadapter;
		} else {
			ArrayList arraylist1 = dataStruct;
			Tab1_Music_DetailListAdapter listviewdetailadapter1 = new Tab1_Music_DetailListAdapter(
					this, arraylist1);
			Tab3Adapter = listviewdetailadapter1;
		}
		return Tab3Adapter;
	}

	/**
	 * Async task for loading the images from the SD card.
	 */
	private void LoadMusicFromApp() {
		ArrayList<Tab1_Music_ListData> mData = app.getMusicDataPage2();
		if (mData == null)
			return;
		for (int i = 0; i < mData.size(); i++) {
			if (mData.get(i) != null && mData.get(i)._data != null
					&& mData.get(i)._data.indexOf("/" + DIR + "/") != -1) {
				dataStruct.add(mData.get(i));
			}
		}

	}

	// /**
	// * Async task for loading the images from the SD card.
	// */
	// private void LoadMusicFromSDCard() {
	//
	// setProgressBarIndeterminateVisibility(true);
	//
	// // String[] projection = { "_id", "_data", "_display_name",
	// // "_size","mime_type","artist","date_modified","album",
	// // "title", "duration" };
	// String[] projection = { MediaStore.Audio.Media._ID,
	// MediaStore.Audio.Media.DATA,
	// MediaStore.Audio.Media.DISPLAY_NAME,
	// MediaStore.Audio.Media.SIZE, MediaStore.Audio.Media.MIME_TYPE,
	// MediaStore.Audio.Media.ARTIST,
	// MediaStore.Audio.Media.DATE_MODIFIED,
	// MediaStore.Audio.Media.ALBUM, MediaStore.Audio.Media.TITLE,
	// MediaStore.Audio.Media.DURATION,
	// MediaStore.Audio.Media.ALBUM_ID
	//
	// };
	//
	// Cursor cursor = null;
	// try {
	// cursor = getContentResolver().query(mWatchUriAudio, projection, // Which
	// // columns
	// // to
	// // return
	// "_data like ? ", // Return all rows
	// new String[] { "%" + DIR + "/%" }, null);
	// while (cursor != null && cursor.moveToNext()) {
	// if (dataStruct != null) {
	// // File file = new File(cursor.getString(1));
	// // if (file.exists())
	// DataAdd(cursor);
	// }
	// }
	// } catch (Throwable t) {
	// Log.w(TAG, "cannot get title from: " + mWatchUriAudio, t);
	// } finally {
	// if (cursor != null)
	// cursor.close();
	// }
	//
	// }

	// private void DataAdd(Cursor cursor) {
	// Tab1_Music_ListData m_Tab1_Music_ListData = new Tab1_Music_ListData();
	// m_Tab1_Music_ListData._id = cursor.getInt(0);
	// m_Tab1_Music_ListData._data = cursor.getString(1);
	// m_Tab1_Music_ListData._display_name = cursor.getString(2);
	// m_Tab1_Music_ListData._size = cursor.getInt(3);
	// m_Tab1_Music_ListData.mime_type = cursor.getString(4);
	// m_Tab1_Music_ListData.artist = cursor.getString(5);
	// m_Tab1_Music_ListData.date_modified = cursor.getString(6);
	// m_Tab1_Music_ListData.album = cursor.getString(7);
	// m_Tab1_Music_ListData.title = cursor.getString(8);
	// m_Tab1_Music_ListData.duration = cursor.getInt(9);
	//
	// int albumID = cursor.getInt(10);
	//
	// String[] mediaColumns1 = new String[] {
	// MediaStore.Audio.Albums.ALBUM_ART,
	// MediaStore.Audio.Albums.ALBUM };
	//
	// Cursor cursor1 = getContentResolver().query(
	// MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI, mediaColumns1,
	// "_id=?", // Return all rows
	// new String[] { String.valueOf(albumID) }, null);
	//
	// if (cursor1 != null) {
	// cursor1.moveToFirst();
	// do {
	// String album_art = cursor1.getString(0);
	// if (album_art != null) {
	// m_Tab1_Music_ListData.album_art = album_art;
	// }
	//
	// // String album = cursor1.getString(1);
	// // if (album != null) {
	// // Log.d("ALBUM_ART", album);
	// // }
	//
	// } while (cursor1.moveToNext());
	//
	// cursor1.close();
	// }
	//
	// if (m_Tab1_Music_ListData.duration / 10000 == 0)// 小于10s不显示
	// return;
	// dataStruct.add(m_Tab1_Music_ListData);
	// }
	//
	private String GetLastDir(String path) {
		if (path != null && path.length() > 0) {
			String[] PTAH1 = path.split("\\/");
			if (PTAH1.length > 1)// sd root
				return PTAH1[PTAH1.length - 2];
			else
				return "sdcard";
		}
		return null;
	}

	@Override
	void ConnectOK(String name) {
		// TODO Auto-generated method stub

	}

	@Override
	void ConnectFailed() {
		// TODO Auto-generated method stub

	}

}
