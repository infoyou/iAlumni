//
//  LoginViewController.h
//  iAlumni
//
//  Created by Adam on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWRootViewController.h"
#import "EncryptUtil.h"
#import "MessageUI/MessageUI.h"
#import "Alumni.h"

@class ECGradientButton;

@interface LoginViewController : WXWRootViewController <UIAlertViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIWebViewDelegate, MFMessageComposeViewControllerDelegate>
{
  Alumni *_alumni;
  
  UIView *_editBGView;
  
  UITextField *_name;
  UITextField *_pswd;
  
  BOOL _hostFetched;
  
  BOOL isBreakFlag;
  
  ECGradientButton *_loginBut;
  
  ECGradientButton *_forgotPwdButton;
  
  ECGradientButton *_followWechatButton;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;
- (void)entryAlumnus;

- (void)addCloseBtn;

@end
