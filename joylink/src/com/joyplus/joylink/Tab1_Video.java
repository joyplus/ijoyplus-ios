package com.joyplus.joylink;

import java.io.File;
import java.util.ArrayList;
import java.util.Timer;
import java.util.TimerTask;

import android.app.ActionBar;
import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore.Files;
import android.provider.MediaStore.Video;
import android.provider.MediaStore.Video.VideoColumns;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.joyplus.joylink.Adapters.Tab1_Video_GridData;
import com.joyplus.joylink.Utils.BitmapUtils;
import com.joyplus.joylink.Utils.JoylinkUtils;
import com.slidingmenu.lib.SlidingMenu;
import com.umeng.analytics.MobclickAgent;

public class Tab1_Video extends BaseActivity implements
		AdapterView.OnItemClickListener, View.OnClickListener {
	private String TAG = "Tab1_Video";
	private App app;
	private AQuery aq;

	private ArrayList<Tab1_Video_GridData> dataStruct;
	private GridView gridView;
	private Tab2GridAdapter Tab2Adapter;
	private String OLD_String = null;
	private MenuFragment mContent;
	private SlidingMenu sm;
	private ImageButton mSlidingMenuButton;
	private ImageButton mSlidingMenuButtonL;

	private static final String EXTERNAL_MEDIA = "external";
	private static final Uri mBaseUri = Files.getContentUri(EXTERNAL_MEDIA);
	private static final Uri mWatchUriVideo = Video.Media.EXTERNAL_CONTENT_URI;

	// private MediaScannerConnection msc ;
	private BroadcastReceiver mMediaScannerReceiver;

	public Tab1_Video() {
		super("视频");
		// TODO Auto-generated constructor stub
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		if (Constant.DISPLAY.equalsIgnoreCase("800*480"))
			setContentView(R.layout.tab1_video_480);
		else
			setContentView(R.layout.tab1_video);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_list);
		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		mTextView.setText("视频");
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

		dataStruct = new ArrayList();
		Tab2Adapter = new Tab2GridAdapter();
		gridView.setAdapter(Tab2Adapter);

		Timer timer = new Timer();
		TimerTask task = new TimerTask() {
			@Override
			public void run() {
				Message msg = Message.obtain();
				msg.what = Constant.MSG_UPDATEDATA;
				mHandler.sendMessage(msg);
			}
		};
		timer.schedule(task, 100);

	}

	final Handler mHandler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			Bundle data = msg.getData();
			switch (msg.what) {
			case Constant.MSG_UPDATEDATA: {
				GetVideoData();
				scanningVideo();
				break;
			}
			}
		}
	};

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

	// listview的点击事件接口函数
	public void onItemClick(AdapterView adapterview, View view, int i, long l) {
		Tab1_Video_GridData m_Tab1_Video_GridData = (Tab1_Video_GridData) gridView
				.getItemAtPosition(i);
		if (m_Tab1_Video_GridData != null) {
			// app.MyToast(this, m_Tab1_Video_GridData.Pic_name,
			// Toast.LENGTH_LONG)
			// .show();
			Intent intent = new Intent(this, Tab1_Video_File.class);
			intent.putExtra("BUCKET_ID", m_Tab1_Video_GridData.bucket_id);
			intent.putExtra("BUCKET_NAME",
					m_Tab1_Video_GridData.bucket_display_name);
			try {
				startActivity(intent);
			} catch (ActivityNotFoundException ex) {
				Log.e(TAG, "Call Tab2_Video failed", ex);
			}
		} else {
			app.MyToast(this, "m_Tab1_Video_GridData is empty.");
		}
	}

	private void GetVideoData() {

		LoadVideoFromSDCard();

		Tab2Adapter.notifyDataSetChanged();

		gridView.setOnItemClickListener(this);
		aq.id(R.id.progressBar1).gone();
	}

	/**
	 * Async task for loading the images from the SD card.
	 */
	private void LoadVideoFromSDCard() {
		String[] mediaColumns = new String[] { VideoColumns._ID,
				VideoColumns.DATA, VideoColumns.DISPLAY_NAME,
				VideoColumns.SIZE, VideoColumns.TITLE, VideoColumns.DURATION,
				VideoColumns.BUCKET_ID, VideoColumns.BUCKET_DISPLAY_NAME };
		// String[] mediaColumns = new String[] { "_id", "_data",
		// "_display_name",
		// "_size", "title", "duration", "bucket_id",
		// "bucket_display_name" };

		Cursor cursor = null;
		try {
			cursor = getContentResolver().query(mWatchUriVideo, mediaColumns, // Which
					// columns
					// to
					// return
					null, // Return all rows
					null, null);
			while (cursor != null && cursor.moveToNext()) {
				if (dataStruct == null || dataStruct.size() == 0) {
					DataAdd(cursor);
				} else {
					if (OLD_String.indexOf(Integer.toString(cursor.getInt(6))
							+ "|") == -1) {
						DataAdd(cursor);
					}
				}
			}
		} catch (Throwable t) {
			Log.w(TAG, "cannot get title from: " + mWatchUriVideo, t);
		} finally {
			if (cursor != null)
				cursor.close();
		}

	}

	private void DataAdd(Cursor cursor) {

		int mDuration = cursor.getInt(5);
		if (mDuration > 0) {
			Tab1_Video_GridData m_Tab1_Video_GridData = new Tab1_Video_GridData();
			m_Tab1_Video_GridData._id = cursor.getInt(0);
			m_Tab1_Video_GridData._data = cursor.getString(1);
			m_Tab1_Video_GridData._display_name = cursor.getString(2);
			m_Tab1_Video_GridData._size = cursor.getString(3);
			m_Tab1_Video_GridData.title = cursor.getString(4);
			m_Tab1_Video_GridData.duration = cursor.getString(5);
			m_Tab1_Video_GridData.bucket_id = cursor.getInt(6);
			m_Tab1_Video_GridData.bucket_display_name = cursor.getString(7);
			if (OLD_String == null)
				OLD_String = Integer.toString(m_Tab1_Video_GridData.bucket_id)
						+ "|";
			else
				OLD_String = OLD_String
						+ Integer.toString(m_Tab1_Video_GridData.bucket_id)
						+ "|";
			m_Tab1_Video_GridData.localVideoThumbnail = Constant.PATH
					+ JoylinkUtils
							.getCacheFileName(m_Tab1_Video_GridData._data);

			File file = new File(m_Tab1_Video_GridData._data);
			if (file.exists())
				dataStruct.add(m_Tab1_Video_GridData);

		}
	}

	private void scanningVideo() {
		new Thread() {
			public void run() {
				runOnUiThread(new Runnable() {
					@Override
					public void run() {
						for (int i = 0; i < dataStruct.size(); i++) {
							File file = new File(Constant.PATH
									+ JoylinkUtils.getCacheFileName(dataStruct
											.get(i)._data));
							if (!file.exists())
								BitmapUtils.createVideoThumbnailtoSD(dataStruct
										.get(i)._data);
						}
					}
				});
			}
		}.start();
	}

	private static class ViewHolder {
		public ImageView mImageView;
		public TextView mName;
		public TextView mName1;
	}

	public class Tab2GridAdapter extends BaseAdapter {

		@Override
		public int getCount() {
			return dataStruct.size();
		}

		@Override
		public Tab1_Video_GridData getItem(int position) {
			return (Tab1_Video_GridData) dataStruct.get(position);
		}

		@Override
		public long getItemId(int position) {
			return position;
		}

		// 获取显示当前的view
		@Override
		public View getView(int i, View view, ViewGroup viewgroup) {

			Integer integer = Integer.valueOf(i);
			ViewHolder holder = null;

			if (view == null) {

				view = getLayoutInflater().inflate(
						R.layout.tab1_video_detail_grid, viewgroup, false);

				holder = new ViewHolder();

				holder.mImageView = (ImageView) view
						.findViewById(R.id.video_preview_img);

				holder.mName = (TextView) view
						.findViewById(R.id.txt_video_caption);
				// holder.mName1 = (TextView) view.findViewById(R.id.textView1);

				view.setTag(holder);
			} else {
				holder = (ViewHolder) view.getTag();
			}

			// 获取当前数据项的数据
			Tab1_Video_GridData m_Tab1_Video_GridData = (Tab1_Video_GridData) getItem(i);

			AQuery aqlist = aq.recycle(view);
			// if (m_Tab1_Video_GridData.duration != null
			// && Integer.parseInt(m_Tab1_Video_GridData.duration) > 0) {
			// aqlist.id(holder.mName1).text(
			// Utils.formatDuration(Integer
			// .parseInt(m_Tab1_Video_GridData.duration)));
			// }

			if (i == 0 || i == 1) {
				RelativeLayout.LayoutParams parms = new RelativeLayout.LayoutParams(
						RelativeLayout.LayoutParams.WRAP_CONTENT,
						RelativeLayout.LayoutParams.WRAP_CONTENT);
				parms.addRule(RelativeLayout.ALIGN_PARENT_TOP,
						RelativeLayout.TRUE);
				parms.topMargin = 30;
				aqlist.id(R.id.video_preview_bg).getView()
						.setLayoutParams(parms);
			}

			aqlist.id(holder.mName).text(
					m_Tab1_Video_GridData.bucket_display_name);

			File file = new File(m_Tab1_Video_GridData.localVideoThumbnail);
			if (file.exists()) {
				aqlist.id(holder.mImageView).image(file, 120);
			} else {
				Bitmap bm = BitmapUtils
						.createVideoThumbnail(m_Tab1_Video_GridData._data);
				if (bm != null) {
					aqlist.id(holder.mImageView).image(bm);
				}
			}

			// aqlist.dismiss();
			return view;
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
