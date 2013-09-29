package com.joyplus.joylink;

import java.util.ArrayList;

import android.app.ActionBar;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore.Files;
import android.provider.MediaStore.Images;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.joyplus.joylink.Adapters.Tab1_Photo_Adapter;
import com.joyplus.joylink.Adapters.Tab1_Photo_GridData;
import com.slidingmenu.lib.SlidingMenu;
import com.umeng.analytics.MobclickAgent;

public class Tab1_Photo extends BaseActivity implements
		AdapterView.OnItemClickListener, View.OnClickListener {
	private String TAG = "Tab1_Photo";
	private App app;
	private AQuery aq;

	private int Fromepage;
	private ArrayList<Tab1_Photo_GridData> dataStruct;
	private GridView gridView;
	private Tab1_Photo_Adapter Tab1Adapter;
	private String OLD_String = null;
	private MenuFragment mContent;
	private SlidingMenu sm;
	private ImageButton mSlidingMenuButton;
	private ImageButton mSlidingMenuButtonL;

	private static final String EXTERNAL_MEDIA = "external";
	private static final Uri mBaseUri = Files.getContentUri(EXTERNAL_MEDIA);
	private static final Uri mWatchUriImage = Images.Media.EXTERNAL_CONTENT_URI;

	public Tab1_Photo() {
		super("图片");
		// TODO Auto-generated constructor stub
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		if (Constant.DISPLAY.equalsIgnoreCase("800*480"))
			setContentView(R.layout.tab1_photo_480);
		else
			setContentView(R.layout.tab1_photo);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_list);
		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		mTextView.setText("图片");
		mSlidingMenuButtonL = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mSlidingMenuButtonL.setOnClickListener(this);
		mSlidingMenuButton = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mSlidingMenuButton.setOnClickListener(this);

		app = (App) getApplication();
		aq = new AQuery(this);

		gridView = (GridView) findViewById(R.id.gridView1);
		gridView.setSelector(new ColorDrawable(Color.TRANSPARENT));

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

	public void OnClickTopLeft(View v) {

	}

	public void OnClickTopRight(View v) {

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

	// 点击事件接口函数
	public void onItemClick(AdapterView adapterview, View view, int i, long l) {
		Tab1_Photo_GridData m_Tab1_Photo_GridData = (Tab1_Photo_GridData) gridView
				.getItemAtPosition(i);
		if (m_Tab1_Photo_GridData != null) {
			// app.MyToast(this, m_Tab1_Photo_GridData.Pic_name,
			// Toast.LENGTH_LONG)
			// .show();
			Intent intent = new Intent(this, Tab1_Photo_File.class);
			intent.putExtra("BUCKET_ID", m_Tab1_Photo_GridData.bucket_id);
			intent.putExtra("BUCKET_NAME",
					m_Tab1_Photo_GridData.bucket_display_name);
			try {
				startActivity(intent);
			} catch (ActivityNotFoundException ex) {
				Log.e(TAG, "Call Tab1_Photo failed", ex);
			}
		} else {
			app.MyToast(this, "m_Tab1_Photo_GridData is empty.");
		}
	}

	private void GetPhotoData() {
		dataStruct = new ArrayList<Tab1_Photo_GridData>();

		LoadImagesFromSDCard();
		Tab1Adapter = new Tab1_Photo_Adapter(this, dataStruct);

		gridView.setAdapter(Tab1Adapter);
		gridView.setOnItemClickListener(this);
	}

	/**
	 * Async task for loading the images from the SD card.
	 */
	private void LoadImagesFromSDCard() {

		String[] projection = { "_id", "_data", "_size", "_display_name",
				"mime_type", "title", "date_added", "date_modified",
				"bucket_id", "bucket_display_name", "width", "height" };

		Cursor cursor = null;
		try {
			cursor = getContentResolver().query(mWatchUriImage, projection, // Which
					// columns
					// to
					// return
					null, // Return all rows
					null, null);
			while (cursor != null && cursor.moveToNext()) {
				if (dataStruct == null || dataStruct.size() == 0) {
					DataAdd(cursor);
				} else if (OLD_String
						.indexOf(Integer.toString(cursor.getInt(8)) + "|") == -1)
					DataAdd(cursor);
				else {
					for (int i = 0; i < dataStruct.size(); i++) {
						if (cursor.getString(2) != null
								&& Long.parseLong(cursor.getString(2))/(200*1024) > 0
								&&cursor.getInt(8) == dataStruct.get(i).bucket_id) {
							Tab1_Photo_GridData m_Tab1_Photo_GridData = dataStruct
									.get(i);
							m_Tab1_Photo_GridData.num++;
							dataStruct.set(i, m_Tab1_Photo_GridData);
						}
					}

				}

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

			m_Tab1_Photo_GridData.num = 1;

			if (OLD_String == null)
				OLD_String = Integer.toString(m_Tab1_Photo_GridData.bucket_id)
						+ "|";
			else
				OLD_String = OLD_String
						+ Integer.toString(m_Tab1_Photo_GridData.bucket_id)
						+ "|";
			dataStruct.add(m_Tab1_Photo_GridData);

		}

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
