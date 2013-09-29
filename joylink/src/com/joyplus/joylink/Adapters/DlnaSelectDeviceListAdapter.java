package com.joyplus.joylink.Adapters;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.dlcs.dlna.Stack.MediaRenderer;
import com.joyplus.joylink.R;

/*
 * 分类导航详情的数据适配器
 * */
public class DlnaSelectDeviceListAdapter extends ArrayAdapter {

	// listview的数据
	private Map viewMap;
	private AQuery aq;


	// 构造函数
	public DlnaSelectDeviceListAdapter(Activity activity, List list) {
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
					R.layout.dlna_select_device_list_adapter, null);

			// 获取当前数据项的数据
			MediaRenderer m_MediaRenderer = (MediaRenderer) getItem(i);
			TextView textView1 = (TextView) view1
					.findViewById(R.id.textView1);
			textView1.setText(m_MediaRenderer.friendlyName);
		}
		return view1;
	}

}
