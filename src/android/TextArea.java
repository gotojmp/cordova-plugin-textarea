package phonegap.leang.plugins;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


import android.content.Context;
import android.widget.Toast;
import android.view.Gravity;

public class TextArea extends CordovaPlugin {

  // cordova Actions
  private static final String OPEN_TEXT_VIEW = "openTextView";

  // Main method for Cordova plugins
    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {

    callbackContext.success("it works!");
    return true;

/*
	  if(OPEN_TEXT_VIEW.equals(action)) {
	    launchTextView(args, callbackContext);
        return true;
	  }
	  else {
	    callbackContext.error("Invalid Action: " + action);
	  }
      return false;
      */
  }

  private void launchTextView(JSONArray args, CallbackContext callbackContext) {

    android.widget.Toast toast = android.widget.Toast.makeText(webView.getContext(), "it works!", 0);
    toast.setGravity(Gravity.TOP|Gravity.CENTER_HORIZONTAL, 0, 20);
    toast.setDuration(android.widget.Toast.LENGTH_LONG);
    toast.show();
    callbackContext.success("it works!");

  }
}