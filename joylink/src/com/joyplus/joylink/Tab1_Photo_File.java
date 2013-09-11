package com.joyplus.joylink;

import java.util.ArrayList;

import android.app.ActionBar;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.database.Cursor;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.IBinder;
import android.provider.MediaStore.Files;
import android.provider.MediaStore.Images;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.dlcs.dlna.Stack.MediaRenderer;
import com.joyplus.joylink.Adapters.Tab1_Photo_GridAdapter;
import com.joyplus.joylink.Adapters.Tab1_Photo_GridData;
import com.joyplus.joylink.Dlna.DlnaPhotoSlideShow;
import com.joyplus.joylink.Dlna.DlnaSelectDevice;
import com.umeng.analytics.MobclickAgent;

public class Tab1_Photo_File extends BaseActivity implements
		AdapterView.OnItemClickListener {
	public Tab1_Photo_File() {
		super("图片文件夹");
		// TODO Auto-generated constructor stub
	}

	private String TAG = "Tab1_Photo_File";
	private App app;
	private AQuery aq;

	private ArrayList<Tab1_Photo_GridData> dataStruct = null;
	private GridView gridView;
	private Tab1_Photo_GridAdapter PhotoAdapter;
	private int BUCKET_ID = 0;
	private String BUCKET_NAME = null;
	private static final String EXTERNAL_MEDIA = "external";
	private ImageButton mSlidingMenuButton;
	private ImageButton mSlidingMenuButtonL;

	private Uri mBaseUri = Files.getContentUri(EXTERNAL_MEDIA);
	private Uri mWatchUriImage = Images.Media.EXTERNAL_CONTENT_URI;

	private DlnaSelectDevice mMyService;

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

		if (Constant.DISPLAY.equalsIgnoreCase("800*480"))
			setContentView(R.layout.tab1_photo_file_480);
		else
			setContentView(R.layout.tab1_photo_file);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_list);

		app = (App) getApplication();
		aq = new AQuery(this);
		Intent intent = getIntent();

		intent.setClass(this, DlnaSelectDevice.class);
		bindService(intent, mServiceConnection, BIND_AUTO_CREATE);

		gridView = (GridView) findViewById(R.id.gridView1);
		gridView.setSelector(new ColorDrawable(Color.TRANSPARENT));

		BUCKET_ID = intent.getIntExtra("BUCKET_ID", 0);
		BUCKET_NAME = intent.getStringExtra("BUCKET_NAME");

		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		mTextView.setText(BUCKET_NAME);
		mSlidingMenuButtonL = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mSlidingMenuButtonL.setOnClickListener(this);
		mSlidingMenuButton = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mSlidingMenuButton.setOnClickListener(this);

		if (BUCKET_NAME != null && BUCKET_NAME.length() > 0)
			aq.id(R.id.textView1).text(BUCKET_NAME);
		if (BUCKET_ID != 0)
			GetPhotoData();

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
		Tab1_Photo_GridData m_Tab1_Photo_GridData = (Tab1_Photo_GridData) gridView
				.getItemAtPosition(i);
		if (m_Tab1_Photo_GridData != null) {
			// save it
			DataSaved mDataSaved = new DataSaved(1);
			mDataSaved.setImages_array(dataStruct);
			mDataSaved.setCurrentPlayItem(i);
			app.setDataSaved(mDataSaved);

			MediaRenderer mMediaRenderer = mMyService.getMediaRenderer();
			ArrayList<MediaRenderer> mDmrCache = mMyService.getDmrCache();

			if (mMediaRenderer != null && mDmrCache != null
					&& mDmrCache.size() > 0) {
				Intent intent = new Intent(this, DlnaPhotoSlideShow.class);

				intent.putExtra("CURRENT", i);
				intent.putParcelableArrayListExtra("IMAGEARRAY", dataStruct);
				try {
					startActivity(intent);
				} catch (ActivityNotFoundException ex) {
					Log.e(TAG, "Call DlnaPhotoSlideShow failed", ex);
				}
			} else {
				Intent intent = new Intent(this, PhotoSlideShow.class);

				intent.putExtra("CURRENT", i);
				intent.putParcelableArrayListExtra("IMAGEARRAY", dataStruct);
				try {
					startActivity(intent);
				} catch (ActivityNotFoundException ex) {
					Log.e(TAG, "Call Tab1_Photo failed", ex);
				}
			}

		} else {
			app.MyToast(this, "m_Tab1_Photo_GridData is empty.");
		}
	}

	private void GetPhotoData() {
		dataStruct = new ArrayList<Tab1_Photo_GridData>();

		LoadImagesFromSDCard();
		PhotoAdapter = new Tab1_Photo_GridAdapter(this, dataStruct);

		gridView.setAdapter(PhotoAdapter);
		gridView.setOnItemClickListener(this);
	}

	/**
	 * Async task for loading the images from the SD card.
	 */
	private void LoadImagesFromSDCard() {

		setProgressBarIndeterminateVisibility(true);

		String[] projection = { "_id", "_data", "_size", "_display_name",
				"mime_type", "title", "date_added", "date_modified",
				"bucket_id", "bucket_display_name", "width", "height" };

		Cursor cursor = null;
		try {
			cursor = getContentResolver().query(mWatchUriImage, projection, // Which
					// columns
					// to
					// return
					"bucket_id=?", // Return all rows
					new String[] { String.valueOf(BUCKET_ID) }, null);

			while (cursor != null && cursor.moveToNext()) {
				DataAdd(cursor);
			}
		} catch (Throwable t) {
			Log.w(TAG, "cannot get title from: " + mWatchUriImage, t);
		} finally {
			if (cursor != null)
				cursor.close();
		}
	}

	private void DataAdd(Cursor cursor) {

		if (cursor.getString(2) != null
				&& Long.parseLong(cursor.getString(2))/(200*1024) > 0) {// 小于200k不显示
			Tab1_Photo_GridData m_Tab1_Photo_GridData = new Tab1_Photo_GridData();
			m_Tab1_Photo_GridData._id = cursor.getInt(0);
			m_Tab1_Photo_GridData._data = cursor.getString(1);
			m_Tab1_Photo_GridData._size = cursor.getString(2);
			m_Tab1_Photo_GridData._display_name = cursor.getString(3);
			m_Tab1_Photo_GridData.mime_type = cursor.getString(4);
			m_Tab1_Photo_GridData.title = cursor.getString(5);
			m_Tab1_Photo_GridData.date_added = cursor.getString(6);
			m_Tab1_Photo_GridData.date_modified = cursor.getString(7);
			m_Tab1_Photo_GridData.bucket_id = cursor.getInt(8);
			m_Tab1_Photo_GridData.bucket_display_name = cursor.getString(9);
			m_Tab1_Photo_GridData.width = cursor.getInt(10);
			m_Tab1_Photo_GridData.height = cursor.getInt(11);
			if (m_Tab1_Photo_GridData._display_name != null
					&& m_Tab1_Photo_GridData._display_name.length() > 12)
				m_Tab1_Photo_GridData._display_name = "... "
						+ m_Tab1_Photo_GridData._display_name
								.substring(m_Tab1_Photo_GridData._display_name
										.indexOf('.') - 8);
			dataStruct.add(m_Tab1_Photo_GridData);
		}

	}

	private String FormatString(String name) {
		String mReturn = null;
		if (name != null && name.length() > 8) {
			mReturn = name.substring(0, 8) + "• • • "
					+ name.substring(name.indexOf('.'));
		}
		return mReturn;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// add here.
		super.onActivityResult(requestCode, resultCode, data);
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
