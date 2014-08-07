//
//  TextArea.m
//
//  Created by Tha Leang on 8/7/14.
//
//

#import "TextArea.h"

@interface TextArea()<UITextViewDelegate> {
  
  NSString *titleString;
  NSString *confirmButtonString;
  NSString *cancelButtonString;
  NSString *placeHolderString;
  NSString *bodyText;
  
  CDVInvokedUrlCommand *cmd;
  UITextView *textView;
  CGRect originalTextViewFrame;
}

@end

@implementation TextArea

- (void)openTextView:(CDVInvokedUrlCommand*)command {
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  
  cmd = command;
  titleString = command.arguments[0];
  confirmButtonString = command.arguments[1];
  cancelButtonString = command.arguments[2];
  placeHolderString = command.arguments[3];
  bodyText = command.arguments[4];
  
  // create controllers
  UIViewController *viewController = [[UIViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
  
  // create view
  textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, viewController.view.frame.size.width, viewController.view.frame.size.height)];
  [textView setDelegate:self];
  
  if ([bodyText isEqualToString:@""] || [bodyText isEqualToString:placeHolderString]) {
    [textView setText:placeHolderString];
    [textView setTextColor:[UIColor lightGrayColor]];
  }
  else {
    [textView setText:bodyText];
    [textView setTextColor:[UIColor blackColor]];
  }
  
  [viewController setTitle:titleString];

  [navController.navigationBar setBarTintColor:[UIColor colorWithRed:225/255.0 green:96/255.0 blue:84/255.0 alpha:1.0]];
  UIBarButtonItem *cancelBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:cancelButtonString style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnPressed:)];
  [cancelBarBtnItem setTintColor:[UIColor whiteColor]];
  UIBarButtonItem *confirmBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:confirmButtonString style:UIBarButtonItemStylePlain target:self action:@selector(confirmBtnPressed:)];
  [confirmBarBtnItem setTintColor:[UIColor whiteColor]];
  
  // add view
  [navController.topViewController.navigationItem setLeftBarButtonItem:cancelBarBtnItem animated:YES];
  [navController.topViewController.navigationItem setRightBarButtonItem:confirmBarBtnItem animated:YES];
  [viewController.view addSubview:textView];
  
  // present the controller
  [self.viewController presentViewController:navController animated:YES completion:NULL];
  
}

#pragma Actions

- (void)cancelBtnPressed: (id) sender {
  [self clearoutPlaceholder];
  [self.viewController dismissViewControllerAnimated:YES completion:^(void) {
    [self removeObservers];
    NSString *escapeString = [textView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *jsonString = [NSString stringWithFormat:@"{\"status\" : \"cancel\",\"body\" : \"%@\"}", escapeString];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonString];
    [self writeJavascript:[pluginResult toSuccessCallbackString:cmd.callbackId]];
  }];
}

- (void)confirmBtnPressed: (id) sender {
  [self clearoutPlaceholder];
  [self removeObservers];
  [self.viewController dismissViewControllerAnimated:YES completion:^(void) {
    NSString *escapeString = [textView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *jsonString = [NSString stringWithFormat:@"{\"status\" : \"success\",\"body\" : \"%@\"}", escapeString];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonString];
    [self writeJavascript:[pluginResult toSuccessCallbackString:cmd.callbackId]];
  }];
}

- (void) clearoutPlaceholder {
  if ([textView.text isEqualToString:placeHolderString]) {
    textView.text = @"";
  }
}

- (void) removeObservers {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma TextView Delegate methods

- (void)textViewDidBeginEditing:(UITextView *)tView
{
  if ([tView.text isEqualToString:placeHolderString]) {
    tView.text = @"";
    tView.textColor = [UIColor blackColor];
  }
  [tView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)tView
{
  if ([tView.text isEqualToString:@""]) {
    tView.text = placeHolderString;
    tView.textColor = [UIColor lightGrayColor];
  }
  [tView resignFirstResponder];
}

#pragma keyboard Notifications

- (void)keyboardWillShow:(NSNotification*)notification {
  [self moveTextViewForKeyboard:notification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
  [self moveTextViewForKeyboard:notification up:NO];
}

- (void)moveTextViewForKeyboard:(NSNotification*)notification up:(BOOL)up {
  NSDictionary *userInfo = [notification userInfo];
  NSTimeInterval animationDuration;
  UIViewAnimationCurve animationCurve;
  CGRect keyboardRect;
  
  [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
  animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  keyboardRect = [self.viewController.view convertRect:keyboardRect fromView:nil];
  
  [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
  [UIView setAnimationDuration:animationDuration];
  [UIView setAnimationCurve:animationCurve];
  
  if (up == YES) {
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = textView.frame;
    originalTextViewFrame = textView.frame;
    newTextViewFrame.size.height = keyboardTop - textView.frame.origin.y;
    
    textView.frame = newTextViewFrame;
  } else {
    // Keyboard is going away (down) - restore original frame
    textView.frame = originalTextViewFrame;
  }
  
  [UIView commitAnimations];
}

@end