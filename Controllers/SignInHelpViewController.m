//
//  SignInHelpViewController.m
//  iAlumni
//
//  Created by Adam on 13-5-20.
//
//

#import "SignInHelpViewController.h"
#import "UIImageButton.h"
#import "WXWLabel.h"
#import "iAlumniAppDelegate.h"
#import "LoginHelpViewController.h"
#import "AppManager.h"

#define BTN_WIDTH   200.0f
#define BTN_HEIGHT  40.0f

@interface SignInHelpViewController ()

@end

@implementation SignInHelpViewController

#pragma mark - user action
- (void)resignIn:(id)sender {
  [(iAlumniAppDelegate *)APP_DELEGATE singleLogin];
}

- (void)getPassword:(id)sender {
  LoginHelpViewController *helpVC = [[[LoginHelpViewController alloc] init] autorelease];
  helpVC.strTitle = LocaleStringForKey(NSLoginHelpTitle, nil);
  helpVC.strUrl = [NSString stringWithFormat:@"%@%@?locale=%@",[AppManager instance].hostUrl, LOGIN_HELP_URL, [WXWSystemInfoManager instance].currentLanguageDesc];
  [self presentModalViewController:helpVC animated:YES];
}


#pragma mark - lifecycle methods
- (id)init {
  self = [super init];
  if (self) {
    
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:DARK_TEXT_COLOR
                                         shadowColor:TEXT_SHADOW_COLOR
                                                font:BOLD_FONT(18)] autorelease];
  label.text = LocaleStringForKey(NSSsoFailedMsg, nil);
  label.numberOfLines = 0;
  label.textAlignment = UITextAlignmentCenter;
  CGSize size = [label.text sizeWithFont:label.font
                       constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 8, CGFLOAT_MAX)];
  label.frame = CGRectMake((self.view.frame.size.width - size.width)/2.0f, MARGIN * 8, size.width, size.height);
  [self.view addSubview:label];
  
  UIImageButton *resignInButton = [[[UIImageButton alloc]
                                    initImageButtonWithFrame:CGRectMake((self.view.frame.size.width - BTN_WIDTH)/2.0f,
                                                                        label.frame.origin.y + label.frame.size.height + MARGIN * 2,
                                                                        BTN_WIDTH,
                                                                        BTN_HEIGHT)
                                    target:self
                                    action:@selector(resignIn:)
                                    title:LocaleStringForKey(NSReSignInTitle, nil)
                                    image:nil
                                    backImgName:@"button_orange.png"
                                    selBackImgName:@"button_orange_selected.png"
                                    titleFont:BOLD_FONT(15)
                                    titleColor:[UIColor whiteColor]
                                    titleShadowColor:TRANSPARENT_COLOR
                                    roundedType:HAS_ROUNDED
                                    imageEdgeInsert:ZERO_EDGE
                                    titleEdgeInsert:ZERO_EDGE] autorelease];
  [self.view addSubview:resignInButton];
  
  UIImageButton *forgetPwdButton = [[[UIImageButton alloc]
                                     initImageButtonWithFrame:CGRectMake((self.view.frame.size.width - BTN_WIDTH)/2.0f,
                                                                         resignInButton.frame.origin.y + resignInButton.frame.size.height + MARGIN * 2,
                                                                         BTN_WIDTH,
                                                                         BTN_HEIGHT)
                                     target:self
                                     action:@selector(getPassword:)
                                     title:LocaleStringForKey(NSLoginPSWDTitle, nil)
                                     image:nil
                                     backImgName:@"button_orange.png"
                                     selBackImgName:@"button_orange_selected.png"
                                     titleFont:BOLD_FONT(15)
                                     titleColor:[UIColor whiteColor]
                                     titleShadowColor:TRANSPARENT_COLOR
                                     roundedType:HAS_ROUNDED
                                     imageEdgeInsert:ZERO_EDGE
                                     titleEdgeInsert:ZERO_EDGE] autorelease];
  [self.view addSubview:forgetPwdButton];
  
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
