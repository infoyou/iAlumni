//
//  WechatIntroViewController.h
//  iAlumni
//
//  Created by Adam on 13-6-5.
//
//

#import "WXWRootViewController.h"

@interface WechatIntroViewController : WXWRootViewController <UIGestureRecognizerDelegate, UIActionSheetDelegate> {
  @private
  UIWebView *_contentWebView;
}

@end
