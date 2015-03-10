//
//  UpdateUserInfoViewController.m
//  iAlumni
//
//  Created by Adam on 12-7-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UpdateUserInfoViewController.h"
#import "WXWLabel.h"
#import "AppManager.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "CommonUtils.h"

#define FONT_SIZE           20.0f
#define CELL_SIZE           3

#define LABEL_X             20.0f
#define CONTENT_X           80.0f
#define NOTE_Y              10.0f
#define EMAIL_Y             70.0f
#define MOBILE_Y            110.0f
#define WEIBO_Y             150.0f
#define LABEL_H             30.0f

typedef enum {
    EMAIL_TAG,
    MOBILE_TAG,
    WEIBO_TAG,
} UPDATE_USERINFO_VIEW_TAG;

@interface UpdateUserInfoViewController ()

@end

@implementation UpdateUserInfoViewController
@synthesize _TableCellShowValArray;
@synthesize _TableCellSaveValArray;
@synthesize _emailField;
@synthesize _mobileField;
@synthesize _weiboField;
@synthesize email;
@synthesize mobile;
@synthesize userId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _TableCellShowValArray = [[NSMutableArray alloc] init];
        _TableCellSaveValArray = [[NSMutableArray alloc] init];
        for (NSUInteger i=0; i<CELL_SIZE; i++) {
            [_TableCellShowValArray addObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]];
            [_TableCellSaveValArray addObject:[NSString stringWithFormat:@"%@",NULL_PARAM_VALUE]];
        }
    }
    return self;
}

- (void)dealloc
{
    RELEASE_OBJ(_emailField);
    RELEASE_OBJ(_mobileField);
    RELEASE_OBJ(_weiboField);
    self.userId = nil;
    
    [super dealloc];
}

#pragma mark - view life cycle
- (void)initView
{
    
    UIView *bgView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 45)] autorelease];
    bgView.backgroundColor = TRANSPARENT_COLOR;
    
    // Note
  UILabel *noteLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    noteLabel.text = LocaleStringForKey(NSUpdateUserInfoNote, nil);
      noteLabel.font = BOLD_FONT(FONT_SIZE);
  CGSize size = [noteLabel.text sizeWithFont:noteLabel.font
                           constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
      CGRect noteFrame = CGRectMake(LABEL_X, NOTE_Y, SCREEN_WIDTH, size.height);
  noteLabel.frame = noteFrame;
    noteLabel.textColor = NAVIGATION_BAR_COLOR;
    noteLabel.numberOfLines = 2;
    [bgView addSubview:noteLabel];
  
  CGFloat y = 0;
  if ([AppManager instance].adminCheckinTableInfo.length > 0) {
    WXWLabel *tableLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(LABEL_X,
                                                                     noteLabel.frame.origin.y + noteLabel.frame.size.height,
                                                                     200,
                                                                     LABEL_H + 20.0f)
                                                textColor:DARK_TEXT_COLOR
                                              shadowColor:[UIColor whiteColor]] autorelease];
    tableLabel.font = BOLD_FONT(FONT_SIZE);
    tableLabel.text = [NSString stringWithFormat:@"%@ %@", LocaleStringForKey(NSTableInfoTitle, nil),
                       [AppManager instance].adminCheckinTableInfo];
    [bgView addSubview:tableLabel];
    
    y = tableLabel.frame.origin.y + tableLabel.frame.size.height + MARGIN;
  } else {
    y = noteLabel.frame.origin.y + noteLabel.frame.size.height + MARGIN;
  }
  
    // Email
    CGRect emailFrame = CGRectMake(LABEL_X, y, SCREEN_WIDTH, LABEL_H);
    UILabel *emailLabel = [[[UILabel alloc] initWithFrame:emailFrame] autorelease];
    emailLabel.text = [NSString stringWithFormat:@"%@:",LocaleStringForKey(NSEmailTitle, nil)];
    emailLabel.textColor = DARK_TEXT_COLOR;
    emailLabel.font = BOLD_FONT(FONT_SIZE);
    [bgView addSubview:emailLabel];
    
    // Text Field
    CGRect emailTextFrame = CGRectMake(CONTENT_X, y + 5, SCREEN_WIDTH-100, LABEL_H);
    _emailField = [[UITextField alloc] initWithFrame:emailTextFrame];
    _emailField.tag = EMAIL_TAG;
    _emailField.returnKeyType = UIReturnKeyDone;
    
    _emailField.text = [AppManager instance].eventAlumniEmail;
    _emailField.delegate = self;
    _emailField.placeholder = LocaleStringForKey(NSEmailTitle, nil);
    _emailField.borderStyle = UITextBorderStyleNone;
    _emailField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _emailField.keyboardType = UIKeyboardTypeASCIICapable;
    [bgView addSubview:_emailField];
  
    // name line
    CGRect nameLineFrame = CGRectMake(LABEL_X, y+LABEL_H, SCREEN_WIDTH-2*LABEL_X, 1);
    UIView *nameLine = [[[UIView alloc] initWithFrame:nameLineFrame] autorelease];
    nameLine.backgroundColor = COLOR(209, 216, 228);
    [bgView addSubview:nameLine];
    
    // Mobile
  y = _emailField.frame.origin.y + _emailField.frame.size.height + MARGIN;
    CGRect mobileFrame = CGRectMake(LABEL_X, y, SCREEN_WIDTH, LABEL_H);
    UILabel *mobileLabel = [[[UILabel alloc] initWithFrame:mobileFrame] autorelease];
    mobileLabel.text = [NSString stringWithFormat:@"%@:",LocaleStringForKey(NSMobileTitle, nil)];
    mobileLabel.textColor = DARK_TEXT_COLOR;
    mobileLabel.font = BOLD_FONT(FONT_SIZE);
    [bgView addSubview:mobileLabel];
    
    // Mobile Field Text
    CGRect mobileTextFrame = CGRectMake(CONTENT_X, y+5, SCREEN_WIDTH-100, LABEL_H);
    _mobileField = [[UITextField alloc] initWithFrame:mobileTextFrame];
    _mobileField.tag = MOBILE_TAG;
    _mobileField.returnKeyType = UIReturnKeyDone;
    
    _mobileField.text = [AppManager instance].eventAlumniMobile;
    _mobileField.delegate = self;
    _mobileField.placeholder = LocaleStringForKey(NSMobileTitle, nil);
    _mobileField.borderStyle = UITextBorderStyleNone;
    _mobileField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _mobileField.keyboardType = UIKeyboardTypePhonePad;
    [bgView addSubview:_mobileField];
    
    CGRect classLineFrame = CGRectMake(LABEL_X, y+LABEL_H, SCREEN_WIDTH-2*LABEL_X, 1);
    UIView *classLine = [[[UIView alloc] initWithFrame:classLineFrame] autorelease];
    classLine.backgroundColor = COLOR(209, 216, 228);
    [bgView addSubview:classLine];
  
    // sina weibo
  y = _mobileField.frame.origin.y + _mobileField.frame.size.height + MARGIN;
    CGRect weiboFrame = CGRectMake(LABEL_X, y, SCREEN_WIDTH, LABEL_H);
    UILabel *weiboLabel = [[[UILabel alloc] initWithFrame:weiboFrame] autorelease];
    weiboLabel.text = [NSString stringWithFormat:@"%@:",LocaleStringForKey(NSSinaWeiboTitle, nil)];
    weiboLabel.textColor = DARK_TEXT_COLOR;
    weiboLabel.font = BOLD_FONT(FONT_SIZE);
    [bgView addSubview:weiboLabel];
    
    // Mobile Field Text
    CGRect weiboTextFrame = CGRectMake(CONTENT_X+30, y+5, SCREEN_WIDTH-120, LABEL_H);
    _weiboField = [[UITextField alloc] initWithFrame:weiboTextFrame];
    _weiboField.tag = WEIBO_TAG;
    _weiboField.returnKeyType = UIReturnKeyDone;
    
    _weiboField.text = [AppManager instance].eventAlumniWeibo;
    _weiboField.delegate = self;
    _weiboField.placeholder = LocaleStringForKey(NSSinaWeiboTitle, nil);
    _weiboField.borderStyle = UITextBorderStyleNone;
    _weiboField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _weiboField.keyboardType = UIKeyboardTypeEmailAddress;
    [bgView addSubview:_weiboField];
    
    CGRect weiboLineFrame = CGRectMake(LABEL_X, y+LABEL_H, SCREEN_WIDTH-2*LABEL_X, 1);
    UIView *weiboLine = [[[UIView alloc] initWithFrame:weiboLineFrame] autorelease];
    weiboLine.backgroundColor = COLOR(209, 216, 228);
    [bgView addSubview:weiboLine];
    
    [self.view addSubview:bgView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = LocaleStringForKey(NSUpdateUserInfoTitle, nil);
    
	// Do any additional setup after loading the view.
    [self initView];
  
  [self addLeftBarButtonWithTitle:LocaleStringForKey(NSBackTitle, nil)
                           target:self
                           action:@selector(doBack:)];

  [self addRightBarButtonWithTitle:LocaleStringForKey(NSDoneTitle, nil)
                            target:self
                            action:@selector(doModify:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - action
- (void)doBack:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)doModify:(id)sender {
    [_emailField resignFirstResponder];
    [_mobileField resignFirstResponder];
    [_weiboField resignFirstResponder];
    
    _currentType = EVENT_CHECK_IN_UPDATE_TY;
    
    NSString *param = [NSString stringWithFormat:@"<target_user_id>%@</target_user_id><update_mobile>%@</update_mobile><update_email>%@</update_email><update_sina_username>%@</update_sina_username><is_from_admin>%d</is_from_admin>",
                       self.userId,
                       _mobileField.text,
                       _emailField.text,
                       _weiboField.text,
                       [AppManager instance].isAdminCheckIn == NO ? 0 : 1];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self 
                                                                    interactionContentType:_currentType] autorelease];
    // [self.connDic setObject:connFacade forKey:url];
    [connFacade fetchGets:url];
}

#pragma mark - animate
- (void)upAnimate
{
    CGFloat heightFraction = 0.25f;
    
    _animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    NSLog(@"heightFraction: %f", heightFraction);
	CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)downAnimate
{
    CGRect viewFrame = self.view.frame;
	
    viewFrame.origin.y += _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{	
    if(textField.tag == WEIBO_TAG)
        [self upAnimate];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.tag == WEIBO_TAG)
        [self downAnimate];
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
    [UIUtils showActivityView:_tableView text:LocaleStringForKey(NSLoadingTitle, nil)];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType{
    [UIUtils closeActivityView];
    
    switch (contentType) {
            
        case EVENT_CHECK_IN_UPDATE_TY:
        {
            if (result == nil || [result length] == 0) {
              [UIUtils showNotificationOnTopWithMsg:@"result is Null"
                                            msgType:ERROR_TY
                                 belowNavigationBar:YES];

                return;
            }
            
            ReturnCode ret = [XMLParser handleCommonResult:result showFlag:YES];
            if (ret == RESP_OK) {
                
                if ([self.userId isEqualToString:[AppManager instance].personId]) {
                    [self doBack:self];
                    return;
                }
                
                if ([NULL_PARAM_VALUE isEqualToString:_mobileField.text] || _mobileField.text.length < 1) {
                    [self doBack:self];
                } else {
                    ShowAlertWithTwoButton(self, LocaleStringForKey(NSNoteTitle, nil), LocaleStringForKey(NSAdminCheckSmsTitle, nil), LocaleStringForKey(NSCancelTitle, nil), LocaleStringForKey(NSSureTitle, nil));
                }
            }
        }
            break;
            
        case EVENT_ADMIN_CHECK_SMS_TY:
        {
            if (result == nil || [result length] == 0) {
              [UIUtils showNotificationOnTopWithMsg:@"result is Null"
                                            msgType:ERROR_TY
                                 belowNavigationBar:YES];
                return;
            }
            
            ReturnCode ret = [XMLParser handleCommonResult:result showFlag:YES];
            if (ret == RESP_OK) {
                [self doBack:self];
            }
        }
            break;
            
        default:
            break;
    }    
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
    [UIUtils closeActivityView];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url 
          contentType:(NSInteger)contentType {
    [UIUtils closeActivityView];
  
  [super connectFailed:error url:url contentType:contentType];
}

- (void)doAdminCheckSms
{
    
    NSString *param = nil;
    _currentType = EVENT_ADMIN_CHECK_SMS_TY;
    param = [NSString stringWithFormat:@"<sms_mobile>%@</sms_mobile>", _mobileField.text];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self 
                                                                    interactionContentType:_currentType] autorelease];
    // [self.connDic setObject:connFacade forKey:url];
    [connFacade fetchGets:url];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [self doAdminCheckSms];
        return;
    } else {
        [self doBack:self];
    }
}

@end
