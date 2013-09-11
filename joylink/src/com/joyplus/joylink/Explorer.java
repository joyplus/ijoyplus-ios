package com.joyplus.joylink;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

import android.app.ActionBar;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.umeng.analytics.MobclickAgent;

public class Explorer extends BaseActivity implements View.OnClickListener {
	public Explorer() {
		super("浏览器");
		// TODO Auto-generated constructor stub
	}

	private String TAG = "Explorer";
	private App app;
	private AQuery aq;

	private ArrayList<ExplorerAppData> mData;
	private ArrayList<ExplorerHistroryData> mDataHistory;
	private ListView ItemsListView;
	private ListView ItemsListViewHistrory;
	private MyListAdapter mAdapter;
	private MyListHistroryAdapter mAdapterHistrory;

	private ImageButton mSlidingMenuButton;
	private ImageButton mSlidingMenuButtonL;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.explorer);
		app = (App) getApplication();
		aq = new AQuery(this);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_list);
		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		mTextView.setText("浏览器");
		mSlidingMenuButtonL = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mSlidingMenuButtonL.setOnClickListener(this);
		mSlidingMenuButton = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mSlidingMenuButton.setOnClickListener(this);

		aq.id(R.id.relativeLayoutList).gone();
		ItemsListView = (ListView) findViewById(R.id.listView1);
		ItemsListView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				ExplorerAppData mExplorerAppData = mData.get(position);
				sendURL(mExplorerAppData.str1);
			}
		});

		ItemsListViewHistrory = (ListView) findViewById(R.id.listView2);
		ItemsListViewHistrory.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				ExplorerHistroryData m_date = mDataHistory.get(position);
				sendURL(m_date.url);
			}
		});

		mData = new ArrayList<ExplorerAppData>();
		mAdapter = new MyListAdapter(this, mData, R.layout.explorer_list);
		ItemsListView.setAdapter(mAdapter);
		setListViewHeightBasedOnChildren(ItemsListView);

		mDataHistory = new ArrayList<ExplorerHistroryData>();
		mAdapterHistrory = new MyListHistroryAdapter(this, mDataHistory,
				R.layout.explorer_history_list);
		ItemsListViewHistrory.setAdapter(mAdapterHistrory);
		setListViewHeightBasedOnChildren(ItemsListViewHistrory);

		GetData();
		GetHistoryData();

		Timer timer = new Timer();

		timer.schedule(new TimerTask() {
			@Override
			public void run() {
				EditText mEditText = (EditText) findViewById(R.id.input_message_edit_text);
				mEditText.setCursorVisible(true);
				// aq.id(R.id.input_message_edit_text).getEditText().setCursorVisible(true);
				InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
				imm.toggleSoftInput(0, InputMethodManager.HIDE_NOT_ALWAYS);
			}
		}, 500);

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

	private void GetHistoryData() {

		String mSaveData = app.GetServiceData("Explorer");
		if (mSaveData != null) {
			String[] m_str = mSaveData.split("\\|");
			for (int i = m_str.length / 2; i > 0; i--) {
				ExplorerHistroryData m_date = new ExplorerHistroryData();
				m_date.time = m_str[i * 2 - 2];
				m_date.url = URLDecoder.decode(m_str[i * 2 - 1]);
				mDataHistory.add(m_date);
			}
			if (mDataHistory.size() > 0)
				aq.id(R.id.relativeLayoutList2).visible();
			else
				aq.id(R.id.relativeLayoutList2).gone();
		} else
			aq.id(R.id.relativeLayoutList2).gone();
	}

	private void GetData() {
		// for (int i = 0; i < 3; i++) {
		ExplorerAppData mExplorerAppData = new ExplorerAppData();
		mExplorerAppData.name = "joyplus官网";
		mExplorerAppData.str1 = "www.joyplus.tv";
		mData.add(mExplorerAppData);
		// }

		mExplorerAppData = new ExplorerAppData();
		mExplorerAppData.name = "百度";
		mExplorerAppData.str1 = "www.baidu.com";
		mData.add(mExplorerAppData);

		mExplorerAppData = new ExplorerAppData();
		mExplorerAppData.name = "hao123";
		mExplorerAppData.str1 = "www.hao123.com";
		mData.add(mExplorerAppData);

		mExplorerAppData = new ExplorerAppData();
		mExplorerAppData.name = "58同城";
		mExplorerAppData.str1 = "www.58.com";
		mData.add(mExplorerAppData);

		mExplorerAppData = new ExplorerAppData();
		mExplorerAppData.name = "优酷";
		mExplorerAppData.str1 = "www.youku.com";
		mData.add(mExplorerAppData);

		mExplorerAppData = new ExplorerAppData();
		mExplorerAppData.name = "音悦台";
		mExplorerAppData.str1 = "www.yinyuetai.com";
		mData.add(mExplorerAppData);

		mExplorerAppData = new ExplorerAppData();
		mExplorerAppData.name = "淘宝网";
		mExplorerAppData.str1 = "www.taobao.com";
		mData.add(mExplorerAppData);

		mExplorerAppData = new ExplorerAppData();
		mExplorerAppData.name = "奇艺网";
		mExplorerAppData.str1 = "www.qiyi.com";
		mData.add(mExplorerAppData);

		mExplorerAppData = new ExplorerAppData();
		mExplorerAppData.name = "糗事百科";
		mExplorerAppData.str1 = "www.qiushibaike.com";
		mData.add(mExplorerAppData);

		mExplorerAppData = new ExplorerAppData();
		mExplorerAppData.name = "星座网";
		mExplorerAppData.str1 = "www.xingzuowu.com";
		mData.add(mExplorerAppData);

		mExplorerAppData = new ExplorerAppData();
		mExplorerAppData.name = "太平洋女性网";
		mExplorerAppData.str1 = "www.pclady.com.cn";
		mData.add(mExplorerAppData);

		mAdapter.notifyDataSetChanged();

	}

	public void OnClickTopLeft(View v) {

	}

	public void OnClickTopRight(View v) {
		InputMethodManager imm = (InputMethodManager) this
				.getSystemService(Context.INPUT_METHOD_SERVICE);
		aq.id(R.id.input_message_edit_text).getEditText()
				.setCursorVisible(false);// 失去光标
		imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
		checkListVisibility();
	}

	private void checkListVisibility() {
		if (aq.id(R.id.relativeLayoutList).getView().getVisibility() == View.VISIBLE) {
			// Its visible
			if (mDataHistory.size() > 0)
				aq.id(R.id.relativeLayoutList2).visible();
			aq.id(R.id.relativeLayoutList).gone();
		} else {
			aq.id(R.id.relativeLayoutList).visible();
			aq.id(R.id.relativeLayoutList2).gone();
			// Either gone or invisible
		}
	}

	public void OnClickBSSend(View v) {
		String url = aq.id(R.id.input_message_edit_text).getText().toString()
				.trim();
		if (url.length() > 0) {
			// {explorer:[{ time: [STRING], url: [STRING]}] }
			try {
				String mSaveData = app.GetServiceData("Explorer");
				String findString = "|" + URLEncoder.encode(url, "UTF-8") + "|";
				if (mSaveData == null || mSaveData.indexOf(findString) == -1) {
					ExplorerHistroryData m_date = new ExplorerHistroryData();
					m_date.time = new SimpleDateFormat("MM-dd HH:mm")
							.format(new Date());
					m_date.url = url;
					mDataHistory.add(0, m_date);
					mAdapterHistrory.notifyDataSetChanged();
					ItemsListViewHistrory.invalidate();
					aq.id(R.id.relativeLayoutList2).visible();

					mSaveData = mSaveData + m_date.time + "|"
							+ URLEncoder.encode(url, "UTF-8") + "|";
					app.SaveServiceData("Explorer", mSaveData);
				}
				sendURL(url);
			} catch (UnsupportedEncodingException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}
	}

	public void OnClickDelHistoryAll(View v) {

		mDataHistory.clear();
		mAdapterHistrory.notifyDataSetChanged();
		ItemsListViewHistrory.invalidate();
		app.DeleteServiceData("Explorer");
		aq.id(R.id.relativeLayoutList2).gone();
	}

	public void sendURL(String url) {
		super.sendURL(url);
		GotoControlMouse();
	}

	private void GotoControlMouse() {
		Intent intent = new Intent(this, ControlMouse.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
		try {
			startActivity(intent);
		} catch (ActivityNotFoundException ex) {
			Log.e("Main", "Call MouseMode failed", ex);
		}
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

	private class MyListAdapter extends BaseAdapter {
		private Context mcontext;
		private LayoutInflater mlayoutInflater;
		private ArrayList<ExplorerAppData> mlistData = null;
		private int resourelayoutid;

		public MyListAdapter(Context context,
				ArrayList<ExplorerAppData> listData, int layout_item) {
			mcontext = context;
			mlayoutInflater = LayoutInflater.from(mcontext);
			mlistData = listData;
			resourelayoutid = layout_item;
		}

		@Override
		public int getCount() {
			// TODO Auto-generated method stub
			return mlistData.size();
		}

		@Override
		public Object getItem(int position) {
			// TODO Auto-generated method stub
			return null;
		}

		@Override
		public long getItemId(int position) {
			// TODO Auto-generated method stub
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			ViewHolder vh = null;
			if (convertView == null) {
				vh = new ViewHolder();
				convertView = mlayoutInflater.inflate(resourelayoutid, null);
				vh.textView1 = (TextView) convertView
						.findViewById(R.id.textView1);
				vh.textView2 = (TextView) convertView
						.findViewById(R.id.textView2);
				convertView.setTag(vh);
			} else {
				vh = (ViewHolder) convertView.getTag();
			}

			vh.textView1.setText(mlistData.get(position).name);
			vh.textView2.setText(mlistData.get(position).str1);
			return convertView;
		}

	}

	public class ViewHolder {

		public TextView textView1;
		public TextView textView2;

	}

	public class ExplorerAppData {

		public String name;
		public String str1;

	}

	public class ExplorerHistroryData {

		public String url;
		public String time;

	}

	private class MyListHistroryAdapter extends BaseAdapter {
		private Context mcontext;
		private LayoutInflater mlayoutInflater;
		private ArrayList<ExplorerHistroryData> mlistData = null;
		private int resourelayoutid;

		public MyListHistroryAdapter(Context context,
				ArrayList<ExplorerHistroryData> listData, int layout_item) {
			mcontext = context;
			mlayoutInflater = LayoutInflater.from(mcontext);
			mlistData = listData;
			resourelayoutid = layout_item;
		}

		@Override
		public int getCount() {
			// TODO Auto-generated method stub
			return mlistData.size();
		}

		@Override
		public Object getItem(int position) {
			// TODO Auto-generated method stub
			return null;
		}

		@Override
		public long getItemId(int position) {
			// TODO Auto-generated method stub
			return position;
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			ViewHolder vh = null;
			if (convertView == null) {
				vh = new ViewHolder();
				convertView = mlayoutInflater.inflate(resourelayoutid, null);
				vh.textView1 = (TextView) convertView
						.findViewById(R.id.textView1);
				vh.textView2 = (TextView) convertView
						.findViewById(R.id.textViewTime);
				convertView.setTag(vh);
			} else {
				vh = (ViewHolder) convertView.getTag();
			}
			vh.textView1.setText(mlistData.get(position).url);
			vh.textView2.setText(mlistData.get(position).time);
			return convertView;
		}

	}

	public static void setListViewHeightBasedOnChildren(ListView listView) {
		ListAdapter listAdapter = listView.getAdapter();
		if (listAdapter == null) {
			// pre-condition
			return;
		}

		int totalHeight = 0;
		for (int i = 0; i < listAdapter.getCount(); i++) {
			View listItem = listAdapter.getView(i, null, listView);
			listItem.measure(0, 0);
			totalHeight += listItem.getMeasuredHeight();
		}

		ViewGroup.LayoutParams params = listView.getLayoutParams();
		params.height = totalHeight
				+ (listView.getDividerHeight() * (listAdapter.getCount() - 1));
		listView.setLayoutParams(params);
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
