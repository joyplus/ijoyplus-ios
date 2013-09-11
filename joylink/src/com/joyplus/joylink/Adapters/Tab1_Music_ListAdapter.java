package com.joyplus.joylink.Adapters;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import com.androidquery.AQuery;
import com.joyplus.joylink.R;

/*
 * 分类导航详情的数据适配器
 * */
public class Tab1_Music_ListAdapter extends ArrayAdapter {

	// listview的数据
	private Map viewMap;
	private AQuery aq;


	// 构造函数
	public Tab1_Music_ListAdapter(Activity activity, List list) {
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
					R.layout.tab1_music_detail_list, null);
			aq = new AQuery(view1);

			// 获取当前数据项的数据
			Tab1_Music_ListData m_Tab3ListData = (Tab1_Music_ListData) getItem(i);
			
			if (m_Tab3ListData.album_art != null) {
				File file = new File(m_Tab3ListData.album_art);
				if (file.exists()) {
					aq.id(R.id.imageView1).image(file, 114);
				}
			}
			aq.id(R.id.txt_video_caption).text(m_Tab3ListData.Dir);
			aq.id(R.id.textView1).text("共 "+ Integer.toString(m_Tab3ListData.num) + " 首");
			if (aq != null)
				aq.dismiss();
		}
		return view1;
	}

}
