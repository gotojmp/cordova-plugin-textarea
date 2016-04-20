var exec = require('cordova/exec');

function TextArea() {
}

TextArea.openTextView = function(titleString, confirmButtonString, cancelButtonString, placeHolderString, bodyText, successCallback, errorCallback) {
  exec(successCallback, errorCallback, "TextArea", "openTextView", [titleString, confirmButtonString, cancelButtonString, placeHolderString, bodyText]);
}

module.exports = TextArea;
