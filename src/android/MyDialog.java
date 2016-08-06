package com.gotojmp.cordova.textarea;

import cc.upapp.up.R;

import android.graphics.Color;
import android.os.Bundle;
import android.widget.Toast;

import android.content.Context;
import android.app.Activity;
import android.app.Dialog;
import android.view.Window;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.widget.TextView;
import android.widget.EditText;
import android.widget.Button;
import android.widget.ToggleButton;
import android.widget.CompoundButton;
import android.widget.CompoundButton.OnCheckedChangeListener;
import android.widget.RelativeLayout;
import android.widget.LinearLayout;
import android.view.ViewGroup.LayoutParams;

import android.view.animation.AnimationUtils;

import com.gotojmp.cordova.tusdk.Tusdk;

import java.util.StringTokenizer;
import java.util.Timer;
import java.util.TimerTask;
import android.os.Handler;
import java.io.File;
import android.graphics.Matrix;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.Editable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.view.inputmethod.InputMethodManager;

import org.apache.cordova.CallbackContext;
import org.json.JSONObject;
import org.json.JSONException;

import android.app.AlertDialog;
import android.content.DialogInterface;

/**
 * Created by gotojmp on 16/7/11.
 */

public class MyDialog extends Dialog implements OnClickListener {

    private Button cancel;
    private Button confirm;
    private Button image;
    private Button draft;
    private ToggleButton anonymous;
    private TextView titleView;
    private EditText bodyView;
    Context context;
    View localView;
    private RelativeLayout mydialog;
    private LinearLayout actionbar;

    private String title;
    private String body;
    private String confirmText;
    private String cancelText;
    private String placeholderText;
    private boolean isRichText;
    boolean isAnonymous;

    Handler handler;
    InputMethodManager imm;
    private static CallbackContext currentCallbackContext;
    TextArea ta;

    protected MyDialog(TextArea textArea, CallbackContext callbackContext, Context context, String title, String body, String placeholderText, String confirmText, String cancelText, boolean isRichText) {
        super(context);
        ta = textArea;
        currentCallbackContext = callbackContext;
        this.context = context;
        this.title = title;
        this.body = body;
        this.placeholderText = placeholderText;
        this.confirmText = confirmText;
        this.cancelText = cancelText;
        this.isRichText = isRichText;
        isAnonymous = false;
        handler = new Handler();
        imm = (InputMethodManager)context.getSystemService(Context.INPUT_METHOD_SERVICE);
    }

    public void insertImage(File imageFile) {
        Bitmap image = BitmapFactory.decodeFile(imageFile.getPath());
        int imgWidth = image.getWidth();
        int imgHeight = image.getHeight();
        int maxWidth = bodyView.getWidth() - 30;
        // 只对大尺寸图片进行下面的压缩，小尺寸图片使用原图
        if (imgWidth >= maxWidth) {
            float scale = (float) (maxWidth / imgWidth);
            Matrix matrix = new Matrix();
            matrix.setScale(scale, scale);
            image = Bitmap.createBitmap(image, 0, 0, imgWidth, imgHeight, matrix, true);
        }

        ImageSpan imageSpan = new ImageSpan(this.context, image);
        String imgTag = "<img src=\"" + imageFile.toString() + "\" width=\"" + String.valueOf(imgWidth) + "\" height=\"" + String.valueOf(imgHeight) + "\">";
        final SpannableString spannableString = new SpannableString(imgTag);
        spannableString.setSpan(imageSpan, 0, imgTag.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);

        handler.post(new Runnable() {
            @Override
            public void run() {
                // 将选择的图片追加到EditText中光标所在位置
                int index = bodyView.getSelectionStart();
                // 获取光标所在位置
                Editable editText = bodyView.getEditableText();
                if (index < 0 || index >= editText.length()) {
                    editText.append(spannableString);
                } else {
                    editText.insert(index, spannableString);
                }
                int curPos = index + spannableString.length();
                //editText.insert(curPos, "\n");
                //bodyView.setSelection(curPos + 1);
                bodyView.setSelection(curPos);
                (new Timer()).schedule(new TimerTask() {
                    @Override
                    public void run() {
                        imm.showSoftInput(bodyView, 0);
                    }
                }, 300);
            }
        });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);

        // 这句代码换掉dialog默认背景，否则dialog的边缘发虚透明而且很宽
        getWindow().setBackgroundDrawableResource(android.R.color.transparent);
        LayoutInflater inflater = ((Activity) this.context).getLayoutInflater();
        localView = inflater.inflate(R.layout.mydialog, null);
        localView.setAnimation(AnimationUtils.loadAnimation(context, R.anim.slide_bottom_to_top));
        setContentView(localView);
        // 这句话起全屏的作用
        getWindow().setLayout(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT);

        initView();
        initListener();
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        //this.dismiss();
        return super.onTouchEvent(event);
    }

    private void initListener() {
        confirm.setOnClickListener(this);
        cancel.setOnClickListener(this);
        image.setOnClickListener(this);
        draft.setOnClickListener(this);
        mydialog.setOnClickListener(this);
        final String title = this.title;
        anonymous.setOnCheckedChangeListener(new OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    titleView.setText(title + "(匿名)");
                    isAnonymous = true;
                } else {
                    titleView.setText(title);
                    isAnonymous = false;
                }
            }
        });
    }

    private void initView() {
        titleView = (TextView) findViewById(R.id.title);
        bodyView = (EditText) findViewById(R.id.body);
        confirm = (Button) findViewById(R.id.confirm);
        cancel = (Button) findViewById(R.id.cancel);
        image = (Button) findViewById(R.id.image);
        anonymous = (ToggleButton) findViewById(R.id.anonymous);
        draft = (Button) findViewById(R.id.draft);
        mydialog = (RelativeLayout) findViewById(R.id.mydialog);
        actionbar = (LinearLayout) findViewById(R.id.actionbar);

        titleView.setText(this.title);
        confirm.setText(this.confirmText);
        cancel.setText(this.cancelText);
        bodyView.setHint(this.placeholderText);
        bodyView.setText(this.body);

        if (this.isRichText) {
            actionbar.setVisibility(View.VISIBLE);
        }
    }

    private void saveToDraft() {
        String text = bodyView.getText().toString().replace("\n", "\\n");
        String js = "TextArea.saveToDraft('" + text + "');";
        try {
            ta.webView.sendJavascript(js);
        } catch (NullPointerException e) {
        } catch (Exception e) {
        }
    }

    private void clearDraft() {
        String js = "TextArea.saveToDraft('');";
        try {
            ta.webView.sendJavascript(js);
        } catch (NullPointerException e) {
        } catch (Exception e) {
        }
    }

    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.confirm:
                if (bodyView.getText().length() == 0) {
                    return;
                }
                JSONObject info = new JSONObject();
                try {
                    info.put("text", bodyView.getText());
                    if (isAnonymous) info.put("anonymous", "1");
                } catch (JSONException e) {
                }
                currentCallbackContext.success(info);
                this.dismiss();
                break;
            case R.id.cancel:
                if (bodyView.getText().length() == 0) {
                    this.dismiss();
                    return;
                }
                final MyDialog self = this;
                String actions;
                if (isRichText) {
                    actions = "存入草稿箱|确定放弃|取消";
                } else {
                    actions = "确定放弃|取消";
                }
                String[] actionList = actions.split("\\|");
                AlertDialog.Builder alert = new AlertDialog.Builder(context);
                alert.setTitle("确定放弃本次编辑吗?");
                alert.setItems(actionList, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) { //下标是从0开始的
                        //Toast.makeText(context, String.valueOf(which), Toast.LENGTH_SHORT).show();
                        if (isRichText) {
                            if (which == 0) { //草稿箱
                                self.saveToDraft();
                                self.dismiss();
                            } else if (which == 1) { //放弃
                                self.clearDraft();
                                self.dismiss();
                            }
                        } else {
                            if (which == 0) { //放弃
                                self.dismiss();
                            }
                        }
                    }
                });
                alert.create().show();
                break;
            case R.id.mydialog:
                break;
            case R.id.image: //打开图片选择器
                Tusdk tusdk = new Tusdk();
                tusdk.openPhotoBoxNative(context, this);
                break;
            case R.id.draft: //存入草稿箱
                if (bodyView.getText().length() == 0) {
                    return;
                }
                this.saveToDraft();
                draft.setEnabled(false);
                draft.setTextColor(Color.parseColor("#AAAAAA"));
                draft.setText("正在保存…");
                (new Timer()).schedule(new TimerTask() {
                    @Override
                    public void run() {
                        handler.post(new Runnable() {
                            @Override
                            public void run() {
                                draft.setText("保存成功");
                            }
                        });
                    }
                }, 500);
                (new Timer()).schedule(new TimerTask() {
                    @Override
                    public void run() {
                        handler.post(new Runnable() {
                            @Override
                            public void run() {
                                draft.setTextColor(Color.parseColor("#007AFF"));
                                draft.setText("存入草稿箱");
                                draft.setEnabled(true);
                            }
                        });
                    }
                }, 1500);
                break;
        }
    }
}
