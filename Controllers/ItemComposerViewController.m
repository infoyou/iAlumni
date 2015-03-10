//
//  ItemComposerViewController.m
//  iAlumni
//
//  Created by Adam on 12-12-8.
//
//

#import "ItemComposerViewController.h"
#import "Club.h"
#import "TextComposerView.h"
#import "PhotoFetcherView.h"
#import "ECPhotoPickerOverlayViewController.h"
#import "ECAsyncConnectorFacade.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "UIUtils.h"


#define TEXT_COMPOSER_35INCH_HEIGHT		(200-KEYBOARD_GAP)
#define TEXT_COMPOSER_40INCH_HEIGHT		TEXT_COMPOSER_35INCH_HEIGHT + 88.0f


@interface ItemComposerViewController ()
@property (nonatomic, retain) Club *group;
@property (nonatomic, retain) UIImage *selectedPhoto;
@property (nonatomic, retain) ECPhotoPickerOverlayViewController *pickerOverlayVC;
@property (nonatomic, retain) id<ECItemUploaderDelegate> uploaderDelegate;
@property (nonatomic, copy) NSString *content;
@end

@implementation ItemComposerViewController

#pragma mark - user actions
- (void)doClose {
  [self cancelConnection];
  [self cancelLocation];
  
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)close:(id)sender {
  
  _actionSheetOwnerType = CLOSE_BTN;
  
  if ([_textComposer charCount] > 0 || self.selectedPhoto) {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSCloseNotificationTitle, nil)
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil];
		[as addButtonWithTitle:LocaleStringForKey(NSCloseTitle, nil)];
		[as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
    as.destructiveButtonIndex = 0;
		as.cancelButtonIndex = [as numberOfButtons] - 1;
		[as showInView:self.navigationController.view];
		RELEASE_OBJ(as)
    
  } else {
    
    [self doClose];
  }
}

- (void)send:(id)sender {
  self.connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                               interactionContentType:SEND_POST_TY] autorelease];
  
  if (self.content.length == 0 || nil == self.content) {
    self.content = @" ";
  }
  
  [(ECAsyncConnectorFacade *)self.connFacade sendPostForGroup:self.group
                            content:self.content
                              photo:self.selectedPhoto];
}

#pragma mark - configure editor
- (void)initViewProperties {
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}

- (void)initNavigationBar {
  
  [self addLeftBarButtonWithTitle:LocaleStringForKey(NSCloseTitle, nil)
                           target:self
                           action:@selector(close:)];
  

  [self addRightBarButtonWithTitle:LocaleStringForKey(NSSendTitle, nil)
                            target:self
                            action:@selector(send:)];
  self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)initTextComposer {
  
  CGFloat y = 0.0f;
  if (_needMoveDownUI) {
    y += NAVIGATION_BAR_HEIGHT;
  }
  
  CGFloat textComposerHeight = 0;
  if ([WXWCommonUtils screenHeightIs4Inch]) {
    textComposerHeight = TEXT_COMPOSER_40INCH_HEIGHT;
  } else {
    textComposerHeight = TEXT_COMPOSER_35INCH_HEIGHT;
  }
  
  _textComposer = [[TextComposerView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, textComposerHeight)
                                                 topColor:COLOR(249, 249, 249)
                                              bottomColor:COLOR(200, 200, 200)
                                                   target:self
                                                      MOC:_MOC
                                              contentType:_contentType
                                         showSwitchButton:YES];
  
  [self.view addSubview:_textComposer];
}

- (void)initPhotoFetcherView {
  
  CGFloat textComposerHeight = 0;
  if ([WXWCommonUtils screenHeightIs4Inch]) {
    textComposerHeight = TEXT_COMPOSER_40INCH_HEIGHT;
  } else {
    textComposerHeight = TEXT_COMPOSER_35INCH_HEIGHT;
  }
  
  CGFloat y = textComposerHeight;
  if (_needMoveDownUI) {
    y += NAVIGATION_BAR_HEIGHT;
  }
  _photoFetcherView = [[PhotoFetcherView alloc] initWithFrame:CGRectMake(0,
                                                                         y,
                                                                         self.view.frame.size.width,
                                                                         self.view.frame.size.height - textComposerHeight)
                                                       target:self
                                        photoManagementAction:@selector(addOrRemovePhoto)
                                       userInteractionEnabled:YES];
  [self.view addSubview:_photoFetcherView];
  
  [self.view bringSubviewToFront:_textComposer];
}

#pragma mark - lifecycle methods

- (id)initWithMOC:(NSManagedObjectContext *)MOC
            group:(Club *)group
      contentType:(NSInteger)contentType
 uploaderDelegate:(id<ECItemUploaderDelegate>)uploaderDelegate {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
                 needGoHome:NO];
  if (self) {
    self.group = group;
    
    self.uploaderDelegate = uploaderDelegate;
    
    _contentType = contentType;
    
    [self registerKeyboardNotifications];
  }
  return self;
}

- (void)deregisterKeyboardNotifications {
  if (CURRENT_OS_VERSION >= IOS5 ) {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
  }
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardDidShowNotification
                                                object:nil];
}

- (void)dealloc {
  
  self.selectedPhoto = nil;
  
  self.group = nil;
  
  self.content = nil;
  
  [self deregisterKeyboardNotifications];
  
  RELEASE_OBJ(_textComposer);
  RELEASE_OBJ(_photoFetcherView);

  self.content = nil;
  self.selectedPhoto = nil;
  self.pickerOverlayVC = nil;
  self.uploaderDelegate = nil;
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self initViewProperties];
  
  [self initNavigationBar];
  
  [self initTextComposer];
  
  [self initPhotoFetcherView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - photo add/remove

- (void)showImagePicker {
  
  _photoSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  if (HAS_CAMERA) {
    _photoSourceType = UIImagePickerControllerSourceTypeCamera;
  }
  
  self.pickerOverlayVC = [[[ECPhotoPickerOverlayViewController alloc] initWithSourceType:_photoSourceType
                                                                                delegate:self
                                                                        uploaderDelegate:self.uploaderDelegate
                                                                               takerType:POST_COMPOSER_TY
                                                                                     MOC:_MOC] autorelease];
  
  [self.pickerOverlayVC arrangeViews];
  
  [self presentModalViewController:self.pickerOverlayVC.imagePicker animated:YES];
}

- (void)addOrRemovePhoto {
  
  if (nil == self.selectedPhoto) {
    [self showImagePicker];
  } else {
    
    _actionSheetOwnerType = PHOTO_BTN;
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil];
    
    if (self.selectedPhoto) {
      [as addButtonWithTitle:LocaleStringForKey(NSClearCurrentSelection, nil)];
      as.destructiveButtonIndex = [as numberOfButtons] - 1;
    }
    
    if (HAS_CAMERA) {
      [as addButtonWithTitle:LocaleStringForKey(NSTakePhotoTitle, nil)];
    } else {
      [as addButtonWithTitle:LocaleStringForKey(NSChooseExistingPhotoTitle, nil)];
    }
    
    [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
    as.cancelButtonIndex = [as numberOfButtons] - 1;
    [as showInView:self.navigationController.view];
    
    RELEASE_OBJ(as);
  }
}

- (void)changeSendButtonStatus {
  if ((self.content && [self.content length] > 0) || self.selectedPhoto) {
    self.navigationItem.rightBarButtonItem.enabled = YES;
  } else {
    self.navigationItem.rightBarButtonItem.enabled = NO;
  }
}

- (void)applyPhotoSelectedStatus:(UIImage *)image {
	self.selectedPhoto = image;
  [_photoFetcherView applySelectedPhoto:[CommonUtils cutPartImage:image
                                                            width:ADD_PHOTO_BUTTON_SIDE_LENGTH
                                                           height:ADD_PHOTO_BUTTON_SIDE_LENGTH]];
  [self changeSendButtonStatus];
}

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

#pragma mark - PhotoPickerDelegate method

- (void)selectPhoto:(UIImage *)selectedImage {
  if (_photoSourceType == UIImagePickerControllerSourceTypeCamera) {
    UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil);
  }
  
  [self applyPhotoSelectedStatus:selectedImage];
}

#pragma mark - ECPhotoPickerOverlayDelegate methods
- (void)didTakePhoto:(UIImage *)photo {
  [self selectPhoto:photo];
}

// as a delegate we are told to finished with the camera
- (void)didFinishWithCamera {
  
  self.pickerOverlayVC = nil;
}

- (void)adjustUIAfterUserBrowseAlbumInImagePicker {
  
  // user browse the album in image picker, so UI layout be set as full screen, then we should recovery
  // the layout corresponding
  
  [UIApplication sharedApplication].statusBarHidden = NO;
  
  self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0f, 20.0f);
  self.view.frame = CGRectOffset(self.view.frame, 0.0f, 20.0f);
  
  _needMoveDown20px = YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
	
  [self handleFinishPickImage:image
                   sourceType:picker.sourceType];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark - action sheet delegate method
- (void)actionSheet:(UIActionSheet *)as  clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  switch (_actionSheetOwnerType) {
    case CLOSE_BTN:
      if (as.cancelButtonIndex == buttonIndex) {
        return;
      } else {
        [self doClose];
      }
      break;
      
    case PHOTO_BTN:
    {
      if (as.cancelButtonIndex == buttonIndex) {
				return;
			} else if (as.destructiveButtonIndex == buttonIndex) {
				self.selectedPhoto = nil;
        [_photoFetcherView applySelectedPhoto:nil];
        [self changeSendButtonStatus];
				return;
			} else {
        [self showImagePicker];
      }
      
      break;
    }
    default:
      break;
  }
  
}

#pragma mark - keyboard notification handlers

- (CGSize)fetchKeyboardSize:(NSNotification *)notification {
  return [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
}

- (CGFloat)calcNoKeyboardAreaHeight:(NSNotification *)notification {
  CGSize size = [self fetchKeyboardSize:notification];
  
  CGFloat areaHeight = self.view.frame.size.height - size.height;
  
  if (_needMoveDownUI) {
    areaHeight -= (SYS_STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT);
  } else {
    if (_needMoveDown20px) {
      areaHeight -= SYS_STATUS_BAR_HEIGHT;
    }
  }
  return areaHeight;
}

- (void)keyboardHeightChanged:(NSNotification*)notification {
  
  [_textComposer arrangeLayoutForKeyboardChange:[self calcNoKeyboardAreaHeight:notification]];
}

- (void)keyboardWasShown:(NSNotification *)notification {
  
  [_textComposer arrangeLayoutForKeyboardChange:[self calcNoKeyboardAreaHeight:notification]];
}

#pragma mark - ECEditorDelegate methods
- (void)textChanged:(NSString *)text {
  
  self.content = text;
  [self changeSendButtonStatus];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  [UIUtils showAsyncLoadingView:LocaleStringForKey(NSSendingTitle, nil)
                toBeBlockedView:NO];
  
  [self doClose];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
      
    case SEND_POST_TY:
    case SEND_EVENT_DISCUSS_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:nil
                     connectorDelegate:self
                                   url:url]) {
        
        if (self.uploaderDelegate) {
          [self.uploaderDelegate afterUploadFinishAction:contentType];
        }
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSSendFeedDoneMsg, nil)
                                      msgType:SUCCESS_TY
                           belowNavigationBar:YES];
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
  
  [UIUtils closeAsyncLoadingView];
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  NSString *msg = nil;
  switch (contentType) {
      
    case SEND_POST_TY:
    case SEND_EVENT_DISCUSS_TY:
    {
      msg = LocaleStringForKey(NSSendFeedFailedMsg, nil);
      break;
    }
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  
  [UIUtils closeAsyncLoadingView];
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - lifecycle methods

- (void)registerKeyboardNotifications {
  if (CURRENT_OS_VERSION >= IOS5) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHeightChanged:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWasShown:)
                                               name:UIKeyboardDidShowNotification
                                             object:nil];
}


@end
