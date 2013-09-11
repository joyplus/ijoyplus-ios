package com.joyplus.joylink;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.net.wifi.ScanResult;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.umeng.analytics.MobclickAgent;

public class WiFi extends Activity implements AdapterView.OnItemClickListener {
	private String TAG = "WiFi";
	private App app;
	private AQuery aq;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.wifi);
		app = (App) getApplication();
		aq = new AQuery(this);

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
	public void onItemClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
		// TODO Auto-generated method stub
		
	}
	
	public class mainListAdapter extends ArrayAdapter {

		// listview的数据
		private Map viewMap;

		// 构造函数
		public mainListAdapter(Activity activity, List list) {
			super(activity, 0, list);

			viewMap = new HashMap();
		}

		// 获取显示当前的view
		public View getView(int i, View view, ViewGroup viewgroup) {
			Integer integer = Integer.valueOf(i);
			View view1 = (View) viewMap.get(integer);

			if (view1 == null) {
				// 加载布局文件
				view1 = ((Activity) getContext()).getLayoutInflater().inflate(
						R.layout.wifi_list_item, null);

				// 获取当前数据项的数据
				ScanResult m_ScanResult = (ScanResult) getItem(i);
				TextView textView1 = (TextView) view1
						.findViewById(R.id.textView1);

				textView1.setText(m_ScanResult.SSID);
			}
			return view1;
		}

	}


}
