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

    @BindView(R.id.EditText_1)
    EditText EditText_1;

    @BindView(R.id.EditText_2)
    EditText EditText_2;

    @BindView(R.id.EditText_3)
    EditText EditText_3;

    @BindView(R.id.EditText_4)
    EditText EditText_4;
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
         if(!TextUtils.isEmpty(EditText_1.getText())&&!TextUtils.isEmpty(EditText_2.getText())
                 &&!TextUtils.isEmpty(EditText_3.getText())
                 &&!TextUtils.isEmpty(EditText_4.getText())){
             int a=Integer.parseInt(EditText_1.getText().toString());
             int b=Integer.parseInt(EditText_2.getText().toString());
             int c=Integer.parseInt(EditText_3.getText().toString());
             int d=Integer.parseInt(EditText_4.getText().toString());
             sendValue(BleSDK.BloodPressureCalibrationWithMinDiastolicBP(a,b,c,d));
         }
             break;
         case R.id.get:
             sendValue(BleSDK.GetBloodPressureCalibrationValue());
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
