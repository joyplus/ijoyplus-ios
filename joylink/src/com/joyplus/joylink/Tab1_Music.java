package com.joyplus.joylink;

import java.util.ArrayList;

import android.app.ActionBar;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.provider.MediaStore.Audio;
import android.provider.MediaStore.Files;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.joyplus.joylink.Adapters.Tab1_Music_ListAdapter;
import com.joyplus.joylink.Adapters.Tab1_Music_ListData;
import com.slidingmenu.lib.SlidingMenu;
import com.umeng.analytics.MobclickAgent;

public class Tab1_Music extends BaseActivity implements
		android.widget.AdapterView.OnItemClickListener, View.OnClickListener {

	private String TAG = "Tab1_Music";
	private App app;
	private AQuery aq;

	private int Fromepage;
	private ArrayList<Tab1_Music_ListData> dataStruct;
	private ArrayList<Tab1_Music_ListData> dataApp;
	private ListView ItemsListView;
	private Tab1_Music_ListAdapter Tab3Adapter;
	private String OLD_String = null;
	private MenuFragment mContent;
	private SlidingMenu sm;
	private ImageButton mSlidingMenuButton;
	private ImageButton mSlidingMenuButtonL;

	private static final String EXTERNAL_MEDIA = "external";
	private static final Uri mBaseUri = Files.getContentUri(EXTERNAL_MEDIA);
	private static final Uri mWatchUriAudio = Audio.Media.EXTERNAL_CONTENT_URI;

	public Tab1_Music() {
		super("音乐");
		// TODO Auto-generated constructor stub
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.tab1_music);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_list);
		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		mTextView.setText("音乐");
		mSlidingMenuButtonL = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mSlidingMenuButtonL.setOnClickListener(this);
		mSlidingMenuButton = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mSlidingMenuButton.setOnClickListener(this);

		app = (App) getApplication();
		aq = new AQuery(this);

		ItemsListView = (ListView) findViewById(R.id.listView1);
		ItemsListView.setOnItemClickListener(this);

		GetMusicData();

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

			Intent intent = new Intent(this, Tab1_Music_File.class);
			intent.putExtra("DIR", m_Tab1_Music_ListData.Dir);
			try {
				startActivity(intent);
			} catch (ActivityNotFoundException ex) {
				Log.e(TAG, "Call Tab3Detail failed", ex);
			}
		} else {
			app.MyToast(this, "m_Tab1_Music_ListData is empty.");
		}
	}

	private void GetMusicData() {
		dataStruct = app.getMusicDataPage1();
		dataApp = app.getMusicDataPage2();
		if (dataStruct == null && dataApp == null) {
			dataStruct = new ArrayList();
			dataApp = new ArrayList();
			// Tab3Adapter = new Tab1_Music_ListAdapter(this, dataStruct);
			//
			// ItemsListView.setAdapter(Tab3Adapter);
			// ItemsListView.setOnItemClickListener(this);

			LoadMusicFromSDCard();
			if (dataStruct.size() == 0)
				aq.id(R.id.listView1).gone();
			else
				app.setMusicDataPage1(dataStruct);

			if (dataApp.size() != 0)
				app.setMusicDataPage2(dataApp);
		}

		NotifyDataAnalysisFinished();

	}

	public void NotifyDataAnalysisFinished() {
		if (dataStruct != null && ItemsListView != null) {
			Tab1_Music_ListAdapter listviewdetailadapter = getAdapter();
			ItemsListView.setAdapter(listviewdetailadapter);
		} else {
			app.MyToast(this, "ItemsListView empty.");
		}
	}

	private Tab1_Music_ListAdapter getAdapter() {
		if (Tab3Adapter == null) {
			ArrayList arraylist = dataStruct;
			Tab1_Music_ListAdapter listviewdetailadapter = new Tab1_Music_ListAdapter(
					this, arraylist);
			Tab3Adapter = listviewdetailadapter;
		} else {
			ArrayList arraylist1 = dataStruct;
			Tab1_Music_ListAdapter listviewdetailadapter1 = new Tab1_Music_ListAdapter(
					this, arraylist1);
			Tab3Adapter = listviewdetailadapter1;
		}
		return Tab3Adapter;
	}

	/**
	 * Async task for loading the images from the SD card.
	 */
	private void LoadMusicFromSDCard() {

		setProgressBarIndeterminateVisibility(true);

		// String[] projection = { "_id", "_data", "_display_name", "_size",
		// "mime_type", "date_added", "is_drm", "date_modified", "title",
		// "title_key", "duration", "artist_id", "composer", "album_id",
		// "track", "year", "is_ringtone", "is_music", "is_alarm",
		// "is_notification", "is_podcast", "bookmark", "album_artist" };
		// String[] projection = { "_id", "_data", "_display_name", "duration"
		// };
		String[] projection = { MediaStore.Audio.Media._ID,
				MediaStore.Audio.Media.DATA,
				MediaStore.Audio.Media.DISPLAY_NAME,
				MediaStore.Audio.Media.SIZE, MediaStore.Audio.Media.MIME_TYPE,
				MediaStore.Audio.Media.ARTIST,
				MediaStore.Audio.Media.DATE_MODIFIED,
				MediaStore.Audio.Media.ALBUM, MediaStore.Audio.Media.TITLE,
				MediaStore.Audio.Media.DURATION,
				MediaStore.Audio.Media.ALBUM_ID

		};

		Cursor cursor = null;
		try {
			cursor = getContentResolver().query(mWatchUriAudio, projection, // Which
					// columns
					// to
					// return
					"is_music=? ", // Return all rows
					new String[] { "1" }, null);

			while (cursor != null && cursor.moveToNext()) {
				if (cursor.getString(1) != null
						&& cursor.getString(1).trim().length() > 0) {
					// File file = new File(cursor.getString(1));
					// if (file.exists()) {
					dataApp.add(DataAdd(cursor, false));
					Tab1_Music_ListData m_temp = null;
					if (dataStruct == null || dataStruct.size() == 0) {
						m_temp = DataAdd(cursor, true);
						if (m_temp != null)
							dataStruct.add(m_temp);
					} else {
						if (OLD_String.indexOf(GetLastDir(cursor.getString(1))
								+ "|") == -1) {
							m_temp = DataAdd(cursor, true);
							if (m_temp != null)
								dataStruct.add(m_temp);
						} else {
							// String str1 =
							// GetLastDir(cursor.getString(1));
							for (int i = 0; i < dataStruct.size(); i++) {
								// String str2 = cursor.getString(1);
								if (cursor.getInt(9) / 10000 != 0
										&& cursor.getString(1).indexOf(
												dataStruct.get(i).Dir + "/") != -1) {
									Tab1_Music_ListData m_Tab1_Music_ListData = dataStruct
											.get(i);
									m_Tab1_Music_ListData.num++;
									dataStruct.set(i, m_Tab1_Music_ListData);
								}
							}

						}
					}
					// }
				}
			}
		} catch (Throwable t) {
			Log.w(TAG, "cannot get title from: " + mWatchUriAudio, t);
		} finally {
			if (cursor != null)
				cursor.close();
		}

	}

	private Tab1_Music_ListData DataAdd(Cursor cursor, boolean isFirstPage) {
		Tab1_Music_ListData m_Tab1_Music_ListData = new Tab1_Music_ListData();
		m_Tab1_Music_ListData._id = cursor.getInt(0);
		m_Tab1_Music_ListData._data = cursor.getString(1);
		m_Tab1_Music_ListData._display_name = cursor.getString(2);
		m_Tab1_Music_ListData._size = cursor.getInt(3);
		m_Tab1_Music_ListData.mime_type = cursor.getString(4);
		m_Tab1_Music_ListData.artist = cursor.getString(5);
		m_Tab1_Music_ListData.date_modified = cursor.getString(6);
		m_Tab1_Music_ListData.album = cursor.getString(7);
		m_Tab1_Music_ListData.title = cursor.getString(8);
		m_Tab1_Music_ListData.duration = cursor.getInt(9);

		if (m_Tab1_Music_ListData.duration / 10000 == 0)// 小于10s不显示
			return null;

		if (isFirstPage) {
			m_Tab1_Music_ListData.Dir = GetLastDir(m_Tab1_Music_ListData._data);
			m_Tab1_Music_ListData.num = 1;
			if (OLD_String == null)
				OLD_String = m_Tab1_Music_ListData.Dir + "|";
			else
				OLD_String = OLD_String + m_Tab1_Music_ListData.Dir + "|";

		}

		int albumID = cursor.getInt(10);

		String[] mediaColumns1 = new String[] { MediaStore.Audio.Albums.ALBUM_ART };
		// MediaStore.Audio.Albums.ALBUM };

		Cursor cursor1 = getContentResolver().query(
				MediaStore.Audio.Albums.EXTERNAL_CONTENT_URI, mediaColumns1,
				"_id=?", // Return all rows
				new String[] { String.valueOf(albumID) }, null);

		if (cursor1 != null) {
			cursor1.moveToFirst();
			do {
				String album_art = cursor1.getString(0);
				if (album_art != null) {
					m_Tab1_Music_ListData.album_art = album_art;
				}

			} while (cursor1.moveToNext());

			cursor1.close();
		}
		return m_Tab1_Music_ListData;
	}

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
