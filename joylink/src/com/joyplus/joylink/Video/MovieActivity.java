/*
 * Copyright (C) 2007 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.joyplus.joylink.Video;

import java.util.ArrayList;

import com.dlcs.dlna.Stack.MediaRenderer;
import com.joyplus.joylink.App;
import com.joyplus.joylink.DataSaved;
import com.joyplus.joylink.R;
import com.joyplus.joylink.Adapters.Tab1_Video_GridData;
import com.joyplus.joylink.Dlna.DlnaSelectDevice;
import com.joyplus.joylink.Dlna.DlnaVideoPlay;

import android.app.ActionBar;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.ActivityInfo;
import android.database.Cursor;
import android.media.AudioManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.IBinder;
import android.provider.MediaStore;
import android.provider.MediaStore.Video.VideoColumns;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ShareActionProvider;
import android.widget.TextView;

/**
 * This activity plays a video from a specified URI.
 */
public class MovieActivity extends Activity implements OnClickListener{
    @SuppressWarnings("unused")
    private static final String TAG = "MovieActivity";

    private MoviePlayer mPlayer;
    private boolean mFinishOnCompletion;
    
    private App app;
	private String prod_url = null;
	private String prod_name = null;
	private DlnaSelectDevice mMyService;
	private DataSaved mDataSaved =null;
	private ImageButton mButtonDlna;
	private ImageButton mButtonBack;

	private ServiceConnection mServiceConnection = new ServiceConnection() {
		public void onServiceConnected(ComponentName name, IBinder service) {
			// TODO Auto-generated method stub
			mMyService = ((DlnaSelectDevice.MyBinder) service).getService();
		}

		public void onServiceDisconnected(ComponentName name) {
			// TODO Auto-generated method stub

		}
	};
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_ACTION_BAR);
        requestWindowFeature(Window.FEATURE_ACTION_BAR_OVERLAY);
        
        setContentView(R.layout.movie_view);

        Intent intent = getIntent();
		prod_name = intent.getStringExtra("title");
		prod_url = intent.getStringExtra("prod_url");
		
		app = (App) getApplication();
		mDataSaved = app.getDataSaved();
		
        View rootView = findViewById(R.id.root);
        initializeActionBar(intent);
        mFinishOnCompletion = intent.getBooleanExtra(
                MediaStore.EXTRA_FINISH_ON_COMPLETION, true);
        mPlayer = new MoviePlayer(rootView, this, Uri.parse(prod_url), savedInstanceState,
                !mFinishOnCompletion) {
            @Override
            public void onCompletion() {
                if (mFinishOnCompletion) {
                    finish();
                }
            }
        };
        if (intent.hasExtra(MediaStore.EXTRA_SCREEN_ORIENTATION)) {
            int orientation = intent.getIntExtra(
                    MediaStore.EXTRA_SCREEN_ORIENTATION,
                    ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED);
            if (orientation != getRequestedOrientation()) {
                setRequestedOrientation(orientation);
            }
        }
        Window win = getWindow();
        WindowManager.LayoutParams winParams = win.getAttributes();
        winParams.buttonBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_OFF;
        winParams.flags |= WindowManager.LayoutParams.FLAG_FULLSCREEN;
        win.setAttributes(winParams);
        
    	Intent i = new Intent();
		i.setClass(this, DlnaSelectDevice.class);
		bindService(i, mServiceConnection, BIND_AUTO_CREATE);
    }

    private void initializeActionBar(Intent intent) {
        ActionBar actionBar = getActionBar();
        actionBar.setDisplayOptions(ActionBar.DISPLAY_HOME_AS_UP,
                ActionBar.DISPLAY_HOME_AS_UP);
//        String title = intent.getStringExtra(Intent.EXTRA_TITLE);
//        mUri = intent.getData();
//        if (title == null) {
//            Cursor cursor = null;
//            try {
//                cursor = getContentResolver().query(mUri,
//                        new String[] {VideoColumns.TITLE}, null, null, null);
//                if (cursor != null && cursor.moveToNext()) {
//                    title = cursor.getString(0);
//                }
//            } catch (Throwable t) {
//                Log.w(TAG, "cannot get title from: " + intent.getDataString(), t);
//            } finally {
//                if (cursor != null) cursor.close();
//            }
//        }
//        if (title != null) actionBar.setTitle(title);
        
        actionBar.setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM); 
        actionBar.setCustomView(R.layout.actionbar_layout_detail);
		
		TextView mTextView = (TextView) actionBar.getCustomView()
				.findViewById(R.id.actionBarTitle);
		
		if (prod_name != null)  mTextView.setText(prod_name);
		mButtonBack = (ImageButton) actionBar.getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mButtonBack.setOnClickListener(this);

		mButtonDlna = (ImageButton) actionBar.getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mButtonDlna.setOnClickListener(this);
    }

    @Override
	public void onClick(View view) {
		if (view == mButtonDlna) {
			OnClickTopRight();
		}else if(view == mButtonBack)
			finish();
	}
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        super.onCreateOptionsMenu(menu);

//        getMenuInflater().inflate(R.menu.movie, menu);
//        ShareActionProvider provider = GalleryActionBar.initializeShareActionProvider(menu);
//
//        if (provider != null) {
//            Intent intent = new Intent(Intent.ACTION_SEND);
//            intent.setType("video/*");
//            intent.putExtra(Intent.EXTRA_STREAM, mUri);
//            provider.setShareIntent(intent);
//        }

        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
            return true;
        }
        return false;
    }

    @Override
    public void onStart() {
        ((AudioManager) getSystemService(AUDIO_SERVICE))
                .requestAudioFocus(null, AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT);
        super.onStart();
    }

    @Override
    protected void onStop() {
        ((AudioManager) getSystemService(AUDIO_SERVICE))
                .abandonAudioFocus(null);
        super.onStop();
    }

    @Override
    public void onPause() {
        mPlayer.onPause();
        super.onPause();
    }

    @Override
    public void onResume() {
        mPlayer.onResume();
        super.onResume();
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        mPlayer.onSaveInstanceState(outState);
    }

    @Override
    public void onDestroy() {
        mPlayer.onDestroy();
        unbindService(mServiceConnection);
        super.onDestroy();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        return mPlayer.onKeyDown(keyCode, event)
                || super.onKeyDown(keyCode, event);
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        return mPlayer.onKeyUp(keyCode, event)
                || super.onKeyUp(keyCode, event);
    }

	public void OnClickTopRight() {
		mPlayer.onPause();

		ArrayList<MediaRenderer> mDmrCache = mMyService.getDmrCache();
		if (mDmrCache.size() > 0) {
			CharSequence[] items = new String[mDmrCache.size()];
			for (int i = 0; i < mDmrCache.size(); i++)
				items[i] = mDmrCache.get(i).friendlyName;

			if (mDmrCache.size() == 1) {
				MediaRenderer mMediaRenderer = mDmrCache.get(0);
				mMyService.SetCurrentDevice(1);
				if (mMediaRenderer != null && mDmrCache != null) {
					gotoDlnaVideoPlay();
				}
			} else {
			AlertDialog.Builder builder = new AlertDialog.Builder(this);
			builder.setTitle("请选择你的设备：");
			builder.setItems(items, new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int item) {
					ArrayList<MediaRenderer> mDmrCache = mMyService
							.getDmrCache();
					MediaRenderer mMediaRenderer = mDmrCache.get(item);
					mMyService.SetCurrentDevice(item + 1);
					if (mMediaRenderer != null && mDmrCache != null) {
						gotoDlnaVideoPlay();
					}
				}
			});
			AlertDialog alert = builder.create();
			alert.show();
			}
		}else {
			app.MyToast(this, "正在搜索设备 ...");
		}
	}

	private void gotoDlnaVideoPlay() {
		Intent intent = new Intent(this, DlnaVideoPlay.class);
		intent.putExtra("prod_url", prod_url);
		intent.putExtra("title", prod_name);

		try {
			startActivity(intent);
			finish();
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call DlnaVideoPlay failed", ex);
		}
	}

	public void OnClickPre(View v) {
		int CurrentPlayItem = mDataSaved.getCurrentPlayItem();
		
		if(CurrentPlayItem-1 >=0)
			CurrentPlayItem --;
		else{ 
			return;
		}
		
		checkPreAndNext(CurrentPlayItem,mDataSaved);
		ArrayList<Tab1_Video_GridData> video_array = mDataSaved.getVideo_array();
		prod_url = video_array.get(CurrentPlayItem)._data;
		prod_name = video_array.get(CurrentPlayItem)._data;
		mDataSaved.setCurrentPlayItem(CurrentPlayItem);
		app.setDataSaved(mDataSaved);
		
		mPlayer.setVideoURI(Uri.parse(prod_url),0);
	}
	public void OnClickResume(View v) {
		mPlayer.onPlayPause();
	}
	public void OnClickNext(View v) {
		int CurrentPlayItem = mDataSaved.getCurrentPlayItem();
		if(CurrentPlayItem+1 <=mDataSaved.getVideo_array().size())
			CurrentPlayItem ++;
		else 
			return;
		
		checkPreAndNext(CurrentPlayItem,mDataSaved);
		ArrayList<Tab1_Video_GridData> video_array = mDataSaved.getVideo_array();
		prod_url = video_array.get(CurrentPlayItem)._data;
		prod_name = video_array.get(CurrentPlayItem)._data;
		mDataSaved.setCurrentPlayItem(CurrentPlayItem);
		app.setDataSaved(mDataSaved);
		
		mPlayer.setVideoURI(Uri.parse(prod_url),0);
	}
	private void checkPreAndNext(int currentItem,DataSaved mDataSaved){
		Button mButtonpre = (Button)findViewById(R.id.button1);
		Button mButtonnext = (Button)findViewById(R.id.button3);
		if(currentItem<=0){
			mButtonpre.setVisibility(View.INVISIBLE);
		}
		if(currentItem>=mDataSaved.getVideo_array().size()){
			mButtonnext.setVisibility(View.INVISIBLE);
		}
	}
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// add here.
		if (resultCode == 102) {
			gotoDlnaVideoPlay();
		}
		super.onActivityResult(requestCode, resultCode, data);
	}
}
