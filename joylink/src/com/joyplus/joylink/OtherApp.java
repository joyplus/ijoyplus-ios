package com.joyplus.joylink;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.ActionBar;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.ArrayAdapter;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.slidingmenu.lib.SlidingMenu;
import com.wind.s1mobile.common.AppDataList;
import com.wind.s1mobile.common.AppInfoData;
import com.wind.s1mobile.common.Protocol.ControlEvent;
import com.wind.s1mobile.common.S1Constant;
import com.wind.s1mobile.common.Utils;
import com.wind.s1mobile.common.packet.ControlEventPacket;
import com.wind.s1mobile.receiver.TcpServiceThread;

public class OtherApp extends BaseActivity implements View.OnClickListener {
	public OtherApp() {
		super("OtherApp");
		// TODO Auto-generated constructor stub
	}

	private String TAG = "OtherApp";
	private App app = null;
	private AQuery aq;
	private TcpServiceThread mTcpServiceThread = null;
	private Thread thread;
	private GridView mGridView = null;
	private ArrayList<AppInfoData> mgridData = null;
	private GridAdapter mGridAdapter = null;
	private boolean isRegister = false;
	private SlidingMenu sm;
	private ImageButton mSlidingMenuButton;
	private ImageButton mSlidingMenuButtonL;
	private ImageButton mMenuButtonRefresh;
	private MenuFragment mContent;

	public BroadcastReceiver controlReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {

			String action = intent.getAction();

			if (action.equals(S1Constant.ACTION_RECEIVER_APP_INFO)) {
				AppDataList mgridData = (AppDataList) intent
						.getSerializableExtra(S1Constant.INTENT_BUNDLE_APP_INFO);
				LoadDataList(mgridData);
			}
		}
	};

	public Handler mSyncHandler = new Handler() {

		@Override
		public void handleMessage(Message msg) {
			// TODO Auto-generated method stub
			int what = msg.what;
			if (ControlEvent.SYNC_LAUNCHER_LIST_INFO.getId() == what) {
				AppDataList adl = (AppDataList) msg.obj;
				System.out.println("obtain Launcher list Info");
				// LoadDataList(adl);
			}
		}

	};

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.other_app);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_list_app);
		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		mTextView.setText("应用程序");
		mSlidingMenuButtonL = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mSlidingMenuButtonL.setOnClickListener(this);

		mMenuButtonRefresh = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.menuButtonRefresh);
		mMenuButtonRefresh.setOnClickListener(this);

		mSlidingMenuButton = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mSlidingMenuButton.setOnClickListener(this);

		app = (App) getApplicationContext();
		aq = new AQuery(this);
		findViewById(R.id.textViewJP).setVisibility(View.VISIBLE);
		mGridView = (GridView) findViewById(R.id.gridView1);
		mGridView.setSelector(new ColorDrawable(Color.TRANSPARENT));

		// RequestAppDateListInfo() ;
		mGridView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
				RequestOpenApkItem(position);

			}
		});
		mGridView.setOnItemLongClickListener(new OnItemLongClickListener() {

			@Override
			public boolean onItemLongClick(AdapterView<?> parent, View view,
					int position, long id) {
				// TODO Auto-generated method stub
				return false;
			}

		});

		AppDataList mgridData = app.getOtherAppData();
		if (mgridData == null) {
			isRegister = true;
			// 动态注册广播消息
			IntentFilter counterActionFilter = new IntentFilter(
					S1Constant.ACTION_RECEIVER_APP_INFO);
			registerReceiver(controlReceiver, counterActionFilter);

		} else {
			isRegister = false;
			LoadDataList(mgridData);
		}

		RequestAppDateListInfo();
		// GetData() ;
	}

	@Override
	public void onClick(View view) {
		if (view == mSlidingMenuButton) {
			getSlidingMenu().toggle();
		} else if (view == mMenuButtonRefresh) {
			if (!isRegister) {
				isRegister = true;
				// 动态注册广播消息
				IntentFilter counterActionFilter = new IntentFilter(
						S1Constant.ACTION_RECEIVER_APP_INFO);
				registerReceiver(controlReceiver, counterActionFilter);
			}
			RequestAppDateListInfo();
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
		if (isRegister)
			unregisterReceiver(controlReceiver);
		if (thread != null) {
			thread.interrupt();
			thread = null;
		}
		if (aq != null)
			aq.dismiss();
		super.onDestroy();
	}

	private void GetData() {
		for (int i = 0; i < 5; i++) {
			AppInfoData mAppInfoData = new AppInfoData();
			mAppInfoData.title = "悦视频";
			mAppInfoData.className = "在线视频应用";
			mgridData.add(mAppInfoData);
		}
		mGridAdapter.notifyDataSetChanged();

	}

	private void RequestAppDateListInfo() {
		mTcpServiceThread = app.getmTcpServiceThread();
		if (mTcpServiceThread == null) {
			mTcpServiceThread = new TcpServiceThread(this, mSyncHandler);
			app.setmTcpServiceThread(mTcpServiceThread);
			thread = new Thread(mTcpServiceThread);
			thread.start();

		}
		ControlEventPacket controlEventPacket = new ControlEventPacket();
		controlEventPacket
				.setControlEvent(ControlEvent.SYNC_LAUNCHER_LIST_INFO);
		sendTouchEvent(controlEventPacket);

	}

	private void RequestOpenApkItem(int position) {
		if (mgridData.get(position).packegeName
				.equalsIgnoreCase("com.android.browser")) {
			Intent intent = new Intent(this, Explorer.class);
			intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
			try {
				startActivity(intent);
			} catch (ActivityNotFoundException ex) {
				Log.e(TAG, "Call Explorer failed", ex);
			}
			return;
		}
		// TODO Auto-generated method stub
		ControlEventPacket controlEventPacket = new ControlEventPacket();
		controlEventPacket
				.setControlEvent(ControlEvent.OPEN_LAUNCHER_ITEM_INFO);
		AppInfoData appData = new AppInfoData();

		appData.packegeName = mgridData.get(position).packegeName;
		appData.className = mgridData.get(position).className;
		controlEventPacket.setAppsItemInfo(appData);
		sendTouchEvent(controlEventPacket);

		if (app.getMyPackegeName() != null
				&& app.getMyPackegeName().length() > 0) {
			KillApp(app.getMyPackegeName());
			app.setMyPackegeName(appData.packegeName);
		}
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

	private void LoadDataList(AppDataList adi) {
		System.out.println("LoadData list for adpater");
		app.setOtherAppData(adi);

		mgridData = adi.mappData;

		// String str1 = null;
		// int mSize = mgridData.size();
		// for (int i = mSize - 1; i >= 0; i--) {
		// System.out.println("Title:--" + mgridData.get(i).title.toString());
		// str1 = mgridData.get(i).title.toString();
		//
		// if ((str1.indexOf("豆瓣") == -1) && (str1.indexOf("酷狗音乐") == -1)
		// && (str1.indexOf("黄金矿工") == -1)
		// && (str1.indexOf("PPTV") == -1)
		// && (str1.indexOf("网易新闻") == -1)) {
		// mgridData.remove(i);
		// }
		//
		// }
		// getBrowserApp();//增加一项
		// mgridData = new ArrayList<AppInfoData>();
		mGridAdapter = new GridAdapter(this, mgridData);
		mGridView.setAdapter(mGridAdapter);
		// mGridAdapter.notifyDataSetChanged();
		findViewById(R.id.textViewJP).setVisibility(View.GONE);
	}

	/**
	 * 查询手机内非系统应用
	 * 
	 * @param context
	 * @return
	 */
	public void getBrowserApp() {
		List<PackageInfo> apps = new ArrayList<PackageInfo>();
		PackageManager pManager = getPackageManager();
		// 获取手机内所有应用
		List<PackageInfo> paklist = pManager.getInstalledPackages(0);
		for (int i = 0; i < paklist.size(); i++) {
			PackageInfo pak = (PackageInfo) paklist.get(i);
			AppInfoData mNewInfoData = new AppInfoData();
			if (pak.packageName.equalsIgnoreCase("com.android.browser")) {
				Bitmap bitmap = ((BitmapDrawable) pManager
						.getApplicationIcon(pak.applicationInfo)).getBitmap();
				ByteArrayOutputStream stream = new ByteArrayOutputStream();
				bitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream);
				mNewInfoData.icon = stream.toByteArray();
				mNewInfoData.title = pManager.getApplicationLabel(
						pak.applicationInfo).toString();
				mNewInfoData.packegeName = "com.android.browser";

				mgridData.add(0, mNewInfoData);
			}
			// 判断是否为非系统预装的应用程序
			// if ((pak.applicationInfo.flags & pak.applicationInfo.FLAG_SYSTEM)
			// <= 0) {
			// // customs applications
			// apps.add(pak);
			// }
		}
	}

	public void OnClickTopLeft(View v) {
		// Intent intent = new Intent(this, Main.class);
		// try {
		// startActivity(intent);
		// finish();
		// } catch (ActivityNotFoundException ex) {
		// Log.e(TAG, "Call Main failed", ex);
		// }
	}

	public void OnClickTopRight(View v) {

	}

	public class GridAdapter extends ArrayAdapter {

		// listview的数据
		private Map viewMap;

		// 构造函数
		public GridAdapter(Activity activity, List list) {
			super(activity, 0, list);

			this.viewMap = new HashMap();
		}

		// 获取显示当前的view
		public View getView(int i, View view, ViewGroup viewgroup) {
			Integer integer = Integer.valueOf(i);
			View view1 = (View) viewMap.get(integer);

			if (view1 == null) {
				// 加载布局文件
				view1 = ((Activity) getContext()).getLayoutInflater().inflate(
						R.layout.other_app_list, null);

				// 获取当前数据项的数据
				AppInfoData m_AppInfoData = (AppInfoData) getItem(i);
				TextView textView1 = (TextView) view1
						.findViewById(R.id.textView1);
				textView1.setText(m_AppInfoData.title);

				// TextView textView2 = (TextView) view1
				// .findViewById(R.id.textView2);
				// textView2.setText(m_AppInfoData.packegeName);

				if (m_AppInfoData.icon != null) {
					ImageView mImageView = (ImageView) view1
							.findViewById(R.id.imageView1);
					// mImageView
					// .setImageBitmap(Utils.Bytes2Bimap(m_AppInfoData.icon));
					mImageView.setBackgroundDrawable(new BitmapDrawable(Utils
							.Bytes2Bimap(m_AppInfoData.icon)));
				}

			}
			return view1;
		}

	}

	private void KillApp(String apkName) {
		// TODO Auto-generated constructor stub
		ControlEventPacket controlEventPacket = new ControlEventPacket();
		controlEventPacket.setControlEvent(ControlEvent.PAUSE_MUSIC);
		
		AppInfoData appData = new AppInfoData();
		appData.packegeName = apkName;
		
		controlEventPacket.setAppsItemInfo(appData);
		sendTouchEvent(controlEventPacket);
		
		controlEventPacket.setControlEvent(ControlEvent.CLOSE_APK);
		controlEventPacket.setAppsItemInfo(appData);
		sendTouchEvent(controlEventPacket);
		
//		ControlEventPacket controlEventPacket = new ControlEventPacket();
//		controlEventPacket.setControlEvent(ControlEvent.CLOSE_APK);
//		AppInfoData appData = new AppInfoData();
//		appData.packegeName = apkName;
//		controlEventPacket.setAppsItemInfo(appData);
//		sendTouchEvent(controlEventPacket);

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
