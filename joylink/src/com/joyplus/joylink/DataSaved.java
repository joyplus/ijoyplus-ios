package com.joyplus.joylink;

import java.util.ArrayList;

import com.joyplus.joylink.Adapters.Tab1_Music_ListData;
import com.joyplus.joylink.Adapters.Tab1_Photo_GridData;
import com.joyplus.joylink.Adapters.Tab1_Video_GridData;

public class DataSaved {
	// 1.photo 2.video 3.music
	private int MODE;
	private int CurrentPlayItem;
	private ArrayList<Tab1_Photo_GridData> images_array = null;
	private ArrayList<Tab1_Video_GridData> video_array = null;
	private ArrayList<Tab1_Music_ListData> music_array = null;

	public DataSaved(int mODE) {
		super();
		MODE = mODE;
	}

	public int getMODE() {
		return MODE;
	}

	public int getCurrentPlayItem() {
		return CurrentPlayItem;
	}

	public void setCurrentPlayItem(int currentPlayItem) {
		CurrentPlayItem = currentPlayItem;
	}

	public ArrayList<Tab1_Photo_GridData> getImages_array() {
		return images_array;
	}

	public void setImages_array(ArrayList<Tab1_Photo_GridData> images_array) {
		this.images_array = images_array;
	}

	public ArrayList<Tab1_Video_GridData> getVideo_array() {
		return video_array;
	}

	public void setVideo_array(ArrayList<Tab1_Video_GridData> video_array) {
		this.video_array = video_array;
	}

	public ArrayList<Tab1_Music_ListData> getMusic_array() {
		return music_array;
	}

	public void setMusic_array(ArrayList<Tab1_Music_ListData> music_array) {
		this.music_array = music_array;
	}
}
