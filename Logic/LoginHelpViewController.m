//
//  LoginHelpViewController.m
//  iAlumni
//
//  Created by Adam on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LoginHelpViewController.h"
#import "iAlumniAppDelegate.h"
#import "GlobalConstants.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIUtils.h"

@implementation LoginHelpViewController

@synthesize strUrl;
@synthesize strTitle;

- (id)init
{
  self = [super init];
  if (self) {
    _noNeedBackButton = YES;
  }
  return self;
}

- (void)dealloc
{
  strUrl = nil;
  strTitle = nil;
  
  [UIUtils closeActivityView];
  RELEASE_OBJ(webView);
  [super dealloc];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)initNavibar
{
  /*
  UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TOOLBAR_HEIGHT)];
  toolbar
  
  UILabel *titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, TOOLBAR_HEIGHT)] autorelease];
  titleLabel.font = FONT(17);
  titleLabel.backgroundColor = TRANSPARENT_COLOR;
  titleLabel.textColor = [UIColor whiteColor];
  
  titleLabel.text = strTitle;
  UIBarButtonItem *titleBarBtn = [[[UIBarButtonItem alloc] initWithCustomView:titleLabel] autorelease];
  
  UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:nil
                                                                          action:nil] autorelease];
  
  UIBarButtonItem *closeBarBtn = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close.png"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(doBack:)] autorelease];
  NSArray *btns = [[[NSArray alloc] initWithObjects:titleBarBtn, space, closeBarBtn, nil] autorelease];
  
  [toolbar setItems:btns animated:YES];
  [self.view addSubview:toolbar];
  RELEASE_OBJ(toolbar);
   */
  
  self.navigationItem.title = strTitle;
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSCloseTitle, nil)
                            target:self
                            action:@selector(doBack:)];
  
}

- (void)initWebView
{
  CGRect webFrame = CGRectMake(0.0, 0, self.view.frame.size.width, self.view.frame.size.height);
  webView = [[UIWebView alloc] initWithFrame:webFrame];
  [webView setBackgroundColor:[UIColor whiteColor]];
  webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
  webView.delegate = self;
  webView.scalesPageToFit = YES;
  webView.userInteractionEnabled = YES;
  
  if (![strUrl hasPrefix:@"http://"]) {
    strUrl = [NSString stringWithFormat:@"http://%@",strUrl];
  }
  NSURL *url = [NSURL URLWithString:[self.strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                          timeoutInterval:NETWORK_TIMEOUT];
  
  [webView loadRequest:requestObj];
  [self.view addSubview:webView];
}

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  [self initNavibar];
  [self initWebView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIWebViewDelegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
  [UIUtils showActivityView:self.view text:LocaleStringForKey(NSLoadingTitle, nil)];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
  NSString *url = [[request URL] absoluteString];
  
  if (url && [url length] > 0) {
    if ([url rangeOfString:NO_PAGE_URL].length > 0) {
      _sessionExpired = YES;
    }
  }
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  if (_sessionExpired) {
    [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:YES];
  }
  [UIUtils closeActivityView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  [UIUtils closeActivityView];
}

#pragma mark - back
- (void)doBack:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}

@end
