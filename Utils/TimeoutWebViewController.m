//
//  TimeoutWebViewController.m
//  iAlumni
//
//  Created by Adam on 12-2-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TimeoutWebViewController.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import <netinet/in.h>
#import "GlobalConstants.h"
#import "TextConstants.h"
#import "AppManager.h"
#import "UIUtils.h"

typedef enum {
WEBVIEW_TAG = 1,
TOOLBAR,
} UIBACKWEB_VIEW_TAG;

@interface TimeoutWebViewController()
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, copy) NSString *backTitle;
@property (nonatomic, retain) UIBarButtonItem *preBtn;
@property (nonatomic, retain) UIBarButtonItem *nextBtn;
@end

@implementation TimeoutWebViewController
@synthesize urlStr;
@synthesize toolbar;
@synthesize webView = _webView;
@synthesize backTitle = _backTitle;
@synthesize preBtn = _preBtn;
@synthesize nextBtn = _nextBtn;
@synthesize currentUrl;

- (id)initWithBackTitle:(NSString *)backTitle
{
    self = [super initWithMOC:nil holder:nil backToHomeAction:nil needGoHome:NO];
    if (self) {
        self.backTitle = backTitle;
        isExit = NO;
    }
    
    return self;
}

- (UIWebView *)webView {
	if (_webView == nil) {
        CGRect webFrame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT - 22);
		_webView = [[UIWebView alloc] initWithFrame:webFrame];
		_webView.tag = WEBVIEW_TAG;
		_webView.userInteractionEnabled = YES;
		_webView.backgroundColor = TRANSPARENT_COLOR;
        _webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [_webView setScalesPageToFit:YES];
		_webView.delegate = self;
		_webView.opaque = NO;
	}
	
	return _webView;
}

- (void)createToolbar
{
    //Creat ToolBar
  CGFloat y = self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - 20;

	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, y, 320, 20)];
	[toolbar setTag:TOOLBAR];
	toolbar.barStyle = UIBarStyleDefault;
	[toolbar sizeToFit];
    
    // add previous bar button
    UIButton *preBarbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [preBarbtn setTitle:LocaleStringForKey(@"Pre", nil) forState:UIControlStateNormal];
    preBarbtn.titleLabel.font = BOLD_FONT(15);
    [preBarbtn setTitleColor:[UIColor whiteColor]
                    forState:UIControlStateNormal];
    [preBarbtn setTitleColor:[UIColor darkGrayColor]
                    forState:UIControlStateDisabled];
    preBarbtn.showsTouchWhenHighlighted = YES;
    
    [preBarbtn addTarget:self
                  action:@selector(navigationBack:)
        forControlEvents:UIControlEventTouchUpInside];
    
    CGSize size = [preBarbtn.titleLabel.text sizeWithFont:[preBarbtn.titleLabel font]];
    
    preBarbtn.frame = CGRectMake(0.0f, 0.0f, size.width,size.height);
    
	self.preBtn = [[[UIBarButtonItem alloc] initWithCustomView:preBarbtn] autorelease];
    self.preBtn.enabled = NO;
    
	
	UIBarButtonItem *Item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];
	
	UIBarButtonItem *Item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];
	
    UIButton *nextBarbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBarbtn setTitle:LocaleStringForKey(@"Next", nil) forState:UIControlStateNormal];
    nextBarbtn.titleLabel.font = BOLD_FONT(15);
    [nextBarbtn setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
    [nextBarbtn setTitleColor:[UIColor darkGrayColor]
                     forState:UIControlStateDisabled];
    nextBarbtn.showsTouchWhenHighlighted = YES;
    
    [nextBarbtn addTarget:self
                   action:@selector(navigationForward:)
         forControlEvents:UIControlEventTouchUpInside];
    
    size = [nextBarbtn.titleLabel.text sizeWithFont:[nextBarbtn.titleLabel font]];
    
    nextBarbtn.frame = CGRectMake(0.0f, 0.0f, size.width,size.height);
	self.nextBtn = [[[UIBarButtonItem alloc] initWithCustomView:nextBarbtn] autorelease];
    self.nextBtn.enabled = NO;
    
	NSArray *items = [[[NSArray alloc] initWithObjects:self.preBtn, Item1, Item2, self.nextBtn, nil] autorelease];
	[toolbar setItems:items];
	toolbar.hidden = NO;
	[self.view addSubview:toolbar];
	
    RELEASE_OBJ(Item1);
    RELEASE_OBJ(Item2);
}

- (void)initNavibar
{
  
  [self addLeftBarButtonWithTitle:self.backTitle
                           target:self
                           action:@selector(back:)];

	[self addLeftBarButtonWithTitle:LocaleStringForKey(NSCloseTitle, nil)
                           target:self
                           action:@selector(doClose:)];
}

//- (void)initNavibar
//{
//    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:LocaleStringForKey(self.backTitle, nil)]];
//	[segmentedControl addTarget:self
//                         action:@selector(back:)
//               forControlEvents:UIControlEventValueChanged];
//	segmentedControl.frame = CGRectMake(0, 0, 70, 30);
//	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
//	segmentedControl.momentary = YES;
//
//	UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
//
//	self.navigationItem.leftBarButtonItem = backBtn;
//	[segmentedControl release];
//	segmentedControl = nil;
//
//	RELEASE_OBJ(backBtn);
//
//	// add refresh button
//	UIBarButtonItem *refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
//                                                                                target:self
//                                                                                action:@selector(refresh:)];
//	self.navigationItem.rightBarButtonItem = refreshBtn;
//	RELEASE_OBJ(refreshBtn);
//}

- (void)addWebView{
    if (self.urlStr && [self.urlStr length] > 0) {
        if (![urlStr hasPrefix:@"http://"]) {
            urlStr = [NSString stringWithFormat:@"http://%@",urlStr];
        }
        NSURL *url = [NSURL URLWithString:[self.urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                             timeoutInterval:NETWORK_TIMEOUT];
        [self.view addSubview:self.webView];
        [self.webView loadRequest:request];
    }
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self initNavibar];
    [self addWebView];
    //    [self createToolbar];
}

- (void)viewDidUnload {
	self.webView = nil;
}

- (void)closeWebView
{
    [UIUtils closeActivityView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)checkUrl {
    if ([currentUrl hasSuffix:[NSString stringWithFormat:@"/wap/wap_questionnaire.jsp?locale=%@",[WXWSystemInfoManager instance].currentLanguageDesc]] || [currentUrl hasSuffix:[NSString stringWithFormat:@"/wap/wap_lookup_questionnaire.jsp?locale=%@",[WXWSystemInfoManager instance].currentLanguageDesc]] || [currentUrl hasSuffix:[NSString stringWithFormat:@"/wap/wap_active_detail.jsp?locale=%@",[WXWSystemInfoManager instance].currentLanguageDesc]] || [currentUrl hasSuffix:NO_PAGE_URL]) {
        return YES;
    }
    return NO;
}

- (void)back:(id)sender {
    
    NSLog(@"back Method CurrentUrl = %@",currentUrl);
    if (isExit || _sessionExpired || [self checkUrl]) {
        [self.webView stopLoading];
        [self.webView removeFromSuperview];
        [self closeWebView];
        [self dismissModalViewControllerAnimated:YES];
        return;
    }
    
    if (self.webView.canGoBack) {
        [self.webView goBack];
        if (isNeedBreakExit) {
            isExit = YES;
        }
    } else {
        [self.webView stopLoading];
        [self.webView removeFromSuperview];
        [self closeWebView];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
}

#pragma mark - UIWebViewDelegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIUtils showActivityView:self.view text:LocaleStringForKey(NSLoadingTitle, nil)];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	
	NSString *url = [[request URL] absoluteString];
    currentUrl = [[NSString alloc] initWithFormat:@"%@",url];
    if (currentUrl && [self checkUrl]) {
        isNeedBreakExit = YES;
    }
    if (url && [url length] > 0) {
        if ([url rangeOfString:NO_PAGE_URL].length > 0) {
            _sessionExpired = YES;
        }
    }
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self closeWebView];
    if (_sessionExpired) {
        [self dismissModalViewControllerAnimated:YES];
        [self.navigationController removeFromParentViewController];
        [AppManager instance].errDesc = LocaleStringForKey(NSSessionInvalidTitle, nil);
        [AppManager instance].sessionExpired = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIUtils closeActivityView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	self.urlStr = nil;
    self.currentUrl = nil;
    self.backTitle = nil;
    
    [UIUtils closeActivityView];
    [_webView setDelegate:nil];
    [_webView stopLoading];
    RELEASE_OBJ(_webView);
	
    self.preBtn = nil;
    self.nextBtn = nil;
    if (toolbar) {
        RELEASE_OBJ(toolbar);
    }
	
	[super dealloc];
}

#pragma mark webView navigation and refresh method
- (void)refresh:(id)sender {
	[self.webView reload];
}

- (void)navigationBack:(id)sender {
	[self.webView goBack];
}

- (void)navigationForward:(id)sender {
	[self.webView goForward];
}

- (void)stop:(id)sender {
	[self.webView stopLoading];
}

- (void)doClose:(id)sender {
    
    [self.webView stopLoading];
    [UIUtils closeActivityView];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark toolbar visibility
- (void)hideToolbar {
	toolbar.hidden = YES;
	self.webView.frame = CGRectMake(0, 0, 320, 420);
}

- (void)showToolbar {
	toolbar.hidden = NO;
	self.webView.frame = CGRectMake(0, 0, 320, 380);
}

@end