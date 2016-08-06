/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "TextArea.h"
#import "CDVTusdk.h"

@implementation MyTextAttachment
@end

@implementation TextAreaNavController

- (void)insertImage:(NSString*)filePath {
    MyTextAttachment* textAttachment = [[MyTextAttachment alloc] initWithData:nil ofType:nil];
    UIImage* image = [UIImage imageWithContentsOfFile:filePath];
    textAttachment.image = image;
    CGFloat width = self.textView.bounds.size.width-10;
    textAttachment.bounds = CGRectMake(0, 0, width, image.size.height * width / image.size.width);
    textAttachment.filePath = filePath;
    
    NSUInteger curPos = self.textView.selectedRange.location;
    [self.textView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment] atIndex:curPos];
    [self.textView.textStorage addAttribute:NSFontAttributeName
                                      value:self.textView.font
                                      range:NSMakeRange(curPos, 1)];
    [self.textView setSelectedRange:NSMakeRange(curPos+1, 0)];
    [self.textView.delegate textViewDidChange:self.textView];
    return;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
}

@end

@interface TextArea()<UITextViewDelegate> {
    
    NSString* titleString;
    NSString* confirmButtonString;
    NSString* cancelButtonString;
    NSString* placeHolderString;
    NSString* bodyText;
    BOOL isRichText;
    BOOL isAnonymous;
    
    TextAreaNavController* navController;
    UITextView* textView;
    UILabel* placeholder;
    CGRect originalTextViewFrame;
    UISwipeGestureRecognizer* swipeGesture;
    UIColor* themeColor;
    UIColor* themeColorDisabled;
    UIBarButtonItem *confirmBarBtnItem;
}

@end

@implementation TextArea

- (void)openTextView:(CDVInvokedUrlCommand*)command {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    themeColor = [UIColor colorWithRed:(100/255.0) green:(56/255.0) blue:(0/255.0) alpha:1];
    themeColorDisabled = [UIColor colorWithRed:(100/255.0) green:(56/255.0) blue:(0/255.0) alpha:0.3];
    
    self.currentCallbackId = command.callbackId;
    
    titleString = command.arguments[0];
    confirmButtonString = command.arguments[1];
    cancelButtonString = command.arguments[2];
    placeHolderString = command.arguments[3];
    bodyText = command.arguments[4];
    isRichText = [[command argumentAtIndex:5 withDefault:0] boolValue];
    isAnonymous = NO;
    
    UIFont* textFont = [UIFont fontWithName:@"STHeitiSC-Light" size:16];
    
    // create controllers
    UIViewController* viewController = [[UIViewController alloc] init];
    navController = [[TextAreaNavController alloc] initWithRootViewController:viewController];
    
    // create view
    textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, viewController.view.frame.size.width-20, viewController.view.frame.size.height-10)];
    [textView becomeFirstResponder];
    
    // image button
    if (isRichText) {
        UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 36.0f)];
        toolbar.translucent = YES;
        toolbar.barStyle = UIBarStyleDefault;
        toolbar.backgroundColor = [UIColor whiteColor];
        toolbar.clipsToBounds = YES;
        
        NSString* imageBtnBg = @"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEgAAAA0CAYAAAApDX79AAAAAXNSR0IArs4c6QAAAAlwSFlzAAALEwAACxMBAJqcGAAAA6ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIKICAgICAgICAgICAgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iPgogICAgICAgICA8eG1wOk1vZGlmeURhdGU+MjAxNi0wNy0xMlQxMzowNzo4MjwveG1wOk1vZGlmeURhdGU+CiAgICAgICAgIDx4bXA6Q3JlYXRvclRvb2w+UGl4ZWxtYXRvciAzLjA8L3htcDpDcmVhdG9yVG9vbD4KICAgICAgICAgPHRpZmY6T3JpZW50YXRpb24+MTwvdGlmZjpPcmllbnRhdGlvbj4KICAgICAgICAgPHRpZmY6Q29tcHJlc3Npb24+NTwvdGlmZjpDb21wcmVzc2lvbj4KICAgICAgICAgPHRpZmY6UmVzb2x1dGlvblVuaXQ+MTwvdGlmZjpSZXNvbHV0aW9uVW5pdD4KICAgICAgICAgPHRpZmY6WVJlc29sdXRpb24+NzI8L3RpZmY6WVJlc29sdXRpb24+CiAgICAgICAgIDx0aWZmOlhSZXNvbHV0aW9uPjcyPC90aWZmOlhSZXNvbHV0aW9uPgogICAgICAgICA8ZXhpZjpQaXhlbFhEaW1lbnNpb24+NzI8L2V4aWY6UGl4ZWxYRGltZW5zaW9uPgogICAgICAgICA8ZXhpZjpDb2xvclNwYWNlPjE8L2V4aWY6Q29sb3JTcGFjZT4KICAgICAgICAgPGV4aWY6UGl4ZWxZRGltZW5zaW9uPjUyPC9leGlmOlBpeGVsWURpbWVuc2lvbj4KICAgICAgPC9yZGY6RGVzY3JpcHRpb24+CiAgIDwvcmRmOlJERj4KPC94OnhtcG1ldGE+CsqZzIsAAAPTSURBVGgF7ZrbThNRFIZ7xGAtImDwgCHWaqw94hFiNNXoK5jwIj6EL0K81EAECpRHaJteeuGFiVf6BEj9/zqQyXTPrJnOUPaEPcnW2Wvt0/rm3wc2JBuNxiBhHlcCKVePcQwJGECCEAwgAVDG6e90Okmn7SLlnWuyUZDw9Q0gA0ggILiNggwggYDgNgoygAQCgnvkHCSUV7prtdpSKpX6BGfTKnB4fHz8sdfr/VRWiJEx9BQjnGQy2UXM60g3rbROG30xYqEcamhAVA5gzDlbp81SldMVq3xoQIi26RGxl8+jmj6uKACdezTFYvHSWQ0iCkCHHoPz8nlU8++qVqtruVzue71ef+6/lv+SoQFxtxoMBn+cXdJGn9MeZR6bwGo6nd7GesfNYAewnkTZPtsKDYhbOWDU0dYG0i8rbdB2lts84LzAJrCD/maQEoA0i3wLSlphPqon6bz/iMN9EKcTgOwCwlUFiN9HR0dv+/1+T+ETTU4eoRUk9hhxAQEOe5vPZDJ7KFeOoutYASqXy888lGPncR2Z/UqlUrIbx3mPDSDCgTLcptVI7AC5iAX8AEp6MOIMYIgFICjhKeFwIQ4QGxfuG0htwC0GqWcvqz0gbt1QQisoHFuQtwC3jXYKNpvvV60BEQ637hBwhiBQf4nTrVQqLfsmYxXUFhDOOY8tONeCBuVSfnlqaqqN6XrHxa80awmIcPDV95CigjMMHu3d5XTDwn1bSUNh1A4QBr+CQDitIoVji/0e2m5juvHuSny0AkQ4GDGVM3K/JEYSrMB9TLcDTLdFqZo2gHDEb0wIzpAJPsJDTLeDiQAqFAqqn4mkvk/9k4Zz2nEi8cj2rnwNrSDI9H0+n/+BLfmdsgfBiEMcbwL2kOaFoufiDgUIa8YbyPQL5DqLc8ZXKKEZJArArWWz2X3U0RIOYxkbEBTzGmA20cY0G8IzjTugTWzRr/5nvf8lHMDVGg4jGAsQlPISh7gt1L9sxwBgOaQtwFuz253v8FctOAtOn275wICgkFUo5RtAXFEFA3se022bP32r/ITDYz982sPh+AMBYtBQDu+A86rgbbYZKGSXJ2KbLYF8BXA4rWIBh2P3DYjBMmjU8bWlA+IsUsvapYZwAJfK4WVWbB5fgHhOYbAMOkhkKD+HXYrXnx/iCIexin+8wDUD5Qhn3OP/Aup+DgJWp7KigvDleYiLzZoRNVxRQeiQ0+qvW8fY0cL+2XCo+lBnqPpucZ3YRUDdbvfMfu99Mgid/xenmM6Dn8TYDCCBsgEkABr53bxQ/sK5jYKET24AGUACAcH9D6JFpa0OgoylAAAAAElFTkSuQmCC";
        UIBarButtonItem* imageButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageBtnBg]] scale:2.0f] style:UIBarButtonItemStyleDone target:self action:@selector(openPhotoBox:)];
        
        UILabel* tmpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50.0f, 26.0f)];
        tmpLabel.text = @"匿名发布";
        tmpLabel.font = textFont;
        [tmpLabel sizeToFit];
        UIBarButtonItem* anonymousLabel = [[UIBarButtonItem alloc] initWithCustomView:tmpLabel];
        
        UISwitch* tmpSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [tmpSwitch addTarget:self action:@selector(anonymousSwitch:) forControlEvents:UIControlEventValueChanged];
        //tmpSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
        UIBarButtonItem* anonymousButton = [[UIBarButtonItem alloc] initWithCustomView:tmpSwitch];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSpace.width = 20.0f;
        
        UIBarButtonItem* draftButton = [[UIBarButtonItem alloc] initWithTitle:@"存入草稿箱" style:UIBarButtonItemStylePlain target:self action:@selector(saveToDraft:)];
        
        [toolbar setItems:@[imageButton, fixedSpace, anonymousLabel, anonymousButton, flexibleSpace, draftButton]];
        textView.inputAccessoryView = toolbar;
    }
    
    // for keyboard hide
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [textView addGestureRecognizer:swipeGesture];
    
    // load body for textView and add border
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.headIndent = 0;
    paragraphStyle.firstLineHeadIndent = 0;
    paragraphStyle.tailIndent = 0;
    NSDictionary *attrsDictionary = @{NSFontAttributeName:textFont, NSParagraphStyleAttributeName:paragraphStyle};
    [textView setDelegate:self];
    [textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [textView setTintColor:themeColor];
    [textView setFont:textFont];
    [textView setTextColor:[UIColor blackColor]];
    textView.attributedText = [[NSAttributedString alloc] initWithString:@" " attributes:attrsDictionary];
    textView.text = bodyText;
    
    [viewController setTitle:titleString];
    
    [navController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [navController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    UIBarButtonItem* cancelBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:cancelButtonString style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnPressed:)];
    [cancelBarBtnItem setTintColor:[UIColor grayColor]];
    confirmBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:confirmButtonString style:UIBarButtonItemStylePlain target:self action:@selector(confirmBtnPressed:)];
    [confirmBarBtnItem setTintColor:themeColorDisabled];
    
    [navController.topViewController.navigationItem setLeftBarButtonItem:cancelBarBtnItem animated:NO];
    [navController.topViewController.navigationItem setRightBarButtonItem:confirmBarBtnItem animated:NO];
    
    // add view
    [viewController.view addSubview:textView];
    
    // add placeholder
    placeholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, viewController.view.frame.size.width, 18)];
    placeholder.font = textFont;
    placeholder.textColor = [UIColor lightGrayColor];
    placeholder.text = placeHolderString;
    placeholder.backgroundColor = [UIColor clearColor];
    
    if (![bodyText isEqualToString:@""]) {
        placeholder.hidden = YES;
        [confirmBarBtnItem setTintColor:themeColor];
    }
    
    [textView addSubview:placeholder];
    
    viewController.view.backgroundColor = [UIColor whiteColor];
    navController.textView = textView;
    
    // present the controller
    [self.viewController presentViewController:navController animated:YES completion:NULL];
}

#pragma Actions

- (NSString *)getPlainString
{
    //最终纯文本
    NSMutableString* plainString = [NSMutableString stringWithString:textView.attributedText.string];
    //替换下标的偏移量
    __block NSUInteger base = 0;
    //遍历
    [textView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                        inRange:NSMakeRange(0, textView.attributedText.length)
                                        options:0
                                     usingBlock:^(id value, NSRange range, BOOL *stop) {
                                         //检查类型是否是NSTextAttachment类
                                         if (value && [value isKindOfClass:[MyTextAttachment class]]) {
                                             //替换
                                             MyTextAttachment* myAttachment = (MyTextAttachment *) value;
                                             NSString* imgStr = [NSString stringWithFormat:@"<img src=\"%@\" width=\"%d\" height=\"%d\">", myAttachment.filePath, (int)myAttachment.image.size.width, (int)myAttachment.image.size.height];
                                             [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length) withString:imgStr];
                                             //增加偏移量
                                             base += imgStr.length - 1;
                                         }
                                     }];
    return plainString;
}

- (void)anonymousSwitch:(id)sender {
    if ([sender isOn]) {
        [navController.topViewController setTitle:[NSString stringWithFormat:@"%@(匿名)", titleString]];
        isAnonymous = YES;
    } else {
        [navController.topViewController setTitle:titleString];
        isAnonymous = NO;
    }
}

- (void)sendDraft:(NSString *)text {
    NSString* js = [NSString stringWithFormat:@"TextArea.saveToDraft('%@');", text];
    if(![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.commandDelegate evalJs:js];
        });
    } else {
        [self.commandDelegate evalJs:js];
    }
}
- (void)clearDraft {
    [self sendDraft:@""];
}
- (void)saveToDraft {
    NSString* text = [textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    [self sendDraft:text];
}
- (void)saveToDraft:(id)sender {
    if (textView.attributedText.length == 0) {
        return;
    }
    __weak UIBarButtonItem* draftButton = sender;
    [draftButton setTitle:@"正在保存…"];
    [draftButton setEnabled:NO];
    [self saveToDraft];
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        [draftButton setTitle:@"保存成功"];
    });
    delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        [draftButton setTitle:@"存入草稿箱"];
        [draftButton setEnabled:YES];
    });
}

- (void)openPhotoBox:(id)sender {
    CDVTusdk* Tusdk = [[CDVTusdk alloc] init];
    [Tusdk openPhotoBoxNative:navController withAppKey:[[self.commandDelegate settings] objectForKey:@"tusdkappkey_ios"]];
}

-(void)handleGesture:(UIGestureRecognizer*)gesture
{
    [textView resignFirstResponder];
}

- (void)cancelBtnPressed: (id) sender {
    if (textView.attributedText.length == 0) {
        [self clearDraft];
        [self canceled];
        return;
    }
    //初始化提示框；
    /**
     preferredStyle参数： UIAlertControllerStyleActionSheet, UIAlertControllerStyleAlert
     */
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"确定放弃本次编辑吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    /**
     *  style参数： UIAlertActionStyleDefault, UIAlertActionStyleCancel, UIAlertActionStyleDestructive
     */
    //分别按顺序放入每个按钮；
    if (isRichText) {
        [alert addAction:[UIAlertAction actionWithTitle:@"存入草稿箱" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
            [self saveToDraft];
            [self canceled];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定放弃" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
        //点击按钮的响应事件； //NSLog(@"点击了确定");
        if (isRichText) {
            [self clearDraft];
        }
        [self canceled];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * __nonnull action) {
        //点击按钮的响应事件； //NSLog(@"点击了取消");
    }]];
    
    //弹出提示框；
    [navController presentViewController:alert animated:YES completion:nil];
    return;
}

- (void)canceled {
    [textView resignFirstResponder];
    [self.viewController dismissViewControllerAnimated:YES completion:^(void) {
        [self removeObservers];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
    }];
}

- (void)confirmBtnPressed: (id) sender {
    if (textView.attributedText.length == 0) {
        return;
    }
    [textView resignFirstResponder];
    NSString *sendingString = @"";
    sendingString = [self getPlainString];
    NSMutableDictionary* textResult = [NSMutableDictionary dictionaryWithDictionary:@{@"text":sendingString}];
    if (isAnonymous) {
        [textResult setObject:@"1" forKey:@"anonymous"];
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:textResult];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
    
    [self.viewController dismissViewControllerAnimated:YES completion:^(void) {
        [self removeObservers]; //closed
    }];
}

- (void) removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [textView removeGestureRecognizer:swipeGesture];
}

#pragma TextView Delegate methods

- (void)textViewDidChange:(UITextView *)tView
{
    if (tView.attributedText.length == 0) {
        placeholder.hidden = NO;
        [confirmBarBtnItem setTintColor:themeColorDisabled];
    } else {
        placeholder.hidden = YES;
        [confirmBarBtnItem setTintColor:themeColor];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)tView
{
    [tView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)tView
{
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
    
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        return;
    }
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardRect;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.viewController.view convertRect:keyboardRect fromView:nil];
    
    //[UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    //[UIView setAnimationDuration:animationDuration];
    //[UIView setAnimationCurve:animationCurve];
    
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

    /*
- (void)insertImage:(NSString*)filePath {
    NSTextAttachment* textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://iknow02.bosstatic.bdimg.com/zhidaoribao/2016/0701/top.jpg"]]];
    //UIImage* image = [UIImage imageWithContentsOfFile:filePath];
    textAttachment.image = image;
    textAttachment.bounds = CGRectMake(0, 0, 100, 100);
    NSAttributedString* textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
    [string insertAttributedString:textAttachmentString atIndex:textView.selectedRange.location];
    [string addAttribute:NSFontAttributeName
                   value:textFont
                   range:NSMakeRange(0, string.length)];
    
    textView.attributedText = string;
}
     */
@end
