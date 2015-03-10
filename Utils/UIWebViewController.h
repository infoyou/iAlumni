//
//  UIWebViewController.h
//  iAlumni
//
//  Created by Adam on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXWRootViewController.h"

@interface UIWebViewController : WXWRootViewController <UIWebViewDelegate>
{
    NSString *strUrl;
    NSString *strTitle;
    
    UIWebView *_webView;
  
    BOOL _needAdjustForiOS7;
}

@property (nonatomic, retain) NSString *strUrl;
@property (nonatomic, retain) NSString *strTitle;

- (id)initWithNeedAdjustForiOS7:(BOOL)needAdjustForiOS7;

- (void)doClose:(id)sender;
- (void)doBack;

@end
