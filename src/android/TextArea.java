package phonegap.leang.plugins;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.app.AlertDialog;
import android.content.DialogInterface;

import android.widget.LinearLayout;
import android.widget.EditText;
import android.graphics.Color;
import android.view.Gravity;
import android.view.WindowManager;


public class TextArea extends CordovaPlugin {
  
  // cordova Actions
  private static final String OPEN_TEXT_VIEW = "openTextView";
  
  private static final String WHITE_COLOR = "#00000000";
  private static final String BLACK_COLOR = "#FF000000";
  private EditText commentText;
  
  // Main method for Cordova plugins
  @Override
  public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
    
    if (action.equals(OPEN_TEXT_VIEW)) {
      
      try {
        String title = args.getString(0);
        String confirmMessage = args.getString(1);
        String cancelMessage = args.getString(2);
        String placeHolderMessage = args.getString(3);
        String bodyMessage = args.getString(4);
        
        AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(cordova.getActivity(), AlertDialog.THEME_HOLO_LIGHT);
        
        alertDialogBuilder.setPositiveButton(confirmMessage, new DialogInterface.OnClickListener() {
          
          @Override
          public void onClick(DialogInterface arg0, int arg1) {
            String escapeString = escapeText(commentText.getText().toString());
            String jsonString = "{\"status\" : \"success\",\"body\" : \"" + escapeString + "\"}";
            callbackContext.success(jsonString);
          }
        });
        alertDialogBuilder.setNegativeButton(cancelMessage, new DialogInterface.OnClickListener() {
          
          @Override
          public void onClick(DialogInterface arg0, int arg1) {
            String escapeString = escapeText(commentText.getText().toString());
            String jsonString = "{\"status\" : \"cancel\",\"body\" : \"" + escapeString + "\"}";
            callbackContext.success(jsonString);
          }
        });
        
        alertDialogBuilder.setTitle(title);
        
        AlertDialog createdDialog = alertDialogBuilder.create();
        createdDialog.setView(theDialogView(placeHolderMessage, bodyMessage));
        createdDialog.show();
        createdDialog.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
      }
      catch (Exception e) {
        callbackContext.error(e.toString());
      }
    }
    
    return true;
    
  }
  
  private String escapeText(String text) {
    String escapeString = text.replace("\n", "%0A");
    escapeString = escapeString.replace("\\", "\\\\");
    escapeString = escapeString.replace("\"", "\\\"");
    return escapeString;
  }
  
  private LinearLayout theDialogView(String placeHolderMessage, String bodyMessage) {
    
    Context context = this.cordova.getActivity().getApplicationContext();
    
    LinearLayout linear = new LinearLayout(context);
    linear.setOrientation(LinearLayout.VERTICAL);
    LinearLayout.LayoutParams linearLP = new LinearLayout.LayoutParams(
                                                                       LinearLayout.LayoutParams.FILL_PARENT,
                                                                       LinearLayout.LayoutParams.FILL_PARENT
                                                                       );
    linear.setLayoutParams(linearLP);
    
    // Edit Text
    commentText = new EditText(context);
    LinearLayout.LayoutParams editTextLP = new LinearLayout.LayoutParams(
                                                                         LinearLayout.LayoutParams.MATCH_PARENT,
                                                                         LinearLayout.LayoutParams.MATCH_PARENT
                                                                         );
    commentText.setLayoutParams(editTextLP);
    commentText.setHint(placeHolderMessage);
    commentText.setText(bodyMessage);
    commentText.setSelection(bodyMessage.length());
    commentText.setGravity(Gravity.TOP);
    commentText.setBackgroundColor(Color.parseColor(WHITE_COLOR));
    commentText.setTextColor(Color.parseColor(BLACK_COLOR));
    
    // Add to main Linear Layout
    linear.addView(commentText);
    return linear;
    
  }
  
}
