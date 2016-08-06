package com.gotojmp.cordova.textarea;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.app.Dialog;
import android.content.DialogInterface;

import android.widget.LinearLayout;
import android.widget.EditText;
import android.graphics.Color;
import android.view.Gravity;
import android.view.WindowManager;

public class TextArea extends CordovaPlugin {

    // Main method for Cordova plugins
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("openTextView")) {
            try {
                String title = args.getString(0);
                String confirmMessage = args.getString(1);
                String cancelMessage = args.getString(2);
                String placeHolderMessage = args.getString(3);
                String bodyMessage = args.getString(4);
                boolean isRichText = args.getBoolean(5);

                MyDialog myDialog = new MyDialog(this, callbackContext, cordova.getActivity(), title, bodyMessage, placeHolderMessage, confirmMessage, cancelMessage, isRichText);
                myDialog.show();
                //myDialog.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
            } catch (Exception e) {
                callbackContext.error(e.toString());
            }
            return true;
        }
        return super.execute(action, args, callbackContext);
    }
}
