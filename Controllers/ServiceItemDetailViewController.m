//
//  ServiceItemDetailViewController.m
//  ExpatCircle
//
//  Created by Adam on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ServiceItemDetailViewController.h"
#import "ServiceItem.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "HttpUtils.h"
#import "ServiceItemHeaderView.h"
#import "UserListViewController.h"
#import "CoreDataUtils.h"
#import "ECHandyAvatarBrowser.h"
#import "UIUtils.h"
#import "ECPhotoPickerOverlayViewController.h"
#import "XMLParser.h"
#import "AlbumListViewController.h"
#import "ServiceItemToolbar.h"
#import "CouponInfoCell.h"
#import "ItemInfoCell.h"
#import "VerticalLayoutItemInfoCell.h"
#import "MapViewController.h"
#import "TaxiCardViewController.h"
#import "WXWNavigationController.h"
#import "HandyCommentListViewController.h"
#import "ComposerViewController.h"
#import "WXWNavigationController.h"
#import "ServiceItemSection.h"
#import "CoreDataUtils.h"
#import "RecommendedItemListViewController.h"
#import "ServiceProviderViewController.h"
#import "ServiceLatestCommentCell.h"
#import "CouponItem.h"
#import "PhoneNumber.h"
#import "CouponDetailViewController.h"
#import "ServiceItemSectionParam.h"
#import "ItemLikersListViewController.h"
#import "BranchListViewController.h"
#import "CheckinListViewController.h"
#import "CouponViewController.h"
#import "Brand.h"

enum {
  SHARE_AS_TY,
  CALL_AS_TY,
};

#define DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH    266.0f
#define DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH  280.0f

#define DEFAULT_CELL_HEIGHT         44.0f

#define TAG_ICON_SIDE_LENGTH        16.0f

#define RECOMMENDED_CELL_MAX_HEIGHT 70.0f
#define RECOMMENDED_ITEMS_NAME_MAX_HEIGHT 40.0f

#define GRADE_ICON_WIDTH            68.0f

#define MORE_ACTION_TOOLBAR_WIDTH   50.0f
#define MORE_ACTION_TOOLBAR_HEIGHT  30.0f

#define ITEM_AVATAR_WIDTH           90.0f

#define AVATAR_HEIGHT               190.0f//240.0f

#define CELL_SEPARATOR              @"|"
#define POSITION_TYPE_SEPARAOTR     @"-"

#define MAIL_BODY           @"<html><body marginwidth=\"0\" marginheight=\"0\" leftmargin=\"0\" topmargin=\"0\" style=\"font-family:ArialMT;font-size:15px;word-wrap:break-word;\" ><p style=\"margin=0\">%@</p><p><img src=\"%@\" alt=\"\" /></p><p>%@: <a href=\"tel:%@\">%@</a></p><p>%@: <a href=\"http://maps.google.com/maps?q=%@,%@&hl=en&sll=37.0625,-95.677068&sspn=40.460237,78.662109&t=m&z=17\">%@</a></p><p>%@: %@</p><br /><p>------<br />%@<br />%@<br />%@</p></body></html>"

#define WITH_IMAGE_ALBUM_HEIGHT       127.0f
#define WITHOUT_IMAGE_ALBUM_HEIGHT    50.0

#define SECTION_WITHOUT_COUPON_COUNT  5//4
#define SECTION_WITH_COUPON_COUNT     6//5

#define INTRO_SEC_HAS_SP_CELL_COUNT     2
#define INTRO_SEC_NO_SP_CELL_COUNT      1

#define MAP_SEC_HAS_TRANSIT_CELL_COUNT  3
#define MAP_SEC_NO_TRANSIT_CELL_COUNT   2

#define CONTACT_SEC_HAS_WEB_CELL_COUNT  2
#define CONTACT_SEC_NO_WEB_CELL_COUNT   1

#define COMMENT_SEC_CELL_COUNT          1

#define AVATAR_BACKGROUND_WIDTH         90.0f
#define AVATAR_BACKGROUND_HEIGHT        60.0f


@interface ServiceItemDetailViewController ()
@property (nonatomic, retain) ECPhotoPickerOverlayViewController *pickerOverlayVC;
@property (nonatomic, retain) NSIndexPath *commentIndexPath;
@property (nonatomic, copy) NSString *hashedServiceItemId;
@property (nonatomic, retain) NSMutableDictionary *sectionInfoDic;
@property (nonatomic, retain) Brand *brand;
@end

@implementation ServiceItemDetailViewController

@synthesize pickerOverlayVC = _pickerOverlayVC;
@synthesize commentIndexPath = _commentIndexPath;
@synthesize hashedServiceItemId = _hashedServiceItemId;
@synthesize sectionInfoDic = _sectionInfoDic;
@synthesize brand = _brand;

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
      serviceItem:(ServiceItem *)serviceItem {
  
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 tableStyle:UITableViewStyleGrouped
                 needGoHome:NO];
  if (self) {
    _item = serviceItem;
    
    self.sectionInfoDic = [NSMutableDictionary dictionary];
    
    [self fetchBrand];
    
    // clear all relationship stuff avoid some objects not be deleted in last time case by
    // abnormal exits
    [self clearSubPropertiesForServiceItem];
    
    self.hashedServiceItemId = [CommonUtils hashStringAsMD5:[NSString stringWithFormat:@"%@_%@_serviceItem",
                                                           _item.itemId, _item.categoryId]];
  }
  
  return self;
}

- (void)fetchBrand {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(brandId == %@)", _item.brandId];
  
  self.brand = (Brand *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                               entityName:@"Brand"
                                                predicate:predicate];
}

- (void)clearCouponInfos {
  
  [WXWCoreDataUtils deleteEntitiesFromMOC:_MOC
                            entityName:@"CouponItem"
                             predicate:nil];
}

- (void)clearSectionInfos {
  [WXWCoreDataUtils deleteEntitiesFromMOC:_MOC
                            entityName:@"ServiceItemSection"
                             predicate:nil];
}

- (void)clearRecommendedItems {
  [WXWCoreDataUtils deleteEntitiesFromMOC:_MOC
                            entityName:@"RecommendedItem"
                             predicate:nil];
}

- (void)clearCommentsForItem {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(parentId == %@)", _item.itemId];
  DELETE_OBJS_FROM_MOC(_MOC, @"Comment", predicate);
}

- (void)clearLikers {
  //DELETE_OBJS_FROM_MOC(_MOC, @"Member", nil);
  DELETE_OBJS_FROM_MOC(_MOC, @"Liker", nil);
}

- (void)clearSubPropertiesForServiceItem {
  [self clearCouponInfos];
  [self clearSectionInfos];
  [self clearRecommendedItems];
  [self clearCommentsForItem];
  [self clearLikers];
}

- (void)dealloc {
  
  [[NSNotificationCenter defaultCenter] postNotificationName:CONN_CANCELL_NOTIFY
                                                      object:self
                                                    userInfo:nil];
  self.pickerOverlayVC = nil;
  
  self.commentIndexPath = nil;
  
  RELEASE_OBJ(_headerView);
  
  self.hashedServiceItemId = nil;
  
  self.sectionInfoDic = nil;
  
  self.brand = nil;
  
  [super dealloc];
}

- (void)initTableViewProperties {
  
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  _tableView.backgroundColor = CELL_COLOR;
  
  UIView *backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, _tableView.frame.size.height * -1,
                                                                     _tableView.frame.size.width,
                                                                     _tableView.frame.size.height)] autorelease];
  backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
  [_tableView addSubview:backgroundView];
}

- (void)addMoreActionToolbarIfNecessary {
  
  if (nil == _moreActionToolbar) {
    CGRect frame = [_headerView convertedAddPhotoButtonRect];
    
    CGFloat y = frame.origin.y + frame.size.height - MORE_ACTION_TOOLBAR_HEIGHT;
    
    _moreActionToolbar = [[[ServiceItemToolbar alloc] initWithFrame:CGRectMake(APP_WINDOW.frame.size.width,
                                                                               y,
                                                                               0, MORE_ACTION_TOOLBAR_HEIGHT)
                                                               item:_item
                                                                MOC:_MOC
                                           clickableElementDelegate:self
                                    connectionTriggerHolderDelegate:self] autorelease];
    [_moreActionToolbar setNeedsDisplay];
    [self.view addSubview:_moreActionToolbar];
    [self.view bringSubviewToFront:_moreActionToolbar];
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                       [_moreActionToolbar displayMoreImage];
                     }];
  }
}

- (void)viewDidLoad{
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
     
  [self initTableViewProperties];
}

- (void)updateCommentCount {
  
  if (self.commentIndexPath) {
    // if self.commentIndexPath is nil, which means user does not scroll the screen
    // down to the comment location
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:@[self.commentIndexPath]
                      withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
  }
}

- (void)loadItemDetail {
  
  NSString *param = [NSString stringWithFormat:@"<service_id>%@</service_id>", _item.itemId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_SERVICE_ITEM_DETAIL_TY];
   
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:LOAD_SERVICE_ITEM_DETAIL_TY] autorelease];
  (self.connDic)[url] = connFacade;
  
  [connFacade fetchNearbyItemDetail:url];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_autoLoaded) {
    
    [self loadItemDetail];
    _autoLoaded = YES;
    
  } else {
    if (_needUpdateCommentCount) {
      [self updateCommentCount];
      
      _needUpdateCommentCount = NO;
    }
  }
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [_moreActionToolbar collapseIfNeeded];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECClickableElementDelegate method
- (void)openLikers {
  
   ItemLikersListViewController *likersListVC = [[[ItemLikersListViewController alloc] initWithMOC:_MOC
                                                                                            holder:_holder
                                                                                  backToHomeAction:_backToHomeAction
                                                                             needRefreshHeaderView:NO
                                                                             needRefreshFooterView:NO
                                                                                 hashedLikedItemId:self.hashedServiceItemId] autorelease];
   likersListVC.title = LocaleStringForKey(NSLikerTitle, nil);
   [self.navigationController pushViewController:likersListVC animated:YES];
}

- (void)openCheckinAlumnus {
  CheckinListViewController *listVC = [[[CheckinListViewController alloc] initWithMOC:_MOC
                                                                                 item:_item
                                                                  hashedServiceItemId:self.hashedServiceItemId] autorelease];
  listVC.title = LocaleStringForKey(NSCheckinAlumnusTitle, nil);
  [self.navigationController pushViewController:listVC animated:YES];
}

- (void)browseAlbum {
  AlbumListViewController *albumListVC = [[[AlbumListViewController alloc] initWithMOC:_MOC
                                                                                holder:_holder
                                                                      backToHomeAction:_backToHomeAction
                                                                                itemId:_item.itemId.longLongValue
                                                                           contentType:LOAD_SERVICE_ITEM_ALBUM_PHOTO_TY] autorelease];
  albumListVC.title = [NSString stringWithFormat:@"%@(%@)", LocaleStringForKey(NSPhotoTitle, nil), _item.photoCount];
  [self.navigationController pushViewController:albumListVC animated:YES];
}

- (void)showBigPhoto:(NSString *)url {
  
  CGRect smallAvatarFrame = CGRectMake(MARGIN * 2, _avatar_y, AVATAR_BACKGROUND_WIDTH, AVATAR_BACKGROUND_HEIGHT);
  
  ECHandyAvatarBrowser *avatarBrowser = [[[ECHandyAvatarBrowser alloc] initWithFrame:CGRectMake(0, 0,
                                                                                                self.view.frame.size.width,
                                                                                                self.view.frame.size.height)
                                                                              imgUrl:url
                                                                     imageStartFrame:smallAvatarFrame
                                                              imageDisplayerDelegate:self] autorelease];
  [self.view addSubview:avatarBrowser];
}

- (void)share {
  
  _actionOwnerType = SHARE_AS_TY;
  
  UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSShareToFriendTitle, nil)
                                                      delegate:self
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil] autorelease];
  [sheet addButtonWithTitle:LocaleStringForKey(NSSMSTitle, nil)];
  [sheet addButtonWithTitle:LocaleStringForKey(NSEmailTitle, nil)];
  [sheet addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
  [sheet showInView:self.view];
}

- (void)shareBySMS {
  MFMessageComposeViewController *smsComposeVC = [[[MFMessageComposeViewController alloc] init] autorelease];
  if ([MFMessageComposeViewController canSendText]) {
    
    smsComposeVC.body = [NSString stringWithFormat:@"%@, %@, %@: %@ [iAlumni]",
                         _item.itemName, _item.address, LocaleStringForKey(NSPhoneTitle, nil), _item.phoneNumber];
    smsComposeVC.messageComposeDelegate = self;
    [self presentModalViewController:smsComposeVC animated:YES];
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCannotSendSMSMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
}

- (void)shareByEmail {
  
  NSString *body = [NSString stringWithFormat:MAIL_BODY, _item.itemName,
                    _item.imageUrl,
                    LocaleStringForKey(NSPhoneTitle, nil), _item.phoneNumber,
                    _item.phoneNumber,
                    LocaleStringForKey(NSAddressTitle, nil), _item.latitude, _item.longitude, _item.address,
                    LocaleStringForKey(NSIntroTitle, nil), _item.bio,
                    LocaleStringForKey(NSSentFromExpatCircleAppTitle, nil), APP_STORE_URL,
                    [AppManager instance].host];
  
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *mailComposeVC = [[[MFMailComposeViewController alloc] init] autorelease];
    
    mailComposeVC.mailComposeDelegate = self;
    [mailComposeVC setSubject:[NSString stringWithFormat:@"%@: %@",
                               LocaleStringForKey(NSShareTitle, nil), _item.itemName]];
    
    [mailComposeVC setMessageBody:body isHTML:YES];
    
    [self presentModalViewController:mailComposeVC animated:YES];
    
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCannotSendEmailMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
}

- (void)addPhoto {
  UIImagePickerControllerSourceType photoSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  if (HAS_CAMERA) {
    photoSourceType = UIImagePickerControllerSourceTypeCamera;
  }
  
  self.pickerOverlayVC = [[[ECPhotoPickerOverlayViewController alloc] initForServiceUploadPhoto:[NSString stringWithFormat:@"%@", _item.itemId]
                                                                                     SourceType:photoSourceType
                                                                                       delegate:self
                                                                               uploaderDelegate:self
                                                                                      takerType:SERVICE_ITEM_PHOTO_TY
                                                                                            MOC:_MOC] autorelease];
  [self.pickerOverlayVC arrangeViews];
  [self presentModalViewController:self.pickerOverlayVC.imagePicker animated:YES];
}

- (void)addComment {
  ComposerViewController *composerVC = [[[ComposerViewController alloc] initServiceItemCommentComposerWithMOC:_MOC
                                                                                                     delegate:self
                                                                                               originalItemId:[NSString stringWithFormat:@"%@", _item.itemId]
                                                                                                      brandId:[NSString stringWithFormat:@"%@", _item.brandId]] autorelease];
  composerVC.title = LocaleStringForKey(NSNewReviewTitle, nil);
  WXWNavigationController *navVC = [[[WXWNavigationController alloc] initWithRootViewController:composerVC] autorelease];
  [self.navigationController presentModalViewController:navVC animated:YES];
}

#pragma mark - ECItemUploaderDelegate method
- (void)afterUploadFinishAction:(WebItemType)actionType {
  
  switch (actionType) {
    case ADD_PHOTO_FOR_SERVICE_ITEM_TY:
    {
      _item.photoCount = @(_item.photoCount.intValue + 1);
      SAVE_MOC(_MOC);
      [self updatePhotoWall];
      
      break;
    }
      
    case SEND_SERVICE_ITEM_COMMENT_TY:// triggered by send comment in tool bar
    case LOAD_SERVICE_ITEM_COMMENT_TY:// triggered by send comment in handy comment list
    {
      [self loadItemDetail];
      
      break;
    }
      
    default:
      break;
  }
}

#pragma mark - ECPhotoPickerOverlayDelegate methods

// as a delegate we are being told a picture was taken
- (void)didTakePhoto:(UIImage *)photo {
  self.connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                               interactionContentType:ADD_PHOTO_FOR_SERVICE_ITEM_TY] autorelease];
  [self.connFacade addPhotoForServiceItem:photo
                                   itemId:_item.itemId.longLongValue
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
                                               interactionContentType:ADD_PHOTO_FOR_SERVICE_ITEM_TY] autorelease];
  [self.connFacade addPhotoForServiceItem:selectedImage
                                   itemId:_item.itemId.longLongValue
                                  caption:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate method
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
  switch (result) {
    case MessageComposeResultCancelled:
      
      break;
      
    case MessageComposeResultFailed:
      [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSSMSSentFailed, nil)
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      break;
      
    case MessageComposeResultSent:
      
      break;
      
    default:
      break;
  }
  
  [self dismissModalViewControllerAnimated:YES];
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

#pragma mark - UIActionSheetDelegate method
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  switch (_actionOwnerType) {
    case SHARE_AS_TY:
    {
      switch (buttonIndex) {
        case 0:
          [self shareBySMS];
          break;
          
        case 1:
          [self shareByEmail];
          break;
          
        default:
          break;
      }
      break;
    }
      
    case CALL_AS_TY:
    {
      if (buttonIndex != actionSheet.numberOfButtons - 1) {
        NSString *number = nil;
        NSString *desc = [actionSheet buttonTitleAtIndex:buttonIndex];
        for (PhoneNumber *phoneNumber in _item.phoneNumbers) {
          if ([desc isEqualToString:phoneNumber.desc]) {
            number = phoneNumber.number;
            break;
          }
        }
        NSString *phoneStr = [[[NSString alloc] initWithFormat:@"tel:%@", number] autorelease];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
        
      }
      break;
    }
    default:
      break;
  }
}

#pragma mark - update header view after detail info loaded or new photo be added
- (void)updateTableForServiceDetailContent {
  [_tableView reloadData];
}

- (void)updatePhotoWall {
  [_tableView reloadData];
  
  [_headerView updatePhotoWall];
}

#pragma mark - parser sections info
- (void)parseSectionsInfoIfNecessary {
  if (self.sectionInfoDic.count <= 0) {
    for (ServiceItemSection *sectionInfo in _item.sections) {
      
      NSMutableDictionary *cellInfoDic = [NSMutableDictionary dictionary];
      
      NSArray *cells = [sectionInfo.cellList componentsSeparatedByString:CELL_SEPARATOR];
      for (NSString *cellInfo in cells) {
        NSArray *detailInfos = [cellInfo componentsSeparatedByString:@"-"];
        if (detailInfos.count == 2) {
          NSInteger position = ((NSString *)detailInfos[0]).intValue;
          NSInteger type = ((NSString *)detailInfos[1]).intValue;
          cellInfoDic[@(position)] = @(type);
        }
      }
      (self.sectionInfoDic)[sectionInfo.sectionType] = cellInfoDic;
    }
  }
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
            blockCurrentView:NO];
  
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
    case LOAD_SERVICE_ITEM_DETAIL_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:LOAD_SERVICE_ITEM_DETAIL_TY
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self parseSectionsInfoIfNecessary];
              
        // refresh all table content
        [self updateTableForServiceDetailContent];
      }
      break;
    }
      /*
       case ADD_PHOTO_FOR_SERVICE_ITEM_TY:
       {
       if ([XMLParser parserResponseXml:result
       type:ADD_PHOTO_FOR_SERVICE_ITEM_TY
       MOC:nil
       connectorDelegate:self
       url:url]) {
       
       _item.photoCount = [NSNumber numberWithInt:(_item.photoCount.intValue + 1)];
       [WXWCoreDataUtils saveMOCChange:_MOC];
       
       [self updateHeaderView];
       
       [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAddPhotoDoneTitle, nil)
       msgType:SUCCESS_TY
       belowNavigationBar:YES];
       } else {
       [UIUtils showNotificationOnTopWithMsg:[self.errorMsgDic objectForKey:url]
       alternativeMsg:LocaleStringForKey(NSAddPhotoFailedTitle, nil)
       msgType:ERROR_TY
       belowNavigationBar:YES];
       }
       
       break;
       }
       */
    default:
      break;
  }
  
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  NSString *errorMsg = nil;
  switch (contentType) {
    case LOAD_SERVICE_ITEM_DETAIL_TY:
      errorMsg = LocaleStringForKey(NSFetchNearbyItemDetailFailedMsg, nil);
      break;
      /*
       case ADD_PHOTO_FOR_SERVICE_ITEM_TY:
       errorMsg = LocaleStringForKey(NSAddPhotoFailedTitle, nil);
       break;
       */
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = errorMsg;
  }
    
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - scroll view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [_headerView adjustScrollSpeedWithOffset:scrollView.contentOffset];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  NSLog(@"section count: %d", _item.sections.count);
  return _item.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((sortKey == %d) AND (serviceItem.itemId == %@))",
                            section, _item.itemId];
  
  ServiceItemSection *sectionItem = (ServiceItemSection *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                                 entityName:@"ServiceItemSection"
                                                                                  predicate:predicate];
  if ([sectionItem.sectionType isEqualToString:ITEM_COUPON_SEC]) {
    return _item.couponInfos.count;
  } else if ([sectionItem.sectionType isEqualToString:ITEM_SPECIAL_SEC]) {
    return sectionItem.specialParams.count;
  } else {
    return ((NSMutableDictionary *)(self.sectionInfoDic)[sectionItem.sectionType]).count;
  }
}

- (CGFloat)headerViewHeight {
  /*
   CGSize size = [_item.itemName sizeWithFont:BOLD_FONT(16)
   constrainedToSize:CGSizeMake(self.view.frame.size.width - (MARGIN * 2 + MARGIN * 2 +
   GRADE_ICON_WIDTH + MARGIN * 2),
   CGFLOAT_MAX)
   lineBreakMode:NSLineBreakByWordWrapping];
   CGFloat height = size.height + MARGIN * 2;
   
   _avatar_y = height;
   
   CGFloat photoBottomLine_y = height + MARGIN + AVATAR_BACKGROUND_HEIGHT + MARGIN * 2;
   
   size = [LocaleStringForKey(NSTagTitle, nil) sizeWithFont:FONT(13)
   forWidth:CGFLOAT_MAX
   lineBreakMode:NSLineBreakByWordWrapping];
   
   CGFloat tagsName_y = photoBottomLine_y - size.height;
   
   NSString *tagInfo = _item.tagNames;
   if (nil == tagInfo || 0 == tagInfo.length) {
   tagInfo = LocaleStringForKey(NSTagTitle, nil);
   }
   size = [tagInfo sizeWithFont:BOLD_FONT(13)
   constrainedToSize:CGSizeMake(self.view.frame.size.width -
   (MARGIN * 2 + ITEM_AVATAR_WIDTH + MARGIN * 2 +
   size.width + MARGIN + MARGIN * 2), CGFLOAT_MAX)
   lineBreakMode:NSLineBreakByWordWrapping];
   height = tagsName_y + size.height;
   
   height += 40.0f + MARGIN * 2;
   */
  
  //////
  
  CGFloat height = AVATAR_HEIGHT;
  
  CGSize size = [_item.itemName sizeWithFont:BOLD_FONT(16)
                           constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 4,
                                                        CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
  height += size.height + MARGIN;
  
  if (nil == _item.tagNames || 0 == _item.tagNames.length) {
    height += TAG_ICON_SIDE_LENGTH + MARGIN;
  } else {
    CGFloat widthLimited = self.view.frame.size.width - MARGIN * 4 - TAG_ICON_SIDE_LENGTH - MARGIN;
    size = [_item.tagNames sizeWithFont:FONT(11)
                      constrainedToSize:CGSizeMake(widthLimited, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height + MARGIN;
  }
  
  height += 40.0f * 2/* + MARGIN * 2*/ - MARGIN;
  //////
  
  NSLog(@"header height: %f", height);
  
  if (_item.photoCount.intValue > 0) {
    height += WITH_IMAGE_ALBUM_HEIGHT;
  } else {
    height += WITHOUT_IMAGE_ALBUM_HEIGHT;
  }
  /*
  if (_item.source && _item.source.length > 0) {
    size = [_item.source sizeWithFont:FONT(11)
                    constrainedToSize:CGSizeMake(300.0f, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height;
  }
   */
  
  return height;
  
}

- (void)adjustMoreActionsToolbarYCoordinate {
  
  CGRect frame = [_headerView convertedAddPhotoButtonRect];
  
  CGFloat y = frame.origin.y + frame.size.height - MORE_ACTION_TOOLBAR_HEIGHT;
  
  _moreActionToolbar.frame = CGRectMake(_moreActionToolbar.frame.origin.x,
                                        y,
                                        MORE_ACTION_TOOLBAR_WIDTH,
                                        MORE_ACTION_TOOLBAR_HEIGHT);
}

- (UIView *)headerView {
  
  if (nil == _headerView) {
    _headerView = [[ServiceItemHeaderView alloc] initWithFrame:CGRectMake(0, 0,
                                                                          self.view.frame.size.width,
                                                                          [self headerViewHeight])
                                                          item:_item
                                           hashedServiceItemId:self.hashedServiceItemId
                                                           MOC:_MOC
                                        imageDisplayerDelegate:self
                                      clickableElementDelegate:self
                               connectionTriggerHolderDelegate:self];
    
    [_headerView updatePhotoWall];
    
    [self addMoreActionToolbarIfNecessary];
    
  } else {
    
    _headerView.frame = CGRectMake(0, 0, _headerView.frame.size.width, [self headerViewHeight]);
    
    if (!_toolbarAdjusted) {
      [self adjustMoreActionsToolbarYCoordinate];
      _toolbarAdjusted = YES;
    }
  }
  
  return _headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
  if (section == 0) {
    return [self headerView];
  } else {
    return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  
  if (section == 0) {
    return [self headerViewHeight];
  } else {
    return 0.0f;
  }
}

#pragma mark - calculate cell height
- (CGFloat)heightForCouponSection:(NSIndexPath *)indexPath {
  return DEFAULT_CELL_HEIGHT;
}

- (CGFloat)heightForBranchSection:(NSIndexPath *)indexPath {
  return DEFAULT_CELL_HEIGHT;
}

- (CGFloat)mapCellHeight:(NSInteger)cellType {
  CGSize size;
  CGFloat height = 0.0f;
  switch (cellType) {
    case SI_MAP_SEC_ADDRESS_CELL:
    {
      size = [LocaleStringForKey(NSMapTitle, nil) sizeWithFont:BOLD_FONT(14)
                                             constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH,
                                                                          CGFLOAT_MAX)
                                                 lineBreakMode:NSLineBreakByWordWrapping];
      height += MARGIN * 2 + size.height + MARGIN * 2;
      
      if (_item.address && _item.address.length > 0) {
        size = [_item.address sizeWithFont:BOLD_FONT(13)
                         constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
        height += size.height;
      }
      
      break;
    }
      
    case SI_MAP_SEC_TAXI_CELL:
    {
      size = [LocaleStringForKey(NSTaxiTitle, nil) sizeWithFont:BOLD_FONT(14)
                                              constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH,
                                                                           CGFLOAT_MAX)
                                                  lineBreakMode:NSLineBreakByWordWrapping];
      height += MARGIN * 2 + size.height + MARGIN * 2;
      
      size = [LocaleStringForKey(NSShowCardTitle, nil) sizeWithFont:BOLD_FONT(13)
                                                  constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH,
                                                                               CGFLOAT_MAX)
                                                      lineBreakMode:NSLineBreakByWordWrapping];
      height += size.height;
      break;
    }
      
    case SI_MAP_SEC_TRANSIT_CELL:
    {
      size = [LocaleStringForKey(NSTransitTitle, nil) sizeWithFont:BOLD_FONT(14)
                                                 constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH,
                                                                              CGFLOAT_MAX)
                                                     lineBreakMode:NSLineBreakByWordWrapping];
      height += MARGIN * 2 + size.height + MARGIN * 2;
      
      if (_item.transit && _item.transit.length > 0) {
        size = [_item.transit sizeWithFont:BOLD_FONT(13)
                         constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
        height += size.height;
      }
      break;
    }
      
    default:
      return 0.0f;
  }
  return height;
}

- (CGFloat)heightForMapSection:(NSIndexPath *)indexPath
                   sectionType:(NSString *)sectionType {
  
  NSMutableDictionary *cellDic = (self.sectionInfoDic)[sectionType];
  return [self mapCellHeight:((NSNumber *)cellDic[@(indexPath.row)]).intValue];
}

- (CGFloat)heightForSpecialParamSection:(NSIndexPath *)indexPath
                            sectionType:(NSString *)sectionType {
  
  NSInteger sortKey = indexPath.row;
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((sortKey == %d) AND (section.serviceItem.itemId == %@))",
                            sortKey, _item.itemId];
  ServiceItemSectionParam *specialParam = (ServiceItemSectionParam *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                                            entityName:@"ServiceItemSectionParam"
                                                                                             predicate:predicate];
  CGFloat height = 0.0f;
  if (specialParam) {
    CGSize size = [specialParam.name sizeWithFont:BOLD_FONT(14)
                                constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    height = MARGIN * 2 + size.height + MARGIN * 2;
    
    size = [specialParam.value sizeWithFont:BOLD_FONT(13)
                          constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height;
  }
  
  return height;
}

- (CGFloat)introCellHeight:(NSInteger)cellType {
  CGSize size;
  CGFloat height = 0.0f;
  
  switch (cellType) {
    case SI_INTRO_SEC_BIO_CELL:
    {
      size = [LocaleStringForKey(NSIntroTitle, nil) sizeWithFont:BOLD_FONT(14)
                                               constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH,
                                                                            CGFLOAT_MAX)
                                                   lineBreakMode:NSLineBreakByWordWrapping];
      height += MARGIN * 2 + size.height + MARGIN * 2;
      
      if (_item.bio && _item.bio.length > 0) {
        size = [_item.bio sizeWithFont:BOLD_FONT(13)
                     constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                         lineBreakMode:NSLineBreakByWordWrapping];
        height += size.height;
      }
      break;
    }
      
    case SI_INTRO_SEC_SP_CELL:
    {
      NSString *title = nil;
      switch (_item.categoryId.longLongValue) {
        case FOOD_DELIVERY_CATEGORY_ID:
        case RESTAURANT_CATEGORY_ID:
        case PRO_CATEGORY_ID:
          title = LocaleStringForKey(NSServiceProviderTitle, nil);
          break;
          
        case NIGHTLIFE_CATEGORY_ID:
        case COUPON_CATEGORY_ID:
          title = LocaleStringForKey(NSVenueTitle, nil);
          break;
          
        case ACTIVITY_CATEGORY_ID:
          title = LocaleStringForKey(NSOrganizerTitle, nil);
          break;
          
        case JOBS_CATEGORY_ID:
          title = LocaleStringForKey(NSRecruiterTitle, nil);
          break;
          
        default:
          title = LocaleStringForKey(NSServiceProviderTitle, nil);
          break;
      }
      
      size = [title sizeWithFont:BOLD_FONT(14)
               constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                   lineBreakMode:NSLineBreakByWordWrapping];
      
      height += MARGIN * 2 + size.height + MARGIN;
      
      if (_item.providerName && _item.providerName.length > 0) {
        size = [_item.providerName sizeWithFont:BOLD_FONT(13)
                              constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        height += size.height + MARGIN;
      }
      break;
    }
      
    default:
      return 0.0f;
  }
  
  return height;
}

- (CGFloat)heightForIntroSection:(NSIndexPath *)indexPath
                     sectionType:(NSString *)sectionType {
  
  NSMutableDictionary *cellDic = (self.sectionInfoDic)[sectionType];
  return [self introCellHeight:((NSNumber *)cellDic[@(indexPath.row)]).intValue];
  
}

- (CGFloat)heightForCommentCell {
  CGFloat height = 0.0f;
  CGSize size = [LocaleStringForKey(NSCommentTitle, nil) sizeWithFont:BOLD_FONT(14)
                                                    constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH,
                                                                                 CGFLOAT_MAX)
                                                        lineBreakMode:NSLineBreakByWordWrapping];
  height += MARGIN * 2 + size.height + MARGIN;
  
  if (_item.latestCommenterName && _item.latestCommenterName.length > 0) {
    size = [_item.latestCommenterName sizeWithFont:FONT(11)
                                 constrainedToSize:CGSizeMake(200.0f, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height + MARGIN;
  }
  
  if (_item.latestComment && _item.latestComment.length > 0) {
    size = [_item.latestComment sizeWithFont:BOLD_FONT(13)
                           constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height + MARGIN * 2;
  }
  
  if (height < DEFAULT_CELL_HEIGHT) {
    height = DEFAULT_CELL_HEIGHT;
  }
  return height;
}

- (CGFloat)contactCellHeight:(NSInteger)cellType {
  
  CGSize size;
  CGFloat height = 0.0f;
  switch (cellType) {
    case SI_CONTACT_SEC_PHONE_CELL:
    {
      size = [LocaleStringForKey(NSPhoneTitle, nil) sizeWithFont:BOLD_FONT(14)
                                               constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH,
                                                                            CGFLOAT_MAX)
                                                   lineBreakMode:NSLineBreakByWordWrapping];
      height += MARGIN * 2 + size.height + MARGIN * 2;
      
      if (_item.phoneNumber && _item.phoneNumber.length > 0) {
        size = [_item.phoneNumber sizeWithFont:BOLD_FONT(13)
                             constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        height += size.height;
      }
      break;
    }
      
    case SI_CONTACT_SEC_WEB_CELL:
    {
      size = [LocaleStringForKey(NSWebSiteTitle, nil) sizeWithFont:BOLD_FONT(14)
                                                 constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                                     lineBreakMode:NSLineBreakByWordWrapping];
      height += MARGIN * 2 + size.height + MARGIN * 2;
      
      if (_item.link && _item.link.length > 0) {
        size = [_item.link sizeWithFont:BOLD_FONT(13)
                      constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
        height += size.height;
      }
      break;
    }
      
    case SI_CONTACT_SEC_EMAIL_CELL:
    {
      size = [LocaleStringForKey(NSEmailTitle, nil) sizeWithFont:BOLD_FONT(14)
                                               constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                                   lineBreakMode:NSLineBreakByWordWrapping];
      height += MARGIN * 2 + size.height + MARGIN * 2;
      
      if (_item.email && _item.email.length > 0) {
        size = [_item.email sizeWithFont:BOLD_FONT(13)
                       constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];
        height += size.height;
      }
      break;
    }
      
    default:
      return 0.0f;
      
  }
  
  return height;
}


- (CGFloat)heightForContactSection:(NSIndexPath *)indexPath
                       sectionType:(NSString *)sectionType {
  
  NSMutableDictionary *cellDic = (self.sectionInfoDic)[sectionType];
  return [self contactCellHeight:((NSNumber *)cellDic[@(indexPath.row)]).intValue];
}

- (CGFloat)heightForRecommendationSecion:(NSIndexPath *)index {
  
  CGSize size = [LocaleStringForKey(NSRecommendationsTitle, nil) sizeWithFont:BOLD_FONT(14)
                                                            constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                                                lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat height = MARGIN * 2 + size.height + MARGIN * 2;
  
  if (_item.recommendedItemNames && _item.recommendedItemNames.length > 0) {
    size = [_item.recommendedItemNames sizeWithFont:BOLD_FONT(13)
                                  constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH,
                                                               RECOMMENDED_ITEMS_NAME_MAX_HEIGHT)
                                      lineBreakMode:NSLineBreakByTruncatingTail];
    height += size.height;
  }
  
  if (height < DEFAULT_CELL_HEIGHT) {
    height = DEFAULT_CELL_HEIGHT;
  }
  return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((sortKey == %d) AND (serviceItem.itemId == %@))",
                            indexPath.section, _item.itemId];
  ServiceItemSection *sectionItem = (ServiceItemSection *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                                 entityName:@"ServiceItemSection"
                                                                                  predicate:predicate];
  
  if ([sectionItem.sectionType isEqualToString:ITEM_COUPON_SEC]) {
    
    return [self heightForCouponSection:indexPath];
  } else if ([sectionItem.sectionType isEqualToString:ITEM_RECOMMENDED_ITEM_SEC]) {
    
    return [self heightForRecommendationSecion:indexPath];
  } else if ([sectionItem.sectionType isEqualToString:ITEM_BRANCH_SEC]) {
    
    return [self heightForBranchSection:indexPath];
  } else if ([sectionItem.sectionType isEqualToString:ITEM_CONTACT_SEC]) {
    
    return [self heightForContactSection:indexPath
                             sectionType:sectionItem.sectionType];
    
  } else if ([sectionItem.sectionType isEqualToString:ITEM_ADDRESS_SEC]) {
    
    return [self heightForMapSection:indexPath
                         sectionType:sectionItem.sectionType];
    
  } else if ([sectionItem.sectionType isEqualToString:ITEM_INTRO_SEC]) {
    
    return [self heightForIntroSection:indexPath
                           sectionType:sectionItem.sectionType];
  } else if ([sectionItem.sectionType isEqualToString:ITEM_COMMENT_SEC]) {
    return [self heightForCommentCell];
  } else if ([sectionItem.sectionType isEqualToString:ITEM_SPECIAL_SEC]) {
    return [self heightForSpecialParamSection:indexPath
                                  sectionType:sectionItem.sectionType];
  } else {
    return 0.0f;
  }
}

#pragma mark - draw cell
- (CouponInfoCell *)drawCouponSection:(NSIndexPath *)indexPath {
  
  NSInteger sortKey = indexPath.row;
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((sortKey == %d) AND (serviceItem.itemId == %@))",
                            sortKey, _item.itemId];
  CouponItem *couponItem = (CouponItem *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                entityName:@"CouponItem"
                                                                 predicate:predicate];
  if (couponItem) {
    static NSString *couponCellIdentifier = @"couponCell";
    
    CouponInfoCell *cell = (CouponInfoCell *)[_tableView dequeueReusableCellWithIdentifier:couponCellIdentifier];
    if (nil == cell) {
      cell = [[[CouponInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:couponCellIdentifier] autorelease];
    }
    
    if (_item.couponInfos.count == 1) {
      [cell drawShadowCell:couponItem.name
                    height:[self heightForCouponSection:indexPath] + 1.0f
          needCornerRadius:YES];
    } else {
      if (sortKey == 0) {
        // first one
        [cell drawNoShadowCell:couponItem.name needCornerRadius:YES];
      } else if (sortKey == _item.couponInfos.count - 1) {
        
        // last one
        [cell drawShadowCell:couponItem.name
                      height:[self heightForCouponSection:indexPath] + 1.0f
            needCornerRadius:NO];
        
      } else {
        // middle elements
        [cell drawNoShadowCell:couponItem.name needCornerRadius:NO];
      }
    }
    
    return cell;
    
  } else {
    return nil;
  }
}

- (UITableViewCell *)drawSpecialParamSection:(NSIndexPath *)indexPath {
  
  NSInteger sortKey = indexPath.row;
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((sortKey == %d) AND (serviceItem.itemId == %@))",
                            indexPath.section, _item.itemId];
  
  ServiceItemSection *sectionItem = (ServiceItemSection *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                                 entityName:@"ServiceItemSection"
                                                                                  predicate:predicate];
  
  predicate = [NSPredicate predicateWithFormat:@"((sortKey == %d) AND (section.serviceItem.itemId == %@))",
               sortKey, _item.itemId];
  ServiceItemSectionParam *specialParam = (ServiceItemSectionParam *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                                            entityName:@"ServiceItemSectionParam"
                                                                                             predicate:predicate];
  if (specialParam) {
    static NSString *cellIdentifier = @"specialParamCell";
    if (indexPath.row < sectionItem.specialParams.count - 1) {
      return [self drawNoShadowVerticalInfoCell:specialParam.name
                                       subTitle:nil
                                        content:specialParam.value
                                 cellIdentifier:cellIdentifier
                                      clickable:NO];
    } else {
      return [self drawShadowVerticalInfoCell:specialParam.name
                                     subTitle:nil
                                      content:specialParam.value
                               cellIdentifier:cellIdentifier
                                       height:[self heightForSpecialParamSection:indexPath
                                                                     sectionType:ITEM_SPECIAL_SEC]
                                    clickable:NO];
    }
  } else {
    return nil;
  }
}

- (UITableViewCell *)drawMapCell:(NSInteger)cellType
                       indexPath:(NSIndexPath *)indexPath
                       cellCount:(NSInteger)cellCount {
  
  switch (cellType) {
    case SI_MAP_SEC_ADDRESS_CELL:
    {
      static NSString *cellIdentifier = @"addressCell";
      if (indexPath.row < cellCount - 1) {
        return [self drawNoShadowVerticalInfoCell:LocaleStringForKey(NSAddressTitle, nil)
                                         subTitle:nil
                                          content:_item.address
                                   cellIdentifier:cellIdentifier
                                        clickable:YES];
      } else {
        return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSAddressTitle, nil)
                                       subTitle:nil
                                        content:_item.address
                                 cellIdentifier:cellIdentifier
                                         height:[self heightForMapSection:indexPath
                                                              sectionType:ITEM_ADDRESS_SEC] + 1.0f
                                      clickable:YES];
      }
    }
      
    case SI_MAP_SEC_TAXI_CELL:
    {
      static NSString *cellIdentifier = @"taxiCell";
      
      if (indexPath.row < cellCount - 1) {
        return [self drawNoShadowVerticalInfoCell:LocaleStringForKey(NSTaxiTitle, nil)
                                         subTitle:nil
                                          content:LocaleStringForKey(NSShowCardTitle, nil)
                                   cellIdentifier:cellIdentifier
                                        clickable:YES];
      } else {
        return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSTaxiTitle, nil)
                                       subTitle:nil
                                        content:LocaleStringForKey(NSShowCardTitle, nil)
                                 cellIdentifier:cellIdentifier
                                         height:[self heightForMapSection:indexPath
                                                              sectionType:ITEM_ADDRESS_SEC] + 1.0f
                                      clickable:YES];
      }
    }
      
    case SI_MAP_SEC_TRANSIT_CELL:
    {
      static NSString *cellIdentifier = @"transitCell";
      if (indexPath.row < cellCount - 1) {
        return [self drawNoShadowVerticalInfoCell:LocaleStringForKey(NSTransitTitle, nil)
                                         subTitle:nil
                                          content:_item.transit
                                   cellIdentifier:cellIdentifier
                                        clickable:NO];
      } else {
        return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSTransitTitle, nil)
                                       subTitle:nil
                                        content:_item.transit
                                 cellIdentifier:cellIdentifier
                                         height:[self heightForMapSection:indexPath
                                                              sectionType:ITEM_ADDRESS_SEC] + 1.0f
                                      clickable:NO];
      }
    }
      
    default:
      return nil;
  }
  
}

- (UITableViewCell *)drawMapSection:(NSIndexPath *)indexPath
                        sectionType:(NSString *)sectionType {
  
  NSMutableDictionary *cellDic = (self.sectionInfoDic)[sectionType];
  return [self drawMapCell:((NSNumber *)cellDic[@(indexPath.row)]).intValue
                 indexPath:indexPath
                 cellCount:cellDic.count];
  
}

- (UITableViewCell *)drawIntroCell:(NSInteger)cellType
                         indexPath:(NSIndexPath *)indexPath
                         cellCount:(NSInteger)cellCount {
  switch (cellType) {
    case SI_INTRO_SEC_BIO_CELL:
    {
      static NSString *introCellIdentifier = @"introCell";
      
      NSString *title = LocaleStringForKey(NSIntroTitle, nil);
      if (_item.categoryId.longLongValue == JOBS_CATEGORY_ID) {
        title = LocaleStringForKey(NSJDTitle, nil);
      }
      
      if (indexPath.row < cellCount - 1) {
        return [self drawNoShadowVerticalInfoCell:title
                                         subTitle:nil
                                          content:_item.bio
                                   cellIdentifier:introCellIdentifier
                                        clickable:NO];
      } else {
        return [self drawShadowVerticalInfoCell:title
                                       subTitle:nil
                                        content:_item.bio
                                 cellIdentifier:introCellIdentifier
                                         height:[self heightForIntroSection:indexPath
                                                                sectionType:ITEM_INTRO_SEC] + 1.0f
                                      clickable:NO];
      }
    }
      
    case SI_INTRO_SEC_SP_CELL:
    {
      static NSString *cellIdentifier = @"spCell";
      
      NSString *title = nil;
      switch (_item.categoryId.longLongValue) {
        case FOOD_DELIVERY_CATEGORY_ID:
        case RESTAURANT_CATEGORY_ID:
        case PRO_CATEGORY_ID:
          title = LocaleStringForKey(NSServiceProviderTitle, nil);
          break;
          
        case NIGHTLIFE_CATEGORY_ID:
        case COUPON_CATEGORY_ID:
          title = LocaleStringForKey(NSVenueTitle, nil);
          break;
          
        case ACTIVITY_CATEGORY_ID:
          title = LocaleStringForKey(NSOrganizerTitle, nil);
          break;
          
        case JOBS_CATEGORY_ID:
          title = LocaleStringForKey(NSRecruiterTitle, nil);
          break;
          
        default:
          title = LocaleStringForKey(NSServiceProviderTitle, nil);
          break;
      }
      
      if (indexPath.row < cellCount - 1) {
        return [self drawNoShadowVerticalInfoCell:title
                                         subTitle:nil
                                          content:_item.providerName
                                   cellIdentifier:cellIdentifier
                                        clickable:YES];
      } else {
        return [self drawShadowVerticalInfoCell:title
                                       subTitle:nil
                                        content:_item.providerName
                                 cellIdentifier:cellIdentifier
                                         height:[self heightForIntroSection:indexPath
                                                                sectionType:ITEM_INTRO_SEC] + 1.0f
                                      clickable:YES];
      }
      
    }
      
    default:
      return nil;
  }
}

- (UITableViewCell *)drawIntroSection:(NSIndexPath *)indexPath
                          sectionType:(NSString *)sectionType {
  
  NSMutableDictionary *cellDic = (self.sectionInfoDic)[sectionType];
  return [self drawIntroCell:((NSNumber *)cellDic[@(indexPath.row)]).intValue
                   indexPath:indexPath
                   cellCount:cellDic.count];
}

- (UITableViewCell *)drawCommentSection:(NSIndexPath *)indexPath {
  
  static NSString *cellIdentifier = @"commentCell";
  
  self.commentIndexPath = indexPath;
  
  ServiceLatestCommentCell *cell = (ServiceLatestCommentCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[ServiceLatestCommentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:cellIdentifier] autorelease];
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  NSString *timeText = nil;
  if (_item.commentCount.intValue > 0) {
    timeText = _item.latestCommentElapsedTime;
  }
  
  [cell drawCell:LocaleStringForKey(NSReviewsTitle, nil)
        subTitle:[NSString stringWithFormat:@"%@", _item.commentCount]
        location:nil
         comment:_item.latestComment
   commenterName:_item.latestCommenterName
            date:timeText
      cellHeight:[self heightForCommentCell] + 1.0f];
  
  return cell;
}

- (UITableViewCell *)drawContactCell:(NSInteger)cellType
                           indexPath:(NSIndexPath *)indexPath
                           cellCount:(NSInteger)cellCount {
  switch (cellType) {
    case SI_CONTACT_SEC_PHONE_CELL:
    {
      static NSString *cellIdentifier = @"phoneCell";
      
      BOOL clickable = (_item.phoneNumber && _item.phoneNumber.length > 1) ? YES : NO;
      if (indexPath.row < cellCount - 1) {
        return [self drawNoShadowVerticalInfoCell:LocaleStringForKey(NSPhoneTitle, nil)
                                         subTitle:nil
                                          content:_item.phoneNumber
                                   cellIdentifier:cellIdentifier
                                        clickable:clickable];
      } else {
        // last cell in current section, then draw shadow in section button
        return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSPhoneTitle, nil)
                                       subTitle:nil
                                        content:_item.phoneNumber
                                 cellIdentifier:cellIdentifier
                                         height:[self heightForContactSection:indexPath
                                                                  sectionType:ITEM_CONTACT_SEC] + 1.0f
                                      clickable:clickable];
      }
    }
      
    case SI_CONTACT_SEC_WEB_CELL:
    {
      static NSString *cellIdentifier = @"webCell";
      
      if (indexPath.row < cellCount - 1) {
        return [self drawNoShadowVerticalInfoCell:LocaleStringForKey(NSWebSiteTitle, nil)
                                         subTitle:nil
                                          content:_item.link
                                   cellIdentifier:cellIdentifier
                                        clickable:YES];
      } else {
        // last cell in current section, then draw shadow in section button
        return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSWebSiteTitle, nil)
                                       subTitle:nil
                                        content:_item.link
                                 cellIdentifier:cellIdentifier
                                         height:[self heightForContactSection:indexPath
                                                                  sectionType:ITEM_CONTACT_SEC]
                                      clickable:YES];
      }
    }
      
    case SI_CONTACT_SEC_EMAIL_CELL:
    {
      
      static NSString *cellIdentifier = @"emailCell";
      
      if (indexPath.row < cellCount - 1) {
        return [self drawNoShadowVerticalInfoCell:LocaleStringForKey(NSEmailTitle, nil)
                                         subTitle:nil
                                          content:_item.email
                                   cellIdentifier:cellIdentifier
                                        clickable:YES];
      } else {
        
        // last cell in current section, then draw shadow in section button
        return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSEmailTitle, nil)
                                       subTitle:nil
                                        content:_item.email
                                 cellIdentifier:cellIdentifier
                                         height:[self heightForContactSection:indexPath
                                                                  sectionType:ITEM_CONTACT_SEC]
                                      clickable:YES];
      }
    }
      
    default:
      return nil;
  }
  
}

- (UITableViewCell *)drawContactSection:(NSIndexPath *)indexPath
                            sectionType:(NSString *)sectionType {
  
  NSMutableDictionary *cellDic = (self.sectionInfoDic)[sectionType];
  return [self drawContactCell:((NSNumber *)cellDic[@(indexPath.row)]).intValue
                     indexPath:indexPath
                     cellCount:cellDic.count];
}

- (UITableViewCell *)drawRecommendedSection:(NSIndexPath *)indexPath {
  
  static NSString *cellIdentifier = @"recommendedItemCell";
  
  VerticalLayoutItemInfoCell *cell = (VerticalLayoutItemInfoCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[VerticalLayoutItemInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:cellIdentifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  
  [cell drawShadowInfoCell:LocaleStringForKey(NSRecommendationsTitle, nil)
                  subTitle:nil
                   content:_item.recommendedItemNames
  contentConstrainedHeight:RECOMMENDED_ITEMS_NAME_MAX_HEIGHT
                cellheight:[self heightForRecommendationSecion:indexPath] + 1.0f
             lineBreakMode:NSLineBreakByTruncatingTail
                 clickable:YES];
  return cell;
}

- (UITableViewCell *)drawBranchSection:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"branchItemCell";
  
  return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSOtherBranchTitle, nil)
                                 subTitle:nil
                                  content:nil
                           cellIdentifier:cellIdentifier
                                   height:[self heightForBranchSection:indexPath]
                                clickable:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((sortKey == %d) AND (serviceItem.itemId == %@))",
                            indexPath.section, _item.itemId];
  ServiceItemSection *sectionItem = (ServiceItemSection *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                                 entityName:@"ServiceItemSection"
                                                                                  predicate:predicate];
  
  if ([sectionItem.sectionType isEqualToString:ITEM_COUPON_SEC]) {
    return [self drawCouponSection:indexPath];
  } else if ([sectionItem.sectionType isEqualToString:ITEM_RECOMMENDED_ITEM_SEC]) {
    return [self drawRecommendedSection:indexPath];
  } else if ([sectionItem.sectionType isEqualToString:ITEM_CONTACT_SEC]) {
    
    return [self drawContactSection:indexPath
                        sectionType:sectionItem.sectionType];
    
  } else if ([sectionItem.sectionType isEqualToString:ITEM_ADDRESS_SEC]) {
    
    return [self drawMapSection:indexPath
                    sectionType:sectionItem.sectionType];    
  } else if ([sectionItem.sectionType isEqualToString:ITEM_INTRO_SEC]) {
    
    return [self drawIntroSection:indexPath
                      sectionType:sectionItem.sectionType];
  } else if ([sectionItem.sectionType isEqualToString:ITEM_COMMENT_SEC]) {

    return [self drawCommentSection:indexPath];
  } else if ([sectionItem.sectionType isEqualToString:ITEM_SPECIAL_SEC]) {

    return [self drawSpecialParamSection:indexPath];
  } else if ([sectionItem.sectionType isEqualToString:ITEM_BRANCH_SEC]) {

    return [self drawBranchSection:indexPath];
  } else {
    return nil;
  }
}

#pragma mark - selection row actions

- (void)selectCouponSection:(NSIndexPath *)indexPath {
  NSInteger sortKey = indexPath.row;
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((sortKey == %d) AND (serviceItem.itemId == %@))",
                            sortKey, _item.itemId];
  CouponItem *couponItem = (CouponItem *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                entityName:@"CouponItem"
                                                                 predicate:predicate];
  CouponDetailViewController *couponDetailVC = [[[CouponDetailViewController alloc] initWithMOC:_MOC
                                                                                         holder:_holder
                                                                               backToHomeAction:_backToHomeAction
                                                                                     couponItem:couponItem] autorelease];
  [self.navigationController pushViewController:couponDetailVC animated:YES];
}

- (void)clickMapCell:(NSInteger)cellType {
  switch (cellType) {
    case SI_MAP_SEC_ADDRESS_CELL:
    {
      if (_item.latlagAttached.boolValue) {
        MapViewController *mapVC = [[[MapViewController alloc] initWithLatitude:_item.latitude.doubleValue
                                                                      longitude:_item.longitude.doubleValue
                                                           allowLaunchGoogleMap:YES] autorelease];
        
        WXWNavigationController *navVC = [[[WXWNavigationController alloc] initWithRootViewController:mapVC] autorelease];
        [self.navigationController presentModalViewController:navVC animated:YES];
      }
      break;
    }
      
    case SI_MAP_SEC_TAXI_CELL:
    {
      TaxiCardViewController *taxiCardVC = [[[TaxiCardViewController alloc] initWithAddressPart1:_item.cnAddressPart1
                                                                                           part2:_item.cnAddressPart2
                                                                                           part3:_item.cnAddressPart3
                                                                                            name:_item.itemName
                                                                                          holder:_holder
                                                                                backToHomeAction:@selector(backToHomepage:)
                                                                                        latitude:_item.latitude.doubleValue
                                                                                       longitude:_item.longitude.doubleValue] autorelease];
      [self.navigationController pushViewController:taxiCardVC animated:YES];
      break;
    }
      
    default:
      break;
  }
}

- (void)selectMapSection:(NSIndexPath *)indexPath sectionType:(NSString *)sectionType {
  NSMutableDictionary *cellDic = (self.sectionInfoDic)[sectionType];
  [self clickMapCell:((NSNumber *)cellDic[@(indexPath.row)]).intValue];
}

- (void)selectIntroSection:(NSIndexPath *)indexPath sectionType:(NSString *)sectionType {
  
  NSMutableDictionary *cellDic = (self.sectionInfoDic)[sectionType];
  
  if (((NSNumber *)cellDic[@(indexPath.row)]).intValue == SI_INTRO_SEC_SP_CELL) {
    ServiceProviderViewController *profileVC = [[[ServiceProviderViewController alloc] initWithMOC:_MOC
                                                                                            holder:_holder
                                                                                  backToHomeAction:_backToHomeAction
                                                                                              spId:_item.providerId.longLongValue] autorelease];
    
    [self.navigationController pushViewController:profileVC animated:YES];
  }
}

- (void)selectCommentSection:(NSIndexPath *)indexPath {
  
  HandyCommentListViewController *newsCommentListVC = [[[HandyCommentListViewController alloc] initWithMOC:_MOC
                                                                                                    holder:_holder
                                                                                          backToHomeAction:_backToHomeAction
                                                                                                    itemId:_item.itemId.longLongValue
                                                                                                   brandId:_item.brandId.longLongValue
                                                                                               contentType:SEND_SERVICE_ITEM_COMMENT_TY
                                                                                      itemUploaderDelegate:self] autorelease];
  
  [self.navigationController pushViewController:newsCommentListVC animated:YES];
  
  _needUpdateCommentCount = YES;
}

- (void)clickContactCell:(NSInteger)cellType {
  switch (cellType) {
    case SI_CONTACT_SEC_PHONE_CELL:
    {
      if (_item.phoneNumber && _item.phoneNumber.length > 2) {
        
        _actionOwnerType = CALL_AS_TY;
        
        UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSCallTitle, nil)
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:nil] autorelease];
        for (PhoneNumber *phoneNumber in _item.phoneNumbers) {
          [sheet addButtonWithTitle:phoneNumber.desc];
        }
        //[sheet addButtonWithTitle:_item.phoneNumber];
        [sheet addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
        sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
        [sheet showInView:self.view];
      }
      break;
    }
      
    case SI_CONTACT_SEC_WEB_CELL:
    {
      if (_item.link && _item.link.length > 2) {
        [CommonUtils openWebView:self.navigationController
                           title:_item.itemName
                             url:_item.link
                 needCloseButton:YES
                  needNavigation:YES
                  needHomeButton:NO];

      }
      break;
    }
      
    case SI_CONTACT_SEC_EMAIL_CELL:
    {
      if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposeVC = [[[MFMailComposeViewController alloc] init] autorelease];
        
        mailComposeVC.mailComposeDelegate = self;
        [mailComposeVC setToRecipients:@[_item.email]];
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


- (void)selectContactSection:(NSIndexPath *)indexPath sectionType:(NSString *)sectionType {
  
  NSMutableDictionary *cellDic = (self.sectionInfoDic)[sectionType];
  [self clickContactCell:((NSNumber *)cellDic[@(indexPath.row)]).intValue];
  
}

- (void)selectRecommendedItemSection:(NSIndexPath *)indexPath {
  /*
  RecommendedItemListViewController *listVC = [[[RecommendedItemListViewController alloc] initWithMOC:_MOC
                                                                                               holder:_holder
                                                                                     backToHomeAction:_backToHomeAction
                                                                                        serviceItemId:_item.itemId.longLongValue] autorelease];
  listVC.title = LocaleStringForKey(NSRecommendationsTitle, nil);
  [self.navigationController pushViewController:listVC animated:YES];
   */
  CouponViewController *couponVC = [[[CouponViewController alloc] initWithMOC:_MOC
                                                                        brand:self.brand] autorelease];
  couponVC.title = LocaleStringForKey(NSCouponInfoTitle, nil);
  [self.navigationController pushViewController:couponVC animated:YES];
}

- (void)selectBranchItemSection {
  BranchListViewController *branchListVC = [[[BranchListViewController alloc] initWithMOC:_MOC] autorelease];
  branchListVC.title = LocaleStringForKey(NSBranchTitle, nil);
  [self.navigationController pushViewController:branchListVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((sortKey == %d) AND (serviceItem.itemId == %@))",
                            indexPath.section, _item.itemId];
  ServiceItemSection *sectionItem = (ServiceItemSection *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                                 entityName:@"ServiceItemSection"
                                                                                  predicate:predicate];
  
  if ([sectionItem.sectionType isEqualToString:ITEM_COUPON_SEC]) {
    [self selectCouponSection:indexPath];
  } else if ([sectionItem.sectionType isEqualToString:ITEM_RECOMMENDED_ITEM_SEC]) {
    
    [self selectRecommendedItemSection:indexPath];
    //[self selectBranchItemSection];
    
  } else if ([sectionItem.sectionType isEqualToString:ITEM_CONTACT_SEC]) {
    
    [self selectContactSection:indexPath sectionType:sectionItem.sectionType];
    
  } else if ([sectionItem.sectionType isEqualToString:ITEM_ADDRESS_SEC]) {
    
    [self selectMapSection:indexPath sectionType:sectionItem.sectionType];
    
  } else if ([sectionItem.sectionType isEqualToString:ITEM_INTRO_SEC]) {
    
    [self selectIntroSection:indexPath sectionType:sectionItem.sectionType];
  } else if ([sectionItem.sectionType isEqualToString:ITEM_COMMENT_SEC]) {
    [self selectCommentSection:indexPath];
  } else if ([sectionItem.sectionType isEqualToString:ITEM_BRANCH_SEC]) {
    [self selectBranchItemSection];
  }
}

@end
