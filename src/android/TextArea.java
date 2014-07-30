package leang.phonegap.textarea;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


import android.content.Context;
import android.widget.Toast;

public class AdMobPlugin extends CordovaPlugin {

    // cordova Actions
    private static final String OPEN_TEXT_VIEW = "openTextView"

    // Main method for Cordova plugins
    @Override
	public boolean execute(String action, JSONArray inputs, CallbackContext callbackContext) throws JSONException {

        if(action.equals(OPEN_TEXT_VIEW)) {
            launchTextView(inputs, CallbackContext);
        }
        else {
            callbackContext.error("Invalid Action: " + action);
        }
    }

    private void launchTextView(JSONArray inputs, CallbackContext callbackContext) {

        // write toast message
        Context context = getApplicationContext();
        int duration = Toast.LENGTH_SHORT;
        Toast toast = Toast.makeText(context, "hello", duration);
        toast.show();

    }
}