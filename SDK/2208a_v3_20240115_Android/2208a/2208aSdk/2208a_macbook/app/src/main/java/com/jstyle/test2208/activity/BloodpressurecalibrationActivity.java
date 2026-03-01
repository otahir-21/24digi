package com.jstyle.test2208.activity;

import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;


import com.jstyle.blesdk2208a.Util.BleSDK;
import com.jstyle.blesdk2208a.constant.BleConst;
import com.jstyle.test2208.R;

import java.util.Map;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

/**
 */
public class BloodpressurecalibrationActivity extends BaseActivity {

    @BindView(R.id.EditText_heigth)
    EditText EditText_heigth;

    @BindView(R.id.EditText_low)
    EditText EditText_low;


    @BindView(R.id.info)
    TextView info;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_bloodpressurecalibration);
        ButterKnife.bind(this);
    }

    @OnClick({R.id.set,R.id.get})
    public void onViewClicked(View view) {
     switch (view.getId()){
         case R.id.set:
         if(!TextUtils.isEmpty(EditText_heigth.getText())&&!TextUtils.isEmpty(EditText_low.getText())){
             int h=Integer.parseInt(EditText_heigth.getText().toString());
             int l=Integer.parseInt(EditText_low.getText().toString());
             sendValue(BleSDK.SetBloodpressure_calibration(h,l));
         }
             break;
         case R.id.get:
             sendValue(BleSDK.ReadBloodpressure_calibration());
             break;
     }
    }






    @Override
    public void dataCallback(Map<String, Object> maps) {
        super.dataCallback(maps);
        Log.e("info",maps.toString());
        String dataType = getDataType(maps);
        switch (dataType) {
            case BleConst.SetBloodpressure_calibration:
            case BleConst.GetBloodpressure_calibration:
                if(null!=info){
                    info.setText(maps.toString());
                }
                break;
        }

    }



}
