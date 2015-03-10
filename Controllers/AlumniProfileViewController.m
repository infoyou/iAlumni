//
//  AlumniProfileViewController.m
//  iAlumni
//
//  Created by Adam on 12-11-13.
//
//

#import "AlumniProfileViewController.h"
#import "CommonUtils.h"
#import "TextConstants.h"
#import "AlumniProfileAvatarView.h"
#import "Alumni.h"
#import "EmailListViewController.h"
#import "MapViewController.h"
#import "WXWNavigationController.h"
#import "ChatListViewController.h"
#import "ECHandyAvatarBrowser.h"
#import "FavoriteAlumniResultView.h"
#import "WithMeLinkListViewController.h"
#import "RecommendAlumniListViewController.h"
#import "AlumniJoinedGroupListViewController.h"
#import "AppManager.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "EncryptUtil.h"
#import "WXWLabel.h"
#import "DMChatViewController.h"

#define AVATAR_VIEW_NO_TOOL_NO_MAP_HEIGHT    100.0f//155.0f
#define AVATAR_VIEW_WITH_TOOL_NO_MAP_HEIGHT  200.0f//255.0f

#define AVATAR_VIEW_NO_TOOL_WITH_MAP_HEIGHT  260.0f//315.0f
#define AVATAR_VIEW_WITH_TOOL_AND_MAP_HEIGHT 300.0f//355.0f

#define TOOL_BUTTON_HEIGHT            30.0f

#define LINK_ENTRANCE_HEIGHT          50.0f

#define AVATAR_DIAMETER               67.0f

#define FAVORITE_RESULT_VIEW_HEIGHT   280.0f//220.0f

#define FOOTER_HEIGHT                 40.0f

enum {
  GROUP_SEC,
  BASE_INFO_SEC,
  CONTACT_INFO_SEC,
};

enum {
  SELECT_PHONE_TY,
  SELECT_MOBILE_TY,
  ADD_TO_AB_TY,
  UNFAVORITE_TY,
};

enum {
  ADD_NEW_IDX,
  ADD_EXISTING_IDX,
};

enum {
  GROUP_SEC_CELL,
};

enum {
  BASE_SEC_CLASS_CELL,
  BASE_SEC_JOBTITLE_CELL,
  BASE_SEC_COMPANY_CELL,
  BASE_SEC_ADDRESS_CN_CELL,
  BASE_SEC_ADDRESS_EN_CELL,
  BASE_SEC_CITY_CELL,
  BASE_SEC_PROVINCE_CELL,
  BASE_SEC_COUNTRY_CN_CELL,
  BASE_SEC_COUNTRY_EN_CELL,
};

enum {
  CONTACT_SEC_TEL_CELL,
  CONTACT_SEC_FAX_CELL,
  CONTACT_SEC_EMAIL_CELL,
  CONTACT_SEC_MOBILE_CELL,
  CONTACT_SEC_SINA_CELL,
  CONTACT_SEC_WECHAT_CELL,
  CONTACT_SEC_LINKEDIN_CELL,
};

#define SECTION_COUNT           3
#define GROUP_SEC_CELL_COUNT    1
#define BASE_SEC_CELL_COUNT     9
#define CONTACT_SEC_CELL_COUNT  7

@interface AlumniProfileViewController ()
@property (nonatomic, retain) Alumni *alumni;
@property (nonatomic, copy) NSString *personId;
@property (nonatomic, retain) UIImage *avatar;
@end

@implementation AlumniProfileViewController

#pragma mark - load user detail
- (void)loadUserDetails
{
  
  WebItemType contentType = 0;
  
  NSString *url = nil;
  switch (_userType) {
    case ALUMNI_USER_TY:
    {
      url = [NSString stringWithFormat:@"%@%@&personId=%@&username=%@&sessionId=%@&userType=%d&active_personId=%@", [AppManager instance].hostUrl, ALUMNI_DETAIL_URL, self.personId, [AppManager instance].userId, [AppManager instance].sessionId, _userType, [AppManager instance].personId];
      
      contentType = ALUMNI_QUERY_DETAIL_TY;
    }
      break;
      
    case NONALUMNI_USER_TY:
    {
      
      contentType = CLUB_USER_DETAIL_TY;
      
      NSString *param = [NSString stringWithFormat:@"<host_id>%@</host_id><host_type>%@</host_type><target_user_id>%@</target_user_id><target_user_type>%d</target_user_type><is_admin>%@</is_admin><event_id>%@</event_id>", [AppManager instance].clubId, [AppManager instance].clubType, self.personId, _userType, [AppManager instance].clubAdmin == YES ? @"1" : @"0", [AppManager instance].eventId];
      url = [CommonUtils geneUrl:param itemType:contentType];
    }
      break;
      
    default:
      break;
  }
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:contentType];
  
  [connFacade fetchGets:url];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"Alumni";
  
  self.predicate = [NSPredicate predicateWithFormat:@"(personId == %@)", self.alumni.personId];
}

#pragma mark - fetch avatar
- (void)saveAvatar:(UIImage *)avatar {
  
  self.avatar = avatar;
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
         personId:(NSString *)personId
         userType:(UserType)userType {
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                                          holder:nil
                                backToHomeAction:nil
                           needRefreshHeaderView:NO
                           needRefreshFooterView:NO
                                      tableStyle:UITableViewStyleGrouped
                                      needGoHome:NO];
  
  if (self) {
    self.personId = personId;
    
    _userType = userType;
    
    _hideLocation = NO;
  }
  
  return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           alumni:(Alumni *)alumni
         userType:(UserType)userType {
  
  self = [self initWithMOC:MOC
                  personId:alumni.personId
                  userType:userType];
  if (self) {
    self.alumni = alumni;
    
    _hideLocation = NO;
  }
  
  return self;
}

- (id)initHideLocationWithMOC:(NSManagedObjectContext *)MOC
                       alumni:(Alumni *)alumni
                     userType:(UserType)userType {
  self = [self initWithMOC:MOC alumni:alumni userType:userType];
  if (self) {
    _hideLocation = YES;
  }
  return self;
}

- (void)dealloc {
  
  self.alumni = nil;
  
  self.personId = nil;
  
  self.avatar = nil;
  
  RELEASE_OBJ(_userSignInInfoView);
  
  [super dealloc];
}

- (BOOL)needToolView {
  if ([[AppManager instance].personId isEqualToString:self.personId]) {
    return NO;
  } else {
    return YES;
  }
}

- (BOOL)needMapView {
  if ((self.alumni.latitude.doubleValue > 0 && self.alumni.longitude.doubleValue > 0) &&
      ![self.alumni.personId isEqualToString:[AppManager instance].personId] && !_hideLocation) {
    return YES;
  } else {
    return NO;
  }
}

- (void)initTableHeaderView {
  
  CGFloat height = 0;
  
  if ([self needToolView]) {
    
    if ([self needMapView]) {
      height = AVATAR_VIEW_WITH_TOOL_AND_MAP_HEIGHT;
    } else {
      height = AVATAR_VIEW_WITH_TOOL_NO_MAP_HEIGHT;
    }
    
  } else {
    
    if ([self needMapView]) {
      height = AVATAR_VIEW_NO_TOOL_WITH_MAP_HEIGHT;
    } else {
      height = AVATAR_VIEW_NO_TOOL_NO_MAP_HEIGHT;
    }
  }
  
  _avatarView = [[[AlumniProfileAvatarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)
                                                            MOC:_MOC
                                                       personId:self.personId
                                       clickableElementDelegate:self
                                                  profileHolder:self
                                               saveAvatarAction:@selector(saveAvatar:)
                                                   hideLocation:_hideLocation] autorelease];
  
  _tableView.tableHeaderView = _avatarView;
}

- (void)initSignInInfoView {
  if (nil == _userSignInInfoView) {
    _userSignInInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FOOTER_HEIGHT)];
    
    _signInInfoLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                              textColor:BASE_INFO_COLOR
                                            shadowColor:TRANSPARENT_COLOR
                                                   font:BOLD_FONT(11)] autorelease];
    [_userSignInInfoView addSubview:_signInInfoLabel];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (CURRENT_OS_VERSION >= IOS7) {
    _tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
  }
  
  [self initTableHeaderView];
  
  self.view.backgroundColor = COLOR(229, 229, 229);
  _tableView.backgroundColor = COLOR(229, 229, 229);
  
  [self initSignInInfoView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_autoLoaded) {
    [self loadUserDetails];
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - arrange views
- (void)arrangeProfileBio {
  
  CGSize size = [self.alumni.profile sizeWithFont:BOLD_FONT(13)
                                constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     _avatarView.frame = CGRectMake(_avatarView.frame.origin.x,
                                                    _avatarView.frame.origin.y,
                                                    _avatarView.frame.size.width,
                                                    _avatarView.frame.size.height + size.height);
                     
                     _tableView.tableHeaderView = _avatarView;
                     
                     [_avatarView arrangeToolViews];
                   }
                   completion:^(BOOL finished){
                     [_avatarView arrangeProfileBio];
                     
                     [_tableView reloadData];
                   }];
  
}

- (void)updateBadges {
  [_avatarView updateBadges];
}

- (void)stopSping {
  [_avatarView stopSpingForSuccess:NO];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case FAVORITE_ALUMNI_TY:
      [_avatarView startSpinView];
      break;
      
    case ALUMNI_QUERY_DETAIL_TY:
    case CLUB_USER_DETAIL_TY:
    {
      [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
                blockCurrentView:YES];
      break;
    }
      
    default:
      break;
  }
  
  [super connectStarted:url contentType:contentType];
}

- (void)arrangeAfterAlumniInfoLoaded:(NSString *)personId needRefreshHeader:(BOOL)needRefreshHeader {
  self.alumni = (Alumni *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                 entityName:@"Alumni"
                                                  predicate:[NSPredicate predicateWithFormat:@"(personId == %@)", personId]];
  
  if (needRefreshHeader) {
    // set loaded entity values to header view
    [_avatarView refreshAfterAlumniLoaded:self.alumni];
  }
  
  if (self.alumni.profile && self.alumni.profile.length > 0) {
    [self arrangeProfileBio];
  } else {
    
    [_tableView reloadData];
  }
  
  // update sign in info
  if (self.alumni.lastSignInTime.length == 0 && self.alumni.platInfo.length > 0) {
    
    _signInInfoLabel.text = self.alumni.platInfo;

    
  } else if (self.alumni.lastSignInTime.length > 0 && self.alumni.platInfo.length > 0) {
    _signInInfoLabel.text = STR_FORMAT(LocaleStringForKey(NSUserSignInInfoMsg, nil), self.alumni.lastSignInTime, self.alumni.platInfo);
  }
  
  if (_signInInfoLabel.text.length > 1) {
    CGSize size = [CommonUtils sizeForText:_signInInfoLabel.text
                                      font:_signInInfoLabel.font];
    _signInInfoLabel.frame = CGRectMake((self.view.frame.size.width - size.width)/2.0f, (FOOTER_HEIGHT - size.height)/2.0f, size.width, size.height);
  }
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  [UIUtils closeActivityView];
  
  switch (contentType) {
      
    case ALUMNI_QUERY_DETAIL_TY:
    case CLUB_USER_DETAIL_TY:
    {
      NSData *decryptedData = [EncryptUtil TripleDESforNSData:result encryptOrDecrypt:kCCDecrypt];
      if ([XMLParser parserResponseXml:decryptedData
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        _autoLoaded = YES;
        
        if (self.alumni) {
          [self arrangeAfterAlumniInfoLoaded:self.alumni.personId needRefreshHeader:NO];
        } else {
          [self arrangeAfterAlumniInfoLoaded:self.personId needRefreshHeader:YES];
        }
        
        /*
         if (self.alumni) {
         
         self.alumni = (Alumni *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
         entityName:@"Alumni"
         predicate:[NSPredicate predicateWithFormat:@"(personId == %@)", self.alumni.personId]];
         
         if (self.alumni.profile && self.alumni.profile.length > 0) {
         [self arrangeProfileBio];
         } else {
         
         [_tableView reloadData];
         }
         } else {
         
         // fetch alumni entity just loaded
         self.alumni = (Alumni *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
         entityName:@"Alumni"
         predicate:[NSPredicate predicateWithFormat:@"(personId == %@)", self.personId]];
         // set loaded entity values to header view
         [_avatarView refreshAfterAlumniLoaded:self.alumni];
         
         if (self.alumni.profile && self.alumni.profile.length > 0) {
         [self arrangeProfileBio];
         }
         [_tableView reloadData];
         }
         */
        
        [self updateFavoriteStatusWithType:self.alumni.relationshipType.intValue];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSGetUserDetialFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      [_avatarView updateBadges];
      
      break;
    }
      
    case FAVORITE_ALUMNI_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        self.alumni.relationshipType = @(_selectedRelationshipType);
        SAVE_MOC(_MOC);
        
        [_avatarView updateFavoriteStatusWithType:_selectedRelationshipType];
        
        [_avatarView stopSpingForSuccess:YES];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      break;
    }
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  NSString *message = nil;
  
  switch (contentType) {
      
    case ALUMNI_QUERY_DETAIL_TY:
    case CLUB_USER_DETAIL_TY:
    {
      message = LocaleStringForKey(NSGetUserDetialFailedMsg, nil);
      
      break;
    }
      
    case FAVORITE_ALUMNI_TY:
    {
      message = LocaleStringForKey(NSActionFaildMsg, nil);
      
      [_avatarView stopSpingForSuccess:NO];
      break;
    }
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = message;
  }
  
  [super connectFailed:error
                   url:url
           contentType:contentType];
}

#pragma mark - ECClickableElementDelegate methods
- (void)openKnownAlumnus {
  
  RecommendAlumniListViewController *relationshipVC = [[[RecommendAlumniListViewController alloc] initWithMOC:_MOC
                                                                                                     listType:_userType alumniPersonId:self.alumni.personId] autorelease];
  
  relationshipVC.title = LocaleStringForKey(NSMaybeConnectedFriendsTitle, nil);
  [self.navigationController pushViewController:relationshipVC animated:YES];
}

- (void)openWithMeConnections {
  WithMeLinkListViewController *withMeLinkListVC = [[[WithMeLinkListViewController alloc] initWithMOC:_MOC] autorelease];
  
  withMeLinkListVC.title = LocaleStringForKey(NSWithMeConnectionTitle, nil);
  [self.navigationController pushViewController:withMeLinkListVC animated:YES];
}

- (void)showBigPhoto:(NSString *)url {
  CGRect smallAvatarFrame = CGRectMake(14,
                                       14, AVATAR_DIAMETER, AVATAR_DIAMETER);
  
  ECHandyAvatarBrowser *avatarBrowser = [[[ECHandyAvatarBrowser alloc] initWithFrame:CGRectMake(0, 0,
                                                                                                self.view.frame.size.width,
                                                                                                self.view.frame.size.height)
                                                                              imgUrl:url
                                                                     imageStartFrame:smallAvatarFrame
                                                              imageDisplayerDelegate:self] autorelease];
  [self.view addSubview:avatarBrowser];
}

- (void)openTraceMap {
  MapViewController *mapVC = [[[MapViewController alloc] initWithLatitude:self.alumni.latitude.doubleValue
                                                                longitude:self.alumni.longitude.doubleValue
                                                     allowLaunchGoogleMap:NO] autorelease];
  
  WXWNavigationController *navVC = [[[WXWNavigationController alloc] initWithRootViewController:mapVC] autorelease];
  [self.navigationController presentModalViewController:navVC animated:YES];
}

- (void)sendDirectMessage {
  
  DMChatViewController *chatVC = [[[DMChatViewController alloc] initWithMOC:_MOC
                                                                     alumni:self.alumni] autorelease];
  [self.navigationController pushViewController:chatVC animated:YES];

  
  /*
  DELETE_OBJS_FROM_MOC(_MOC, @"Chat", nil);
  
  ChatListViewController *chartVC = [[[ChatListViewController alloc] initWithMOC:_MOC
                                                                          alumni:self.alumni] autorelease];
  [self.navigationController pushViewController:chartVC animated:YES];
   */
}

- (void)addToAddressbook {
  
  //    NSMutableArray *groupNames = [[[NSMutableArray alloc] init] autorelease];
  //    ABAddressBookRef addressbook = ABAddressBookCreate();
  //    NSArray *array = (NSArray *)ABAddressBookCopyArrayOfAllGroups(addressbook);
  //    for (int i = 0 ; i < [array count]; i++)
  //    {
  //        ABRecordRef group = [array objectAtIndex:i];
  //        CFTypeRef groupName = ABRecordCopyValue(group, kABGroupNameProperty);
  //        NSString *groupNameStr = [NSString stringWithFormat:@"%@", (NSString *)groupName];
  //        NSLog(@"groupNames is %@", groupNameStr);
  //        [groupNames addObject:groupNameStr];
  //        CFRelease(groupName);
  //    }
  
  //    CFErrorRef error;
  //    ABRecordRef group = ABGroupCreate();
  //    ABRecordSetValue(group, kABGroupNameProperty,@"new group2", &error);
  //    ABAddressBookAddRecord(addressbook, group, &error);
  //    ABAddressBookSave(addressbook, &error);
  
  ABAddressBookRef addressbook = ABAddressBookCreate();
  ABRecordRef person = [CommonUtils prepareContactData:self.alumni];
  UIImage * img = self.avatar;
  NSData *dataRef = UIImagePNGRepresentation(img);
  ABPersonSetImageData(person, (CFDataRef)dataRef, nil);
  ABAddressBookAddRecord(addressbook, person, nil);
  //    ABAddressBookSave(addressbook, &error);
  CFRelease(addressbook);
  
  ABUnknownPersonViewController *unKnownPersonDetail = [[[ABUnknownPersonViewController alloc] init] autorelease];
  unKnownPersonDetail.unknownPersonViewDelegate = self;
  
  // initialize for create/add
  unKnownPersonDetail.displayedPerson = person;
  unKnownPersonDetail.allowsAddingToAddressBook = YES;
  unKnownPersonDetail.title = LocaleStringForKey(NSAddContactTitle, nil);
  
  // Back Button
  unKnownPersonDetail.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSBackTitle, nil)
                                                                                           style:UIBarButtonItemStyleBordered
                                                                                          target:self
                                                                                          action:@selector(backFromContact:)] autorelease];
  WXWNavigationController *nav = [[[WXWNavigationController alloc] initWithRootViewController:unKnownPersonDetail] autorelease];
  [self presentModalViewController:nav animated:YES];
  
}

- (void)changeSaveStatus {
  [self showFavoriteResult];
}

#pragma mark - favorite alumni
- (void)updateFavoriteStatusWithType:(AlumniRelationshipType)relationType {
  
  [_avatarView updateFavoriteStatusWithType:relationType];
}

- (void)closeFavoriteActionView {
  [self dismissModalQuickView];
}

- (void)showFavoriteResult {
  
  FavoriteAlumniResultView *resultView = [[[FavoriteAlumniResultView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FAVORITE_RESULT_VIEW_HEIGHT)
                                                                                      MOC:_MOC
                                                                                   holder:self
                                                                              closeAction:@selector(closeFavoriteActionView)
                                                                           favoriteAction:@selector(afterFavoriteAlumni:)
                                                                   imageDisplayerDelegate:self
                                                                   connectTriggerDelegate:self
                                                                                   alumni:self.alumni] autorelease];
  
  [self presentModalQuickView:resultView];
}

- (void)afterFavoriteAlumni:(NSNumber *)currentRelationshipType {
  
  // save the selected relationship type
  _selectedRelationshipType = currentRelationshipType.intValue;
  
  _currentType = FAVORITE_ALUMNI_TY;
  
  NSString *param = [NSString stringWithFormat:@"<favorites>%@</favorites><target_user_id>%@</target_user_id>", currentRelationshipType, self.alumni.personId];
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  
  [connFacade asyncGet:url showAlertMsg:YES];
  
  [self dismissModalQuickView];
}

#pragma mark - back from contact
- (void)backFromContact:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - draw cells
- (CGFloat)groupInfoCellHeight:(NSIndexPath *)indexPath {
  
  NSString *title = [NSString stringWithFormat:LocaleStringForKey(NSWhoJoinedGroupTitle, nil), self.alumni.name];
  
  return [self calculateCommonCellHeightWithTitle:title
                                          content:nil
                                        indexPath:indexPath
                                        clickable:YES];
}

- (CGFloat)classCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSClassTitle, nil)
                                          content:self.alumni.classGroupName
                                        indexPath:indexPath
                                        clickable:NO];
  
}

- (CGFloat)jobTitleCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSPositionTitle, nil)
                                          content:self.alumni.jobTitle
                                        indexPath:indexPath
                                        clickable:NO];
  
}

- (CGFloat)companyCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSCompanyTitle, nil)
                                          content:self.alumni.companyName
                                        indexPath:indexPath
                                        clickable:NO];
  
}

- (CGFloat)cnAddressCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSCompanyAddressTitle, nil)
                                          content:self.alumni.companyAddressC
                                        indexPath:indexPath
                                        clickable:NO];
  
}

- (CGFloat)enAddressCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:[NSString stringWithFormat:@"%@ (en)", LocaleStringForKey(NSCompanyAddressTitle, nil)]
                                          content:self.alumni.companyAddressE
                                        indexPath:indexPath
                                        clickable:NO];
  
}

- (CGFloat)cityCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSCompanyCityTitle, nil)
                                          content:self.alumni.companyCity
                                        indexPath:indexPath
                                        clickable:NO];
  
}

- (CGFloat)provinceCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSCompanyProvinceTitle, nil)
                                          content:self.alumni.companyProvince
                                        indexPath:indexPath
                                        clickable:NO];
  
}

- (CGFloat)cnCountryCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSCountryTitle, nil)
                                          content:self.alumni.companyCountryC
                                        indexPath:indexPath
                                        clickable:NO];
}

- (CGFloat)enCountryCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:[NSString stringWithFormat:@"%@ (en)", LocaleStringForKey(NSCountryTitle, nil)]
                                          content:self.alumni.companyCountryE
                                        indexPath:indexPath
                                        clickable:NO];
}

- (CGFloat)telCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSCompanyPhoneTitle, nil)
                                          content:self.alumni.companyPhone
                                        indexPath:indexPath
                                        clickable:YES];
  
}

- (CGFloat)faxCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSCompanyFaxTitle, nil)
                                          content:self.alumni.companyFax
                                        indexPath:indexPath
                                        clickable:NO];
  
}

- (CGFloat)emailCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSEmailTitle, nil)
                                          content:self.alumni.email
                                        indexPath:indexPath
                                        clickable:YES];
}

- (CGFloat)mobileCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSMobileTitle, nil)
                                          content:self.alumni.phoneNumber
                                        indexPath:indexPath
                                        clickable:YES];
  
}

- (CGFloat)sinaCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSSinaWeiboTitle, nil)
                                          content:self.alumni.sina
                                        indexPath:indexPath
                                        clickable:NO];
}

- (CGFloat)wechatCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSWeixinTitle, nil)
                                          content:self.alumni.weixin
                                        indexPath:indexPath
                                        clickable:NO];
  
}

- (CGFloat)linkedinCellHeight:(NSIndexPath *)indexPath {
  
  return [self calculateCommonCellHeightWithTitle:@"Linkedin"
                                          content:self.alumni.linkedin
                                        indexPath:indexPath
                                        clickable:NO];
}

#pragma mark - user selection actions

- (void)displayJoinedGroups {
  AlumniJoinedGroupListViewController *joinedGroupsVC = [[[AlumniJoinedGroupListViewController alloc] initWithMOC:_MOC alumniPersonId:self.alumni.personId userType:self.alumni.userType] autorelease];
  joinedGroupsVC.title = LocaleStringForKey(NSJoinedGroupTitle, nil);
  [self.navigationController pushViewController:joinedGroupsVC animated:YES];
}

- (void)selectPhoneCell {
  if (self.alumni.companyPhone && [self.alumni.companyPhone length]>1) {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.alumni.companyPhone]]]) {
      UIActionSheet *mSheet = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSCallActionSheetTitle, nil)
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:LocaleStringForKey(NSCallTitle, nil)
                                                  otherButtonTitles:nil] autorelease];
      
      [mSheet addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
      mSheet.cancelButtonIndex = [mSheet numberOfButtons] - 1;
      [mSheet showInView:self.navigationController.view];
      
      _asOwnerType = SELECT_PHONE_TY;
    } else {
      [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCannotCallMsg, nil)
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
    }
  }
}

- (void)sendEmail:(NSString *)email {
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *mailComposeVC = [[[MFMailComposeViewController alloc] init] autorelease];
    
    mailComposeVC.mailComposeDelegate = self;
    [mailComposeVC setToRecipients:@[email]];
    [self presentModalViewController:mailComposeVC animated:YES];
    
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCannotSendEmailMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
}

- (void)selectEmailCell {
  
  if (self.alumni.email && self.alumni.email.length > 1) {
    if ([self.alumni.email rangeOfString:EMAIL_SEPARATOR].length > 0) {
      EmailListViewController *emailListVC = [[[EmailListViewController alloc] initWithEmails:self.alumni.email] autorelease];
      emailListVC.title = LocaleStringForKey(NSEmailTitle, nil);
      [self.navigationController pushViewController:emailListVC animated:YES];
    } else {
      [self sendEmail:self.alumni.email];
    }
  }
}

- (void)selectMobileCell {
  
  if (self.alumni.phoneNumber && [self.alumni.phoneNumber length] > 1) {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.alumni.phoneNumber]]]) {
      
      UIActionSheet *mSheet = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSCallActionSheetTitle, nil)
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:LocaleStringForKey(NSCallTitle, nil)
                                                  otherButtonTitles:nil] autorelease];
      
      [mSheet addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
      mSheet.cancelButtonIndex = [mSheet numberOfButtons] - 1;
      [mSheet showInView:self.navigationController.view];
      
      _asOwnerType = SELECT_MOBILE_TY;
      
    } else {
      [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCannotCallMsg, nil)
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
    }
  }
}

#pragma mark - ABUnknownPersonViewControllerDelegate method

- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownCardViewController didResolveToPerson:(ABRecordRef)person {
  [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController
shouldPerformDefaultActionForPerson:(ABRecordRef)person
                           property:(ABPropertyID)property
                         identifier:(ABMultiValueIdentifier)identifier {
  return YES;
}

#pragma mark - MFMailComposeViewControllerDelegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
  switch (result)
	{
		case MFMailComposeResultCancelled:
			
			break;
		case MFMailComposeResultSaved:
			
			break;
		case MFMailComposeResultSent:
			
			break;
		case MFMailComposeResultFailed:
			
			break;
		default:
			
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (_asOwnerType) {
    case SELECT_PHONE_TY:
      if (buttonIndex == CALL_ACTION_SHEET_IDX) {
        NSString *phoneStr = [NSString stringWithFormat:@"tel:%@", self.alumni.companyPhone];
        NSURL *phoneURL = [[[NSURL alloc] initWithString:phoneStr] autorelease];
        [[UIApplication sharedApplication] openURL:phoneURL];
      }
      
      break;
      
    case SELECT_MOBILE_TY:
    {
      if (buttonIndex == CALL_ACTION_SHEET_IDX) {
        NSString *phoneStr = [NSString stringWithFormat:@"tel:%@", self.alumni.phoneNumber];
        NSURL *phoneURL = [[[NSURL alloc] initWithString:phoneStr] autorelease];
        [[UIApplication sharedApplication] openURL:phoneURL];
      }
      
      break;
    }
      
    default:
      break;
  }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case GROUP_SEC:
      return GROUP_SEC_CELL_COUNT;
      
    case BASE_INFO_SEC:
      return BASE_SEC_CELL_COUNT;
      
    case CONTACT_INFO_SEC:
      return CONTACT_SEC_CELL_COUNT;
      
    default:
      return 0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
      
    case GROUP_SEC:
      switch (indexPath.row) {
        case GROUP_SEC_CELL:
          return [self groupInfoCellHeight:indexPath];
          
        default:
          return 0;
      }
      
    case BASE_INFO_SEC:
      switch (indexPath.row) {
        case BASE_SEC_CLASS_CELL:
          
          return [self classCellHeight:indexPath];
          
        case BASE_SEC_JOBTITLE_CELL:
          
          return [self jobTitleCellHeight:indexPath];
          
        case BASE_SEC_COMPANY_CELL:
          
          return [self companyCellHeight:indexPath];
          
        case BASE_SEC_ADDRESS_CN_CELL:
          
          return [self cnAddressCellHeight:indexPath];
          
        case BASE_SEC_ADDRESS_EN_CELL:
          
          return [self enAddressCellHeight:indexPath];
          
        case BASE_SEC_CITY_CELL:
          
          return [self cityCellHeight:indexPath];
          
        case BASE_SEC_PROVINCE_CELL:
          
          return [self provinceCellHeight:indexPath];
          
        case BASE_SEC_COUNTRY_CN_CELL:
          
          return [self cnCountryCellHeight:indexPath];
          
        case BASE_SEC_COUNTRY_EN_CELL:
          
          return [self enCountryCellHeight:indexPath];
          
        default:
          return 0;
      }
      break;
      
    case CONTACT_INFO_SEC:
      switch (indexPath.row) {
        case CONTACT_SEC_TEL_CELL:
          
          return [self telCellHeight:indexPath];
          
        case CONTACT_SEC_FAX_CELL:
          
          return [self faxCellHeight:indexPath];
          
        case CONTACT_SEC_EMAIL_CELL:
          
          return [self emailCellHeight:indexPath];
          
        case CONTACT_SEC_MOBILE_CELL:
          
          return [self mobileCellHeight:indexPath];
          
        case CONTACT_SEC_SINA_CELL:
          
          return [self sinaCellHeight:indexPath];
          
        case CONTACT_SEC_WECHAT_CELL:
          
          return [self wechatCellHeight:indexPath];
          
        case CONTACT_SEC_LINKEDIN_CELL:
          
          return [self linkedinCellHeight:indexPath];
          
        default:
          return 0;
      }
      break;
      
    default:
      return 0;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = nil;
  
  switch (indexPath.section) {
    case GROUP_SEC:
      switch (indexPath.row) {
        case GROUP_SEC_CELL:
          kCellIdentifier = @"groupInfoCell";
          
          NSString *title = nil;
          if (self.alumni.name && self.alumni.name.length > 0) {
            title = [NSString stringWithFormat:LocaleStringForKey(NSWhoJoinedGroupTitle, nil), self.alumni.name];
          } else {
            title = [NSString stringWithFormat:LocaleStringForKey(NSWhoJoinedGroupTitle, nil), NULL_PARAM_VALUE];
          }
          
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:title
                                       badgeCount:self.alumni.joinedGroupCount.intValue
                                          content:nil
                                        indexPath:indexPath
                                        clickable:YES
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        default:
          return 0;
      }
      
    case BASE_INFO_SEC:
      switch (indexPath.row) {
        case BASE_SEC_CLASS_CELL:
          
          kCellIdentifier = @"classCell";
          
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:LocaleStringForKey(NSClassTitle, nil)
                                       badgeCount:0
                                          content:self.alumni.classGroupName
                                        indexPath:indexPath
                                        clickable:NO
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case BASE_SEC_JOBTITLE_CELL:
          kCellIdentifier = @"jobCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:LocaleStringForKey(NSPositionTitle, nil)
                                       badgeCount:0
                                          content:self.alumni.jobTitle
                                        indexPath:indexPath
                                        clickable:NO
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case BASE_SEC_COMPANY_CELL:
          
          kCellIdentifier = @"companyCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:LocaleStringForKey(NSCompanyNameTitle, nil)
                                       badgeCount:0
                                          content:self.alumni.companyName
                                        indexPath:indexPath
                                        clickable:NO
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case BASE_SEC_ADDRESS_CN_CELL:
          
          kCellIdentifier = @"cnAddressCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:LocaleStringForKey(NSCompanyAddressTitle, nil)
                                       badgeCount:0
                                          content:self.alumni.companyAddressC
                                        indexPath:indexPath
                                        clickable:NO
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case BASE_SEC_ADDRESS_EN_CELL:
          
          kCellIdentifier = @"classCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:[NSString stringWithFormat:@"%@ (en)", LocaleStringForKey(NSCompanyAddressTitle, nil)]
                                       badgeCount:0
                                          content:self.alumni.companyAddressE
                                        indexPath:indexPath
                                        clickable:NO
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case BASE_SEC_CITY_CELL:
          
          kCellIdentifier = @"cityCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:LocaleStringForKey(NSCompanyCityTitle, nil)
                                       badgeCount:0
                                          content:self.alumni.companyCity
                                        indexPath:indexPath
                                        clickable:NO
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case BASE_SEC_PROVINCE_CELL:
          
          kCellIdentifier = @"provinceCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:LocaleStringForKey(NSCompanyProvinceTitle, nil)
                                       badgeCount:0
                                          content:self.alumni.companyProvince
                                        indexPath:indexPath
                                        clickable:NO
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case BASE_SEC_COUNTRY_CN_CELL:
          
          kCellIdentifier = @"cnCountryCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:LocaleStringForKey(NSCountryTitle, nil)
                                       badgeCount:0
                                          content:self.alumni.companyCountryC
                                        indexPath:indexPath
                                        clickable:NO
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case BASE_SEC_COUNTRY_EN_CELL:
          
          kCellIdentifier = @"enCountryCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:[NSString stringWithFormat:@"%@ (en)", LocaleStringForKey(NSCountryTitle, nil)]
                                       badgeCount:0
                                          content:self.alumni.companyCountryE
                                        indexPath:indexPath
                                        clickable:NO
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        default:
          return nil;
      }
      break;
      
    case CONTACT_INFO_SEC:
      switch (indexPath.row) {
        case CONTACT_SEC_TEL_CELL:
          
          kCellIdentifier = @"telCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:LocaleStringForKey(NSTelTitle, nil)
                                       badgeCount:0
                                          content:self.alumni.companyPhone
                                        indexPath:indexPath
                                        clickable:YES
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case CONTACT_SEC_FAX_CELL:
          
          kCellIdentifier = @"faxCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:LocaleStringForKey(NSCompanyFaxTitle, nil)
                                       badgeCount:0
                                          content:self.alumni.companyFax
                                        indexPath:indexPath
                                        clickable:NO
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case CONTACT_SEC_EMAIL_CELL:
          
          kCellIdentifier = @"emailCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:LocaleStringForKey(NSEmailTitle, nil)
                                       badgeCount:0
                                          content:self.alumni.email
                                        indexPath:indexPath
                                        clickable:YES
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case CONTACT_SEC_MOBILE_CELL:
          
          kCellIdentifier = @"mobileCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:LocaleStringForKey(NSMobileTitle, nil)
                                       badgeCount:0
                                          content:self.alumni.phoneNumber
                                        indexPath:indexPath
                                        clickable:YES
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case CONTACT_SEC_SINA_CELL:
          
          kCellIdentifier = @"sinaCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:LocaleStringForKey(NSSinaWeiboTitle, nil)
                                       badgeCount:0
                                          content:self.alumni.sina
                                        indexPath:indexPath
                                        clickable:NO
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case CONTACT_SEC_WECHAT_CELL:
          
          kCellIdentifier = @"wechatCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:LocaleStringForKey(NSWeixinTitle, nil)
                                       badgeCount:0
                                          content:self.alumni.weixin
                                        indexPath:indexPath
                                        clickable:NO
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        case CONTACT_SEC_LINKEDIN_CELL:
          
          kCellIdentifier = @"linkedinCell";
          return [self configureCommonGroupedCell:kCellIdentifier
                                            title:@"Linkedin"
                                       badgeCount:0
                                          content:self.alumni.linkedin
                                        indexPath:indexPath
                                        clickable:NO
                                       dropShadow:YES
                                     cornerRadius:GROUPED_CELL_CORNER_RADIUS];
          
        default:
          return nil;
      }
      break;
      
    default:
      return nil;
  }
  
  return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (indexPath.section) {
      
    case GROUP_SEC:
      switch (indexPath.row) {
        case GROUP_SEC_CELL:
          [self displayJoinedGroups];
          break;
          
        default:
          break;
      }
      break;
      
    case CONTACT_INFO_SEC:
      switch (indexPath.row) {
        case CONTACT_SEC_TEL_CELL:
          [self selectPhoneCell];
          break;
          
        case CONTACT_SEC_EMAIL_CELL:
          [self selectEmailCell];
          break;
          
        case CONTACT_SEC_MOBILE_CELL:
          [self selectMobileCell];
          break;
          
        default:
          break;
      }
      break;
      
    default:
      break;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  if (section == CONTACT_INFO_SEC) {
    return _userSignInInfoView;
  } else {
    return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  if (section == CONTACT_INFO_SEC) {
    return FOOTER_HEIGHT;
  } else {
    return 0;
  }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return YES;
}

@end
