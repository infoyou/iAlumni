//
//  ProfileSettingViewController.m
//  iAlumni
//
//  Created by Adam on 13-5-22.
//
//

#import "ProfileSettingViewController.h"
#import "UIWebViewController.h"
#import "AppManager.h"
#import "ECHandyAvatarBrowser.h"
#import "ECPhotoPickerOverlayViewController.h"
#import "PhotoFetcherView.h"
#import "XMLParser.h"
#import "UserProfileHeaderView.h"
#import "UIUtils.h"
#import "CommonUtils.h"


enum {
  INFO_SEC_3RD_SNS_SEC,
  INFO_SEC_PROF_SEC,
  INFO_SEC_CONTACT_SEC,
  INFO_SEC_COMPANY_SEC,
};

#define COUNT  4

@interface ProfileSettingViewController ()
@property (nonatomic, retain) ECPhotoPickerOverlayViewController *pickerOverlayVC;
@property (nonatomic, retain) UIImage *selectedPhoto;
@end

@implementation ProfileSettingViewController

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                                          holder:nil
                                backToHomeAction:nil
                           needRefreshHeaderView:NO
                           needRefreshFooterView:NO
                                      tableStyle:UITableViewStyleGrouped
                                      needGoHome:NO];
  if (self) {
    
  }
  return self;
}

- (void)dealloc {
  
  self.pickerOverlayVC = nil;
  self.selectedPhoto = nil;
  
  //RELEASE_OBJ(_headerView);
  
  [super dealloc];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [_tableView reloadData];
  
  [_headerView refreshModifyButtonTitle];

}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (UIView *)sectionHeaderView {
  
  if (nil == _headerView) {
    _headerView = [[UserProfileHeaderView alloc] initWithFrame:CGRectMake(0, 0,
                                                                          self.view.frame.size.width,
                                                                          USERDETAIL_PHOTO_HEIGHT + PHOTO_MARGIN * 2 + MARGIN * 4)
                                        imageDisplayerDelegate:self
                                      clickableElementDelegate:self
                                                        target:self
                                                        action:@selector(changeAvatar:)];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  }
  
  return _headerView;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return COUNT;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case INFO_SEC_3RD_SNS_SEC:
      
      return [self configureWithTitleImageCell:@"thirdPartySNSCell"
                                         title:LocaleStringForKey(NSProfileAccountTitle, nil)
                                    badgeCount:0
                                       content:nil
                                         image:[UIImage imageNamed:@"weibo.png"]
                                     indexPath:indexPath
                                     clickable:YES
                                    dropShadow:YES
                                  cornerRadius:GROUPED_CELL_CORNER_RADIUS];
      
    case INFO_SEC_PROF_SEC:
      
      return [self configureWithTitleImageCell:@"profileCell"
                                         title:LocaleStringForKey(NSProfileBaseTitle, nil)
                                    badgeCount:0
                                       content:nil
                                         image:[UIImage imageNamed:@"personalInfo.png"]
                                     indexPath:indexPath
                                     clickable:YES
                                    dropShadow:YES
                                  cornerRadius:GROUPED_CELL_CORNER_RADIUS];
      
    case INFO_SEC_CONTACT_SEC:
      
      return [self configureWithTitleImageCell:@"contactCell"
                                         title:LocaleStringForKey(NSProfileHomeTitle, nil)
                                    badgeCount:0
                                       content:LocaleStringForKey(NSProfileHomeNoteMsg, nil)
                                         image:[UIImage imageNamed:@"addressContact.png"]
                                     indexPath:indexPath
                                     clickable:YES
                                    dropShadow:YES
                                  cornerRadius:GROUPED_CELL_CORNER_RADIUS];
      
    case INFO_SEC_COMPANY_SEC:
      
      return [self configureWithTitleImageCell:@"companyCell"
                                         title:LocaleStringForKey(NSProfileCompanyTitle, nil)
                                    badgeCount:0
                                       content:nil
                                         image:[UIImage imageNamed:@"companyContact.png"]
                                     indexPath:indexPath
                                     clickable:YES
                                    dropShadow:YES
                                  cornerRadius:GROUPED_CELL_CORNER_RADIUS];
      
      
    default:
      return nil;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  NSString *url = NULL_PARAM_VALUE;
  
  switch (indexPath.section) {
      
    case INFO_SEC_PROF_SEC:
    {
      url = PROFILE_BASE_URL;
      break;
    }
      
    case INFO_SEC_CONTACT_SEC:
    {
      url = PROFILE_HOME_URL;
      break;
    }
      
    case INFO_SEC_COMPANY_SEC:
    {
      url = PROFILE_COMPANY_URL;
      break;
    }
      
    case INFO_SEC_3RD_SNS_SEC:
    {
      url = PROFILE_ACCOUNT_URL;
      break;
    }
      
    default:
      break;
  }
  
  NSString *targetUrl = [NSString stringWithFormat:@"%@%@&user_id=%@&locale=%@&plat=%@&version=%@&sessionId=%@&person_id=%@", [AppManager instance].hostUrl, url, [AppManager instance].userId, [WXWSystemInfoManager instance].currentLanguageDesc, PLATFORM, VERSION,[AppManager instance].sessionId, [AppManager instance].personId];
  
    NSLog(@"targetUrl is %@", targetUrl);
    
  UIWebViewController *webVC = [[[UIWebViewController alloc] initWithNeedAdjustForiOS7:YES] autorelease];
  UINavigationController *webViewNav = [[[UINavigationController alloc] initWithRootViewController:webVC] autorelease];
  webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
  webVC.strUrl = targetUrl;
  
  [self presentModalViewController:webViewNav
                          animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
      
    case INFO_SEC_PROF_SEC:
      return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSProfileBaseTitle, nil)
                                              content:nil
                                            indexPath:indexPath
                                            clickable:YES];
      
    case INFO_SEC_CONTACT_SEC:
      return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSProfileHomeTitle, nil)
                                              content:[LocaleStringForKey(NSProfileHomeNoteMsg, nil) stringByReplacingOccurrencesOfString:@" " withString:NULL_PARAM_VALUE]
                                            indexPath:indexPath
                                            clickable:YES];
      
    case INFO_SEC_COMPANY_SEC:
      return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSProfileCompanyTitle, nil)
                                              content:nil
                                            indexPath:indexPath
                                            clickable:YES];
      
    case INFO_SEC_3RD_SNS_SEC:
      return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSProfileAccountTitle, nil)
                                              content:nil
                                            indexPath:indexPath
                                            clickable:YES];
      
    default:
      return 0;
  }
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  switch (section) {
    case INFO_SEC_3RD_SNS_SEC:
      return USERDETAIL_PHOTO_HEIGHT + PHOTO_MARGIN * 2 + MARGIN * 4;
      
    default:
      return 0;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  switch (section) {
    case INFO_SEC_3RD_SNS_SEC:
      return [self sectionHeaderView];
      
    default:
      return nil;
  }
}
*/

#pragma mark - change photo

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType {
  
  _photoSourceType = sourceType;
  
  self.pickerOverlayVC = [[[ECPhotoPickerOverlayViewController alloc] initWithSourceType:_photoSourceType
                                                                                delegate:self
                                                                        uploaderDelegate:self
                                                                               takerType:USER_AVATAR_TY
                                                                                     MOC:_MOC] autorelease];
  
  [self.pickerOverlayVC arrangeViews];
  
  [self presentModalViewController:self.pickerOverlayVC.imagePicker animated:YES];
  
}

- (void)changeAvatar:(id)sender {
  
  UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
  
  if (HAS_CAMERA) {
    [as addButtonWithTitle:LocaleStringForKey(NSTakePhotoTitle, nil)];
    [as addButtonWithTitle:LocaleStringForKey(NSChooseExistingPhotoTitle, nil)];
  } else {
    [as addButtonWithTitle:LocaleStringForKey(NSChooseExistingPhotoTitle, nil)];
  }
  
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  
  [as showInView:self.view];
  
  
  RELEASE_OBJ(as);
}

- (void)initPhotoFetcherView {
  BOOL userInteractionEnabled = YES;
  if (_photoTakerType == HANDY_PHOTO_TAKER_TY/* || _photoTakerType == SERVICE_ITEM_AVATAR_TY*/) {
    userInteractionEnabled = NO;
  }
  
  _photoFetcherView = [[PhotoFetcherView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN, USERDETAIL_PHOTO_WIDTH, USERDETAIL_PHOTO_HEIGHT)
                                                       target:self
                                        photoManagementAction:@selector(addOrRemovePhoto)
                                       userInteractionEnabled:userInteractionEnabled];
  [self.view addSubview:_photoFetcherView];
}

#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
    
  [super connectStarted:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  
  switch (contentType) {
    case MODIFY_USER_ICON_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:nil
                     connectorDelegate:self
                                   url:url]) {
        
        [_headerView updateAvatar:self.selectedPhoto];
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSUpdatePhotoDoneMsg, nil)
                                      msgType:SUCCESS_TY
                           belowNavigationBar:YES];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSUpdatePhotoFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      break;
    }
      
    case LOAD_CONNECTED_ALUMNUS_COUNT_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        _autoLoaded = YES;
        
        [_tableView reloadData];
      }
      break;
    }
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  NSString *msg = nil;
  switch (contentType) {
    case MODIFY_USER_ICON_TY:
    {
      msg = LocaleStringForKey(NSUpdatePhotoFailedMsg, nil);
      break;
    }
      
    case LOAD_CONNECTED_ALUMNUS_COUNT_TY:
    {
      
      break;
    }
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - ECPhotoPickerOverlayDelegate methods

- (void)applyPhotoSelectedStatus:(UIImage *)image {
  
	self.selectedPhoto = image;
  
  // upload new avatar
  self.connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                               interactionContentType:MODIFY_USER_ICON_TY] autorelease];
  
  [self.connFacade modifyUserIcon:self.selectedPhoto];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)saveImageIfNecessary:(UIImage *)image
                  sourceType:(UIImagePickerControllerSourceType)sourceType {
  if (sourceType == UIImagePickerControllerSourceTypeCamera) {
    
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
	}
}

- (void)handleFinishPickImage:(UIImage *)image
                   sourceType:(UIImagePickerControllerSourceType)sourceType {
  UIImage *handledImage = [CommonUtils scaleAndRotateImage:image sourceType:sourceType];
	
  [self saveImageIfNecessary:handledImage sourceType:sourceType];
	
	[self applyPhotoSelectedStatus:handledImage];
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
	
  [self handleFinishPickImage:image
                   sourceType:picker.sourceType];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - ECPhotoPickerDelegate method
- (void)selectPhoto:(UIImage *)selectedImage {
  if (_photoSourceType == UIImagePickerControllerSourceTypeCamera) {
    UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil);
  }
  
  [self applyPhotoSelectedStatus:selectedImage];
}

#pragma mark - ECPhotoPickerOverlayDelegate
- (void)didTakePhoto:(UIImage *)photo {
  [self selectPhoto:photo];
}

- (void)didFinishWithCamera {
  self.pickerOverlayVC = nil;
}

- (void)adjustUIAfterUserBrowseAlbumInImagePicker {
  // user browse the album in image picker, so UI layout be set as full screen, then we should recovery
  // the layout corresponding
  [UIApplication sharedApplication].statusBarHidden = NO;
  self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0f, 20.0f);
  self.view.frame = CGRectOffset(self.view.frame, 0.0f, 20.0f);
}

#pragma mark - ECItemUploaderDelegate method
- (void)afterUploadFinishAction:(WebItemType)actionType {
  
}

#pragma mark - action sheet delegate method
- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  if (HAS_CAMERA) {
    switch (buttonIndex) {
      case PHOTO_ACTION_SHEET_IDX:
        [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
        break;
        
      case LIBRARY_ACTION_SHEET_IDX:
        [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
        break;
        
      case CANCEL_PHOTO_SHEET_IDX:
        return;
        
      default:
        break;
    }
  } else {
    switch (buttonIndex) {
      case 0:
        [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
        break;
        
      case 1:
        return;
        
      default:
        break;
    }
  }
}

#pragma mark - ECClickableElementDelegate methods
- (void)showBigPhoto:(NSString *)url {
  
  CGRect smallAvatarFrame = CGRectMake(MARGIN * 2 + PHOTO_MARGIN, MARGIN * 2 + PHOTO_MARGIN,
                                       USERDETAIL_PHOTO_WIDTH, USERDETAIL_PHOTO_HEIGHT);
  
  ECHandyAvatarBrowser *avatarBrowser = [[[ECHandyAvatarBrowser alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                                              imgUrl:url
                                                                     imageStartFrame:smallAvatarFrame
                                                              imageDisplayerDelegate:self] autorelease];
  
  [self.view addSubview:avatarBrowser];
  
}

@end
