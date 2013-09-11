package com.joyplus.joylink.weibo.net;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.SocketAddress;
import java.net.URL;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.net.http.SslError;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.webkit.SslErrorHandler;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.joyplus.joylink.App;
import com.joyplus.joylink.R;

public class WeiboDialog2 extends Activity {

	// static final FrameLayout.LayoutParams FILL = new
	// FrameLayout.LayoutParams(
	// ViewGroup.LayoutParams.FILL_PARENT, ViewGroup.LayoutParams.FILL_PARENT);
	static final int MARGIN = 4;
	static final int PADDING = 2;

	Weibo mWeibo;
	private WeiboDialogListener mListener;
	private ProgressDialog mSpinner;
	private WebView mWebView;
	App application;
	// private RelativeLayout webViewContainer;
	// private RelativeLayout mContent;
	Context context;
	private final static String TAG = "Weibo-WebView";

	// public WeiboDialog2(final Weibo weibo, Context context, String url,
	// WeiboDialogListener listener) {
	// super(context, R.style.ContentOverlay);
	// mWeibo = weibo;
	// mUrl = url;
	// mListener = listener;
	// }

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		// requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.sinawebview);
		context = this;
		application = (App) getApplicationContext();
		mWeibo = application.getWeibo();
		mSpinner = new ProgressDialog(context);
		// mSpinner.requestWindowFeature(Window.FEATURE_NO_TITLE);
		mSpinner.setMessage("Loading...");

		// mContent = new RelativeLayout(getContext());

		setUpWebView();

		// setUpCloseBtn();

		// addContentView(mContent, new LayoutParams(LayoutParams.FILL_PARENT,
		// LayoutParams.FILL_PARENT));
	}

	private void setUpWebView() {
		// webViewContainer = new RelativeLayout(getContext());
		// webViewContainer.setOrientation(LinearLayout.VERTICAL);

		// webViewContainer.addView(title, new
		// LinearLayout.LayoutParams(LayoutParams.FILL_PARENT,
		// getContext().getResources().getDimensionPixelSize(R.dimen.dialog_title_height)));

		mWebView = (WebView) findViewById(R.id.sinawebview);
		mWebView.setVerticalScrollBarEnabled(false);
		mWebView.setHorizontalScrollBarEnabled(false);
		mWebView.getSettings().setJavaScriptEnabled(true);
		mWebView.setWebViewClient(new WeiboDialog2.WeiboWebViewClient());
		mWebView.loadUrl(application.geturl());
		mListener = application.getWeiboDialogListener();

		// mWebView.setLayoutParams(FILL);
		// mWebView.setVisibility(View.INVISIBLE);

		// webViewContainer.addView(mWebView);

		// RelativeLayout.LayoutParams lp = new
		// RelativeLayout.LayoutParams(LayoutParams.FILL_PARENT,
		// LayoutParams.FILL_PARENT);
		// Resources resources = getContext().getResources();
		// lp.leftMargin =
		// resources.getDimensionPixelSize(R.dimen.dialog_left_margin);
		// lp.topMargin =
		// resources.getDimensionPixelSize(R.dimen.dialog_top_margin);
		// lp.rightMargin =
		// resources.getDimensionPixelSize(R.dimen.dialog_right_margin);
		// lp.bottomMargin =
		// resources.getDimensionPixelSize(R.dimen.dialog_bottom_margin);
		// mContent.addView(webViewContainer, lp);
	}

	// private void setUpCloseBtn() {
	// mBtnClose = new ImageView(getContext());
	// mBtnClose.setClickable(true);
	// mBtnClose.setOnClickListener(new View.OnClickListener() {
	// @Override
	// public void onClick(View v) {
	// mListener.onCancel();
	// WeiboDialog2.this.dismiss();
	// }
	// });
	//
	// mBtnClose.setImageResource(R.drawable.close_selector);
	// mBtnClose.setVisibility(View.INVISIBLE);
	//
	// RelativeLayout.LayoutParams closeBtnRL = new RelativeLayout.LayoutParams(
	// LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
	// closeBtnRL.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
	// closeBtnRL.addRule(RelativeLayout.ALIGN_PARENT_TOP);
	// closeBtnRL.topMargin = getContext().getResources().getDimensionPixelSize(
	// R.dimen.dialog_btn_close_right_margin);
	// closeBtnRL.rightMargin =
	// getContext().getResources().getDimensionPixelSize(
	// R.dimen.dialog_btn_close_top_margin);
	//
	// webViewContainer.addView(mBtnClose, closeBtnRL);
	// }

	private class WeiboWebViewClient extends WebViewClient {

		@Override
		public boolean shouldOverrideUrlLoading(WebView view, String url) {
			Log.d(TAG, "Redirect URL: " + url);
			// 待后台增加对默认重定向地址的支持后修改下面的逻辑
			if (url.startsWith(mWeibo.getRedirectUrl())) {
				handleRedirectUrl(view, url);
				// WeiboDialog2.this.dismiss();
				finish();
				return true;
			}
			// launch non-dialog URLs in a full browser
			startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
			return true;
		}

		@Override
		public void onReceivedError(WebView view, int errorCode,
				String description, String failingUrl) {
			super.onReceivedError(view, errorCode, description, failingUrl);
			mListener.onError(new DialogError(description, errorCode,
					failingUrl));
			// WeiboDialog2.this.dismiss();
			finish();
		}

		@Override
		public void onPageStarted(WebView view, String url, Bitmap favicon) {
			Log.d(TAG, "onPageStarted URL: " + url);
			// google issue. shouldOverrideUrlLoading not executed
			if (url.startsWith(mWeibo.getRedirectUrl())) {
				handleRedirectUrl(view, url);
				view.stopLoading();
				// WeiboDialog2.this.dismiss();
				finish();
				return;
			}
			super.onPageStarted(view, url, favicon);
			mSpinner.show();
		}

		@Override
		public void onPageFinished(WebView view, String url) {
			Log.d(TAG, "onPageFinished URL: " + url);
			super.onPageFinished(view, url);
			mSpinner.dismiss();

			// mContent.setBackgroundColor(Color.TRANSPARENT);
			// webViewContainer.setBackgroundResource(R.drawable.dialog_bg);
			// mBtnClose.setVisibility(View.VISIBLE);
			mWebView.setVisibility(View.VISIBLE);
		}

		public void onReceivedSslError(WebView view, SslErrorHandler handler,
				SslError error) {
			handler.proceed();
		}

	}

	private void handleRedirectUrl(WebView view, String url) {
		Bundle values = Utility.parseUrl(url);

		String error = values.getString("error");
		String error_code = values.getString("error_code");

		if (error == null && error_code == null) {
			mListener.onComplete(values);
		} else if (error.equals("access_denied")) {
			// 用户或授权服务器拒绝授予数据访问权限
			mListener.onCancel();
		} else {
			mListener.onWeiboException(new WeiboException(error, Integer
					.parseInt(error_code)));
		}
	}

	private static String getHtml(String urlString) {

		try {

			StringBuffer html = new StringBuffer();

			SocketAddress sa = new InetSocketAddress("10.75.0.103", 8093);
			Proxy proxy = new Proxy(java.net.Proxy.Type.HTTP, sa);

			URL url = new URL(urlString);

			HttpURLConnection conn = (HttpURLConnection) url
					.openConnection(proxy);

			InputStreamReader isr = new InputStreamReader(conn.getInputStream());

			BufferedReader br = new BufferedReader(isr);

			String temp;

			while ((temp = br.readLine()) != null) {

				html.append(temp);

			}

			br.close();

			isr.close();
			return html.toString();

		} catch (Exception e) {

			e.printStackTrace();

			return null;

		}
	}

	public void onResume() {
		super.onResume();
	}

	public void onPause() {
		super.onPause();
	}
}
