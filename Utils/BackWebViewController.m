//
//  BackWebViewController.m
//  iAlumni
//
//  Created by Adam on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BackWebViewController.h"
#import "iAlumniAppDelegate.h"
#import "GlobalConstants.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIUtils.h"
#import "WXWBarItemButton.h"
#import "AppManager.h"

#define BACK_BUTTON_WIDTH   48.0f
#define BACK_BUTTON_HEIGHT  44.0f

@interface BackWebViewController()
@property (nonatomic, retain) UIWebView *webView;
@end

@implementation BackWebViewController
@synthesize strUrl;
@synthesize strTitle;
@synthesize webView = _webView;

- (id)initWithNeedAdjustForiOS7:(BOOL)needAdjustForiOS7
{
    self = [super init];
    
    if (self) {
        _needAdjustForiOS7 = needAdjustForiOS7;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveEventNotify)
                                                     name:DM_PUSH_EVENT_NOTIFY
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    self.strUrl = nil;
    self.strTitle = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DM_PUSH_EVENT_NOTIFY
                                                  object:nil];

    [UIUtils closeActivityView];
    [self.webView setDelegate:nil];
    [self.webView stopLoading];
    self.webView = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.strTitle;
    
//    [self addRightBarBut];
    [self addLeftBarBut];
    
    CGFloat height = 0;
    if (_needAdjustForiOS7) {
        height = SCREEN_HEIGHT;
    } else {
        height = SCREEN_HEIGHT - 22;
    }
    
    CGRect webFrame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, height);
    self.webView = [[[UIWebView alloc] initWithFrame:webFrame] autorelease];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.webView.userInteractionEnabled = YES;
    
    if (![self.strUrl hasPrefix:@"http://"]) {
        self.strUrl = [NSString stringWithFormat:@"http://%@",self.strUrl];
    }
    NSURL *url = [NSURL URLWithString:[self.strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    [self.view addSubview:self.webView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)addRightBarBut
{
    WXWBarItemButton *backButton = [[[WXWBarItemButton alloc] initBackStyleButtonWithFrame:CGRectMake(0, 0, BACK_BUTTON_WIDTH, BACK_BUTTON_HEIGHT)] autorelease];
    [backButton addTarget:self action:@selector(doClose:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    [self addRightBarButtonWithTitle:LocaleStringForKey(NSCloseTitle, nil)
                              target:self
                              action:@selector(doClose:)];
}

- (void)addLeftBarBut
{
    WXWBarItemButton *backButton = [[[WXWBarItemButton alloc] initBackStyleButtonWithFrame:CGRectMake(0, 0, BACK_BUTTON_WIDTH, BACK_BUTTON_HEIGHT)] autorelease];
    [backButton addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    [self addLeftBarButtonWithTitle:LocaleStringForKey(NSBackTitle, nil)
                              target:self
                              action:@selector(doBack:)];
}

#pragma mark - UIWebViewDelegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIUtils showActivityView:self.view text:LocaleStringForKey(NSLoadingTitle, nil)];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];
    
    NSLog(@"url = %@", url);
    
    if (url && [url length] > 0) {
        if ([url rangeOfString:NO_PAGE_URL].length > 0) {
            _sessionExpired = YES;
        }
        
        
        if ([url rangeOfString:@"http://wx.xiehuibang.cn:9004/HtmlApps/html/public/recruitZone/PubJobRecruitment.html"].length > 0) {
            
            NSLog(@"======PubJobRecruitment.html======");
        }
        
        if ([url rangeOfString:@"http://wx.xiehuibang.cn:9004/HtmlApps/html/public/recruitZone/pubPublishResume.html"].length > 0) {
            
            NSLog(@"======pubPublishResume.html======");
        }

    }
    
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_sessionExpired) {
        [AppManager instance].errDesc = LocaleStringForKey(NSSessionInvalidTitle, nil);
        [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:YES];
    }
    
    if (needBack) {
        needBack = NO;
        [webView goBack];
    }
    
    [UIUtils closeActivityView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIUtils closeActivityView];
}

- (void)doBack:(id)sender
{
    if ([self.webView canGoBack]) {
        
        [self.webView goBack];
    } else {
        
        [self doClose:nil];
    }
}

- (void)doClose:(id)sender {
    
    [UIUtils closeActivityView];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)receiveEventNotify
{
    NSLog(@"receive event notify");
}

@end
