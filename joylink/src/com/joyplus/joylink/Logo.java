package com.joyplus.joylink;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

public class Logo extends Activity {
	
	 private static String TAG = Logo.class.getName();
	 private static long MAX_SPLASH_TIME = 2000;

     @Override
     protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.logo);

	
        new Thread() {
            @Override
            public void run() {
                synchronized (Tab1.SPLASH_LOCK) {
                    // wait for notify or time-out
                    try { Tab1.SPLASH_LOCK.wait(MAX_SPLASH_TIME); }
                    catch (InterruptedException ignored) {}
                }
                Intent intent = new Intent(Logo.this, Tab1.class);
        		startActivity(intent);
                finish();
            }
        }.start();
     }
}