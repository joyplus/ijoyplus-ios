package com.joyplus.joylink;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.ListFragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ListView;
	
public class MenuFragment extends Fragment{
	public Button homeButton;
	public Button mouseButton;
	public Button remoteControlButton;
	public Button SettingButton;
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

//		if (container == null) {
//	        return null;
//	    }
		
		View view1 = inflater.inflate(R.layout.menu_list, container, false);
		
//		this.homeButton = (Button)view1.findViewById(R.id.Button1);
//		
//		this.remoteControlButton = (Button)view1.findViewById(R.id.Button2);
//		
//		this.mouseButton = (Button)view1.findViewById(R.id.Button3);
//		
//		this.SettingButton = (Button)view1.findViewById(R.id.Button4);
		
		return view1;
	}

	@Override
	public void onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
		
//		String[] colors = getResources().getStringArray(R.array.color_names);
//		ArrayAdapter<String> colorAdapter = new ArrayAdapter<String>(getActivity(), 
//				android.R.layout.simple_list_item_1, android.R.id.text1, colors);
//		setListAdapter(colorAdapter);
	}	
//	@Override
//	public void onListItemClick(ListView lv, View v, int position, long id) {
//		Fragment newContent = null;
//		switch (position) {
//		case 0:
//			newContent = new ColorFragment(R.color.red);
//			break;
//		case 1:
//			newContent = new ColorFragment(R.color.green);
//			break;
//		case 2:
//			newContent = new ColorFragment(R.color.blue);
//			break;
//		case 3:
//			newContent = new ColorFragment(android.R.color.white);
//			break;
//		case 4:
//			newContent = new ColorFragment(android.R.color.black);
//			break;
//		}
//		if (newContent != null)
//			switchFragment(newContent);
//	}



//	// the meat of switching the above fragment
//	private void switchFragment(Fragment fragment) {
//		if (getActivity() == null)
//			return;
//		
//		if (getActivity() instanceof Tab1) {
//			Tab1 fca = (Tab1) getActivity();
//			fca.switchContent(fragment);
//		} else if (getActivity() instanceof ControlKey) {
//			ControlKey ra = (ControlKey) getActivity();
//			ra.switchContent(fragment);
//		}
//	}


}
