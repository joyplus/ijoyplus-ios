package com.joyplus.joylink.Adapters;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import android.app.Activity;
import android.graphics.Bitmap;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.RelativeLayout;

import com.androidquery.AQuery;
import com.joyplus.joylink.Constant;
import com.joyplus.joylink.R;
import com.joyplus.joylink.Utils.BitmapUtils;
import com.joyplus.joylink.Utils.JoylinkUtils;

/*
 * 分类导航详情的数据适配器
 * */
public class Tab1_Video_GridAdapter extends ArrayAdapter {

	// listview的数据
	private Map viewMap;
	private AQuery aq;
	private String mdata;

	// 构造函数
	public Tab1_Video_GridAdapter(Activity activity, List list) {
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
						R.layout.tab1_video_detail_grid_480, null);
			else
				view1 = ((Activity) getContext()).getLayoutInflater().inflate(
					R.layout.tab1_video_detail_grid, null);
			aq = new AQuery(view1);

			// 获取当前数据项的数据
			Tab1_Video_GridData m_Tab1_Video_GridData = (Tab1_Video_GridData) getItem(i);

			if (m_Tab1_Video_GridData.duration != null
					&& Integer.parseInt(m_Tab1_Video_GridData.duration) > 0) {
				aq.id(R.id.textView1).text(
						JoylinkUtils.formatDuration(Integer
								.parseInt(m_Tab1_Video_GridData.duration)));
			}

			aq.id(R.id.txt_video_caption).text(
					m_Tab1_Video_GridData.bucket_display_name);
			
			File file = new File(m_Tab1_Video_GridData.localVideoThumbnail);
			if (file.exists()) {
				aq.id(R.id.video_preview_img).image(file, 120);
			} else {
				Bitmap bm = BitmapUtils
						.createVideoThumbnail(m_Tab1_Video_GridData._data);
				if (bm != null) {
					aq.id(R.id.video_preview_img).image(bm);
				}
			}
			if (aq != null)
				aq.dismiss();
		}
		return view1;
	}
}
