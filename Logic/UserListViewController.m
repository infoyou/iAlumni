//
//  UserListViewController.m
//  CEIBS
//
//  Created by Adam on 11-2-27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserListViewController.h"
#import "AdminCheckInViewController.h"
#import "ClubSearchViewController.h"
#import "ChatListViewController.h"
#import "WXWDebugLogOutput.h"
#import "UserListCell.h"
#import "Alumni.h"
#import "AlumniProfileViewController.h"
#import "Club.h"
#import "EncryptUtil.h"
#import "UIWebViewController.h"
#import "WXWNavigationController.h"
#import "DMChatViewController.h"

#define SHAKE_HEADER_HEIGHT 40.0f//85.0f

@interface UserListViewController()
@property (nonatomic, retain) Alumni *alumni;
@property (nonatomic, retain) Club *group;
@end

@implementation UserListViewController

static int iSize = 0;

@synthesize requestParam;
@synthesize pageIndex;
@synthesize alumni = _alumni;

- (id)initWithType:(WebItemType)aType
      needGoToHome:(BOOL)aNeedGoToHome
               MOC:(NSManagedObjectContext*)MOC
             group:(Club *)group
 needAdjustForiOS7:(BOOL)needAdjustForiOS7 {
  
  if (aType != SHAKE_USER_LIST_TY) {
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:NO
        needRefreshFooterView:YES
                   tableStyle:UITableViewStylePlain
                   needGoHome:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateForPushNotification:)
                                                 name:DM_REFRESH_IN_CHAT_ALUMNUS_KEY
                                               object:nil];
    
  } else {
    
    DELETE_OBJS_FROM_MOC(MOC, @"Alumni", nil);
    
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:YES
        needRefreshFooterView:YES
                   tableStyle:UITableViewStylePlain
                   needGoHome:NO];
  }
  
  
  if (self) {
		_userListType = aType;
    needGoToHome = NO;//aNeedGoToHome;
    
    self.group = group;
    
    _needAdjustForiOS7 = needAdjustForiOS7;
    
    if (_userListType == SHAKE_USER_LIST_TY) {
      [super clearPickerSelIndex2Init:3];
      [self addRefreshBtn];
      
      [AppManager instance].shakeWinnerType = INIT_VALUE_WINNER_TY;
    }
    
	}
	
	return self;
}

#pragma mark - core data
- (void)configureMOCFetchConditions {
  
  self.entityName = @"Alumni";
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"orderId" ascending:YES] autorelease];
  
  [self.descriptors addObject:dateDesc];
  
  if (_userListType == CHAT_USER_LIST_TY) {
    self.predicate = [NSPredicate predicateWithFormat:@"personId <> %@", [AppManager instance].personId];
  }
}

#pragma mark - load user list from web

- (void)updateForPushNotification:(NSNotification *)notification {
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)stopAutoRefreshUserList {
  [timer invalidate];
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = _userListType;
  if (_currentType == ALUMNI_TY || _currentType == SHAKE_USER_LIST_TY) {
    [AppManager instance].clubAdmin = NO;
  }
  
  NSString *tmpStr = [NSString stringWithFormat:@"<page>%d</page>", (self.pageIndex++)];
  NSString *param = [self.requestParam stringByReplacingOccurrencesOfString:@"<page>0</page>" withString:tmpStr];
  
  if (_currentType == SHAKE_USER_LIST_TY) {
    
    if (isFirst) {
      param = [param stringByReplacingOccurrencesOfString:@"<refresh_only>0</refresh_only>" withString:@"<refresh_only>1</refresh_only>"];
      isFirst = NO;
    }else if (forNew) {
      param = [param stringByReplacingOccurrencesOfString:[AppManager instance].shakeLocationHistory withString:[NSString stringWithFormat:@"<longitude>%f</longitude><latitude>%f</latitude>", [AppManager instance].longitude, [AppManager instance].latitude]];
    }
    
    if (_TableCellSaveValArray && _TableCellSaveValArray.count > 2) {
      // distance
      param = [param stringByReplacingOccurrencesOfString:@"<distance_scope>10</distance_scope>" withString:[NSString stringWithFormat:@"<distance_scope>%@</distance_scope>", _TableCellSaveValArray[0]]];
      
      // time
      param = [param stringByReplacingOccurrencesOfString:@"<time_scope>1000</time_scope>" withString:[NSString stringWithFormat:@"<time_scope>%@</time_scope>", _TableCellSaveValArray[1]]];
      
      // sort
      param = [param stringByReplacingOccurrencesOfString:@"<order_by_column>datetime</order_by_column>" withString:[NSString stringWithFormat:@"<order_by_column>%@</order_by_column>", _TableCellSaveValArray[2]]];
    }
  }
  
  NSString *url = [CommonUtils geneUrl:param itemType:_userListType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_userListType];
  [connFacade fetchGets:url];
}

- (void)addGoManageBtn {
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSClubAddMemberTitle, nil)
                            target:self
                            action:@selector(doManage:)];
}

- (void)addRefreshBtn {
  
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSRefreshTitle, nil)
                            target:self
                            action:@selector(doRefresh:)];
}

#pragma mark - UITableView lifecycle

- (void)backToEntrance:(id)sender {
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad {
  
	[super viewDidLoad];
  
  if (_userListType == SHAKE_USER_LIST_TY) {
    
    _toolTitleView = [[PostToolView alloc] initForShake:CGRectMake(0, 0, self.view.frame.size.width, SHAKE_HEADER_HEIGHT)
                                               topColor:COLOR(236, 232, 226)
                                            bottomColor:COLOR(223, 220, 212)
                                               delegate:self
                                       userListDelegate:self];
    
    // distance default 50km
    int distanceSize = [[AppManager instance].distanceList count];
    NSString *distanceStr = NULL_PARAM_VALUE;
    if (distanceSize > 0) {
      distanceStr = [AppManager instance].distanceList[distanceSize-2][1];
    }
    
    [_toolTitleView setBackValue:distanceStr
                            time:([AppManager instance].timeList)[0][1]
                            sort:([AppManager instance].sortList)[0][1]];
    [self.view addSubview:_toolTitleView];
    
    _tableView.frame = CGRectMake(0, _toolTitleView.frame.origin.y + _toolTitleView.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height - (_toolTitleView.frame.origin.y + _toolTitleView.frame.size.height));
    
    _TableCellShowValArray = [[NSMutableArray alloc] init];
    _TableCellSaveValArray = [[NSMutableArray alloc] init];
    for (NSUInteger i=0; i<3; i++) {
      [_TableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:i];
      [_TableCellSaveValArray insertObject:NULL_PARAM_VALUE atIndex:i];
    }
    
    // distance default 50km
    if (distanceSize > 0) {
      [_TableCellShowValArray insertObject:[AppManager instance].distanceList[distanceSize-2][1] atIndex:0];
      [_TableCellSaveValArray insertObject:[AppManager instance].distanceList[distanceSize-2][0] atIndex:0];
      
      [[WXWSystemInfoManager instance].pickerSel0IndexList insertObject:[NSString stringWithFormat:@"%d", (distanceSize-1)] atIndex:iFliterIndex];
    }
    
    // time default 1 week
    if ([AppManager instance].timeList.count > 0) {
      if (((NSArray *)([AppManager instance].timeList)[0]).count > 1) {
        [_TableCellShowValArray insertObject:[AppManager instance].timeList[0][1]
                                     atIndex:1];
        [_TableCellSaveValArray insertObject:[AppManager instance].timeList[0][0]
                                     atIndex:1];
      }
    }
    
    // sort default
    if ([AppManager instance].sortList.count > 0) {
      if (((NSArray *)([AppManager instance].sortList)[0]).count > 1) {
        [_TableCellShowValArray insertObject:([AppManager instance].sortList)[0][1] atIndex:2];
        [_TableCellSaveValArray insertObject:@"datetime" atIndex:2];
      }
    }
  }
    
}

- (void)viewWillAppear:(BOOL)animated {
  isFirst = YES;
  
  // Event checkin alumni
  if (_userListType == CHECKIN_USER_TY && [AppManager instance].isNeedReLoadUserList) {
    [CommonUtils doDelete:_MOC entityName:@"Alumni"];
    self.pageIndex = 0;
    _autoLoaded = NO;
    
    [AppManager instance].isNeedReLoadUserList = NO;
  }
  
  // Club manage alumni
  if (_userListType == CLUB_MANAGE_USER_TY && [AppManager instance].clubAdmin && ![[AppManager instance].clubSupType isEqualToString:SELF_CLASS_TYPE] && [AppManager instance].isNeedReLoadUserList) {
    [CommonUtils doDelete:_MOC entityName:@"Alumni"];
    self.pageIndex = 0;
    _autoLoaded = NO;
    
    [AppManager instance].isNeedReLoadUserList = NO;
  }
  
  if (_userListType == CHAT_USER_LIST_TY) {
    self.pageIndex = self.pageIndex-1;
    if (self.pageIndex < 0) {
      self.pageIndex = 0;
    }
    _autoLoaded = NO;
  }
	
	if (!_autoLoaded) {
		[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
	}
  
}

- (void)viewWillDisappear:(BOOL)animated {
	[UIUtils closeActivityView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
  self.alumni = nil;
  self.requestParam = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:DM_REFRESH_IN_CHAT_ALUMNUS_KEY object:nil];
  
  [NSFetchedResultsController deleteCacheWithName:nil];
	[super dealloc];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRC sections][section];
	iSize = [sectionInfo numberOfObjects];
	return iSize + 1;
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == iSize) {
    return [self drawFooterCell];
	}
  
	static NSString *kCellIdentifier = @"AlumniCell";
  
	UserListCell *cell = nil;
  
  cell = [[[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault
                              reuseIdentifier:kCellIdentifier
                       imageDisplayerDelegate:self
                       imageClickableDelegate:self
                                          MOC:_MOC] autorelease];
  
  Alumni *aAlumni = (Alumni *)[self.fetchedRC objectAtIndexPath:indexPath];
  [cell drawCell:aAlumni userListType:_userListType];
  
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIDeviceOrientationPortrait);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return USER_LIST_CELL_HEIGHT;
}

- (void)didSelectCell:(Alumni *)alumni {
  switch (_userListType) {
    case ALUMNI_TY:
      [self showAlumniDetailByLocal:alumni needAddContact:NO];
      break;
      
    case CHAT_USER_LIST_TY:
      [self goChatView:alumni];
      break;
      
    default:
      [self showAlumniDetailByNet:alumni needAddContact:YES];
      break;
  }
}

- (void)adjustNewMessageNumberForAlumni:(Alumni *)alumni {
  NSInteger allNewMsgNumber = [AppManager instance].msgNumber.intValue;
  allNewMsgNumber -= alumni.notReadMsgCount.intValue;
  if (allNewMsgNumber < 0) {
    allNewMsgNumber = 0;
  }
 
  [CommonUtils updateNewDMNumber:allNewMsgNumber];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == [[self.fetchedRC fetchedObjects] count]) {
    return;
  }
  
  Alumni *alumni = [self.fetchedRC objectAtIndexPath:indexPath];
  
  [self didSelectCell:alumni];
  
  [self adjustNewMessageNumberForAlumni:alumni];
}

#pragma mark - show alumni detail info
- (void)showAlumniDetailByNet:(Alumni*)aAlumni needAddContact:(BOOL)needAddContact
{
  /*
   UserType showType;
   showType = ALUMNI_USER_TY;
   
   if (_userListType == SHAKE_USER_LIST_TY) {
   
   showType = ALUMNI_USER_TY;
   [AppManager instance].latitude = [aAlumni.latitude doubleValue];
   [AppManager instance].longitude = [aAlumni.longitude doubleValue];
   [AppManager instance].defaultPlace = aAlumni.shakePlace;
   [AppManager instance].defaultDistance = aAlumni.distance;
   [AppManager instance].defaultThing = aAlumni.shakeThing;
   }
   
   */
  
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC alumni:aAlumni userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)showAlumniDetailByLocal:(Alumni*)aAlumni needAddContact:(BOOL)needAddContact
{
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC alumni:aAlumni userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType{
  
  switch (contentType) {
      
    case CLUB_MANAGE_USER_TY:
    case CLUB_MANAGE_QUERY_USER_TY:
    case CHECKIN_USER_TY:
    case SIGNUP_USER_TY:
    case WINNER_USER_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        [self resetUIElementsForConnectDoneOrFailed];
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
      }
      
      break;
    }
      
    case POST_LIKE_USER_LIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        [self resetUIElementsForConnectDoneOrFailed];
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
      }
      
      break;
    }
      
    case CHAT_USER_LIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        [self resetUIElementsForConnectDoneOrFailed];
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
      }
      
      break;
    }
      
    case SHAKE_USER_LIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [_toolTitleView setWinnerInfo:[AppManager instance].shakeWinnerInfo
                           winnerType:[AppManager instance].shakeWinnerType];
        
        [self resetUIElementsForConnectDoneOrFailed];
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
      }
      
      break;
    }
      
    case ALUMNI_TY:
    {
      if ([XMLParser parserResponseXml:[EncryptUtil TripleDESforNSData:result encryptOrDecrypt:kCCDecrypt]
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        [self resetUIElementsForConnectDoneOrFailed];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
      }
      break;
    }
      
    default:
      break;
  }
  
  [self refreshTable];
  
  _autoLoaded = YES;
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - action
- (void)doGoHomePage:(id)sender {
  //    [self.navigationController popToRootViewControllerAnimated:YES];
  [((iAlumniAppDelegate*)APP_DELEGATE) goHomePage];
}

- (void)doManage:(id)sender
{
  [AppManager instance].eventId = NULL_PARAM_VALUE;
  ClubSearchViewController *mClubSearchVC = [[ClubSearchViewController alloc] initWithMOC:_MOC group:self.group];
  
  UINavigationController *mNC = [[UINavigationController alloc] initWithRootViewController:mClubSearchVC];
  mNC.navigationBar.tintColor = TITLESTYLE_COLOR;
  [self presentModalViewController:mNC animated:NO];
  RELEASE_OBJ(mClubSearchVC);
  RELEASE_OBJ(mNC);
}

- (void)doRefresh:(id)sender
{
  [self getCurrentLocationInfoIfNecessary];
}

- (void)doSelect
{
  [CommonUtils doDelete:_MOC entityName:@"Alumni"];
  self.pageIndex = 0;
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - UIPickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  pickSel0Index = row;
  isPickSelChange = YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  return [_PickData count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  return _PickData[row];
}

- (void)setDropDownValueArray:(int)type
{
  [NSFetchedResultsController deleteCacheWithName:nil];
  iFliterIndex = type;
  self.descriptors = [NSMutableArray array];
  
  self.DropDownValArray = [[[NSMutableArray alloc] init] autorelease];
  switch (type) {
      
    case 0:
    {
      self.DropDownValArray = [AppManager instance].distanceList;
    }
      break;
      
    case 1:
    {
      self.DropDownValArray = [AppManager instance].timeList;
    }
      break;
      
    case 2:
    {
      self.DropDownValArray = [AppManager instance].sortList;
    }
      break;
  }
  
  [super setPopView];
}

-(void)onPopCancle:(id)sender {
  [super onPopCancle];
  
  [_TableCellShowValArray removeObjectAtIndex:iFliterIndex];
  [_TableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:iFliterIndex];
  
  [_TableCellSaveValArray removeObjectAtIndex:iFliterIndex];
  [_TableCellSaveValArray insertObject:NULL_PARAM_VALUE atIndex:iFliterIndex];
  
  [_tableView reloadData];
}

-(void)onPopOk:(id)sender {
  
  [super onPopSelectedOk];
  int iPickSelectIndex = [super pickerList0Index];
  
  [self setTableCellVal:iFliterIndex aShowVal:(self.DropDownValArray)[iPickSelectIndex][RECORD_NAME_IDX]
               aSaveVal:(self.DropDownValArray)[iPickSelectIndex][RECORD_ID_IDX] isFresh:YES];
  
  [self doSelect];
}

-(void)setTableCellVal:(int)index aShowVal:(NSString*)aShowVal aSaveVal:(NSString*)aSaveVal isFresh:(BOOL)isFresh
{
  [_TableCellShowValArray removeObjectAtIndex:index];
  [_TableCellShowValArray insertObject:aShowVal atIndex:index];
  
  [_TableCellSaveValArray removeObjectAtIndex:index];
  [_TableCellSaveValArray insertObject:aSaveVal atIndex:index];
  
  [_toolTitleView setBackValue:_TableCellShowValArray[0]
                          time:_TableCellShowValArray[1]
                          sort:_TableCellShowValArray[2]];
  
}

#pragma mark - ECFilterListDelegate
- (void)showDistanceList
{
  [self setDropDownValueArray:0];
}

- (void)showTimeList
{
  [self setDropDownValueArray:1];
}

- (void)showSortList
{
  [self setDropDownValueArray:2];
}

#pragma mark - location result
- (void)locationResult:(LocationResultType)type {
  
  [UIUtils closeActivityView];
  
  switch (type) {
    case LOCATE_SUCCESS_TY:
    {
      _reloading = YES;
      [self loadListData:TRIGGERED_BY_SCROLL forNew:YES];
      
      if (_toolTitleView) {
        [_toolTitleView animationGift];
      }
    }
      break;
      
    case LOCATE_FAILED_TY:
    {
      [UIUtils showNotificationOnTopWithMsg:@"定位失败"
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      
    }
      break;
      
    default:
      break;
  }
  
}

#pragma mark - ECClickableElementDelegate method
- (void)doChat:(Alumni*)aAlumni
{
  
  [self goActionSheet];
  self.alumni = aAlumni;
}

- (void)openProfile:(NSString*)userId userType:(NSString*)userType
{
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                    personId:userId
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)goChatView:(Alumni*)aAlumni {
  
  DMChatViewController *chatVC = [[[DMChatViewController alloc] initWithMOC:_MOC
                                                                     alumni:aAlumni] autorelease];
  [self.navigationController pushViewController:chatVC animated:YES];
  
//  [CommonUtils doDelete:_MOC entityName:@"Chat"];
//  ChatListViewController *chartVC = [[ChatListViewController alloc] initWithMOC:_MOC alumni:aAlumni];
//  [self.navigationController pushViewController:chartVC animated:YES];
//  RELEASE_OBJ(chartVC);

}

- (void)goActionSheet {
  
  UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSActionSheetTitle, nil)
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:LocaleStringForKey(NSChatActionSheetTitle, nil)
                                          otherButtonTitles:nil] autorelease];
  
  [as addButtonWithTitle:LocaleStringForKey(NSProfileActionSheetTitle, nil)];
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.navigationController.view];
}

- (void)showWinnersAndAwards {
  
  NSString *url = [NSString stringWithFormat:@"%@event?action=page_load&page_name=shake_it_off_wap&locale=%@&user_id=%@&plat=%@&version=%@&sessionId=%@&person_id=%@&channel=%d&user_name=%@&user_type=%@&class_id=%@&class_name=%@&latitude=%f&longitude=%f&winner_type=%d",
                   [AppManager instance].hostUrl,
                   [WXWSystemInfoManager instance].currentLanguageDesc,
                   [AppManager instance].userId,
                   PLATFORM,
                   VERSION,
                   [AppManager instance].sessionId,
                   [AppManager instance].personId,
                   [AppManager instance].releaseChannelType,
                   [AppManager instance].userName,
                   [AppManager instance].userType,
                   [AppManager instance].classGroupId,
                   [AppManager instance].className,
                   [AppManager instance].latitude,
                   [AppManager instance].longitude,
                   [AppManager instance].shakeWinnerType];
  
  
  UIWebViewController *webVC = [[[UIWebViewController alloc] initWithNeedAdjustForiOS7:_needAdjustForiOS7] autorelease];
  WXWNavigationController *webViewNav = [[[WXWNavigationController alloc] initWithRootViewController:webVC] autorelease];
  //webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
  webVC.strUrl = url;
  
  [self.parentViewController presentModalViewController:webViewNav
                                               animated:YES];
}

#pragma mark - Action Sheet
- (void)actionSheet:(UIActionSheet*)aSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case CHAT_SHEET_IDX:
		{
      [self goChatView:self.alumni];
      return;
		}
      
		case DETAIL_SHEET_IDX:
      [self didSelectCell:self.alumni];
			return;
			
    case CANCEL_SHEET_IDX:
      return;
      
		default:
			break;
	}
}

@end
