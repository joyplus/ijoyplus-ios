package com.joyplus.joylink;

import java.io.File;
import java.util.ArrayList;

import android.app.ActionBar;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.dlcs.dlna.Stack.MediaRenderer;
import com.joyplus.joylink.Adapters.Tab1_Photo_GridData;
import com.joyplus.joylink.Dlna.DlnaPhotoSlideShow;
import com.joyplus.joylink.Dlna.DlnaSelectDevice;

public class PhotoSlideShow extends FragmentActivity implements OnClickListener {
	private String TAG = "PhotoSlideShow";
	private SectionsPagerAdapter mSectionsPagerAdapter;

	/**
	 * The {@link ViewPager} that will host the section contents.
	 */
	private ViewPager mViewPager;
	private App app;
	private AQuery aq;
	private ArrayList<Tab1_Photo_GridData> images_array = null;
	private int current_item = 0;

	private DlnaSelectDevice mMyService;
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
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.photo_slideshow);
		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_detail);

		app = (App) getApplication();
		aq = new AQuery(this);

		Intent i = new Intent();
		i.setClass(this, DlnaSelectDevice.class);
		bindService(i, mServiceConnection, BIND_AUTO_CREATE);

		aq.id(R.id.progressBar1).gone();

		Intent intent = getIntent();
		current_item = intent.getIntExtra("CURRENT", 0);
		images_array = intent.getParcelableArrayListExtra("IMAGEARRAY");

		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);

		mTextView.setText(images_array.get(current_item).title);
		mButtonBack = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mButtonBack.setOnClickListener(this);

		mButtonDlna = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mButtonDlna.setOnClickListener(this);

		// Create the adapter that will return a fragment for each of the three
		// primary sections of the app.
		mSectionsPagerAdapter = new SectionsPagerAdapter(
				getSupportFragmentManager());

		// Set up the ViewPager with the sections adapter.
		mViewPager = (ViewPager) findViewById(R.id.viewPager1);
		mViewPager.setAdapter(mSectionsPagerAdapter);
		mViewPager.setOnPageChangeListener(new MyPageChangeListener());
		mViewPager.setCurrentItem(current_item);
	}

	private class MyPageChangeListener implements OnPageChangeListener {

		/**
		 * This method will be invoked when a new page becomes selected.
		 * position: Position index of the new selected page.
		 */
		public void onPageSelected(int position) {
			current_item = position;
		}

		public void onPageScrollStateChanged(int arg0) {

		}

		public void onPageScrolled(int arg0, float arg1, int arg2) {

		}
	}

	@Override
	public void onClick(View view) {
		if (view == mButtonDlna) {
			OnClickTopRight();
		} else if (view == mButtonBack)
			finish();
	}

	@Override
	protected void onDestroy() {
		if (aq != null)
			aq.dismiss();
		unbindService(mServiceConnection);
		super.onDestroy();
	}

	// @Override
	// public boolean onCreateOptionsMenu(Menu menu) {
	// // Inflate the menu; this adds items to the action bar if it is present.
	// getMenuInflater().inflate(R.menu.activity_main, menu);
	// return true;
	// }

	/**
	 * A {@link FragmentPagerAdapter} that returns a fragment corresponding to
	 * one of the sections/tabs/pages.
	 */
	public class SectionsPagerAdapter extends FragmentPagerAdapter {

		public SectionsPagerAdapter(FragmentManager fm) {
			super(fm);
		}

		@Override
		public Fragment getItem(int position) {
			// getItem is called to instantiate the fragment for the given page.
			// Return a DummySectionFragment (defined as a static inner class
			// below) with the page number as its lone argument.
			Fragment fragment = new DummySectionFragment();
			Bundle args = new Bundle();
			// args.putInt(DummySectionFragment.ARG_SECTION_NUMBER, position +
			// 1);
			args.putString(DummySectionFragment.ARG_SECTION_NUMBER,
					images_array.get(position)._data);
			args.putInt("width", images_array.get(position).width);
			args.putInt("height", images_array.get(position).height);
			fragment.setArguments(args);

			return fragment;
		}

		@Override
		public int getCount() {
			// Show 3 total pages.
			return images_array.size();
		}

		@Override
		public CharSequence getPageTitle(int position) {
			// switch (position) {
			// case 0:
			// return getString(R.string.title_section1).toUpperCase();
			// case 1:
			// return getString(R.string.title_section2).toUpperCase();
			// case 2:
			// return getString(R.string.title_section3).toUpperCase();
			// }
			return null;
		}
	}

	/**
	 * A dummy fragment representing a section of the app, but that simply
	 * displays dummy text.
	 */
	public static class DummySectionFragment extends Fragment {
		/**
		 * The fragment argument representing the section number for this
		 * fragment.
		 */
		public static final String ARG_SECTION_NUMBER = "section_number";

		public DummySectionFragment() {
		}

		@Override
		public View onCreateView(LayoutInflater inflater, ViewGroup container,
				Bundle savedInstanceState) {
			// Create a new TextView and set its text to the fragment's section
			// number argument value.
			DisplayMetrics dm = new DisplayMetrics();
			getActivity().getWindowManager().getDefaultDisplay().getMetrics(dm);

			ImageView mImageView = new ImageView(getActivity());
			File file1 = new File(getArguments().getString(ARG_SECTION_NUMBER));
			AQuery aq2 = new AQuery(mImageView);
			if (file1.exists()) {
				aq2.image(file1, 0);
				if (getArguments().getInt("width") > dm.widthPixels
						|| getArguments().getInt("height") > (dm.heightPixels-150))
					// mImageView.setScaleType(ScaleType.FIT_XY);
					mImageView.setScaleType(ScaleType.CENTER_INSIDE);
				else
					mImageView.setScaleType(ScaleType.CENTER);
				aq2.dismiss();
			}
			return mImageView;
		}
	}

	// private class MyPageChangeListener implements OnPageChangeListener {
	//
	// /**
	// * This method will be invoked when a new page becomes selected.
	// * position: Position index of the new selected page.
	// */
	// public void onPageSelected(int position) {
	// current_item = position;
	// app.dataSaved.setCurrentPlayItem(current_item);
	// // tv_title.setText(titles[position]);
	// // dots.get(oldPosition).setBackgroundResource(R.drawable.dot_normal);
	// // dots.get(position).setBackgroundResource(R.drawable.dot_focused);
	// // oldPosition = position;
	//
	// }
	//
	// public void onPageScrollStateChanged(int arg0) {
	//
	// }
	//
	// public void onPageScrolled(int arg0, float arg1, int arg2) {
	//
	// }
	// }

	public void OnClickTopLeft(View v) {
		app.dataSaved.setCurrentPlayItem(current_item);

	}

	public void OnClickTopRight() {

		// MediaRenderer mMediaRenderer = app.getmMediaRenderer();
		// ArrayList<MediaRenderer> mDmrCache = app.getmDmrCache();
		// MediaRenderer mMediaRenderer = mMyService.getMediaRenderer();
		// ArrayList<MediaRenderer> mDmrCache = mMyService.getDmrCache();
		//
		// if (mMediaRenderer != null && mDmrCache != null && mDmrCache.size()
		// ==1) {
		// gotoDlnaPhotoSlideShow();
		// }
		ArrayList<MediaRenderer> mDmrCache = mMyService.getDmrCache();

		if (mDmrCache.size() > 0) {
			CharSequence[] items = new String[mDmrCache.size()];
			for (int i = 0; i < mDmrCache.size(); i++)
				items[i] = mDmrCache.get(i).friendlyName;

			if (mDmrCache.size() == 1) {
				MediaRenderer mMediaRenderer = mDmrCache.get(0);
				mMyService.SetCurrentDevice(1);
				if (mMediaRenderer != null && mDmrCache != null) {
					gotoDlnaPhotoSlideShow();
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
							gotoDlnaPhotoSlideShow();
						}
					}
				});
				AlertDialog alert = builder.create();
				alert.show();
			}
		} else {
			app.MyToast(this, "正在搜索设备 ...");
		}
	}

	private void gotoDlnaPhotoSlideShow() {
		Intent intent = new Intent(this, DlnaPhotoSlideShow.class);
		intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);

		intent.putExtra("CURRENT", current_item);
		intent.putParcelableArrayListExtra("IMAGEARRAY", images_array);
		try {
			startActivity(intent);
			finish();
		} catch (ActivityNotFoundException ex) {
			Log.e(TAG, "Call DlnaPhotoSlideShow failed", ex);
		}
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		// add here.
		if (resultCode == 102) {
			gotoDlnaPhotoSlideShow();
		}
		super.onActivityResult(requestCode, resultCode, data);
	}

}
