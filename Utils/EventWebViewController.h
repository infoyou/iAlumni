//
//  EventWebViewController.h
//  iAlumni
//
//  Created by Adam on 15-3-10.
//  Copyright (c) 2015年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXWRootViewController.h"

@interface EventWebViewController : WXWRootViewController <UIWebViewDelegate>
{
    NSString *strUrl;
    NSString *strTitle;
  
    BOOL _needAdjustForiOS7;
}

@property (nonatomic, retain) NSString *strUrl;
@property (nonatomic, retain) NSString *strTitle;

@property (nonatomic, retain) UIWebView *webView;

- (id)initWithNeedAdjustForiOS7:(BOOL)needAdjustForiOS7;

- (void)doClose:(id)sender;
- (void)doBack;

@end
