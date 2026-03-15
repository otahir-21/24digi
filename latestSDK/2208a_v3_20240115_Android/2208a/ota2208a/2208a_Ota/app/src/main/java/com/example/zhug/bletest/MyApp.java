package com.example.zhug.bletest;

import android.app.Application;
import android.bluetooth.BluetoothAdapter;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.StrictMode;
import android.util.Log;

import androidx.multidex.MultiDex;

import com.example.zhug.bletest.ble.BleManager;


public class MyApp extends Application {
    private ListenerReceiver receiver;
    public static MyApp getInstance() {
        return instance;
    }
    private static MyApp instance;
    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        StrictMode.VmPolicy.Builder builder = new StrictMode.VmPolicy.Builder();
        StrictMode.setVmPolicy(builder.build());
        builder.detectFileUriExposure();
        SharedPreferenceUtils.init(this);
        BleManager.init(this);
        registerReceiver();
//        Bugly.init(this, "958da0fb75", true);
//        Beta.autoDownloadOnWifi=true;
    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(base);
        //   Beta.installTinker();
    }
    private void registerReceiver() {
        IntentFilter filter = new IntentFilter();

        filter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED);
        receiver = new ListenerReceiver();
        registerReceiver(receiver, filter);
    }
    private static final String TAG = "MyApp";

    class ListenerReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals(BluetoothAdapter.ACTION_STATE_CHANGED)) {
                int state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE,
                        BluetoothAdapter.ERROR);
                switch (state) {
                    case BluetoothAdapter.STATE_ON:
                        new Handler().postDelayed(new Runnable() {
                            @Override
                            public void run() {

                                BleManager.getInstance().reConnect();

                            }
                        }, 600);


                        Log.i(TAG, "onReceive: 开启蓝牙");
                        break;
                    case BluetoothAdapter.STATE_OFF:
                        BleManager.getInstance().disconnectDeviceAndClose();
                        Log.i(TAG, "onReceive: 关闭蓝牙");
                        break;

                }
            }
        }
    }

}
