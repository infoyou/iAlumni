//
//  PaymentWebViewController.m
//  iAlumni
//
//  Created by Adam on 13-8-28.
//
//

#import "PaymentWebViewController.h"
#import "UIUtils.h"

@interface PaymentWebViewController ()
@property (nonatomic, copy) NSString *url;
@end

@implementation PaymentWebViewController

#pragma mark - life cycle methods

- (void)closeAndBackToItemDetail {
  
  if (_parentVC && [_parentVC respondsToSelector:@selector(backToItemDetail)]) {
    
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaymentDoneMsg, nil) msgType:SUCCESS_TY belowNavigationBar:YES];
    
    [_parentVC performSelector:@selector(backToItemDetail)];
  }
  
  [self doClose];
}

- (void)doClose {
  
  [_webView stopLoading];
  
  [UIUtils closeActivityView];
  
  [self dismissModalViewControllerAnimated:YES];
}

- (void)closePaymentView:(id)sender {
  
  [self doClose];
}

- (id)initWithUrl:(NSString *)url parentVC:(UIViewController *)parentVC
{
  self = [super init];
  if (self) {
    self.url = url;
    
    _parentVC = parentVC;
  }
  return self;
}

- (void)dealloc {
  
  [_webView stopLoading];
  _webView.delegate = nil;
  
  self.url = nil;
  
  [super dealloc];
}

- (void)initWebView {
  CGFloat height = 0;
  if (CURRENT_OS_VERSION >= IOS7) {
    height = SCREEN_HEIGHT;
  } else {
    height = SCREEN_HEIGHT - 22;
  }
  
  CGRect webFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, height);
  _webView = [[[UIWebView alloc] initWithFrame:webFrame] autorelease];
  _webView.backgroundColor = [UIColor whiteColor];
  _webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
  _webView.delegate = self;
  _webView.scalesPageToFit = YES;
  _webView.userInteractionEnabled = YES;
  
  if (![self.url hasPrefix:@"http://"]) {
    self.url = [NSString stringWithFormat:@"http://%@",self.url];
  }
  NSURL *url = [NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  
  [_webView loadRequest:[NSURLRequest requestWithURL:url]];
  
  [self.view addSubview:_webView];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self addLeftBarButtonWithTitle:LocaleStringForKey(NSCloseTitle, nil)
                           target:self
                           action:@selector(closePaymentView:)];
  
  [self initWebView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UIWebViewDelegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
  [UIUtils showActivityView:self.view text:LocaleStringForKey(NSLoadingTitle, nil)];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
  NSString *url = [[request URL] absoluteString];
  
  NSLog(@"url: %@", url);
  
  if (url && [url length] > 0) {
    if ([url rangeOfString:GROUP_PAYMENT_SUFFIX].length > 0 ||
        [url rangeOfString:EVENT_PAYMENT_SUFFIX].length > 0 ||
        [url rangeOfString:WELFARE_PAYMENT_SUFFIX].length > 0) {
    
      [self closeAndBackToItemDetail];
      
      return NO;
    } else if ([url rangeOfString:@"common_check_code.htm?"].length > 0 &&
               [url rangeOfString:@"awid="].length > 0 &&
               [url rangeOfString:@"orderId="].length == 0 &&
               [url rangeOfString:@"channelToken="].length == 0) {
      
      // current loading loop is for last payment action, then hide "Close" button,
      // leave the "返回商户" button on UI as only back entrance
      self.navigationItem.leftBarButtonItem = nil;
      
      return YES;
    }
  }
  
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [UIUtils closeActivityView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  [UIUtils closeActivityView];
}

@end
