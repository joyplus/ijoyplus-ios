package com.joyplus.joylink.Adapters;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.RelativeLayout;

import com.androidquery.AQuery;
import com.joyplus.joylink.Constant;
import com.joyplus.joylink.R;

/*
 * 分类导航详情的数据适配器
 * */
public class Tab1_Photo_Adapter extends ArrayAdapter {

	// listview的数据
	private Map viewMap;
	private AQuery aq;

	// 构造函数
	public Tab1_Photo_Adapter(Activity activity, List list) {
		super(activity, 0, list);

		viewMap = new HashMap();
	}

	// 获取显示当前的view
	public View getView(int i, View view, ViewGroup viewgroup) {
		Integer integer = Integer.valueOf(i);
		View view1 = (View) viewMap.get(integer);

		if (view1 == null) {
			// 加载布局文件
			if (Constant.DISPLAY.equalsIgnoreCase("800*480"))
				view1 = ((Activity) getContext()).getLayoutInflater().inflate(
						R.layout.tab1_photo_detail_grid_480, null);
			else
				view1 = ((Activity) getContext()).getLayoutInflater().inflate(
						R.layout.tab1_photo_detail_grid, null);
			aq = new AQuery(view1);

			// 获取当前数据项的数据
			Tab1_Photo_GridData m_Tab1_Photo_GridData = (Tab1_Photo_GridData) getItem(i);

			aq.id(R.id.txt_video_caption)
					.text(m_Tab1_Photo_GridData.bucket_display_name + "("
							+ Integer.toString(m_Tab1_Photo_GridData.num) + ")");

			// aq.id(R.id.txt_video_caption).text(m_Tab1_Photo_GridData.title);
			if (i == 0 || i == 1) {
				RelativeLayout.LayoutParams parms = new RelativeLayout.LayoutParams(
						RelativeLayout.LayoutParams.WRAP_CONTENT,
						RelativeLayout.LayoutParams.WRAP_CONTENT);
				parms.addRule(RelativeLayout.ALIGN_PARENT_TOP,
						RelativeLayout.TRUE);
				parms.topMargin = 30;
				aq.id(R.id.video_preview_bg).getView().setLayoutParams(parms);
			}

			File file = new File(m_Tab1_Photo_GridData._data);
			if (file.exists()) {
				aq.id(R.id.video_preview_img).image(file, 113);
			}

			if (aq != null)
				aq.dismiss();
			// Integer integer1 = Integer.valueOf(i);
			// Object obj = viewMap.put(integer1, view1);
		}
		return view1;
	}
}
