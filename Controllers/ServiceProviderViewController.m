//
//  ServiceProviderViewController.m
//  ExpatCircle
//
//  Created by Adam on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ServiceProviderViewController.h"
#import "ServiceProviderProfileHeaderView.h"
#import "ItemInfoCell.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "ECHandyAvatarBrowser.h"
#import "TaxiCardViewController.h"
#import "ComposerViewController.h"
#import "WXWNavigationController.h"
#import "CoreDataUtils.h"
#import "ECPhotoPickerController.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "UserListViewController.h"
#import "ReviewsListViewController.h"
#import "MapViewController.h"
#import "AlbumListViewController.h"
#import "ECPhotoPickerOverlayViewController.h"
#import "CouponInfoCell.h"
#import "ECAsyncConnectorFacade.h"
#import "HttpUtils.h"
#import "VerticalLayoutItemInfoCell.h"
#import "ServiceProvider.h"
#import "PhoneNumber.h"

enum {
  INTRO_NO_COUPON_SEC,
  MAP_NO_COUPON_SEC,
  CONTACT_NO_COUPON_SEC,
};

enum {
  COUPON_SEC_CELL,
};

enum {
  INTRO_SEC_CELL,
};

enum {
  MAP_SEC_ADDRESS_CELL,
  MAP_SEC_TAXI_CELL,
};

enum {
  CONTACT_SEC_PHONE_CELL,
  CONTACT_SEC_WEB_CELL,
  CONTACT_SEC_EMAIL_CELL,
};

#define SECTION_WITHOUT_COUPON_COUNT  3
#define SECTION_WITH_COUPON_COUNT     4
#define INTRO_SEC_CELL_COUNT          1
#define COUPON_SEC_CELL_COUNT         1
#define MAP_SEC_CELL_COUNT            2
#define CONTACT_SEC_HAS_PHONE_CELL_COUNT  3
#define CONTACT_SEC_NO_PHONE_CELL_COUNT   2

@interface ServiceProviderViewController()
@property (nonatomic, retain) ECPhotoPickerOverlayViewController *pickerOverlayVC;
@property (nonatomic, copy) NSString *hashedLikedItemId;
@property (nonatomic, retain) ServiceProvider *sp;
@end

@implementation ServiceProviderViewController

@synthesize pickerOverlayVC = _pickerOverlayVC;
@synthesize hashedLikedItemId = _hashedLikedItemId;
@synthesize sp = _sp;

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
             spId:(long long)spId {
  
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:NO 
      needRefreshFooterView:NO 
                 tableStyle:UITableViewStyleGrouped
                 needGoHome:NO];
  
  if (self) {
    _spId = spId;
    
    // clear current existing service provider objects from MOC
    [WXWCoreDataUtils deleteEntitiesFromMOC:MOC entityName:@"ServiceProvider" predicate:nil];
    
    self.hashedLikedItemId = [CommonUtils hashStringAsMD5:[NSString stringWithFormat:@"%@_%@", 
                                                           self.sp.spId, self.sp.spId]];
    
    _startIndex = 0;
    _sectionCount = SECTION_WITHOUT_COUPON_COUNT;
  }
  
  return self;
}

- (void)dealloc {
  
  self.pickerOverlayVC = nil;
  
  self.hashedLikedItemId = nil;
  
  self.sp = nil;
  
  [WXWCoreDataUtils deleteEntitiesFromMOC:_MOC entityName:@"ServiceProvider" predicate:nil];
  
  [super dealloc];
}

- (void)initTableViewProperties {
  
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  [self initTableViewProperties];
  
  //[_tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_autoLoaded) {
    
    NSString *requestUrl = [HttpUtils assembleFetchServiceProviderDetailUrl:_spId];
    NSString *url = [CommonUtils assembleXmlRequestUrl:@"service_provider_single_get" param:requestUrl];
    
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self 
                                                                    interactionContentType:LOAD_SERVICE_PROVIDER_DETAIL_TY] autorelease];
    (self.connDic)[url] = connFacade;
    
    [connFacade fetchNearbyItemDetail:url];
    
    _autoLoaded = YES;
  } else {
    // update the header view for the counts of like, comment and photos
    [self updateTableHeaderView];
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - update table header View 
- (void)updateTableHeaderView {
 
  [_tableView beginUpdates];
  [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
            withRowAnimation:UITableViewRowAnimationNone];
  [_tableView endUpdates];

  [_tableView endUpdates];
}

#pragma mark - fetch service provider entity
- (void)fetchSPEntity {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(spId == %lld)", _spId];
  
  self.sp = (ServiceProvider *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                  entityName:@"ServiceProvider"
                                                   predicate:predicate];
}

#pragma mark - WXWConnectionTriggerHolderDelegate method
- (void)registerRequestUrl:(NSString *)url connFacade:(ECAsyncConnectorFacade *)connFacade {
  [super registerRequestUrl:url connFacade:connFacade];
}

#pragma mark - ECClickableElementDelegate method
- (void)openLikers {
  /*
  LikersListViewController *likersListVC = [[[LikersListViewController alloc] initWithMOC:_MOC
                                                                                   holder:_holder 
                                                                         backToHomeAction:_backToHomeAction 
                                                                    needRefreshHeaderView:NO 
                                                                    needRefreshFooterView:NO
                                                                        hashedLikedItemId:self.hashedLikedItemId] autorelease];
  likersListVC.title = LocaleStringForKey(NSLikerTitle, nil);
  [self.navigationController pushViewController:likersListVC animated:YES];
   */
}

- (void)browseComments {
  ReviewsListViewController *commentListVC = [[[ReviewsListViewController alloc] initWithMOC:_MOC
                                                                                      holder:_holder 
                                                                            backToHomeAction:@selector(backToHomepage:) 
                                                                                          sp:self.sp
                                                                             allowAddComment:YES] autorelease];
  commentListVC.title = LocaleStringForKey(NSReviewsTitle, nil);
  [self.navigationController pushViewController:commentListVC animated:YES];
}

- (void)browseAlbum {
  AlbumListViewController *albumListVC = [[[AlbumListViewController alloc] initWithMOC:_MOC
                                                                                holder:_holder 
                                                                      backToHomeAction:_backToHomeAction 
                                                                                itemId:_spId
                                                                           contentType:LOAD_SERVICE_PROVIDER_ALBUM_PHOTO_TY] autorelease];
  albumListVC.title = [NSString stringWithFormat:@"%@(%@)", LocaleStringForKey(NSPhotoTitle, nil), self.sp.photoCount];
  [self.navigationController pushViewController:albumListVC animated:YES];
}

- (void)showBigPhoto:(NSString *)url {
  
  CGRect smallAvatarFrame = CGRectMake(MARGIN * 2, MARGIN * 2, PHOTO_SIDE_LENGTH, PHOTO_SIDE_LENGTH);
  
  ECHandyAvatarBrowser *avatarBrowser = [[[ECHandyAvatarBrowser alloc] initWithFrame:CGRectMake(0, 0, 
                                                                                                self.view.frame.size.width,
                                                                                                self.view.frame.size.height)
                                                                              imgUrl:url 
                                                                     imageStartFrame:smallAvatarFrame 
                                                              imageDisplayerDelegate:self] autorelease];
  [self.view addSubview:avatarBrowser];
}

- (void)addComment {
  ComposerViewController *composerVC = [[[ComposerViewController alloc] initServiceProviderCommentComposerWithMOC:_MOC
                                                                                                         delegate:self
                                                                                                   originalItemId:[NSString stringWithFormat:@"%@", self.sp.spId]] autorelease];
  composerVC.title = LocaleStringForKey(NSNewReviewTitle, nil);
  WXWNavigationController *navVC = [[[WXWNavigationController alloc] initWithRootViewController:composerVC] autorelease];
  [self.navigationController presentModalViewController:navVC animated:YES];
}

/*
- (void)showImagePicker:(BOOL)hasCamera {
  _photoSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  if (hasCamera) {
    _photoSourceType = UIImagePickerControllerSourceTypeCamera;
  }
	ECPhotoPickerController *picker = [[[ECPhotoPickerController alloc] initWithSourceType:_photoSourceType] autorelease];
  picker.title = LocaleStringForKey(NSPhotoEffectHandleTitle, nil);
	picker.delegate = self;
  [self.navigationController pushViewController:picker animated:YES];
  [picker.navigationController presentModalViewController:picker.imagePicker animated:YES];
}
 */

- (void)addPhoto {
  
  UIImagePickerControllerSourceType photoSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  if (HAS_CAMERA) {
    photoSourceType = UIImagePickerControllerSourceTypeCamera;
  }

  self.pickerOverlayVC = [[[ECPhotoPickerOverlayViewController alloc] initForServiceUploadPhoto:LLINT_TO_STRING(_spId)
                                                                                     SourceType:photoSourceType 
                                                                                       delegate:self 
                                                                               uploaderDelegate:self 
                                                                                      takerType:SERVICE_PROVIDER_PHOTO_TY 
                                                                                            MOC:_MOC] autorelease];
  
  [self.pickerOverlayVC arrangeViews];
  
  [self presentModalViewController:self.pickerOverlayVC.imagePicker animated:YES];
}

#pragma mark - ECPhotoPickerOverlayDelegate methods

// as a delegate we are being told a picture was taken
- (void)didTakePhoto:(UIImage *)photo {
  self.connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self 
                                               interactionContentType:ADD_PHOTO_FOR_SERVICE_PROVIDER_TY] autorelease];
  [self.connFacade addPhotoForServiceProvider:photo
                                   providerId:_spId
                                      caption:nil];
}

// as a delegate we are told to finished with the camera
- (void)didFinishWithCamera {
  
  self.pickerOverlayVC = nil;
}

- (void)adjustUIAfterUserBrowseAlbumInImagePicker {
  [UIApplication sharedApplication].statusBarHidden = NO;
  self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame,
                                                               0.0, 20.0);
  self.view.frame = CGRectOffset(self.view.frame, 0.0f, 20.0f);
}

#pragma mark - PhotoPickerDelegate method

- (void)selectPhoto:(UIImage *)selectedImage {
  if (_pickerOverlayVC.needSaveToAlbum) {
    UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil);    
  }
  
  self.connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self 
                                               interactionContentType:ADD_PHOTO_FOR_SERVICE_PROVIDER_TY] autorelease];
  [self.connFacade addPhotoForServiceProvider:selectedImage
                                   providerId:_spId
                                      caption:nil];
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

#pragma mark - UIActionSheetDelegate delegate method
- (void)actionSheet:(UIActionSheet *)as  clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex != as.numberOfButtons - 1) {
    NSString *number = nil;
    NSString *desc = [as buttonTitleAtIndex:buttonIndex];
    for (PhoneNumber *phoneNumber in self.sp.phoneNumbers) {
      if ([desc isEqualToString:phoneNumber.desc]) {
        number = phoneNumber.number;
        break;
      }
    }
    NSString *phoneStr = [[[NSString alloc] initWithFormat:@"tel:%@", number] autorelease];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
    
  }

}

#pragma mark - UIAlertViewDelegate delegate method
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (0 == buttonIndex) {
    NSString *number = [self.sp.phoneNumber stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *phoneStr = [[[NSString alloc] initWithFormat:@"tel:%@", number] autorelease];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
  }
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url 
           contentType:(NSInteger)contentType {
  [super connectStarted:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url 
        contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case LOAD_SERVICE_PROVIDER_DETAIL_TY:
    {
      if ([XMLParser parserResponseXml:result 
                                  type:LOAD_SERVICE_PROVIDER_DETAIL_TY 
                                   MOC:_MOC 
                     connectorDelegate:self
                                   url:url]) {
        //[_headerView updatePhotoCount];
        [self fetchSPEntity];
        [_tableView reloadData];
        
      }
      break;
    }
      
    case ADD_PHOTO_FOR_SERVICE_PROVIDER_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:ADD_PHOTO_FOR_SERVICE_PROVIDER_TY 
                                   MOC:nil
                     connectorDelegate:self 
                                   url:url]) {
        
        self.sp.photoCount = @(self.sp.photoCount.intValue + 1);
        [WXWCoreDataUtils saveMOCChange:_MOC];
        
        [_headerView updatePhotoCount];
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAddPhotoDoneTitle, nil)
                                      msgType:SUCCESS_TY
                           belowNavigationBar:YES];
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSAddPhotoFailedTitle, nil)
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

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  NSString *errorMsg = nil;
  switch (contentType) {
    case LOAD_SERVICE_PROVIDER_DETAIL_TY:
      errorMsg = LocaleStringForKey(NSFetchNearbyItemDetailFailedMsg, nil);
      break;
      
    case ADD_PHOTO_FOR_SERVICE_PROVIDER_TY:
      errorMsg = LocaleStringForKey(NSAddPhotoFailedTitle, nil);
      break;
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = errorMsg;
  }
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - ECItemUploaderDelegate methods
- (void)afterUploadFinishAction:(WebItemType)actionType {
  
  switch (actionType) {
    case SEND_SERVICE_PROVIDER_COMMENT_TY:
    {
      self.sp.commentCount = @(self.sp.commentCount.intValue + 1);
      SAVE_MOC(_MOC);
      
      [_headerView updateCommentCount];
      break;
    } 
      
    case ADD_PHOTO_FOR_SERVICE_PROVIDER_TY:
    {
      self.sp.photoCount = @(self.sp.photoCount.intValue + 1);
      SAVE_MOC(_MOC);
      [_headerView updatePhotoCount];
      break;
    }
    default:
      break;
  }

}

#pragma mar - draw header view
- (UIView *)drawProfileHeaderView {
  if (nil == _headerView) {
    _headerView = [[ServiceProviderProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0) 
                                              imageDisplayerDelegate:self 
                                            clickableElementDelegate:self
                                     connectionTriggerHolderDelegate:self
                                                                 MOC:_MOC
                                                   hashedLikedItemId:self.hashedLikedItemId];
  }
  
  CGSize size = [self.sp.spName sizeWithFont:FONT(13) 
                           constrainedToSize:CGSizeMake(250, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat height = MARGIN * 8 + size.height + MARGIN * 2 + 2 + USER_PROF_BUTTONS_BACKGROUND_HEIGHT + 2;
  _headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, height);
  
  [_headerView drawProfile:self.sp];
  
  [_headerView updatePhotoCount];
  
  [_headerView updateLikeActionButtonImage];
  
  return _headerView;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case INTRO_NO_COUPON_SEC:
      return INTRO_SEC_CELL_COUNT;
      
    case MAP_NO_COUPON_SEC:      
      return MAP_SEC_CELL_COUNT;
      
    case CONTACT_NO_COUPON_SEC:
    {
      if (self.sp.email && self.sp.email.length > 0) {
        return CONTACT_SEC_HAS_PHONE_CELL_COUNT;
      } else {
        return CONTACT_SEC_NO_PHONE_CELL_COUNT;
      }
    } 
    default:
      return 0;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
  switch (section) {
    case INTRO_NO_COUPON_SEC: //MAP_NO_COUPON_SEC:           
      return [self drawProfileHeaderView];      
    default:
      return nil;
  }
  
}

- (CGFloat)heightForProfileHeaderView {
  CGFloat height = 60 + MARGIN * 2 + 2 + USER_PROF_BUTTONS_BACKGROUND_HEIGHT + 2 + MARGIN + 30;
  
  return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  switch (section) {
    case INTRO_NO_COUPON_SEC://MAP_NO_COUPON_SEC:      
      return [self heightForProfileHeaderView];
    default:
      return 0.0f;
  }
  
}

- (ItemInfoCell *)drawInfoCell:(ServiceProviderInfoType)type 
                cellIdentifier:(NSString *)cellIdentifier
              needBottomShadow:(BOOL)needBottomShadow {
  
  ItemInfoCell *cell = (ItemInfoCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[ItemInfoCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                reuseIdentifier:cellIdentifier] autorelease];
  }
  
  [cell drawInfoCell:self.sp infoType:type needBottomShadow:needBottomShadow];
  
  return cell;
}

- (UITableViewCell *)drawMapSectionCell:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case MAP_SEC_ADDRESS_CELL: 
    {
      static NSString *cellIdentifier = @"addressCell";
      return [self drawInfoCell:SP_MAP_INFO_TY
                 cellIdentifier:cellIdentifier
               needBottomShadow:NO];
    }
      
    case MAP_SEC_TAXI_CELL:
    {
      static NSString *cellIdentifier = @"taxiCell";
      return [self drawInfoCell:SP_TAXI_INFO_TY
                 cellIdentifier:cellIdentifier
               needBottomShadow:YES];
    }
    default:
      return nil;
  }
}

- (UITableViewCell *)drawContactSectionCell:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case CONTACT_SEC_PHONE_CELL:
    {
      static NSString *cellIdentifier = @"phoneCell";
      return [self drawInfoCell:SP_PHONE_INFO_TY 
                 cellIdentifier:cellIdentifier
               needBottomShadow:NO];
    }
      
    case CONTACT_SEC_WEB_CELL:
    {
      static NSString *cellIdentifier = @"webCell";
      BOOL needShadow = YES;
      if (self.sp.email && self.sp.email.length > 0) {
        needShadow = NO;
      }
      return [self drawInfoCell:SP_WEBSITE_INFO_TY 
                 cellIdentifier:cellIdentifier
               needBottomShadow:needShadow];
    }
      
    case CONTACT_SEC_EMAIL_CELL:
    {
      static NSString *cellIdentifier = @"emailCell";
      return [self drawInfoCell:SP_EMAIL_INFO_TY
                 cellIdentifier:cellIdentifier
               needBottomShadow:YES];
    }
    default:
      return nil;
  }
}

- (UITableViewCell *)drawIntroSectionCell {
  
  static NSString *introCellIdentifier = @"introCell";
  
  VerticalLayoutItemInfoCell *cell = (VerticalLayoutItemInfoCell *)[_tableView dequeueReusableCellWithIdentifier:introCellIdentifier];
  if (nil == cell) {
    cell = [[[VerticalLayoutItemInfoCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                              reuseIdentifier:introCellIdentifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  [cell drawShadowInfoCell:[NSString stringWithFormat:@"%@:", LocaleStringForKey(NSIntroTitle, nil)]
                  subTitle:nil
                   content:self.sp.bio
                cellHeight:[self introSectionCellHeight] + 1.0f
                 clickable:NO];
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case INTRO_NO_COUPON_SEC:
      return [self drawIntroSectionCell];
      
    case MAP_NO_COUPON_SEC:
      return [self drawMapSectionCell:indexPath];
      
    case CONTACT_NO_COUPON_SEC:
      return [self drawContactSectionCell:indexPath];        
      
    default:
      return nil;
  }
  
}

- (CGFloat)cellHeight:(NSString *)text {
  if (nil == text || text.length <= 1) {
    return 44.0f;
  }
  CGSize size = [text sizeWithFont:BOLD_FONT(14)
                 constrainedToSize:CGSizeMake(200, CGFLOAT_MAX) 
                     lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat height = MARGIN * 2 + size.height + MARGIN * 2;
  if (height < 44) {
    height = 44;
  }
  return height;
}

- (CGFloat)mapSectionCellHeight:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case MAP_SEC_ADDRESS_CELL:          
      return [self cellHeight:self.sp.address];
      
    case MAP_SEC_TAXI_CELL:
      return 44.0f;
      
    default:
      return 0.0f;
  }
}

- (CGFloat)contactSectionCellHeight:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case CONTACT_SEC_PHONE_CELL:
      return [self cellHeight:self.sp.phoneNumber];
      
    case CONTACT_SEC_WEB_CELL:
      return [self cellHeight:self.sp.link];
      
    case CONTACT_SEC_EMAIL_CELL:
      return [self cellHeight:self.sp.email];
      
    default:
      return 0.0f;
  }
}

- (CGFloat)introSectionCellHeight {
  
  NSString *title = [NSString stringWithFormat:@"%@:", LocaleStringForKey(NSIntroTitle, nil)];
  CGSize size = [title sizeWithFont:BOLD_FONT(15) forWidth:260.0f lineBreakMode:NSLineBreakByWordWrapping];
  
  CGFloat height = MARGIN * 2 + size.height + MARGIN * 2;
  
  if (self.sp.bio && self.sp.bio.length > 0) {
    size = [self.sp.bio sizeWithFont:BOLD_FONT(14) 
               constrainedToSize:CGSizeMake(280.0f, CGFLOAT_MAX)
                   lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height + MARGIN;
  }
  
  return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  
  switch (indexPath.section) {
    case INTRO_NO_COUPON_SEC:
      return [self introSectionCellHeight];
      
    case MAP_NO_COUPON_SEC:
      return [self mapSectionCellHeight:indexPath];
      
    case CONTACT_NO_COUPON_SEC:
      return [self contactSectionCellHeight:indexPath];
      
    default:
      return 0.0f;
  }
  
}

- (void)selectMapSectionCell:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case MAP_SEC_ADDRESS_CELL:          
    {
      if (self.sp.latlagAttached.boolValue) {
        MapViewController *mapVC = [[[MapViewController alloc] initWithLatitude:self.sp.latitude.doubleValue
                                                                      longitude:self.sp.longitude.doubleValue
                                                           allowLaunchGoogleMap:YES] autorelease];
        
        WXWNavigationController *navVC = [[[WXWNavigationController alloc] initWithRootViewController:mapVC] autorelease];
        [self.navigationController presentModalViewController:navVC animated:YES];
      }
      break;
    }
      
    case MAP_SEC_TAXI_CELL:
    {
      TaxiCardViewController *taxiCardVC = [[[TaxiCardViewController alloc] initWithAddressPart1:self.sp.cnAddressPart1
                                                                                           part2:self.sp.cnAddressPart2
                                                                                           part3:self.sp.cnAddressPart3
                                                                                            name:self.sp.spName                                                
                                                                                          holder:_holder 
                                                                                backToHomeAction:@selector(backToHomepage:)
                                                                                        latitude:_sp.latitude.doubleValue
                                                                                       longitude:_sp.longitude.doubleValue] autorelease];
      [self.navigationController pushViewController:taxiCardVC animated:YES];
      break;
    }
      
    default:
      break;
  }
}

- (void)selectContactSectionCell:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case CONTACT_SEC_PHONE_CELL:
    {
      if (self.sp.phoneNumber && self.sp.phoneNumber.length > 2) {
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:LocaleStringForKey(NSCallThisNumberTitle, nil), self.sp.phoneNumber]
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:LocaleStringForKey(NSYesTitle, nil)
                                              otherButtonTitles:LocaleStringForKey(NSNoTitle, nil), nil];
        [alert show];
        RELEASE_OBJ(alert);
         */
        UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSCallThisNumberTitle, nil)
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:nil] autorelease];
        for (PhoneNumber *phoneNumber in self.sp.phoneNumbers) {
          [sheet addButtonWithTitle:phoneNumber.desc];
        }
        //[sheet addButtonWithTitle:self.sp.phoneNumber];
        [sheet addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
        sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
        [sheet showInView:self.view];

      }
      break;
    }
      
    case CONTACT_SEC_WEB_CELL:
    {
      if (self.sp.link && self.sp.link.length > 2) {
        [CommonUtils openWebView:self.navigationController 
                           title:self.sp.spName
                             url:self.sp.link
                 needCloseButton:YES
                  needNavigation:YES
                  needHomeButton:NO];
        
      }
      break;
    }
      
    case CONTACT_SEC_EMAIL_CELL:
    {
      if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposeVC = [[[MFMailComposeViewController alloc] init] autorelease];
        
        mailComposeVC.mailComposeDelegate = self;
        [mailComposeVC setToRecipients:@[self.sp.email]];
        [self presentModalViewController:mailComposeVC animated:YES];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCannotSendEmailMsg, nil)
                                      msgType:ERROR_TY 
                           belowNavigationBar:YES];
      }

      break;
    }
      
    default:
      break;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
    case MAP_NO_COUPON_SEC:
      [self selectMapSectionCell:indexPath];
      break;
      
    case CONTACT_NO_COUPON_SEC:
      [self selectContactSectionCell:indexPath];
      break;
      
    default:
      break;
      
  }
  
  if (indexPath.section != INTRO_NO_COUPON_SEC) {
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
  }
}

@end
