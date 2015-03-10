//
//  TimeoutWebViewController.h
//  iAlumni
//
//  Created by Adam on 12-2-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWRootViewController.h"

@interface TimeoutWebViewController : WXWRootViewController <UIWebViewDelegate>
{
    UIWebView *_webView;
	
	NSString *urlStr;
	UIToolbar *toolbar;
    
	NSString *_backTitle;
    
    NSString *currentUrl;
    BOOL isNeedBreakExit;
    BOOL isExit;
}

@property (nonatomic, retain) NSString *urlStr;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSString *currentUrl;

- (id)initWithBackTitle:(NSString *)backTitle;
- (void)hideToolbar;
- (void)showToolbar;

@end