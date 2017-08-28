
package io.rnkit.linkface;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.Nullable;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.sensetime.stlivenesslibrary.ui.LivenessActivity;
import com.sensetime.stlivenesslibrary.util.Constants;

import java.io.File;

public class LinkFaceModule extends ReactContextBaseJavaModule implements ActivityEventListener {

    private static Promise promise;
    public static String EXTRA_RESULT_PATH = null;

    public LinkFaceModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "RNKitLinkFace";
    }

    @Override
    public void initialize() {
        super.initialize();
        EXTRA_RESULT_PATH = Environment
                .getExternalStorageDirectory().getAbsolutePath()
                + File.separator
                + "rnkit_liveness"+File.separator;
        getReactApplicationContext().addActivityEventListener(this);
    }

    @Override
    public void onCatalystInstanceDestroy() {
        getReactApplicationContext().removeActivityEventListener(this);
        super.onCatalystInstanceDestroy();
    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        try {
            if (resultCode == Activity.RESULT_OK) {
                WritableMap map = Arguments.createMap();
                map.putString("encryTarData", EXTRA_RESULT_PATH + LivenessActivity.LIVENESS_FILE_NAME);
                WritableArray list = Arguments.createArray();
                for (int i = 0; i < 4; i ++) {
                    byte[] image = data.getByteArrayExtra("image" + i);
                    String imageName = java.util.UUID.randomUUID().toString() + ".jpg";
                    LivenessActivity.saveFile(image, EXTRA_RESULT_PATH, imageName);
                    list.pushString(EXTRA_RESULT_PATH + imageName);
                }
                map.putArray("arrSTImage", list);
                promise.resolve(map);
            } else if (resultCode == Activity.RESULT_CANCELED) {
                promise.reject("Cancel", "用户取消识别");
            } else {
                promise.reject("Unknow", requestCode + "");
            }
        } catch (Exception e) {
            promise.reject("Exception", e.getMessage());
        }
    }

    @Override
    public void onNewIntent(Intent intent) {

    }

    @ReactMethod
    public void start(@Nullable final ReadableMap options, @Nullable final Promise promise) {
        this.promise = promise;
        this.clean();

        try {
            Bundle bundle = new Bundle();
            StringBuilder sBuilder = new StringBuilder();

            sBuilder.append(Constants.BLINK + " ");
            sBuilder.append(Constants.MOUTH + " ");
            sBuilder.append(Constants.NOD + " ");
            sBuilder.append(Constants.YAW + " ");
            /**
             * OUTPUT_TYPE 配置, 传入的outputType类型为singleImg （单图），multiImg （多图），video（低质量视频），fullvideo（高质量视频）
             */
            if (options.hasKey("outType")) {
                bundle.putString(LivenessActivity.OUTTYPE, options.getString("outType"));
            } else {
                bundle.putString(LivenessActivity.OUTTYPE, Constants.SINGLEIMG);
            }

            /**
             * EXTRA_MOTION_SEQUENCE 动作检测序列配置，支持四种检测动作， BLINK(眨眼), MOUTH（张嘴）, NOD（点头）, YAW（摇头）, 各个动作以空格隔开。 推荐第一个动作为BLINK。
             * 默认配置为"BLINK MOUTH NOD YAW"
             */
            bundle.putString(LivenessActivity.EXTRA_MOTION_SEQUENCE, sBuilder.toString());
            /**
             * SOUND_NOTICE 配置, 传入的soundNotice为boolean值，true为打开, false为关闭。
             */
            if (options.hasKey("voicePromptOn")) {
                bundle.putBoolean(LivenessActivity.SOUND_NOTICE, options.getBoolean("voicePromptOn"));
            } else {
                bundle.putBoolean(LivenessActivity.SOUND_NOTICE, true);
            }

            /**
             * COMPLEXITY 配置, 传入的complexity类型为normal,支持四种难度，easy, normal, hard, hell.
             */
            bundle.putString(LivenessActivity.COMPLEXITY, Constants.NORMAL);

            Intent intent = new Intent();
            intent.setClass(getCurrentActivity(), LivenessActivity.class);
		    intent.putExtra(LivenessActivity.EXTRA_RESULT_PATH, EXTRA_RESULT_PATH);
            intent.putExtra(LivenessActivity.SEQUENCE_JSON,
                    bundle.getString("sequence_json"));
            intent.putExtra(LivenessActivity.SOUND_NOTICE, bundle.getBoolean(LivenessActivity.SOUND_NOTICE));
            intent.putExtras(bundle);
            getCurrentActivity().startActivityForResult(intent, 0);

        } catch (Exception e) {
            e.printStackTrace();
            promise.reject("Exception", e.getMessage());
        }
    }

    @ReactMethod
    public void clean() {
        try {
            File cacheFileDir = new File(EXTRA_RESULT_PATH);
            if(cacheFileDir != null && cacheFileDir.exists() && cacheFileDir.isDirectory()){
                for(File item : cacheFileDir.listFiles()){
                    item.delete();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void version(@Nullable final Promise promise) {
        promise.resolve("no version");
    }
}