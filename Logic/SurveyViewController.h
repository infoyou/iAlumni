//
//  SurveyViewController.h
//  iAlumni
//
//  Created by Adam on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWRootViewController.h"

@interface SurveyViewController : WXWRootViewController <UIWebViewDelegate>
{
    NSString *strUrl;
    NSString *strTitle;
    
    UIWebView *webView;
}

@property(nonatomic,retain) NSString *strUrl;
@property(nonatomic,retain) NSString *strTitle;

@end