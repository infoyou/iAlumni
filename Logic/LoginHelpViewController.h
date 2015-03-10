//
//  LoginHelpViewController.h
//  iAlumni
//
//  Created by Adam on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXWRootViewController.h"

@interface LoginHelpViewController : WXWRootViewController <UIWebViewDelegate>
{
    NSString *strUrl;
    NSString *strTitle;
    
    UIWebView *webView;
}

@property(nonatomic,retain) NSString *strUrl;
@property(nonatomic,retain) NSString *strTitle;

@end
