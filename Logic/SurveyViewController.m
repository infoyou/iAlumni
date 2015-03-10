//
//  SurveyViewController.m
//  iAlumni
//
//  Created by Adam on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SurveyViewController.h"
#import "UIUtils.h"

@interface SurveyViewController ()

@end

@implementation SurveyViewController
@synthesize strUrl;
@synthesize strTitle;

- (id)init
{
    self = [super initWithMOC:nil holder:nil backToHomeAction:nil needGoHome:NO];
    if (self) {
        // Custom initialization
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!self.title){
        self.title = strTitle;
    }
    
    CGRect webFrame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT - 22);
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

@end
