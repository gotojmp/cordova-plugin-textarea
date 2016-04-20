#import <Cordova/CDV.h>

@interface TextArea : CDVPlugin

- (void)openTextView:(CDVInvokedUrlCommand*)command;

@property (nonatomic, copy) NSString* currentCallbackId;

@end
