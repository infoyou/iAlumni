//
//  LoginViewController.m
//  iAlumni
//
//  Created by Adam on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginHelpViewController.h"
#import "ECAsyncConnectorFacade.h"
#import "ECGradientButton.h"
#import "WXWDebugLogOutput.h"
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "WXApi.h"
#import "WechatIntroViewController.h"
#import "WXWNavigationController.h"

#define FONT_SIZE       15
#define TEXT_X          10.0f
#define OFFSET_Y        120.0f
#define EDITBGVIEW_Y    20.0f
#define LOGIN_BTN_Y     115.f
#define LOGIN_BTN_H     35.0f

typedef enum {
    
    UPDATE_SOFT_TYPE = 0,
    LOGIN_HELP_TYPE,
    NO_WECHAT_TYPE,
    
} LOGIN_ALERT_TYPE;

@interface LoginViewController()

@end

@implementation LoginViewController

- (void)getHostUrl {
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:GET_HOST_URL contentType:GET_HOST_TY];
    [connFacade fetchGets:GET_HOST_URL];
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
    self = [super init];
    
    if (self) {
        _MOC = MOC;
        
        _noNeedBackButton = YES;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark - logic method
- (void)checkSoftVersion {
    NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:CHECK_VERSION_TY];
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:CHECK_VERSION_TY] autorelease];
    [connFacade fetchGets:url];
}

#pragma mark - View lifecycle

- (void)viewDidDisappear:(BOOL)animated {
    if (_name.isFirstResponder) {
        [_name resignFirstResponder];
    }
    
    if (_pswd.isFirstResponder) {
        [_pswd resignFirstResponder];
    }
}

- (void)addLogo {
    self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:IMAGE_WITH_NAME(@"login_top.png")] autorelease];
}

- (void)addCloseBtn
{

    [self addRightBarButtonWithTitle:LocaleStringForKey(NSCloseTitle, nil)
                              target:self
                              action:@selector(close:)];
}

- (void)close:(id)sender
{
    [AppManager instance].prepareForLogin = NO;
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[AppManager instance] getHostUrl];
    
    [self addLogo];
    
    CGRect mFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    UIView *backView = [[[UIView alloc] initWithFrame:mFrame] autorelease];
    
    // Edit view
    _editBGView = [[[UIView alloc] initWithFrame:CGRectMake(15.0f, EDITBGVIEW_Y, SCREEN_WIDTH-30.0f, 80.0f)]autorelease];
    [_editBGView setBackgroundColor:[UIColor whiteColor]];
    _editBGView.layer.cornerRadius = 6.0f;
    _editBGView.layer.masksToBounds = YES;
    _editBGView.layer.borderWidth = 1.0f;
    _editBGView.layer.borderColor = COLOR(202, 202, 202).CGColor;
    
    // User Name
    CGRect mName = CGRectMake(TEXT_X, 9.f, 170.f, 30.0f);
    _name = [[[UITextField alloc] initWithFrame:mName] autorelease];
    //    _name.returnKeyType = UIReturnKeyDone;
    _name.borderStyle = UITextBorderStyleNone;
    _name.autocorrectionType = UITextAutocorrectionTypeNo;
    _name.keyboardType = UIKeyboardTypeASCIICapable;
    _name.delegate = self;
    
    _name.text = [[AppManager instance] getUserIdFromLocal];
    _name.placeholder = LocaleStringForKey(NSUserPlaceholder, nil);
    _name.font = FONT(FONT_SIZE+2);
    _name.layer.cornerRadius = 6.0f;
    _name.layer.masksToBounds = YES;
    //    _name.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_editBGView addSubview:_name];
    
    // @CEIBS.EDU
    UIView *ceibsView = [[[UIView alloc] initWithFrame:CGRectMake(181.0f, 1, SCREEN_WIDTH-15.0f-181.0f, 39.f)] autorelease];
    [ceibsView setBackgroundColor:COLOR(234, 234, 234)];
    ceibsView.clipsToBounds = YES;
    UILabel *ceibsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 110, 30.f)] autorelease];
    [ceibsLabel setText:@"@CEIBS.EDU"];
    [ceibsLabel setFont:FONT(FONT_SIZE)];
    [ceibsLabel setTextColor:COLOR(154, 154, 154)];
    [ceibsLabel setBackgroundColor:TRANSPARENT_COLOR];
    [ceibsView addSubview:ceibsLabel];
    [_editBGView addSubview:ceibsView];
    
    // Line
    CGRect lineFrame = CGRectMake(0.0f, 40.0f, SCREEN_WIDTH-30.0f, 1);
    UIView *lineView = [[[UIView alloc] initWithFrame:lineFrame] autorelease];
    lineView.backgroundColor = COLOR(193, 193, 193);
    [_editBGView addSubview:lineView];
    
    // User Password
    CGRect mPswd = CGRectMake(TEXT_X, 50.0f, 170.f, 30.0f);
    _pswd = [[[UITextField alloc] initWithFrame:mPswd] autorelease];
    _pswd.delegate = self;
    //    _pswd.returnKeyType = UIReturnKeyDone;
    _pswd.borderStyle = UITextBorderStyleNone;
    _pswd.autocorrectionType = UITextAutocorrectionTypeNo;
    
    _pswd.text = [[AppManager instance] getPasswordFromLocal];
    _pswd.placeholder = LocaleStringForKey(NSPswdPlaceholder, nil);
    _pswd.font = FONT(FONT_SIZE+2);
    _pswd.layer.cornerRadius = 6.0f;
    _pswd.layer.masksToBounds = YES;
    _pswd.secureTextEntry = YES;
    //    _pswd.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_editBGView addSubview:_pswd];
    
    [backView addSubview:_editBGView];
    
    // Login Button
    _loginBut = [[[ECGradientButton alloc] initWithFrame:CGRectMake(15.0f, LOGIN_BTN_Y, 175.f, LOGIN_BTN_H)
                                                  target:self
                                                  action:@selector(doLogin:)
                                               colorType:RED_BTN_COLOR_TY
                                                   title:LocaleStringForKey(NSLoginTitle, nil)
                                                   image:nil
                                              titleColor:BLUE_BTN_TITLE_COLOR
                                        titleShadowColor:TRANSPARENT_COLOR
                                               titleFont:BOLD_FONT(FONT_SIZE+1)
                                             roundedType:HAS_ROUNDED
                                         imageEdgeInsert:ZERO_EDGE
                                         titleEdgeInsert:ZERO_EDGE] autorelease];
    [backView addSubview:_loginBut];
    
    // Forget Password
    _forgotPwdButton = [[[ECGradientButton alloc] initWithFrame:CGRectMake(200.0f, LOGIN_BTN_Y, 105.f, LOGIN_BTN_H)
                                                         target:self
                                                         action:@selector(doLoginHelp:)
                                                      colorType:BLUE_BTN_COLOR_TY
                                                          title:LocaleStringForKey(NSLoginPSWDTitle, nil)
                                                          image:nil
                                                     titleColor:[UIColor whiteColor]
                                               titleShadowColor:TRANSPARENT_COLOR
                                                      titleFont:BOLD_FONT(FONT_SIZE+1)
                                                    roundedType:HAS_ROUNDED
                                                imageEdgeInsert:ZERO_EDGE
                                                titleEdgeInsert:ZERO_EDGE] autorelease];
    [backView addSubview:_forgotPwdButton];
    
    // follow wechat
    _followWechatButton = [[[ECGradientButton alloc] initWithFrame:CGRectMake(15.0f, LOGIN_BTN_Y+45, SCREEN_WIDTH-30.0f, LOGIN_BTN_H)
                                                            target:self
                                                            action:@selector(followWechat:)
                                                         colorType:TINY_GRAY_BTN_COLOR_TY
                                                             title:LocaleStringForKey(NSFollowUsOnWechatTitle, nil)
                                                             image:nil
                                                        titleColor:COLOR(117, 117, 117)
                                                  titleShadowColor:GRAY_BTN_TITLE_SHADOW_COLOR
                                                         titleFont:BOLD_FONT(FONT_SIZE+1)
                                                       roundedType:HAS_ROUNDED
                                                   imageEdgeInsert:ZERO_EDGE
                                                   titleEdgeInsert:ZERO_EDGE] autorelease];
    
    [backView addSubview:_followWechatButton];
    
    // Version
    WXWLabel *versionLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                    textColor:BASE_INFO_COLOR
                                                  shadowColor:TEXT_SHADOW_COLOR] autorelease];
    versionLabel.font = BOLD_FONT(11);
    versionLabel.text = [NSString stringWithFormat:@"Version %@",VERSION];
    versionLabel.textAlignment = UITextAlignmentCenter;
    CGSize size = [versionLabel.text sizeWithFont:versionLabel.font
                                constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat y = backView.frame.size.height - size.height - MARGIN * 4 - NAVIGATION_BAR_HEIGHT;
    if (CURRENT_OS_VERSION >= IOS7) {
        y = y - SYS_STATUS_BAR_HEIGHT;
    }
    versionLabel.frame = CGRectMake((self.view.frame.size.width - size.width)/2.0f,
                                    y, size.width, size.height);
    [backView addSubview:versionLabel];
    
    // Login Note
    WXWLabel *comeBackLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                     textColor:BASE_INFO_COLOR
                                                   shadowColor:TEXT_SHADOW_COLOR] autorelease];
    comeBackLabel.font = BOLD_FONT(15);
    comeBackLabel.text = LocaleStringForKey(NSLoginNote1Title, nil);
    comeBackLabel.textAlignment = UITextAlignmentCenter;
    size = [comeBackLabel.text sizeWithFont:comeBackLabel.font
                          constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
    comeBackLabel.frame = CGRectMake((self.view.frame.size.width - size.width)/2.0f,
                                     versionLabel.frame.origin.y - MARGIN * 2 - size.height, size.width, size.height);
    [backView addSubview:comeBackLabel];
    
    [self.view addSubview:backView];
    
    [self checkSoftVersion];
    
    
    if ([AppManager instance].prepareForLogin) {
        _name.text = @"";
        _pswd.text = @"";
        
        [self addCloseBtn];
    }
}


#pragma mark - logic method
- (void)entryAlumnus {
    
    NSString *param = [NSString stringWithFormat:@"username=%@&password=%@",
                       [_name.text lowercaseString],
                       [CommonUtils stringByURLEncodingStringParameter:_pswd.text]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@&%@&locale=%@&plat=%@&version=%@&device_token=%@&channel=%d",
                     [AppManager instance].hostUrl,
                     ALUMNI_LOGIN_REQ_URL,
                     param,
                     [WXWSystemInfoManager instance].currentLanguageDesc,
                     PLATFORM,
                     VERSION,
                     [AppManager instance].deviceToken,
                     [AppManager instance].releaseChannelType];
    
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:LOGIN_TY] autorelease];
    // [self.connDic setObject:connFacade forKey:url];
    [connFacade fetchGets:url];
}

// check value is available
- (BOOL)checkForLogin:(NSString *)userAccount
             password:(NSString *)password {
    
    if ([userAccount isEqualToString:NULL_PARAM_VALUE] || 0 == [userAccount length]) {
        debugLog(@"userAccount is nil");
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSUserInfoNeeded, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
        [UIUtils closeActivityView];
        return NO;
    }
    
    if ([password isEqualToString:NULL_PARAM_VALUE] || 0 == [password length]) {
        debugLog(@"Password is nil");
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPswdInfoNeeded, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
        [UIUtils closeActivityView];
        return NO;
    }
    
    return YES;
}

- (void)loginLogic
{
    if (![AppManager instance].hostUrl || [[AppManager instance].hostUrl isEqualToString:NULL_PARAM_VALUE]) {
        //[self getHostUrl];
        
        [[AppManager instance] getHostUrl];
        
        isBreakFlag = YES;
        return;
    }
    
    if (_name.isFirstResponder) {
        [_name resignFirstResponder];
    }
    
    if (_pswd.isFirstResponder) {
        [_pswd resignFirstResponder];
    }
    
    if (![self checkForLogin:[_name.text lowercaseString] password:_pswd.text]) {
        return;
    }
    
    [self entryAlumnus];
}

#pragma mark - action
- (void)doLogin:(id)sender
{
    [self loginLogic];
}

- (void)doLoginHelp:(id)sender
{
    
    LoginHelpViewController *helpVC = [[[LoginHelpViewController alloc] init] autorelease];
    helpVC.strTitle = LocaleStringForKey(NSResetPSWDTitle, nil);
    helpVC.strUrl = [NSString stringWithFormat:@"%@%@?locale=%@",[AppManager instance].hostUrl, LOGIN_HELP_URL, [WXWSystemInfoManager instance].currentLanguageDesc];
    
    WXWNavigationController *nav = [[[WXWNavigationController alloc] initWithRootViewController:helpVC] autorelease];
    [self.navigationController presentModalViewController:nav animated:YES];
    
}

- (void)followWechat:(id)sender {
    
    WechatIntroViewController *wechatIntroVC = [[[WechatIntroViewController alloc] init] autorelease];
    wechatIntroVC.title = LocaleStringForKey(NSFollowWechatPublicNoTitle, nil);
    [self.navigationController pushViewController:wechatIntroVC animated:YES];
    
}

#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
    if (contentType != GET_HOST_TY) {
        [UIUtils showActivityView:self.view
                             text:LocaleStringForKey(NSLoadingTitle, nil)];
    }
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType
{
    [UIUtils closeActivityView];
    
    switch (contentType) {

        case CHECK_VERSION_TY:
        {
            ReturnCode ret = [XMLParser handleSoftMsg:result MOC:_MOC];
            
            switch (ret) {
                case RESP_OK:
                {
                    if (isBreakFlag) {
                        [self loginLogic];
                        isBreakFlag = NO;
                    }
                    
                    [_name becomeFirstResponder];
                }
                    break;
                    
                case SOFT_UPDATE_CODE:
                {
                    _alertType = UPDATE_SOFT_TYPE;
                    ShowAlertWithOneButton(self, LocaleStringForKey(NSNoteTitle, nil),[AppManager instance].softDesc, LocaleStringForKey(NSSureTitle, nil));
                    break;
                }
                    
                case ERR_CODE:
                {
                    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSNetworkUnstableMsg, nil)
                                                  msgType:ERROR_TY
                                       belowNavigationBar:YES];
                    
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        case LOGIN_TY:
        {
            NSData *decryptedData = [EncryptUtil TripleDESforNSData:result encryptOrDecrypt:kCCDecrypt];
            if ([XMLParser parserSyncResponseXml:decryptedData type:LOGIN_SRC MOC:_MOC]) {
                [AppManager instance].passwd = _pswd.text;
                [[AppManager instance] saveUserInfoIntoLocal];
                
                if ([AppManager instance].prepareForLogin) {
                    [AppManager instance].isLogin = YES;
                    [self close:nil];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"loginEd"];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];

                } else {
                    [self.view removeFromSuperview];
                    [((iAlumniAppDelegate*)APP_DELEGATE) goHomePage];
                }
            } else {
                _alertType = LOGIN_HELP_TYPE;
                
                ShowAlertWithTwoButton(self,LocaleStringForKey(NSNoteTitle, nil),[AppManager instance].errDesc, LocaleStringForKey(NSTryAgainTitle, nil),LocaleStringForKey(NSResetPSWDTitle, nil));
            }
            
            break;
        }
            
        default:
            break;
    }
    
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType
{
    [UIUtils closeActivityView];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
    /*
     switch (contentType) {
     case GET_HOST_TY:
     {
     [AppManager instance].hostUrl = [CommonUtils fetchStringValueFromLocal:HOST_LOCAL_KEY];
     _hostFetched = YES;
     break;
     }
     
     default:
     break;
     }
     */
    [UIUtils closeActivityView];
}

#pragma mark - UIWebViewDelegate method
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
        controller.body = [AppManager instance].recommend;
        controller.recipients = @[NULL_PARAM_VALUE];
        controller.messageComposeDelegate = self;
        [self.navigationController presentModalViewController:controller animated:YES];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{}
- (void)webViewDidFinishLoad:(UIWebView *)webView{}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{}

#pragma mark - MFMessageComposeViewControllerDelegate method
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSString *backMsg;
    
    switch (result) {
        case MessageComposeResultSent:
            backMsg = @"Success";
            break;
        case MessageComposeResultCancelled:
            backMsg = @"Cancelled";
            break;
        case MessageComposeResultFailed:
            backMsg = @"Failure";
            break;
        default:
            break;
    }
    
    NSLog(@"back %@", backMsg);
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (_alertType) {
        case UPDATE_SOFT_TYPE:
        {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager instance].softUrl]];
            
            break;
        }      
            
        case LOGIN_HELP_TYPE:
        {
            if (buttonIndex == 1) {
                LoginHelpViewController *helpVC = [[[LoginHelpViewController alloc] init] autorelease];
                helpVC.strTitle = LocaleStringForKey(NSResetPSWDTitle, nil);
                helpVC.strUrl = [NSString stringWithFormat:@"%@%@",[AppManager instance].hostUrl,[AppManager instance].loginHelpUrl];
                
                WXWNavigationController *nav = [[[WXWNavigationController alloc] initWithRootViewController:helpVC] autorelease];
                [self.navigationController presentModalViewController:nav animated:NO];
            }
            break;
        }
            
        case NO_WECHAT_TYPE:
        {
            switch (buttonIndex) {
                case 1:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WECHAT_ITUNES_URL]];
                    break;
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
    
}

@end