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
public class Tab1_Photo_GridAdapter extends ArrayAdapter {

	// listview的数据
	private Map viewMap;
	private AQuery aq;

	// 构造函数
	public Tab1_Photo_GridAdapter(Activity activity, List list) {
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
					R.layout.tab1_photo_file_detail_grid, null);
			aq = new AQuery(view1);
			
			if (i == 0 || i == 1 || i == 2) {
				RelativeLayout.LayoutParams parms = new RelativeLayout.LayoutParams(
						RelativeLayout.LayoutParams.WRAP_CONTENT,
						RelativeLayout.LayoutParams.WRAP_CONTENT);
				parms.addRule(RelativeLayout.ALIGN_PARENT_TOP,
						RelativeLayout.TRUE);
				parms.topMargin = 30;
				aq.id(R.id.image_preview_bg).getView().setLayoutParams(parms);
			}
			
			// 获取当前数据项的数据
			Tab1_Photo_GridData m_Tab1_Photo_GridData = (Tab1_Photo_GridData) getItem(i);

//			aq.id(R.id.textView1).text(
//					"共 "+ Integer.toString(m_Tab1_Photo_GridData.num) + " 张");

//			File file = new File(m_Tab1_Photo_GridData._data);
			
			File file = new File(m_Tab1_Photo_GridData._data);
			if (file.exists()) {
				aq.id(R.id.video_preview_img).image(file, 120);
			}

			if (aq != null)
				aq.dismiss();
		}
		return view1;
	}
}
