
//
//  ClubDetailViewController.m
//  iAlumni
//
//  Created by Adam on 11-12-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ClubDetailViewController.h"
#import "UserListViewController.h"
#import "UIWebViewController.h"
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "EncryptUtil.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "UIImageButton.h"
#import "GroupMemberListViewController.h"
#import "ClubEventListViewController.h"
#import "GroupMemberPhotoListViewController.h"
#import "UIImage-Extensions.h"
#import "UPOMP.h"
#import "OrderViewController.h"
#import "Club.h"


#define NAME_WIDTH                      270.0f
#define TITLE_ICON_WIDTH                26.0f
#define TITLE_ICON_HEIGHT               7.0f

#define TITLE_X                         28.0f
#define HEADER_VIEW_H                   274.f
#define GROUP_ICON_H                    176.f
#define GROUP_MEMBER_H                  63.7f

#define NUMBER_FONT_SIZE                23.0f
#define FONT_SIZE                       13.0f
#define NUMBER_X                        220.f
#define LABEL_X                         20.0f
#define LABEL_Y                         16.0f
#define DESC_TITLE_HEIGHT               25.0f
#define DESC_BUTTON_HEIGHT              25.0f
#define TEL_X                           60.0f
#define MEMBER_ACTIVITY_X               80.f

#define BTN_WIDTH                       120.0f
#define BTN_HEIGHT                      35.0f

#define LABEL_MAX                       100.0f
#define LABEL_CONTENT_INTERVAL          10.0f
#define NUMBER_X                        220.f
#define BUTTON_W                        90.f
#define PHOTO_WIDTH                     98.0f//110.0f
#define PHOTO_HEIGHT                    80.0f//90.0f

#define MEMBER2ACTIVITY_X               MARGIN*3
#define MEMBER2ACTIVITY_Y               30.0f

#define JOIN2MANAGE_Y                   60.0f

#define SECTION_COUNT                   3

#define FOOT_HEIGHT                     80.0f
#define GROUP_CELL_H                    46.f

#define CELL_IMG_X                      3.f
#define CELL_IMG_W                      289.f

enum {
  GROUP_QUIT_TYPE,
};

enum {
  CALL_ACTION,
  PAY_ACTION,
};

enum {
  GROUP_CHANGE_SECTION,
  GROUP_SERVICE_SECTION,
  GROUP_CONTRACT_SECTION,
  GROUP_DESC_SECTION,
  GROUP_MEMBER_ACTIVITY_SECTION,
};

enum {
  nameTag = 0,
  memberLabelTag,
  memberCountTag,
  activityLabelTag,
  activityCountTag,
  joinTag,
  manageTag,
  sendTag,
  descTag,
  activityTag,
  personTag,
};

@interface ClubDetailViewController () <UPOMPDelegate>
{
  BOOL joinStatus;
  int tableHeight;
  int paymentStatus;
  
  int iDescHeight;
  int iChargeHeight;
  int iManageCount;
  
  int iChangeMarkHeight;
  int iPayHeight;
  
  BOOL isClass;
}

@property (nonatomic, retain) UPOMP *cpView;
@property (nonatomic, retain) ClubDetail *club;
@property (nonatomic, retain) NSArray *contractLabelArray;
@property (nonatomic, retain) NSArray *contractValueArray;
@property (nonatomic, retain) NSArray *groupMember2ActivityLabelArray;
@property (nonatomic, retain) NSArray *groupMember2ActivityValueArray;

@property (nonatomic, retain) UIView *userPhotoShadowView;
@property (nonatomic, retain) UIButton *userPhotoBtn;
@property (nonatomic, retain) NSArray *clubInstructionList;

@property (nonatomic, copy) NSString *join2quitTitle;
@property (nonatomic, copy) NSString *join2quitValue;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, retain) UIImageView *cellIconView;
@end

@implementation ClubDetailViewController

#pragma mark - set refresh flag
- (void)setRefreshFlag {
  if (_parentListVC != nil) {
    if ([_parentListVC respondsToSelector:@selector(setTriggerReloadListFlag)]) {
      [_parentListVC performSelector:@selector(setTriggerReloadListFlag)];
    }
  }
}

#pragma mark - life cycle methods
- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext*)MOC
       parentListVC:(BaseListViewController *)parentListVC;
{
  self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needGoHome:NO];
  if (self) {
    _frame = frame;
    joinStatus = NO;
    
    _parentListVC = parentListVC;
    
    if (CURRENT_OS_VERSION >= IOS7) {
      _imageX = MARGIN * 3;
      
      _labelX = 25.0f;
    } else {
      _imageX = 3.0f;
      
      _labelX = 20.0f;
    }
  }
  return self;
}

- (void)dealloc
{
  
  self.contractLabelArray = nil;
  self.contractValueArray = nil;
  self.groupMember2ActivityLabelArray = nil;
  self.groupMember2ActivityValueArray = nil;
  
  self.club = nil;
  self.cellIconView = nil;
  self.userPhotoBtn = nil;
  
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

- (void)doBack:(id)sender
{
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - load detail
- (void)loadSponsorDetail {
  [CommonUtils doDelete:_MOC entityName:@"ClubDetail"];
  
  NSString *param = [NSString stringWithFormat:@"<host_id>%@</host_id><host_type>%@</host_type>", [AppManager instance].clubId, [AppManager instance].hostTypeValue];
  
  _currentType = SPONSOR_TY;
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:_currentType] autorelease];
  // [self.connDic setObject:connFacade forKey:url];
  [connFacade fetchGets:url];
}

- (void)initResource
{
  // Cell Array
  self.contractLabelArray = [[[NSArray alloc] initWithObjects:LocaleStringForKey(NSTelTitle, nil), LocaleStringForKey(NSEmailTitle, nil), LocaleStringForKey(NSWebSiteTitle, nil), nil] autorelease];
  self.contractValueArray = [[[NSArray alloc] initWithObjects:self.club.tel, self.club.email, self.club.webUrl, nil] autorelease];
  
  // Cell Array
  self.groupMember2ActivityLabelArray = [[[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSGroupMemberTitle, nil)], [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSGroupEventTitle, nil)], nil] autorelease];
  self.groupMember2ActivityValueArray = [[[NSArray alloc] initWithObjects:self.club.membercount.stringValue, self.club.eventcount.stringValue, nil] autorelease];
  
  // club instruction
  self.clubInstructionList = @[LocaleStringForKey(NSServicePlanTitle, nil),
                               LocaleStringForKey(NSConstitutionTitle, nil),
                               LocaleStringForKey(NSCouncilListTitle, nil)];
  
  // Desc Height
  if (self.club.desc && self.club.desc.length > 0) {
    CGSize constraint = CGSizeMake(SCREEN_WIDTH-60, CGFLOAT_MAX);
    CGSize descSize = [self.club.desc sizeWithFont:FONT(FONT_SIZE) constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    iDescHeight = descSize.height;
  } else {
    iDescHeight = 0;
  }
  
  // Change Height
  if (self.club.change && self.club.change.length > 0) {
    CGSize constraint = CGSizeMake(SCREEN_WIDTH-60, CGFLOAT_MAX);
    CGSize chargeSize = [self.club.change sizeWithFont:FONT(FONT_SIZE) constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    iChargeHeight = chargeSize.height;
  } else {
    iChargeHeight = 0;
  }
  
  // MemberShip
  if (self.club.memberShipInfo && self.club.memberShipInfo.length > 0) {
    CGSize constraint = CGSizeMake(SCREEN_WIDTH-60, CGFLOAT_MAX);
    CGSize memberShipSize = [self.club.memberShipInfo sizeWithFont:FONT(FONT_SIZE) constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    iChangeMarkHeight = memberShipSize.height;
  } else {
    iChangeMarkHeight = 0;
  }
  
  if (paymentStatus == NOT_PAY_WECHAT_BTN_TY || paymentStatus == NEED_RENEW_WECHAT_BTN_TY || paymentStatus == EXPIRED_WECHAT_BTN_TY) {
    iPayHeight = 60;
  } else {
    iPayHeight = 0;
  }
  
}

- (void)initTableView {
  if (self.tableView == nil) {
    CGRect mTabFrame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
    self.tableView = [[[UITableView alloc] initWithFrame:mTabFrame
                                                   style:UITableViewStyleGrouped] autorelease];
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = TRANSPARENT_COLOR;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
  }
  
	[self.view addSubview:self.tableView];
  [super initTableView];
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded || _needReload) {
    [self loadSponsorDetail];
    
    _needReload = NO;
  }
}

- (void)initGroupBGView {
  self.cellIconView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, GROUP_ICON_H)] autorelease];
  [self.cellIconView setImage:[UIImage imageNamed:@"groupIconDefault.png"]];
  self.cellIconView.backgroundColor = TRANSPARENT_COLOR;
}

- (void)initPhotoButton {
  self.userPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  self.userPhotoBtn.frame = CGRectMake(MARGIN * 2, MARGIN, PHOTO_WIDTH, PHOTO_HEIGHT);
  self.userPhotoBtn.backgroundColor = COLOR(234, 234, 234);
  [self.userPhotoBtn setImage:[UIImage imageNamed:@"clubIcon.png"]
                     forState:UIControlStateNormal];
  AsyncImageView *asyncImage = [[[AsyncImageView alloc] initWithFrame:self.userPhotoBtn.frame] autorelease];
  asyncImage.delegate = self;
  asyncImage._type = 0;
  [asyncImage loadImageFromURL:[NSURL URLWithString:self.club.imgUrl]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  self.view.frame = _frame;
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIDeviceOrientationPortrait);
}

#pragma mark - Table View

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  switch (section) {
    case 0:
    {
      UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEADER_VIEW_H)] autorelease];
      
      UIImage *clubDetailImg = [UIImage imageNamed:@"clubDetailBG.png"];
      UIImageView *clubDetailBG = [[[UIImageView alloc] initWithImage:clubDetailImg] autorelease];
      clubDetailBG.backgroundColor = TRANSPARENT_COLOR;
      clubDetailBG.frame = CGRectMake(15.f, 10.f, 287, 256.3f);
      [headerView addSubview:clubDetailBG];
      
      // Group Member & Activity
      UIView *groupMemberView = [[[UIView alloc] initWithFrame:CGRectMake(25, 190, 131, 64)] autorelease];
      groupMemberView.backgroundColor = COLOR(236, 238, 240);
      
      UILabel *memberLable = [[UILabel alloc] initWithFrame:CGRectZero];
      memberLable.text = LocaleStringForKey(NSGroupMemberTitle, nil);
      memberLable.font = BOLD_FONT(FONT_SIZE+2);
      CGSize memberSize = [memberLable.text sizeWithFont:memberLable.font];
      memberLable.frame = CGRectMake(29, 11, memberSize.width, memberSize.height);
      memberLable.textColor = COLOR(51, 51, 51);
      [memberLable setBackgroundColor:TRANSPARENT_COLOR];
      [groupMemberView addSubview:memberLable];
      [memberLable release];
      
      // Number
      UILabel *memberCountLable = [[[UILabel alloc] init] autorelease];
      memberCountLable.text = self.club.membercount.stringValue;
      memberCountLable.font = BOLD_FONT(NUMBER_FONT_SIZE);
      memberCountLable.textColor = COLOR(234, 47, 52);
      [memberCountLable setBackgroundColor:TRANSPARENT_COLOR];
      memberCountLable.frame = CGRectMake(61, 39, 66, 20.f);
      [groupMemberView addSubview:memberCountLable];
      
      // member icon
      UIImageView *groupMemberIconView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"groupMemberIcon.png"]] autorelease];
      groupMemberIconView.backgroundColor = TRANSPARENT_COLOR;
      groupMemberIconView.frame = CGRectMake(15.f, 15.f, 10.5, 11.5);
      [groupMemberView addSubview:groupMemberIconView];
      
      groupMemberView.userInteractionEnabled = YES;
      UIGestureRecognizer *clickMemberTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(goClubUserList:)];
      clickMemberTap.delegate = self;
      [groupMemberView addGestureRecognizer:clickMemberTap];
      
      [headerView addSubview:groupMemberView];
      
      // Activity Member
      UIView *groupActivityView = [[[UIView alloc] initWithFrame:CGRectMake(162, 190, 131, 64)] autorelease];
      
      [groupActivityView setBackgroundColor:COLOR(236, 238, 240)];
      
      UILabel *clubActivityLable = [[UILabel alloc] initWithFrame:CGRectZero];
      clubActivityLable.text = LocaleStringForKey(NSGroupEventTitle, nil);
      clubActivityLable.font = BOLD_FONT(FONT_SIZE+2);
      CGSize mActivitySize = [clubActivityLable.text sizeWithFont:clubActivityLable.font];
      clubActivityLable.frame = CGRectMake(29, 11, mActivitySize.width, mActivitySize.height);
      clubActivityLable.textColor = COLOR(51, 51, 51);
      [clubActivityLable setBackgroundColor:TRANSPARENT_COLOR];
      [groupActivityView addSubview:clubActivityLable];
      [clubActivityLable release];
      
      // Number
      UILabel *activityCountLable = [[[UILabel alloc] init] autorelease];
      activityCountLable.text = self.club.eventcount.stringValue;
      activityCountLable.font = BOLD_FONT(NUMBER_FONT_SIZE);
      activityCountLable.textColor = COLOR(234, 47, 52);
      [activityCountLable setBackgroundColor:TRANSPARENT_COLOR];
      activityCountLable.frame = CGRectMake(61, 39, 66, 20.f);
      [groupActivityView addSubview:activityCountLable];
      
      // activity icon
      UIImageView *groupActivityIconView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"groupActivityIcon.png"]] autorelease];
      groupActivityIconView.backgroundColor = TRANSPARENT_COLOR;
      groupActivityIconView.frame = CGRectMake(15, 15, 8.5, 10.5);
      [groupActivityView addSubview:groupActivityIconView];
      
      groupActivityView.userInteractionEnabled = YES;
      UIGestureRecognizer *clickActivityTap = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(goClubActivityList:)];
      clickActivityTap.delegate = self;
      [groupActivityView addGestureRecognizer:clickActivityTap];
      
      [headerView addSubview:groupActivityView];
      
      // group Name
      WXWLabel *groupNameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                        textColor:COLOR(51, 51, 51)
                                                      shadowColor:TRANSPARENT_COLOR] autorelease];
      groupNameLabel.font = BOLD_FONT(18);
      groupNameLabel.numberOfLines = 0;
      groupNameLabel.text = self.club.name;
      
      CGSize groupSize = [groupNameLabel.text sizeWithFont:groupNameLabel.font
                                         constrainedToSize:CGSizeMake(NAME_WIDTH, CGFLOAT_MAX)
                                             lineBreakMode:NSLineBreakByWordWrapping];
      
      if (groupSize.height > 20) {
        groupNameLabel.frame = CGRectMake(TITLE_X, 25.f,
                                          groupSize.width, groupSize.height);
      } else {
        groupNameLabel.frame = CGRectMake(TITLE_X, 31.f,
                                          groupSize.width, groupSize.height);
      }
      [headerView addSubview:groupNameLabel];
      
      // desc
      WXWLabel *descLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                   textColor:COLOR(102, 102, 102)
                                                 shadowColor:TRANSPARENT_COLOR] autorelease];
      descLabel.font = FONT(12);
      descLabel.numberOfLines = 3;
      
      descLabel.text = self.club.desc;
      CGSize descSize = [descLabel.text sizeWithFont:descLabel.font];
      descLabel.frame = CGRectMake(TITLE_X, 90.f, NAME_WIDTH, descSize.height*3);
      
      [headerView addSubview:descLabel];
      
      // club detail button
      UIImageView *clubDetailImage = [[[UIImageView alloc] initWithFrame:CGRectMake(240.f, 153.f, 52.f, 23.5f)] autorelease];
      clubDetailImage.image = [UIImage imageNamed:@"clubDetail.png"];
      clubDetailImage.userInteractionEnabled = YES;
      [headerView addSubview:clubDetailImage];
      
      WXWLabel *clubDetailLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(242.f, 156.f, 48.f, 15.f)
                                                         textColor:COLOR(114, 114, 115)
                                                       shadowColor:TRANSPARENT_COLOR] autorelease];
      clubDetailLabel.text = LocaleStringForKey(NSCheckAllTitle, nil);
      clubDetailLabel.font = FONT(FONT_SIZE-3);
      clubDetailLabel.textAlignment = NSTextAlignmentCenter;
      [headerView addSubview:clubDetailLabel];
      
      // club detail but
      UIButton *detailBut = [UIButton buttonWithType:UIButtonTypeCustom];
      detailBut.frame = CGRectMake(240.f-20.f, 153.f-5.f, 52.f+40.f, 23.5f+10.f);
      [detailBut addTarget:self action:@selector(goClubDetail:) forControlEvents:UIControlEventTouchUpInside];
      [headerView addSubview:detailBut];
      
      if (!isClass && paymentStatus == NOT_SHOW_CHANGE_AREA_TY) {
        [headerView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEADER_VIEW_H + 40)];
        
        CGRect join2quitFrame = CGRectMake(15.f, HEADER_VIEW_H, 287, BTN_HEIGHT);
        self.join2quitValue = LocaleStringForKey(NSClubJoinButTitle, nil);
        
        NSString *buttonImgName = @"joinGroupLongBut.png";
        NSString *buttonSelImgName = @"joinGroupLongButSel.png";
        if ([@"1" isEqualToString:self.club.ifmember]) {
          self.join2quitValue = LocaleStringForKey(NSClubQuitButTitle, nil);
          buttonImgName = @"quitGroupLongBut.png";
          buttonSelImgName = @"quitGroupLongButSel.png";
          joinStatus = YES;
        } else {
          buttonImgName = @"joinGroupLongBut.png";
          buttonSelImgName = @"joinGroupLongButSel.png";
          joinStatus = NO;
        }
        
        // join quit button
        UIImageButton *join2quitButton = [[[UIImageButton alloc]
                                           initImageButtonWithFrame:join2quitFrame
                                           target:self
                                           action:@selector(doJoin2Quit:)
                                           title:self.join2quitValue
                                           image:nil
                                           backImgName:buttonImgName
                                           selBackImgName:buttonSelImgName
                                           titleFont:BOLD_FONT(15)
                                           titleColor:[UIColor whiteColor]
                                           titleShadowColor:TRANSPARENT_COLOR
                                           roundedType:HAS_ROUNDED
                                           imageEdgeInsert:ZERO_EDGE
                                           titleEdgeInsert:ZERO_EDGE] autorelease];
        
        [headerView addSubview:join2quitButton];
      }
      
      return headerView;
    }
      break;
  }
  
  return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
  /*
   if (paymentStatus == NOT_SHOW_CHANGE_AREA_TY) {
   section += 1;
   }
   
   if (section == GROUP_CONTRACT_SECTION) {
   
   UIView *mUIView = [[[UIView alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, FOOT_HEIGHT)] autorelease];
   [mUIView setBackgroundColor:TRANSPARENT_COLOR];
   
   CGRect join2quitFrame = CGRectMake(16.5, 15, 287, 48);
   self.join2quitValue = LocaleStringForKey(NSClubJoinButTitle, nil);
   
   if ([@"1" isEqualToString:self.club.ifmember]) {
   self.join2quitValue = LocaleStringForKey(NSClubQuitButTitle, nil);
   joinStatus = YES;
   } else {
   joinStatus = NO;
   }
   
   // join quit button
   UIImageButton *join2quitButton = [[[UIImageButton alloc]
   initImageButtonWithFrame:join2quitFrame
   target:self
   action:@selector(doJoin2Quit:)
   title:self.join2quitValue
   image:nil
   backImgName:@"clubBottom.png"
   selBackImgName:@"clubBottomSel.png"
   titleFont:BOLD_FONT(15)
   titleColor:[UIColor whiteColor]
   titleShadowColor:TRANSPARENT_COLOR
   roundedType:HAS_ROUNDED
   imageEdgeInsert:ZERO_EDGE
   titleEdgeInsert:ZERO_EDGE] autorelease];
   
   [mUIView addSubview:join2quitButton];
   
   return mUIView;
   }
   */
  
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
  //    if (paymentStatus == NOT_SHOW_CHANGE_AREA_TY) {
  //        section += 1;
  //    }
  //
  //    if (section == GROUP_CONTRACT_SECTION) {
  //        return FOOT_HEIGHT;
  //    }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"ClubDetailCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
  for (UIView *subview in subviews) {
    [subview removeFromSuperview];
  }
  [subviews release];
  
  // Configure the cell...
  [self configureCell:indexPath aCell:cell];
  
  return cell;
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  return NO;
}

#pragma mark - Table view delegate

- (void)drawIntroCell:(UITableViewCell *)cell {
  UIView *mCellView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, SCREEN_WIDTH-55, DESC_TITLE_HEIGHT+MARGIN*2+iDescHeight)];
  [mCellView setBackgroundColor:COLOR(222, 222, 222)];
  
  CGRect descTitleFrame = CGRectMake(_labelX, 0, SCREEN_WIDTH-20-4, DESC_TITLE_HEIGHT);
  UILabel *mLabel = [[UILabel alloc] initWithFrame:descTitleFrame];
  [mLabel setText:LocaleStringForKey(NSIntroductionTitle, nil)];
  [mLabel setFont:BOLD_FONT(FONT_SIZE+2)];
  [mLabel setTextColor:COLOR(196, 24, 32)];
  [mLabel setBackgroundColor:TRANSPARENT_COLOR];
  [mCellView addSubview:mLabel];
  [mLabel release];
  
  CGRect descFrame = CGRectMake(_labelX, DESC_TITLE_HEIGHT, SCREEN_WIDTH-40, iDescHeight);
  UILabel *mDesc = [[UILabel alloc] initWithFrame:descFrame];
  [mDesc setText:self.club.desc];
  mDesc.numberOfLines = 0;
  mDesc.lineBreakMode = NSLineBreakByCharWrapping;
  [mDesc setFont:FONT(FONT_SIZE)];
  [mDesc setBackgroundColor:TRANSPARENT_COLOR];
  [mDesc setTextColor:[UIColor blackColor]];
  [mCellView addSubview:mDesc];
  [mDesc release];
  
  [mCellView setBackgroundColor:TRANSPARENT_COLOR];
  [cell.contentView addSubview:mCellView];
  [mCellView release];
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)drawManagementCell:(UITableViewCell *)cell {
  UIView *mCellView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, SCREEN_WIDTH-55, DESC_TITLE_HEIGHT+MARGIN*2+iDescHeight)];
  [mCellView setBackgroundColor:COLOR(222, 222, 222)];
  
  CGRect descTitleFrame = CGRectMake(_labelX, (DEFAULT_CELL_HEIGHT - DESC_TITLE_HEIGHT)/2.0f, SCREEN_WIDTH-20-4, DESC_TITLE_HEIGHT);
  UILabel *mLabel = [[UILabel alloc] initWithFrame:descTitleFrame];
  [mLabel setText:LocaleStringForKey(NSGroupManagementTitle, nil)];
  [mLabel setFont:BOLD_FONT(FONT_SIZE+2)];
  [mLabel setTextColor:COLOR(196, 24, 32)];
  [mLabel setBackgroundColor:TRANSPARENT_COLOR];
  [mCellView addSubview:mLabel];
  [mLabel release];
  
  [mCellView setBackgroundColor:TRANSPARENT_COLOR];
  [cell.contentView addSubview:mCellView];
  [mCellView release];
  
  cell.selectionStyle = UITableViewCellSelectionStyleBlue;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

-(void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell
{
  int section = [indexPath section];
  int row = [indexPath row];
  [cell setBackgroundColor:[UIColor whiteColor]];
  
  if (paymentStatus == NOT_SHOW_CHANGE_AREA_TY) {
    section += 1;
  }
  
  switch (section) {
    case GROUP_DESC_SECTION:
    {
      if (indexPath.row == 0) {
        [self drawIntroCell:cell];
      }
      
      if ([AppManager instance].clubAdmin && indexPath.row == 1) {
        [self drawManagementCell:cell];
      }
      
      break;
    }
      
    case GROUP_MEMBER_ACTIVITY_SECTION:
    {
      // Label
      NSString *mText = self.groupMember2ActivityLabelArray[row];
      CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE + 3)];
      UILabel *mLable = [[UILabel alloc] initWithFrame:CGRectMake(_labelX, LABEL_Y, mDescSize.width, mDescSize.height)];
      mLable.text = mText;
      mLable.textColor = COLOR(82, 82, 82);
      [mLable setBackgroundColor:TRANSPARENT_COLOR];
      mLable.font = BOLD_FONT(FONT_SIZE);
      mLable.tag = row + 30;
      [cell.contentView addSubview:mLable];
      [mLable release];
      
      // Number
      NSString *mNumber = self.groupMember2ActivityValueArray[row];
      CGSize mNumberSize = [mNumber sizeWithFont:FONT(FONT_SIZE + 3)];
      
      UILabel *textLable = [[UILabel alloc] init];
      textLable.text = mNumber;
      textLable.font = FONT(FONT_SIZE + 3);
      textLable.textColor = COLOR(196, 24, 32);
      [textLable setBackgroundColor:TRANSPARENT_COLOR];
      CGRect mLabelFrame = CGRectMake(MEMBER_ACTIVITY_X, LABEL_Y, 80, mNumberSize.height);
      
      textLable.frame = mLabelFrame;
      textLable.lineBreakMode = NSLineBreakByTruncatingTail;
      
      [cell.contentView addSubview:textLable];
      [textLable release];
      
      if (![mNumber isEqualToString:@"0"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
      }
      
      break;
    }
      
    case GROUP_CHANGE_SECTION:
    {
      [cell setBackgroundColor:TRANSPARENT_COLOR];
      
      UIImage *cellBGImage = [UIImage imageNamed:@"clubDetailBG.png"];
      UIImageView *cellImageView = [[[UIImageView alloc] initWithImage:cellBGImage] autorelease];
      cellImageView.frame = CGRectMake(_imageX, 0, CELL_IMG_W, iChargeHeight + 20*MARGIN + iChangeMarkHeight + BTN_HEIGHT);
      
      CGRect descTitleFrame = CGRectMake(10, 10, CELL_IMG_W-2*_labelX, DESC_TITLE_HEIGHT);
      UILabel *mLabel = [[[UILabel alloc] initWithFrame:descTitleFrame] autorelease];
      [mLabel setText:LocaleStringForKey(NSChangeTitle, nil)];
      [mLabel setFont:BOLD_FONT(FONT_SIZE+3)];
      [mLabel setTextColor:COLOR(51, 51, 51)];
      [mLabel setBackgroundColor:TRANSPARENT_COLOR];
      [cellImageView addSubview:mLabel];
      
      CGRect descBGFrame = CGRectMake(10, 38.f, CELL_IMG_W - 20.f, iChargeHeight + 8*MARGIN + iChangeMarkHeight);
      UIView *descBGView = [[[UIView alloc] initWithFrame:descBGFrame] autorelease];
      descBGView.backgroundColor = COLOR(237, 238, 240);
      
      CGRect descFrame = CGRectMake(10, 15, CELL_IMG_W-40, iChargeHeight);
      UILabel *mDesc = [[[UILabel alloc] initWithFrame:descFrame] autorelease];
      [mDesc setText:self.club.change];
      mDesc.numberOfLines = 0;
      mDesc.lineBreakMode = NSLineBreakByCharWrapping;
      [mDesc setFont:FONT(FONT_SIZE)];
      [mDesc setBackgroundColor:TRANSPARENT_COLOR];
      [mDesc setTextColor:COLOR(135, 135, 135)];
      [descBGView addSubview:mDesc];
      [cellImageView addSubview:descBGView];
      
      if(paymentStatus == NEED_RENEW_WECHAT_BTN_TY || paymentStatus == PAID_WECHAT_BTN_TY || paymentStatus == EXPIRED_WECHAT_BTN_TY) {
        
        CGRect payInfoFrame = CGRectMake(_labelX, descBGFrame.origin.y + iChargeHeight + 5*MARGIN, CELL_IMG_W-2*_labelX, iChangeMarkHeight);
        UILabel *payInfoLabel = [[[UILabel alloc] initWithFrame:payInfoFrame] autorelease];
        [payInfoLabel setText:self.club.memberShipInfo];
        payInfoLabel.numberOfLines = 0;
        payInfoLabel.textAlignment = NSTextAlignmentCenter;
        payInfoLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [payInfoLabel setFont:BOLD_FONT(FONT_SIZE)];
        [payInfoLabel setBackgroundColor:TRANSPARENT_COLOR];
        [payInfoLabel setTextColor:COLOR(207, 73, 79)];
        [cellImageView addSubview:payInfoLabel];
      }
      
      if (paymentStatus == NOT_PAY_WECHAT_BTN_TY || paymentStatus == NEED_RENEW_WECHAT_BTN_TY || paymentStatus == EXPIRED_WECHAT_BTN_TY) {
        
        int buttonY = iChargeHeight + 17*MARGIN + iChangeMarkHeight;
        CGRect join2quitFrame = CGRectMake((CELL_IMG_W / 2 - BTN_WIDTH-10),
                                           buttonY,
                                           BTN_WIDTH,
                                           BTN_HEIGHT);
        self.join2quitValue = LocaleStringForKey(NSClubJoinButTitle, nil);
        
        if ([@"1" isEqualToString:self.club.ifmember]) {
          self.join2quitValue = LocaleStringForKey(NSClubQuitButTitle, nil);
          joinStatus = YES;
        } else {
          joinStatus = NO;
        }
        
        // join quit button
        UIImageButton *join2quitButton = [[[UIImageButton alloc]
                                           initImageButtonWithFrame:join2quitFrame
                                           target:self
                                           action:@selector(doJoin2Quit:)
                                           title:self.join2quitValue
                                           image:nil
                                           backImgName:@"quitGroupBut.png"
                                           selBackImgName:@"quitGroupButSel.png"
                                           titleFont:BOLD_FONT(15)
                                           titleColor:[UIColor whiteColor]
                                           titleShadowColor:TRANSPARENT_COLOR
                                           roundedType:HAS_ROUNDED
                                           imageEdgeInsert:ZERO_EDGE
                                           titleEdgeInsert:ZERO_EDGE] autorelease];
        [cellImageView addSubview:join2quitButton];
        
        // Pay button
        NSString *payLabelVal = LocaleStringForKey(NSRenewalsTitle, nil);
        if (paymentStatus == NOT_PAY_WECHAT_BTN_TY) {
          payLabelVal = LocaleStringForKey(NSPayNowTitle, nil);
        }
        CGRect payFrame = CGRectMake((CELL_IMG_W / 2 + 10),
                                     buttonY,
                                     BTN_WIDTH,
                                     BTN_HEIGHT);
        UIImageButton *payButton = [[[UIImageButton alloc]
                                     initImageButtonWithFrame:payFrame
                                     target:self
                                     action:@selector(doPay)
                                     title:payLabelVal
                                     image:nil
                                     backImgName:@"joinGroupBut.png"
                                     selBackImgName:@"joinGroupButSel.png"
                                     titleFont:BOLD_FONT(15)
                                     titleColor:[UIColor whiteColor]
                                     titleShadowColor:TRANSPARENT_COLOR
                                     roundedType:HAS_ROUNDED
                                     imageEdgeInsert:ZERO_EDGE
                                     titleEdgeInsert:ZERO_EDGE] autorelease];
        [cellImageView addSubview:payButton];
      }
      
      if (paymentStatus == NOT_JOIN_WECHAT_BTN_TY) {
        
        int buttonY = iChargeHeight + 17*MARGIN + iChangeMarkHeight;
        CGRect join2quitFrame = CGRectMake(10.f, buttonY, CELL_IMG_W-20.f, BTN_HEIGHT);
        self.join2quitValue = LocaleStringForKey(NSClubJoinButTitle, nil);
        
        if ([@"1" isEqualToString:self.club.ifmember]) {
          self.join2quitValue = LocaleStringForKey(NSClubQuitButTitle, nil);
          joinStatus = YES;
        } else {
          joinStatus = NO;
        }
        
        // join quit button
        UIImageButton *join2quitButton = [[[UIImageButton alloc]
                                           initImageButtonWithFrame:join2quitFrame
                                           target:self
                                           action:@selector(doJoin2Quit:)
                                           title:self.join2quitValue
                                           image:nil
                                           backImgName:@"joinGroupLongBut.png"
                                           selBackImgName:@"joinGroupButSel.png"
                                           titleFont:BOLD_FONT(15)
                                           titleColor:[UIColor whiteColor]
                                           titleShadowColor:TRANSPARENT_COLOR
                                           roundedType:HAS_ROUNDED
                                           imageEdgeInsert:ZERO_EDGE
                                           titleEdgeInsert:ZERO_EDGE] autorelease];
        [cellImageView addSubview:join2quitButton];
      }
      
      if (paymentStatus == PAID_WECHAT_BTN_TY) {
        
        int buttonY = iChargeHeight + 17*MARGIN + iChangeMarkHeight;
        CGRect join2quitFrame = CGRectMake(10.f, buttonY, CELL_IMG_W-20.f, BTN_HEIGHT);
        self.join2quitValue = LocaleStringForKey(NSClubJoinButTitle, nil);
        
        if ([@"1" isEqualToString:self.club.ifmember]) {
          self.join2quitValue = LocaleStringForKey(NSClubQuitButTitle, nil);
          joinStatus = YES;
        } else {
          joinStatus = NO;
        }
        
        // join quit button
        UIImageButton *join2quitButton = [[[UIImageButton alloc]
                                           initImageButtonWithFrame:join2quitFrame
                                           target:self
                                           action:@selector(doJoin2Quit:)
                                           title:self.join2quitValue
                                           image:nil
                                           backImgName:@"quitGroupLongBut.png"
                                           selBackImgName:@"quitGroupButSel.png"
                                           titleFont:BOLD_FONT(15)
                                           titleColor:[UIColor whiteColor]
                                           titleShadowColor:TRANSPARENT_COLOR
                                           roundedType:HAS_ROUNDED
                                           imageEdgeInsert:ZERO_EDGE
                                           titleEdgeInsert:ZERO_EDGE] autorelease];
        [cellImageView addSubview:join2quitButton];
      }
      
      cellImageView.userInteractionEnabled = YES;
      [cell.contentView addSubview:cellImageView];
      
      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      
      break;
    }
      
    case GROUP_SERVICE_SECTION:
    {
      [cell setBackgroundColor:TRANSPARENT_COLOR];
      UIImage *cellBGImage = [UIImage imageNamed:@"groupCellBGArrow1.png"];
      if (row == 2)
        cellBGImage = [UIImage imageNamed:@"groupCellBGArrow2.png"];
      UIImageView *cellImageView = [[[UIImageView alloc] initWithImage:cellBGImage] autorelease];
      cellImageView.frame = CGRectMake(_imageX, 0, CELL_IMG_W, GROUP_CELL_H);
      
      [cell.contentView addSubview:cellImageView];
      
      NSString *mText = (self.clubInstructionList)[row];
      CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE + 3)];
      UILabel *mUILable = [[UILabel alloc] initWithFrame:CGRectMake(_labelX, LABEL_Y, mDescSize.width, mDescSize.height)];
      mUILable.text = mText;
      mUILable.textColor = COLOR(82, 82, 82);
      [mUILable setBackgroundColor:TRANSPARENT_COLOR];
      mUILable.font = BOLD_FONT(FONT_SIZE+3);
      mUILable.tag = row + 50;
      [cell.contentView addSubview:mUILable];
      [mUILable release];
      
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.accessoryType = UITableViewCellAccessoryNone;
      
      break;
    }
      
    case GROUP_CONTRACT_SECTION:
    {
      [cell setBackgroundColor:TRANSPARENT_COLOR];
      UIImage *cellBGImage = [UIImage imageNamed:@"groupCellBG1.png"];
      if (row == 2)
        cellBGImage = [UIImage imageNamed:@"groupCellBG2.png"];
      UIImageView *cellImageView = [[[UIImageView alloc] initWithImage:cellBGImage] autorelease];
      cellImageView.frame = CGRectMake(_imageX, 0, CELL_IMG_W, GROUP_CELL_H);
      
      [cell.contentView addSubview:cellImageView];
      
      // Label
      NSString *mText = self.contractLabelArray[row];
      CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE + 3)];
      UILabel *mUILable = [[UILabel alloc] initWithFrame:CGRectMake(_labelX, LABEL_Y, mDescSize.width, mDescSize.height)];
      mUILable.text = mText;
      mUILable.textColor = COLOR(82, 82, 82);
      [mUILable setBackgroundColor:TRANSPARENT_COLOR];
      mUILable.font = BOLD_FONT(FONT_SIZE+3);
      mUILable.tag = row + 40;
      [cell.contentView addSubview:mUILable];
      [mUILable release];
      
      // Number
      NSString *mNumber = self.contractValueArray[row];
      CGSize mNumberSize = [mNumber sizeWithFont:FONT(FONT_SIZE + 3)];
      
      UILabel *mLable = [[UILabel alloc] init];
      mLable.text = mNumber;
      mLable.font = FONT(FONT_SIZE + 3);
      mLable.textColor = [UIColor blackColor];
      [mLable setBackgroundColor:TRANSPARENT_COLOR];
      CGRect mLabelFrame = CGRectMake(TEL_X, LABEL_Y, 200, mNumberSize.height);
      
      mLable.frame = mLabelFrame;
      mLable.lineBreakMode = NSLineBreakByTruncatingTail;
      
      [cell.contentView addSubview:mLable];
      [mLable release];
      
      //            if (![mNumber isEqualToString:NULL_PARAM_VALUE]) {
      //                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      //            } else {
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      cell.accessoryType = UITableViewCellAccessoryNone;
      //            }
      
      break;
    }
      
    default:
      break;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  int section = [indexPath section];
  
  if (paymentStatus == NOT_SHOW_CHANGE_AREA_TY) {
    section += 1;
  }
  
  switch (section) {
    case GROUP_DESC_SECTION:
    {
      if ([AppManager instance].clubAdmin && indexPath.row == 1) {
        
        NSString *url = [NSString stringWithFormat:@"%@app_login.jsp?logname=%@&password=%@", [AppManager instance].hostUrl, [EncryptUtil TripleDES:[AppManager instance].userId
                                                                                                                                   encryptOrDecrypt:kCCEncrypt],
                         [EncryptUtil TripleDES:[AppManager instance].passwd
                               encryptOrDecrypt:kCCEncrypt]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
      }
      break;
    }
      
    case GROUP_MEMBER_ACTIVITY_SECTION:
    {
      switch (indexPath.row) {
        case 0:
        {
          if ([self.club.membercount intValue] > 0) {
            [self goClubUserList:nil];
          }
        }
          break;
          
        case 1:
        {
          if ([self.club.eventcount intValue] > 0) {
            [self goClubActivityList:nil];
          }
        }
          break;
          
        default:
          break;
      }
    }
      break;
      
    case GROUP_SERVICE_SECTION:
    {
      NSString *url = nil;
      NSString *title = nil;
      switch (indexPath.row) {
        case 0:
        {
          url = [NSString stringWithFormat:@"%@%@&host_id=%@&locale=%@&plat=%@&version=%@&sessionId=%@", [AppManager instance].hostUrl, EVENT_SERVICE_PLAN_URL, [AppManager instance].clubId, [WXWSystemInfoManager instance].currentLanguageDesc, PLATFORM, VERSION, [AppManager instance].sessionId];
          title = LocaleStringForKey(NSServicePlanTitle, nil);
          break;
        }
          
        case 1:
        {
          url = [NSString stringWithFormat:@"%@%@&host_id=%@&locale=%@&plat=%@&version=%@&sessionId=%@", [AppManager instance].hostUrl, EVENT_CONSTITUTION_URL, [AppManager instance].clubId, [WXWSystemInfoManager instance].currentLanguageDesc, PLATFORM, VERSION, [AppManager instance].sessionId];
          title = LocaleStringForKey(NSConstitutionTitle, nil);
          break;
        }
          
        case 2:
        {
          url = [NSString stringWithFormat:@"%@%@&host_id=%@&locale=%@&plat=%@&version=%@&sessionId=%@", [AppManager instance].hostUrl, EVENT_COUNCIL_LIST_URL, [AppManager instance].clubId, [WXWSystemInfoManager instance].currentLanguageDesc, PLATFORM, VERSION, [AppManager instance].sessionId];
          title = LocaleStringForKey(NSCouncilListTitle, nil);
          break;
        }
          
        default:
          break;
      }
      
      [self gotoUrl:url aTitle:title];
      
      break;
    }
      
    case GROUP_CONTRACT_SECTION:
    {
      switch ([indexPath row]) {
        case 0:
        {
          if (self.club.tel && self.club.tel.length > 0) {
            [self goCallPhone];
          }
          
          break;
        }
          
        case 1:
        {
          if (self.club.email && self.club.email.length > 0) {
            NSString *url;
            url = [NSString stringWithFormat:@"mailto://%@",self.club.email];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
          }
          break;
        }
          
        case 2:
        {
          if (self.club.webUrl && self.club.webUrl.length > 0) {
            [self gotoUrl:self.club.webUrl
                   aTitle:self.club.name];
          }
          break;
        }
          
        default:
          break;
      }
      
      break;
    }
      
    default:
      break;
  }
  
  [super deselectCell];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (paymentStatus == NOT_SHOW_CHANGE_AREA_TY) {
    return SECTION_COUNT - 1;
  }
  return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (paymentStatus == NOT_SHOW_CHANGE_AREA_TY) {
    section += 1;
  }
  
  switch (section) {
      
    case GROUP_CHANGE_SECTION:
      return 1;
      
    case GROUP_DESC_SECTION:
      if ([AppManager instance].clubAdmin) {
        return 2;
      } else {
        return 1;
      }
      
    case GROUP_MEMBER_ACTIVITY_SECTION:
      return 2;
      
    case GROUP_SERVICE_SECTION:
      return 3;
      
    case GROUP_CONTRACT_SECTION:
      return 3;
      
    default:
      return 1;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  if (paymentStatus == NOT_SHOW_CHANGE_AREA_TY) {
    section += 1;
  }
  
  if (paymentStatus == NOT_SHOW_CHANGE_AREA_TY) {
    switch (section) {
      case GROUP_SERVICE_SECTION:
        if (isClass) {
          return HEADER_VIEW_H;
        } else {
          return HEADER_VIEW_H + 40;
        }
        
      default:
        return 2;
    }
  } else {
    switch (section) {
      case GROUP_CHANGE_SECTION:
        return HEADER_VIEW_H;
        
      default:
        return 2;
    }
  }
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  int section = [indexPath section];
  
  if (paymentStatus == NOT_SHOW_CHANGE_AREA_TY) {
    section += 1;
  }
  
  switch (section) {
      
    case GROUP_DESC_SECTION:
    {
      if (indexPath.row == 0) {
        return (DESC_TITLE_HEIGHT+MARGIN*3+iDescHeight);
      }
      
      if ([AppManager instance].clubAdmin && indexPath.row == 1) {
        return DEFAULT_CELL_HEIGHT;
      }
    }
      
    case GROUP_CHANGE_SECTION:
      return iChargeHeight + 20*MARGIN + iChangeMarkHeight + BTN_HEIGHT;
      
    default:
      return GROUP_CELL_H;
  }
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
  if (contentType == IMAGE_TY) {
    self.cellIconView.image = [[UIImage imageNamed:@"groupIconDefault.png"] imageByScalingToSize:CGSizeMake(SCREEN_WIDTH, GROUP_ICON_H)];
    return;
  }
  
  [UIUtils showActivityView:self.tableView text:LocaleStringForKey(NSLoadingTitle, nil)];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  [UIUtils closeActivityView];
  
  switch (contentType) {
      
    case PAY_DATA_TY:
    {
      [self goPay:result];
      break;
    }
      
    case IMAGE_TY:
    {
      if (url && url.length > 0) {
        UIImage *image = [UIImage imageWithData:result];
        if (image) {
          [[WXWImageManager instance].imageCache saveImageIntoCache:url image:image];
          
        }
        
        if ([url isEqualToString:self.url]) {
          self.cellIconView.image = image;
        }
      }
      
      break;
    }
      
    case SPONSOR_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        [self fetchItems];
        _autoLoaded = YES;
      } else {
        [UIUtils showNotificationOnTopWithMsg:@"Failed Msg"
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
      }
    }
      break;
      
    case CLUB_JOIN_TY:
    case CLUB_QUIT_TY:
    {
      if (result == nil || [result length] == 0) {
        [UIUtils showNotificationOnTopWithMsg:@"result is Null"
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
        return;
      }
      
      ReturnCode ret = [XMLParser handleCommonResult:result showFlag:YES];
      if (ret == RESP_OK) {
        [self loadSponsorDetail];
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

#pragma mark - show photo

- (UIView *)userPhotoShadowView {
  if (nil == _userPhotoShadowView) {
		_userPhotoShadowView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN, PHOTO_WIDTH, PHOTO_HEIGHT)];
		_userPhotoShadowView.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
		_userPhotoShadowView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
		_userPhotoShadowView.layer.shadowOpacity = 0.8;
		_userPhotoShadowView.layer.shadowRadius = 2.0f;
		_userPhotoShadowView.layer.shouldRasterize = YES;
    [_userPhotoShadowView addSubview:self.userPhotoBtn];
  }
  return _userPhotoShadowView;
}

- (void)setImage:(UIImage*)image aType:(NSUInteger)aType
{
  if (aType==0) {
    [self.userPhotoBtn setBackgroundImage:image forState:UIControlStateNormal];
  }
}

#pragma mark - core date parameter
- (void)setFetchCondition {
  self.entityName = @"ClubDetail";
  
  self.descriptors = [NSMutableArray array];
  
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];
}

- (void)fetchItems {
  [NSFetchedResultsController deleteCacheWithName:nil];
  
  NSError *error = nil;
  BOOL res = [[super prepareFetchRC] performFetch:&error];
  if (!res) {
		NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
	}
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(sponsorId == %@)",[AppManager instance].clubId];
  NSArray *sponsorDetail = [CommonUtils objectsInMOC:_MOC
                                          entityName:self.entityName
                                        sortDescKeys:nil
                                           predicate:predicate];
  
  if ([sponsorDetail count]) {
    self.club = (ClubDetail*)[sponsorDetail lastObject];
    
    paymentStatus = self.club.paymentStatus.intValue;
    
    [AppManager instance].hostSupTypeValue = [NSString stringWithFormat:@"%@", self.club.hostSupTypeValue];
    
    // 班级时不显示
    if ([[AppManager instance].hostSupTypeValue isEqualToString:SELF_CLASS_TYPE]) {
      isClass = YES;
      paymentStatus = NOT_SHOW_CHANGE_AREA_TY;
    } else {
      isClass = NO;
      // 费用 小于１分钱
      if ([self.club.feesValue intValue] < 1) {
        paymentStatus = NOT_SHOW_CHANGE_AREA_TY;
      }
    }

    [self initResource];
    [self initTableView];
    
  }
  [self.tableView reloadData];
}

- (void)goClubDetail:(id)sender {
  if (self.club.detailDescUrl && self.club.detailDescUrl.length > 0) {
    [self gotoUrl:self.club.detailDescUrl aTitle:self.club.name];
  }
}

- (void)gotoUrl:(NSString*)url aTitle:(NSString*)title
{
  UIWebViewController *webVC = [[UIWebViewController alloc] initWithNeedAdjustForiOS7:YES];
  UINavigationController *webViewNav = [[UINavigationController alloc] initWithRootViewController:webVC];
  webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
  webVC.strUrl = url;
  webVC.strTitle = title;
  
  [self.parentViewController presentModalViewController:webViewNav
                                               animated:YES];
  RELEASE_OBJ(webVC);
  RELEASE_OBJ(webViewNav);
}

- (void)goCallPhone {
  _sheetType = CALL_ACTION;
  UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSCallActionSheetTitle, nil)
                                                  delegate:self
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:LocaleStringForKey(NSCallTitle, nil)
                                         otherButtonTitles:nil];
  
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.navigationController.view];
  
  [as release];
  as = nil;
}

#pragma mark - action

- (NSString *)getSkuId {
  if (self.club.skuMsg.length > 0) {
    NSArray *list = [self.club.skuMsg componentsSeparatedByString:@"#"];
    if (list.count >= 4) {
      return (NSString *)list[0];
    }
  }
  return NULL_PARAM_VALUE;
}

- (void)doJoin2Quit:(id)sender
{
  if (!joinStatus) {
    _currentType = CLUB_JOIN_TY;
    NSString *param = nil;
    
    param = [NSString stringWithFormat:@"<host_type>%@</host_type><host_id>%@</host_id><if_admin_submit>%@</if_admin_submit><target_user_id>%@</target_user_id><target_user_type>%@</target_user_type><sku_id>%@</sku_id>",
             [AppManager instance].hostTypeValue,
             [AppManager instance].clubId,
             self.club.ifadmin,
             [AppManager instance].personId,
             [AppManager instance].userType,
             [self getSkuId]];
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:_currentType] autorelease];
    // [self.connDic setObject:connFacade forKey:url];
    [connFacade fetchGets:url];
    
    [self setRefreshFlag];
  } else {
    _alertType = GROUP_QUIT_TYPE;
    ShowAlertWithTwoButton(self,LocaleStringForKey(NSNoteTitle, nil),LocaleStringForKey(NSQuitNoteTitle, nil),LocaleStringForKey(NSCancelTitle, nil),LocaleStringForKey(NSSureTitle, nil));
  }
  
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  switch (_alertType) {
    case GROUP_QUIT_TYPE:{
      if (buttonIndex == 1)
      {
        NSString *param = nil;
        _currentType = CLUB_QUIT_TY;
        param = [NSString stringWithFormat:@"<host_type>%@</host_type><host_id>%@</host_id><target_user_id>%@</target_user_id><target_user_type>%@</target_user_type>",
                 [AppManager instance].hostTypeValue,
                 [AppManager instance].clubId,
                 [AppManager instance].personId,
                 [AppManager instance].userType];
        
        NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
        ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                        interactionContentType:_currentType] autorelease];
        // [self.connDic setObject:connFacade forKey:url];
        [connFacade fetchGets:url];
        
        [self setRefreshFlag];
        
        return;
      }
    }
      break;
  }
  
}

- (void)goClubUserList:(UIGestureRecognizer *)sender {

  Club *briefClubInfo = (Club *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                          entityName:@"Club"
                                                           predicate:[NSPredicate predicateWithFormat:@"clubId == %@", [AppManager instance].clubId]];
  
  if ([[AppManager instance].hostSupTypeValue isEqualToString:SELF_CLASS_TYPE]) {
    briefClubInfo.needPay = @(NO);
  } else {

    if (self.club.skuPrice.floatValue > 0.0f) {
      briefClubInfo.needPay = @(YES);
    } else {
      briefClubInfo.needPay = @(NO);
    }
  }
  
  SAVE_MOC(_MOC);

  GroupMemberListViewController *memberListVC = [[[GroupMemberListViewController alloc] initWithMOC:_MOC
                                                                                              group:briefClubInfo] autorelease];
  [self.navigationController pushViewController:memberListVC animated:YES];
}

- (void)goClubActivityList:(UIGestureRecognizer *)sender {
  
  ClubEventListViewController *eventListVC = [[[ClubEventListViewController alloc] initWithMOC:_MOC] autorelease];
  
  eventListVC.title = LocaleStringForKey(NSClubEventTitle, nil);
  [self.navigationController pushViewController:eventListVC animated:YES];
}

- (void)drawImage:(NSString *)imageUrl
{
  UIImage *image = nil;
  if (imageUrl && [imageUrl length] > 0 ) {
    self.url = imageUrl;
    
    image = [[WXWImageManager instance].imageCache getImage:self.url];
    if (!image) {
      ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                      interactionContentType:IMAGE_TY] autorelease];
      [connFacade fetchGets:self.url];
    }
  } else {
    image = [[UIImage imageNamed:@"groupIconDefault.png"] imageByScalingToSize:CGSizeMake(SCREEN_WIDTH, GROUP_ICON_H)];
  }
  
  if (image) {
    self.cellIconView.image = [WXWCommonUtils cutPartImage:image
                                                     width:self.cellIconView.frame.size.width
                                                    height:self.cellIconView.frame.size.height];//image;
  }
  
  [self initTableView];
}

#pragma mark - pay action
- (void)doPay {
  
  if (self.club.skuMsg && self.club.skuMsg.length > 0) {
    
    CGRect mFrame = CGRectMake(0, 0, LIST_WIDTH, self.view.bounds.size.height);
    OrderViewController *orderVC = [[[OrderViewController alloc] initWithFrame:mFrame MOC:_MOC paymentItemType:GROUP_PAYMENT_TY] autorelease];
    
    [orderVC setPayOrderId:self.club.payOrderId orderTitle:self.club.orderTitle skuMsg:self.club.skuMsg];
    
    orderVC.title = LocaleStringForKey(NSSubmitOrderTitle, nil);
    [self.navigationController pushViewController:orderVC animated:YES];
    
    
    _needReload = YES;
  } else {
    ShowAlertWithOneButton(self, LocaleStringForKey(NSNoteTitle,nil), LocaleStringForKey(NSUnpayOrderDescTitle, nil), LocaleStringForKey(NSOKTitle, nil));
  }
  
  /*
   _sheetType = PAY_ACTION;
   UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSPayActionSheetTitle, nil)
   delegate:self
   cancelButtonTitle:nil
   destructiveButtonTitle:nil
   otherButtonTitles:
   LocaleStringForKey(NSAlipayTitle, nil),LocaleStringForKey(NSUnionpayTitle, nil), nil];
   
   [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
   as.cancelButtonIndex = [as numberOfButtons] - 1;
   [as showInView:self.navigationController.view];
   
   [as release];
   as = nil;
   */
}

- (void)doAliPay {
  
  NSString *url = [NSString stringWithFormat:@"%@/event?action=order_by_online_payment&order_id=%@", [AppManager instance].hostUrl, self.club.payOrderId];
  [self gotoUrl:url aTitle:NULL_PARAM_VALUE];
  
  [self setRefreshFlag];
}

- (void)doUnionPay {
  
  _currentType = PAY_DATA_TY;
  NSString *param = [NSString stringWithFormat:@"<order_id>%@</order_id>", self.club.payOrderId];
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:_currentType] autorelease];
  [connFacade fetchGets:url];
  
  [self setRefreshFlag];
}

#pragma mark - UIActionSheetDelegate method
- (void)actionSheet:(UIActionSheet*)aSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
  switch (_sheetType) {
    case CALL_ACTION:
    {
      switch (buttonIndex) {
        case CALL_ACTION_SHEET_IDX:
        {
          NSString *phoneStr = [[NSString alloc] initWithFormat:@"tel:%@", self.club.tel];
          NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
          [[UIApplication sharedApplication] openURL:phoneURL];
          [phoneURL release];
          [phoneStr release];
          break;
        }
        case CANCEL_ACTION_SHEET_IDX:
          return;
          
        default:
          break;
      }
    }
      break;
      
    case PAY_ACTION:
    {
      switch (buttonIndex) {
        case ALIPAY_ACTION_SHEET_IDX:
        {
          [self doAliPay];
          break;
        }
          
        case UNIONPAY_ACTION_SHEET_IDX:
        {
          [self doUnionPay];
          break;
        }
          
        case CANCEL_PAY_ACTION_SHEET_IDX:
          return;
          
        default:
          break;
      }
    }
      break;
      
    default:
      break;
  }
	
}

- (void)goPay:(NSData *)result {
  self.cpView = [[[UPOMP alloc] init] autorelease];
  self.cpView.viewDelegate = self;
  [((iAlumniAppDelegate*)APP_DELEGATE).window addSubview:self.cpView.view];
  
  [self.cpView setXmlData:result];
  
  NSLog(@"message: %@", [[[NSString alloc] initWithData:result
                                               encoding:NSUTF8StringEncoding] autorelease]);
}

- (BOOL)checkPaymentRecallResult:(NSString *)result {
  if (nil == result || 0 == result.length) {
    return NO;
  }
  
  NSArray *list = [result componentsSeparatedByString:PAYMENT_RESPCODE_START_SEPARATOR];
  if (list.count == 2) {
    NSString *partResult = list[1];
    if (0 == partResult.length) {
      return NO;
    }
    
    NSArray *resultList = [partResult componentsSeparatedByString:PAYMENT_RESPCODE_END_SEPARATOR];
    if (resultList.count == 2) {
      NSString *codeStr = resultList[0];
      if (0 == codeStr.length) {
        return NO;
      }
      
      NSInteger code = codeStr.intValue;
      
      if (code != 0) {
        return NO;
      } else {
        return YES;
      }
    }
  }
  
  return NO;
}

#pragma mark - UPOMPDelegate method
-(void)viewClose:(NSData*)data {
  
  //获得返回数据并释放内存
  self.cpView.viewDelegate = nil;
  self.cpView = nil;
  
  NSString *resultStr = [[[NSString alloc] initWithData:data
                                               encoding:NSUTF8StringEncoding] autorelease];
  NSLog(@"resultStr = %@", resultStr);
  
  //以下为自定义相关操作
  if ([self checkPaymentRecallResult:resultStr]) {
    
    // refresh payment successful flag
    [self loadSponsorDetail];
    
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaymentDoneMsg, nil)
                                  msgType:SUCCESS_TY
                       belowNavigationBar:YES];
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaymentErrorMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
  
}

#pragma mark - UIWebViewDelegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
  [UIUtils showActivityView:self.view text:LocaleStringForKey(NSLoadingTitle, nil)];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
  NSString *url = [[request URL] absoluteString];
  
  if (url && [url length] > 0) {
    if ([url rangeOfString:ALIPAY_MARK].length > 0) {
      _sessionExpired = YES;
    }
  }
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  if (_sessionExpired) {
    //[((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:YES];
    //[self loadSponsorDetail];
    [self.view removeFromSuperview];
  }
  [UIUtils closeActivityView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  [UIUtils closeActivityView];
}

@end
