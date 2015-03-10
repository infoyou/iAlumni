//
//  ClubHeadView.m
//  iAlumni
//
//  Created by Adam on 12-8-16.
//
//

#import "ClubHeadView.h"
#import "UserListViewController.h"
#import "ClubSimple.h"
#import "UIImageButton.h"
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "Club.h"

static int HEADER_VIEW_H = 155.f;

#define FONT_SIZE                       13.0f
#define TOP_VIEW_Y                      2*MARGIN
#define TOP_VIEW_H                      60.f
#define BUTTON_W                        70.0f
#define BUTTON_H                        28.0f
#define CLUB_MEMBER_ACTIVITY_BUTTON_W   140.f
#define EVENT_VIEW_H                    72.f
#define DARK_BTN_TITLE_COLOR            COLOR(66, 66, 66)


@interface ClubHeadView ()
@property (nonatomic, retain) ClubSimple *clubSimple;
@property (nonatomic, retain) UIView  *headerView;
@property (nonatomic, retain) NSMutableArray *barButtons;
@end

@implementation ClubHeadView
@synthesize joinStatus;
@synthesize clubSimple = _clubSimple;
@synthesize headerView = _headerView;

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext*)MOC
   clubHeadDelegate:(id<ClubManagementDelegate>) clubHeadDelegate
{
  self = [super initWithFrame:frame];
  
  if (self) {
    _delegate = clubHeadDelegate;
    _MOC = MOC;
    
    _frame = frame;
    joinStatus = NO;
    
    HEADER_VIEW_H = _frame.size.height - 1;
    
    [self loadData];
    
    // topSeparator
    UIView *topSeparator = [[[UIView alloc] initWithFrame:CGRectMake(0, HEADER_VIEW_H, SCREEN_WIDTH, 0.8f)] autorelease];
    topSeparator.backgroundColor = CELL_TOP_COLOR;
    [self addSubview:topSeparator];
    
    // bottomSeparator
    UIView *bottomSeparator = [[[UIView alloc] initWithFrame:CGRectMake(0, HEADER_VIEW_H-0.8f, SCREEN_WIDTH, 0.8f)] autorelease];
    bottomSeparator.backgroundColor = CELL_BOTTOM_COLOR;
    [self addSubview:bottomSeparator];
  }
  return self;
}

- (void)dealloc {
  self.clubSimple = nil;
  self.headerView = nil;
  
  self.barButtons = nil;
  
  [super dealloc];
}

- (void)updateStatusAfterPaymentDone {
  
  self.clubSimple.userPaid = @(YES);
  self.clubSimple.userPayDate = [CommonUtils simpleFormatDateWithYear:[NSDate date] secondAccuracy:NO];
  SAVE_MOC(_MOC);

  WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:DARK_BTN_TITLE_COLOR
                                         shadowColor:TEXT_SHADOW_COLOR
                                                font:BOLD_FONT(FONT_SIZE)] autorelease];
  label.text = STR_FORMAT(LocaleStringForKey(NSPaidDateMsg, nil), self.clubSimple.userPayDate);
  CGSize size = [label.text sizeWithFont:label.font];
  label.frame = CGRectMake(0, 0, size.width, size.height);
  UIBarButtonItem *payBarButton = [[[UIBarButtonItem alloc] initWithCustomView:label] autorelease];
  if (self.barButtons) {
    [self.barButtons replaceObjectAtIndex:0 withObject:payBarButton];
    
    [_postToolbar setItems:self.barButtons];
  }
}

- (void)arrangeJointAndQuiteButton {
  CGRect activityFrame = CGRectMake(SCREEN_WIDTH/2+MARGIN*2, MARGIN, CLUB_MEMBER_ACTIVITY_BUTTON_W, BUTTON_H);
  
  NSString *title = nil;
  NSString *buttonImageName = nil;
  NSString *buttonSelectedImageName = nil;
  UIColor *titleColor = nil;
  if ([@"1" isEqualToString:self.clubSimple.ifmember]) {
    title = LocaleStringForKey(NSQuitButTitle, nil);
    joinStatus = YES;
    
    buttonImageName = @"club_button.png";
    buttonSelectedImageName = @"club_button_selected.png";
    titleColor = DARK_BTN_TITLE_COLOR;
  }else {
    joinStatus = NO;
    title = LocaleStringForKey(NSJoinButTitle, nil);
    buttonImageName = @"button_orange.png";
    buttonSelectedImageName = @"button_orange_selected.png";
    titleColor = [UIColor whiteColor];
  }
  
  _joinAndQuitBut = [[[UIImageButton alloc]
                      initImageButtonWithFrame:activityFrame
                      target:self
                      action:@selector(doJoin2Quit:)
                      title:title
                      image:nil
                      backImgName:buttonImageName
                      selBackImgName:buttonSelectedImageName
                      titleFont:BOLD_FONT(FONT_SIZE)
                      titleColor:titleColor
                      titleShadowColor:TRANSPARENT_COLOR
                      roundedType:HAS_ROUNDED
                      imageEdgeInsert:ZERO_EDGE
                      titleEdgeInsert:ZERO_EDGE] autorelease];
  
  [_member2ActivityView addSubview:_joinAndQuitBut];

}

- (void)loadData {
  [NSFetchedResultsController deleteCacheWithName:nil];
  
  NSArray *clubSimpleArray = [CommonUtils objectsInMOC:_MOC
                                            entityName:@"ClubSimple"
                                          sortDescKeys:nil
                                             predicate:nil];
  
  if ([clubSimpleArray count]) {
    self.clubSimple = (ClubSimple*)[clubSimpleArray lastObject];
    
    [self addSubview:self.headerView];
    
    if ([@"1" isEqualToString:self.clubSimple.ifadmin]) {
      [AppManager instance].clubAdmin = YES;
    } else {
      [AppManager instance].clubAdmin = NO;
    }
    
    [self arrangeJointAndQuiteButton];
    
    [_memberBut setTitle:[NSString stringWithFormat: @" %@: %@", LocaleStringForKey(NSClubLabelTitle, nil), self.clubSimple.membercount]
                forState:UIControlStateNormal];
  }
}

#pragma mark - init view
/*
- (void)addJoinButton
{
  
  NSString *strJoin2Quit = LocaleStringForKey(NSJoinButTitle, nil);
  
  NSString *buttonImageName = NULL_PARAM_VALUE;
  NSString *buttonSelectedImageName = NULL_PARAM_VALUE;
  UIColor *titleColor = nil;
  if ([@"1" isEqualToString:self.clubSimple.ifmember]) {
    strJoin2Quit = LocaleStringForKey(NSQuitButTitle, nil);
    joinStatus = YES;
    
    buttonImageName = @"club_button.png";
    buttonSelectedImageName = @"club_button_selected.png";
    titleColor = DARK_BTN_TITLE_COLOR;
  }else {
    joinStatus = NO;
    buttonImageName = @"button_orange.png";
    buttonSelectedImageName = @"button_orange_selected.png";
    titleColor = [UIColor whiteColor];
  }
  
  CGRect join2QuitFrame = CGRectMake(240.f, MARGIN*4, 60.f, BUTTON_H);
  
  UIImageButton *joinBut = [[[UIImageButton alloc]
                             initImageButtonWithFrame:join2QuitFrame
                             target:self
                             action:@selector(doJoin2Quit:)
                             title:strJoin2Quit
                             image:nil
                             backImgName:buttonImageName
                             selBackImgName:buttonSelectedImageName
                             titleFont:BOLD_FONT(FONT_SIZE)
                             titleColor:titleColor
                             titleShadowColor:TRANSPARENT_COLOR
                             roundedType:HAS_ROUNDED
                             imageEdgeInsert:ZERO_EDGE
                             titleEdgeInsert:ZERO_EDGE] autorelease];
  [self.headerView addSubview:joinBut];
}

- (void)addManageBut
{
  // Manage
  CGRect manageFrame = CGRectMake(240.f, MARGIN*4, 60.f, BUTTON_H);
  
  UIImageButton *manageBut = [[[UIImageButton alloc]
                               initImageButtonWithFrame:manageFrame
                               target:self
                               action:@selector(doManage:)
                               title:LocaleStringForKey(NSClubManageTitle,nil)
                               image:nil
                               backImgName:@"button_orange.png"
                               selBackImgName:@"button_orange_selected.png"
                               titleFont:BOLD_FONT(FONT_SIZE)
                               titleColor:[UIColor whiteColor]
                               titleShadowColor:TRANSPARENT_COLOR
                               roundedType:HAS_ROUNDED
                               imageEdgeInsert:ZERO_EDGE
                               titleEdgeInsert:ZERO_EDGE] autorelease];
  
  [self.headerView addSubview:manageBut];
}
*/

- (UIView *)headerView
{
  if (_headerView == nil) {

    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, SCREEN_WIDTH, HEADER_VIEW_H)];
    _headerView.backgroundColor = LIGHT_CELL_COLOR;
    
    CGRect topFrame = CGRectMake(2*MARGIN, TOP_VIEW_Y, SCREEN_WIDTH - 4*MARGIN, TOP_VIEW_H);
    UIImageView *_topBgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"club_detail_bg.png"]] autorelease];
    _topBgView.frame = topFrame;
    [_headerView addSubview:_topBgView];
    
    topView = [[UIView alloc] initWithFrame:topFrame];
    topView.backgroundColor = TRANSPARENT_COLOR;
    UIGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(doManage:)] autorelease];
    [topView addGestureRecognizer:tapGesture];
    
    UIImageView *arrowIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_arrow.png"]] autorelease];
    arrowIcon.backgroundColor = TRANSPARENT_COLOR;
    arrowIcon.frame = CGRectMake(topView.frame.size.width - MARGIN - TABLE_ACCESSOR_ARROW_WIDTH,
                                 (topView.frame.size.height - TABLE_ACCESSOR_ARROW_HEIGHT)/2.0f,
                                 TABLE_ACCESSOR_ARROW_WIDTH, TABLE_ACCESSOR_ARROW_HEIGHT);
    [topView addSubview:arrowIcon];
    
    WXWLabel *checkDetailLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                      textColor:BASE_INFO_COLOR
                                                    shadowColor:TRANSPARENT_COLOR] autorelease];
    checkDetailLabel.font = BOLD_FONT(12);
    checkDetailLabel.numberOfLines = 1;
    checkDetailLabel.text = LocaleStringForKey(NSCheckDetailTitle, nil);
    CGSize size = [checkDetailLabel.text sizeWithFont:checkDetailLabel.font
                                    constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                        lineBreakMode:NSLineBreakByWordWrapping];
    checkDetailLabel.frame = CGRectMake(arrowIcon.frame.origin.x - MARGIN - size.width,
                                        (topView.frame.size.height - size.height)/2.0f,
                                        size.width, size.height);
    [topView addSubview:checkDetailLabel];
    
    CGFloat nameLimitedWidth = checkDetailLabel.frame.origin.x - MARGIN * 2;
    UILabel *mNameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN, MARGIN*2,
                                                                     nameLimitedWidth,
                                                                     TOP_VIEW_H - MARGIN * 4)] autorelease];
    [mNameLabel setTextColor:[UIColor blackColor]];
    [mNameLabel setFont:BOLD_FONT(FONT_SIZE)];
    [mNameLabel setBackgroundColor:TRANSPARENT_COLOR];
    mNameLabel.text = self.clubSimple.name;
    size = [mNameLabel.text sizeWithFont:mNameLabel.font
                       constrainedToSize:CGSizeMake(nameLimitedWidth, mNameLabel.frame.size.height)
                           lineBreakMode:NSLineBreakByWordWrapping];
    mNameLabel.frame = CGRectMake(MARGIN, (topView.frame.size.height - size.height)/2.0f,
                                  size.width, size.height);
    [topView addSubview:mNameLabel];
    
    [_headerView addSubview:topView];
    
    // Button
    if ([@"1" isEqualToString:self.clubSimple.ifadmin]) {

      [AppManager instance].clubAdmin = YES;
    } else {
      [AppManager instance].clubAdmin = NO;
      
    }
    
    // member & activity
    _member2ActivityView = [[[UIView alloc] initWithFrame:CGRectMake(0, TOP_VIEW_Y+TOP_VIEW_H, SCREEN_WIDTH, BUTTON_H+20)] autorelease];
    [_member2ActivityView setBackgroundColor:TRANSPARENT_COLOR];
    
    {
      CGRect memberFrame = CGRectMake(MARGIN*2, MARGIN, CLUB_MEMBER_ACTIVITY_BUTTON_W, BUTTON_H);
      
      _memberBut = [[[UIImageButton alloc] initImageButtonWithFrame:memberFrame
                                                             target:self
                                                             action:@selector(goClubUserList:)
                                                              title:[NSString stringWithFormat: @" %@: %@", LocaleStringForKey(NSClubLabelTitle, nil), self.clubSimple.membercount]
                                                              image:[UIImage imageNamed:@"club_member.png"]
                                                        backImgName:@"club_button.png"
                                                     selBackImgName:@"club_button_selected.png"
                                                          titleFont:BOLD_FONT(FONT_SIZE)
                                                         titleColor:DARK_BTN_TITLE_COLOR
                                                   titleShadowColor:TRANSPARENT_COLOR
                                                        roundedType:HAS_ROUNDED
                                                    imageEdgeInsert:ZERO_EDGE
                                                    titleEdgeInsert:ZERO_EDGE] autorelease];
      [_member2ActivityView addSubview:_memberBut];
    }
    
    // Activity
    {
      CGRect activityFrame = CGRectMake(SCREEN_WIDTH/2+MARGIN*2, MARGIN, CLUB_MEMBER_ACTIVITY_BUTTON_W, BUTTON_H);
      
      NSString *title = nil;
      NSString *buttonImageName = nil;
      NSString *buttonSelectedImageName = nil;
      UIColor *titleColor = nil;
      if ([@"1" isEqualToString:self.clubSimple.ifmember]) {
        title = LocaleStringForKey(NSQuitButTitle, nil);
        joinStatus = YES;
        
        buttonImageName = @"club_button.png";
        buttonSelectedImageName = @"club_button_selected.png";
        titleColor = DARK_BTN_TITLE_COLOR;
      }else {
        joinStatus = NO;
        title = LocaleStringForKey(NSJoinButTitle, nil);
        buttonImageName = @"button_orange.png";
        buttonSelectedImageName = @"button_orange_selected.png";
        titleColor = [UIColor whiteColor];
      }
      
      _joinAndQuitBut = [[[UIImageButton alloc]
                                     initImageButtonWithFrame:activityFrame
                                     target:self
                                     action:@selector(doJoin2Quit:)
                                     title:title
                                     image:nil
                                     backImgName:buttonImageName
                                     selBackImgName:buttonSelectedImageName
                                     titleFont:BOLD_FONT(FONT_SIZE)
                                     titleColor:titleColor
                                     titleShadowColor:TRANSPARENT_COLOR
                                     roundedType:HAS_ROUNDED
                                     imageEdgeInsert:ZERO_EDGE
                                     titleEdgeInsert:ZERO_EDGE] autorelease];
      
      [_member2ActivityView addSubview:_joinAndQuitBut];
    }
    
    [_headerView addSubview:_member2ActivityView];
    
    /*
    // event
    UIView *eventView = [[[UIView alloc] initWithFrame:CGRectMake(0, TOP_VIEW_Y+TOP_VIEW_H+BUTTON_H+MARGIN*3, SCREEN_WIDTH, EVENT_VIEW_H)] autorelease];
    eventView.backgroundColor = COLOR(238, 238, 238);
    
    [_headerView addSubview:eventView];
    
    UILabel *eventTitleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN*2, MARGIN, 200.f, 18.f)] autorelease];
    eventTitleLabel.font = FONT(FONT_SIZE);
    
    NSInteger number = self.clubSimple.newEventNum.intValue;
    eventTitleLabel.text = [NSString stringWithFormat:@"%@ (%d)", LocaleStringForKey(NSGroupEventTitle,nil), number];
    
    [eventTitleLabel setTextColor:COLOR(136, 136, 136)];
    [eventTitleLabel setBackgroundColor:TRANSPARENT_COLOR];
    [eventView addSubview:eventTitleLabel];
    
    UILabel *eventDescLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN*2, MARGIN*4, SCREEN_WIDTH - MARGIN*6, 54.f)] autorelease];
    eventDescLabel.font = BOLD_FONT(FONT_SIZE);
    
    if (![NULL_PARAM_VALUE isEqualToString:self.clubSimple.eventDesc]) {
      NSArray *eventArray = [self.clubSimple.eventDesc componentsSeparatedByString:@"$"];
      
      if ([eventArray count]>0) {
        NSArray *eventDetailArray = [eventArray[0] componentsSeparatedByString:@"|"];
        
        [eventDescLabel setText:[NSString stringWithFormat:@"%@ (%@) %@", eventDetailArray[0], eventDetailArray[1], eventDetailArray[2]]];
      }
      
      UIImageView *postImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
      postImgView.frame = CGRectMake(300.f, (EVENT_VIEW_H-14.f)/2.f, 10.f, 14.f);
      postImgView.backgroundColor = TRANSPARENT_COLOR;
      [eventView addSubview:postImgView];
      [postImgView release];
      
      UIButton *eventViewClick = [UIButton buttonWithType:UIButtonTypeCustom];
      eventViewClick.frame = eventView.frame;
      [eventViewClick addTarget:self action:@selector(goClubActivity:)forControlEvents:UIControlEventTouchUpInside];
      [_headerView addSubview:eventViewClick];
      
    } else {
      [eventDescLabel setText:LocaleStringForKey(NSNoGroupEventTitle, nil)];
    }
    
    eventDescLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    eventDescLabel.numberOfLines = 3;
    [eventDescLabel setTextColor:DARK_BTN_TITLE_COLOR];
    [eventDescLabel setBackgroundColor:TRANSPARENT_COLOR];
    [eventView addSubview:eventDescLabel];
    */
     
    // post area
    _postToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, TOP_VIEW_Y+TOP_VIEW_H+BUTTON_H + 15, SCREEN_WIDTH, BUTTON_H+20)] autorelease];
    _postToolbar.barStyle = UIBarStyleBlack;
    _postToolbar.translucent = YES;
    _postToolbar.tintColor = DARK_CELL_COLOR;
    _postToolbar.layer.masksToBounds = YES;
    
    [_headerView addSubview:_postToolbar];
    
    _payBarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    self.clubSimple.payType = @(NEED_FEE_PAY_TY);
    
    switch (self.clubSimple.payType.intValue) {
      case NEED_FEE_PAY_TY:
      {
        if (self.clubSimple.userPaid.boolValue) {
          
          WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                   textColor:DARK_BTN_TITLE_COLOR
                                                 shadowColor:TEXT_SHADOW_COLOR
                                                        font:BOLD_FONT(FONT_SIZE)] autorelease];
          label.text = STR_FORMAT(LocaleStringForKey(NSPaidDateMsg, nil), self.clubSimple.userPayDate);
          size = [label.text sizeWithFont:label.font];
          label.frame = CGRectMake(0, 0, size.width, size.height);
          _payBarButton = [[[UIBarButtonItem alloc] initWithCustomView:label] autorelease];

        } else {
          
          UIImageButton *payButton = [[[UIImageButton alloc]
                                       initImageButtonWithFrame:CGRectMake(0, 0, BUTTON_W, BUTTON_H)
                                       target:self
                                       action:@selector(pay:)
                                       title:LocaleStringForKey(NSPayNowTitle, nil)
                                       image:nil
                                       backImgName:@"club_button.png"
                                       selBackImgName:@"club_button_selected.png"
                                       titleFont:BOLD_FONT(FONT_SIZE)
                                       titleColor:DARK_BTN_TITLE_COLOR
                                       titleShadowColor:[UIColor whiteColor]
                                       roundedType:HAS_ROUNDED
                                       imageEdgeInsert:ZERO_EDGE
                                       titleEdgeInsert:ZERO_EDGE] autorelease];
          
          _payBarButton = [[[UIBarButtonItem alloc] initWithCustomView:payButton] autorelease];      

        }

        break;
      }
        
      case RENEWALS_PAY_TY:
      {
        UIImageButton *payButton = [[[UIImageButton alloc]
                                     initImageButtonWithFrame:CGRectMake(0, 0, BUTTON_W, BUTTON_H)
                                     target:self
                                     action:@selector(pay:)
                                     title:LocaleStringForKey(NSRenewalsTitle, nil)
                                     image:nil
                                     backImgName:@"club_button.png"
                                     selBackImgName:@"club_button_selected.png"
                                     titleFont:BOLD_FONT(FONT_SIZE)
                                     titleColor:DARK_BTN_TITLE_COLOR
                                     titleShadowColor:[UIColor whiteColor]
                                     roundedType:HAS_ROUNDED
                                     imageEdgeInsert:ZERO_EDGE
                                     titleEdgeInsert:ZERO_EDGE] autorelease];
        WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                 textColor:DARK_BTN_TITLE_COLOR
                                               shadowColor:TEXT_SHADOW_COLOR
                                                      font:BOLD_FONT(FONT_SIZE)] autorelease];
        label.text = STR_FORMAT(LocaleStringForKey(NSPaidDateMsg, nil), self.clubSimple.userPayDate);
        size = [label.text sizeWithFont:label.font];
        label.frame = CGRectMake(BUTTON_W + MARGIN, (BUTTON_H - size.height)/2.0f, size.width, size.height);
        //payBarButton = [[[UIBarButtonItem alloc] initWithCustomView:label] autorelease];

        UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, BUTTON_W + size.width + MARGIN, BUTTON_H)] autorelease];
        [view addSubview:payButton];
        [view addSubview:label];
        
        _payBarButton = [[[UIBarButtonItem alloc] initWithCustomView:view] autorelease];
        
        break;
      }
        
      default:
        break;
    }
    
    UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    UIImageButton *postButton = [[[UIImageButton alloc]
                                  initImageButtonWithFrame:CGRectMake(0, 0, 80.f, BUTTON_H)
                                  target:self
                                  action:@selector(doPost:)
                                  title:LocaleStringForKey(NSPostTitle, nil)
                                  image:[UIImage imageNamed:@"club_post_white.png"]
                                  backImgName:@"button_orange.png"
                                  selBackImgName:@"button_orange_selected.png"
                                  titleFont:BOLD_FONT(FONT_SIZE)
                                  titleColor:[UIColor whiteColor]
                                  titleShadowColor:TRANSPARENT_COLOR
                                  roundedType:HAS_ROUNDED
                                  imageEdgeInsert:ZERO_EDGE
                                  titleEdgeInsert:ZERO_EDGE] autorelease];
    
    UIBarButtonItem *postBarButton = [[[UIBarButtonItem alloc] initWithCustomView:postButton] autorelease];
    
    if (!self.clubSimple.ifmember.boolValue) {
      _payBarButton.enabled = NO;
    }
    
    self.barButtons = [NSMutableArray arrayWithObjects:_payBarButton, space, postBarButton, nil];
    
    [_postToolbar setItems:self.barButtons];
  }
  
  return _headerView;
}
#pragma mark - action
- (void)doJoin2Quit:(id)sender
{
  if (joinStatus && self.clubSimple.userPaid.boolValue) {
    [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaidUserCannotExitMsg, nil)
                                     msgType:INFO_TY
                          belowNavigationBar:YES];
    
    return;
  }
  
  /*
  if (!joinStatus && self.clubSimple.payType.intValue == NEED_FEE_PAY_TY) {
    // check whether need pay fee
    ShowAlertWithTwoButton(self, nil, LocaleStringForKey(NSNeedPayGroupFeeMsg, nil), LocaleStringForKey(NSPayNowTitle, nil), LocaleStringForKey(NSNoThanksTitle, nil));
    return;
  }
  */
  
  [_delegate doJoin2Quit:joinStatus ifAdmin:self.clubSimple.ifadmin];
}

- (void)doManage:(UITapGestureRecognizer *)recognizer {
  if (_delegate) {
    [_delegate doManage];
  }
}

- (void)goClubActivity:(id)sender
{
  [_delegate goClubActivity];
}

- (void)goClubUserList:(id)sender
{
  [_delegate goClubUserList];
}

- (void)doPost:(id)sender {
  [_delegate doPost];
}

- (void)showTagFilter:(id)sender {
  [_delegate showFilters];
}

- (void)pay:(id)sender {
  [_delegate payWithOrderId:self.clubSimple.orderId];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  
}

@end
