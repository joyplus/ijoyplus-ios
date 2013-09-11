package com.joyplus.joylink.Adapters;

import android.os.Parcel;
import android.os.Parcelable;

public class Tab1_Music_ListData  implements Parcelable{
	public int _id;
	public String _data;
	public String _display_name;
	public int _size;
	public String mime_type;
	public String artist;
	public String date_modified;
	public String album;
	public String title;
	public int duration;
	public String Dir;
	public int num;
	public String album_art;
	

	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}
	public Tab1_Music_ListData() {
		
	}
	@Override
	public void writeToParcel(Parcel arg0, int arg1) {
		// TODO Auto-generated method stub
		arg0.writeInt(_id);
		arg0.writeString(_data);
		arg0.writeString(_display_name);
		arg0.writeInt(_size);
		arg0.writeString(mime_type);
		arg0.writeString(artist);
		arg0.writeString(date_modified);
		arg0.writeString(album);
		arg0.writeString(title);
		arg0.writeInt(duration);
		arg0.writeString(Dir);
		arg0.writeInt(num);
		arg0.writeString(album_art);
	}
	public static final Parcelable.Creator<Tab1_Music_ListData> CREATOR = new Creator<Tab1_Music_ListData>() {    
        public Tab1_Music_ListData createFromParcel(Parcel source) {    
        	Tab1_Music_ListData m_Tab3ListData = new Tab1_Music_ListData();    
       	 m_Tab3ListData._id = source.readInt();
       	 m_Tab3ListData._data = source.readString();
       	 m_Tab3ListData._display_name = source.readString();
       	m_Tab3ListData._size = source.readInt();
       	m_Tab3ListData.mime_type = source.readString();
       	m_Tab3ListData.artist = source.readString();
       	m_Tab3ListData.date_modified = source.readString();
       	m_Tab3ListData.album = source.readString();
       	 m_Tab3ListData.title = source.readString();
       	 m_Tab3ListData.duration = source.readInt();
       	 m_Tab3ListData.Dir = source.readString();
       	 m_Tab3ListData.num = source.readInt();
       	m_Tab3ListData.album_art = source.readString();
            return m_Tab3ListData;    
        }    
        public Tab1_Music_ListData[] newArray(int size) {    
            return new Tab1_Music_ListData[size];    
        }    
    };    
}
