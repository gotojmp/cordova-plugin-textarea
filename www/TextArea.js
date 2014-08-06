// constructor
function TextArea() {

}

TextArea.prototype.openTextView = function(titleString, confirmButtonString, cancelButtonString, placeHolderString, bodyText, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "TextArea", "openTextView", [titleString, confirmButtonString, cancelButtonString, placeHolderString, bodyText]);
}

TextArea.install = function () {
  if (!window.plugins) {
    window.plugins = {};
  }

  window.plugins.textarea = new TextArea();
  return window.plugins.textarea;
};

cordova.addConstructor(TextArea.install);