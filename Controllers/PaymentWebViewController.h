//
//  PaymentWebViewController.h
//  iAlumni
//
//  Created by Adam on 13-8-28.
//
//

#import "WXWRootViewController.h"

@interface PaymentWebViewController : WXWRootViewController <UIWebViewDelegate> {
  @private
  UIWebView *_webView;
  
  UIViewController *_parentVC;
}

- (id)initWithUrl:(NSString *)url parentVC:(UIViewController *)parentVC;

@end
