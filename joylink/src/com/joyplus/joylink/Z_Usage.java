package com.joyplus.joylink;

import android.app.ActionBar;
import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings.PluginState;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ImageButton;
import android.widget.TextView;

import com.androidquery.AQuery;
import com.umeng.analytics.MobclickAgent;

public class Z_Usage extends BaseActivity implements View.OnClickListener {
	private String TAG = "Z_Usage";

	private AQuery aq;
	private WebView mWebView;
	boolean flashInstalled = false;
	final Activity activity = this;
	private ImageButton mSlidingMenuButton;
	private ImageButton mSlidingMenuButtonL;

	public Z_Usage() {
		super("");
		// TODO Auto-generated constructor stub
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.z_usage);

		getActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
		getActionBar().setCustomView(R.layout.actionbar_layout_list);
		TextView mTextView = (TextView) getActionBar().getCustomView()
				.findViewById(R.id.actionBarTitle);
		mTextView.setText("常见问题");
		mSlidingMenuButtonL = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButtonL);
		mSlidingMenuButtonL.setOnClickListener(this);
		mSlidingMenuButton = (ImageButton) getActionBar().getCustomView()
				.findViewById(R.id.slidingMenuButton1);
		mSlidingMenuButton.setOnClickListener(this);

		aq = new AQuery(this);

		mWebView = (WebView) findViewById(R.id.webView1);

		// try {
		// PackageManager pm = getPackageManager();
		// ApplicationInfo ai = pm.getApplicationInfo("com.adobe.flashplayer",
		// 0);
		// if (ai != null)
		// flashInstalled = true;
		// Toast.makeText(this, "Support Flash plugin.",
		// Toast.LENGTH_LONG).show();
		// } catch (NameNotFoundException e) {
		// flashInstalled = false;
		// Toast.makeText(this, "Not support Flash plugin.",
		// Toast.LENGTH_LONG).show();
		// }

		mWebView.getSettings().setJavaScriptEnabled(true);
		mWebView.getSettings().setJavaScriptEnabled(true);
		mWebView.getSettings().setPluginsEnabled(true);
		mWebView.getSettings().setAllowFileAccess(true);
		mWebView.getSettings().setPluginsEnabled(true);
		mWebView.getSettings().setPluginState(PluginState.ON);

		mWebView.setWebChromeClient(new WebChromeClient() {
			public void onProgressChanged(WebView view, int progress) {
				// activity.setTitle("Loading...");
				activity.setProgress(progress * 100);
				if (progress == 100)
					aq.id(R.id.progressBar1).gone();
				// activity.setTitle(R.string.app_name);
			}
		});
		mWebView.setWebViewClient(new WebViewClient() {
			public void onReceivedError(WebView view, int errorCode,
					String description, String failingUrl) { // Handle the error
			}

			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				view.loadUrl(url);
				return true;
			}
		});
		// 加载URL内容
		mWebView.loadUrl("http://www.joyplus.tv/faqs");
		// mWebView.loadUrl("http://www.sohu.com");
	}

	@Override
	public void onClick(View view) {
		if (view == mSlidingMenuButton) {
			getSlidingMenu().toggle();
		} else if (view == mSlidingMenuButtonL)
			finish();
	}

	public void OnClickSlidingMenu(View v) {
		getSlidingMenu().toggle();
	}

	public void OnClickHome(View v) {
		super.OnClickHome(this);
	}

	public void OnClickRemoteMouse(View v) {
		super.OnClickRemoteMouse(this);

	}

	public void OnClickRemoteControl(View v) {
		super.OnClickRemoteControl(this);
	}

	public void OnClickSetting(View v) {
		super.OnClickSetting(this);

	}

	public void OnClickTopLeft(View v) {
	}

	@Override
	protected void onDestroy() {
		if (aq != null)
			aq.dismiss();
		super.onDestroy();
	}

	@Override
	public void onResume() {
		super.onResume();
		MobclickAgent.onResume(this);
	}

	@Override
	public void onPause() {
		super.onPause();
		MobclickAgent.onPause(this);
	}

	class MyWebChromeClient extends WebChromeClient {
		@Override
		public void onProgressChanged(WebView view, int newProgress) {
			// TODO Auto-generated method stub
			super.onProgressChanged(view, newProgress);
		}
	}

	@Override
	void ConnectOK(String name) {
		// TODO Auto-generated method stub

	}

	@Override
	void ConnectFailed() {
		// TODO Auto-generated method stub

	}
}