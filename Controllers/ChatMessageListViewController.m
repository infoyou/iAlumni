//
//  ChatMessageListViewController.m
//  iAlumni
//
//  Created by Adam on 13-10-23.
//
//

#import "ChatMessageListViewController.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "Post.h"
#import "WXWDebugLogOutput.h"
#import "ClubDetailViewController.h"
#import "ECTextView.h"
#import "ECAsyncConnectorFacade.h"
#import "AlumniProfileViewController.h"
#import "ECPhotoPickerOverlayViewController.h"
#import "ECImageBrowseViewController.h"
#import "WXWNavigationController.h"
#import "WXWLabel.h"

#define MAX_MSG_WIDTH       140.0f
#define MIN_BUBBLE_HEIGHT   70.0f

#define SECTION_VIEW_HEIGHT 30.0f

#define SPIN_SIDE_LEN       20.0f

#define MAX_INPUT_VIEW_HEIGHT   80.0f

#define INPUT_AREA_INIT_HEIGHT  50.0f

@interface ChatMessageListViewController ()
@property (nonatomic, retain) UIActivityIndicatorView *spinView;
@property (nonatomic, retain) WXWLabel *spinLabel;
@property (nonatomic, copy, readwrite) NSString *content;
@property (nonatomic, retain) ECPhotoPickerOverlayViewController *pickerOverlayVC;
@end

@implementation ChatMessageListViewController

#pragma mark - user actions

- (void)send {
  //implemented by sub class
}

#pragma mark - ChatterDelegate methods
- (void)openProfile:(NSString *)alumniId {

  [self closeKeyboard];
  
  AlumniProfileViewController *vc = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                             personId:alumniId
                                                                             userType:ALUMNI_USER_TY] autorelease];
  vc.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  
  [self.navigationController pushViewController:vc animated:YES];

}

- (void)openPhotoWithImageUrl:(NSString *)imageUrl {
  
  if (imageUrl.length > 0) {
    ECImageBrowseViewController *imageBrowserVC = [[[ECImageBrowseViewController alloc] initWithImageUrl:imageUrl] autorelease];
    WXWNavigationController *nav = [[[WXWNavigationController alloc] initWithRootViewController:imageBrowserVC] autorelease];
    
    [self.navigationController presentModalViewController:nav animated:YES];
  }
}

- (void)registerIndexPathForPopViewCell:(ChaterBubbleCell *)cell {
  if (cell != nil) {
    self.currentHasPopViewCellIndexPath = [_tableView indexPathForCell:cell];
  }
}

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  //implemented by sub class
}

- (void)configureMOCFetchConditions {
  //implemented by sub class
}

- (void)fetchContentFromMOC {
  
  self.fetchedRC = nil;
  
  [NSFetchedResultsController deleteCacheWithName:nil];
  
  [self configureMOCFetchConditions];
  
  self.fetchedRC = [WXWCoreDataUtils fetchObject:_MOC
                        fetchedResultsController:self.fetchedRC
                                      entityName:self.entityName
                              sectionNameKeyPath:self.sectionNameKeyPath
                                 sortDescriptors:self.descriptors
                                       predicate:self.predicate];
  NSError *error = nil;
  if (![self.fetchedRC performFetch:&error]) {
    debugLog(@"Unhandled error performing fetch: %@", [error localizedDescription]);
		NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
  }
}


- (void)refreshTable {
  
  [self fetchContentFromMOC];
  
  [_tableView reloadData];
  
  if (!_autoLoaded) {
    if (self.fetchedRC.fetchedObjects.count > 0) {
      [self scrollToBottomWithAnimated:NO];
    }
  } else if (_needAutoScrollToBottom) {
    if (self.fetchedRC.fetchedObjects.count > 0) {
      [self scrollToBottomWithAnimated:YES];
    }
    
    _needAutoScrollToBottom = NO;
  }
  
  _autoLoaded = YES;
}

#pragma mark - arrange table view
- (void)scrollToBottomWithAnimated:(BOOL)animated {
  
  if (self.fetchedRC.fetchedObjects.count > 0) {
    NSIndexPath *latestChatIndexPaht = [NSIndexPath indexPathForRow:self.fetchedRC.fetchedObjects.count - 1
                                                          inSection:0];
    [_tableView scrollToRowAtIndexPath:latestChatIndexPaht
                      atScrollPosition:UITableViewScrollPositionBottom
                              animated:animated];
  }
}

#pragma mark - life cycle methods
- (void)prepare {
  self.content = NULL_PARAM_VALUE;
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Post", nil);
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC needTakePhoto:(BOOL)needTakePhoto
{
  self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needGoHome:NO];
  if (self) {
    
    _needTakePhoto = needTakePhoto;
    
    [self prepare];
  }
  return self;
}

- (void)dealloc {
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  self.spinView = nil;
  self.spinLabel = nil;
  
  _tableView.delegate = nil;
  _tableView.dataSource = nil;
  RELEASE_OBJ(_tableView);
  
  RELEASE_OBJ(_headerView);
  RELEASE_OBJ(_footerView);
  
  self.content = nil;
  
  self.pickerOverlayVC = nil;
  self.selectedPhoto = nil;
  
  _tapGesture.delegate = nil;
  
  self.currentHasPopViewCellIndexPath = nil;
  
  [super dealloc];
}

- (void)initSpinView {
  self.spinView = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectZero] autorelease];
  self.spinView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
  self.spinView.frame = CGRectMake((self.view.frame.size.width - SPIN_SIDE_LEN)/2.0f,
                                   (SECTION_VIEW_HEIGHT- SPIN_SIDE_LEN)/2.0f,
                                   SPIN_SIDE_LEN, SPIN_SIDE_LEN);
  
  self.spinLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                          textColor:BASE_INFO_COLOR
                                        shadowColor:TRANSPARENT_COLOR
                                               font:FONT(10)] autorelease];
  
  [self addSpinViewInView:_tableView text:LocaleStringForKey(NSLoadingTitle, nil)];
}

- (void)addHeaderView {
  _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SECTION_VIEW_HEIGHT)];
  _headerView.backgroundColor = TRANSPARENT_COLOR;
  _tableView.tableHeaderView = _headerView;
  
}

- (void)initTableView {
  
  _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - _inputView.frame.size.height)
                                            style:UITableViewStylePlain];
  _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _tableView.backgroundView = nil;
  _tableView.backgroundColor = TRANSPARENT_COLOR;
  _tableView.delegate = self;
  _tableView.dataSource = self;
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  if (CURRENT_OS_VERSION >= IOS7) {
    _tableView.separatorInset = ZERO_EDGE;
  }
  
  _inputViewTopAndTableTopOffset = _inputView.frame.origin.y - _tableView.frame.origin.y;
  
  [self.view addSubview:_tableView];
  
  [self addHeaderView];
  
  [self initSpinView];
}

- (void)addInputView {
  CGFloat y = self.view.frame.size.height - INPUT_AREA_INIT_HEIGHT;
  if (CURRENT_OS_VERSION >= IOS7) {
    y -= SYS_STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT;
  } else {
    y -= NAVIGATION_BAR_HEIGHT;
  }
  
  _inputView = [[[ChatInputView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, INPUT_AREA_INIT_HEIGHT)
                                    textViewDelegate:self
                                       needTakePhoto:_needTakePhoto] autorelease];
  
  [self.view addSubview:_inputView];
}

- (void)addTapGestureForResignFirstResponder {
  _tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                         action:@selector(endInputting:)] autorelease];
  _tapGesture.delegate = self;
  [self.view addGestureRecognizer:_tapGesture];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	
  [self addInputView];
  
  [self initTableView];
  
  [self addTapGestureForResignFirstResponder];
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_autoLoaded) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - scrolling overrides

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
  if ([scrollView isKindOfClass:[ECTextView class]]) {
    // ignore if current user scroll input view
    return;
  }
  
  [self endInputting:nil];
  
  if (_lastContentOffset > scrollView.contentOffset.y) {
    _scrollDirection = SCROLL_DOWN_TY;
  } else if (_lastContentOffset < scrollView.contentOffset.y) {
    _scrollDirection = SCROLL_UP_TY;
  }
  
  _lastContentOffset = scrollView.contentOffset.y;
  
  // for loading latest items
  if (_scrollDirection == SCROLL_UP_TY &&
      [UIUtils shouldLoadLatestChat:scrollView
                    tableViewHeight:_tableView.contentSize.height
                          reloading:_reloading
                      currentStatus:&_footerRefreshStatus]) {
        
        _reloading = YES;
        
        [self loadListData:TRIGGERED_BY_SCROLL forNew:YES];
      }
  
  // for loading older items
  if (_scrollDirection == SCROLL_DOWN_TY &&
      [UIUtils shouldLoadOlderChat:scrollView
                     currentStatus:&_headerRefreshStatus
                         reloading:_reloading]) {
        
        _reloading = YES;
        
        [self loadListData:TRIGGERED_BY_SCROLL forNew:NO];
      }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  if ([scrollView isKindOfClass:[ECTextView class]]) {
    // ignore if current user scroll input view
    return;
  }
  
  _userTouchedTable = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
  
  if ([scrollView isKindOfClass:[ECTextView class]]) {
    // ignore if current user scroll input view
    return;
  }
  
  if (scrollView.contentOffset.y <= -(HEADER_TRIGGER_OFFSET) && !_reloading) {
    
    _reloading = YES;
    
    [self loadListData:TRIGGERED_BY_SCROLL forNew:YES];
  }
  
  _userTouchedTable = NO;
}

#pragma mark - reset loading status
- (void)resetLoadingStatus {
  [self.spinView stopAnimating];
  [self.spinView removeFromSuperview];
  
  _reloading = NO;
  _footerRefreshStatus = PULL_FOOTER_NORMAL;
  _headerRefreshStatus = PULL_HEADER_NORMAL;
  
  [self.spinLabel removeFromSuperview];
}

- (void)addSpinViewInView:(UIView *)view text:(NSString *)text {
  
  CGFloat width = self.spinView.frame.size.width + MARGIN + self.spinLabel.frame.size.width;
  CGFloat x = (self.view.frame.size.width - width)/2.0f;
  self.spinView.frame = CGRectMake(x, self.spinView.frame.origin.y, self.spinView.frame.size.width, self.spinView.frame.size.height);
  [view addSubview:self.spinView];
  
  [self.spinView startAnimating];
  
  self.spinLabel.text = text;
  CGSize size = [CommonUtils sizeForText:text font:self.spinLabel.font];
  self.spinLabel.frame = CGRectMake(x + self.spinView.frame.size.width + MARGIN,
                                    (SECTION_VIEW_HEIGHT - size.height)/2.0f,
                                    size.width,
                                    size.height);
  [view addSubview:self.spinLabel];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  return self.fetchedRC.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"cell";
  ChaterBubbleCell *cell = (ChaterBubbleCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[ChaterBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:kCellIdentifier
                             imageDisplayerDelegate:self
                                                MOC:_MOC
                                    chatterDelegate:self] autorelease];
  }
  
  Post *chatInfo = (Post *)[self.fetchedRC objectAtIndexPath:indexPath];
  [cell drawCellWithChatInfo:chatInfo];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Post *chatInfo = (Post *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  CGFloat height = MARGIN * 4;
  
  if (chatInfo.imageUrl.length > 0 && chatInfo.thumbnailUrl.length > 0) {
    
    height += MIN_BUBBLE_HEIGHT + MARGIN * 4;
    
  } else {
    
    CGSize size = [CommonUtils sizeForText:chatInfo.content
                                      font:FONT(15)
                         constrainedToSize:CGSizeMake(MAX_MSG_WIDTH, CGFLOAT_MAX)
                             lineBreakMode:BREAK_BY_WORD_WRAPPING];
    
    CGFloat messageButtonHeight = size.height + MARGIN * 8;
    messageButtonHeight = messageButtonHeight < MIN_BUBBLE_HEIGHT ? MIN_BUBBLE_HEIGHT : messageButtonHeight;
    
    height += messageButtonHeight;
  }
  
  height += MARGIN * 4;
  
  return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  
  if (_footerView == nil) {
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SECTION_VIEW_HEIGHT)];
    _footerView.backgroundColor = TRANSPARENT_COLOR;
    
  }
  return _footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return SECTION_VIEW_HEIGHT;
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  if ([touch.view isKindOfClass:[UIButton class]]) {
    return NO;
  } else {
    CGPoint touchPoint = [touch locationInView:self.view];
    return !CGRectContainsPoint(_inputView.frame, touchPoint);
  }
}

#pragma mark - handle keyboard

- (void)closeKeyboard {
  if (_inputting) {
    _inputting = NO;
    
    [_inputView resignFirstResponder];
  }
}

- (void)resignTextViewIfNeeded {
  if ([_inputView isFirstResponder] && _inputting && _userTouchedTable) {
    _inputting = NO;
    
    _userTouchedTable = NO;
    
    [_inputView resignFirstResponder];
  }
}

- (void)endInputting:(UIGestureRecognizer *)gesture {
  
  [self dismissPopViews];
  
  if (gesture != nil) {
    
    if ([gesture.view isKindOfClass:[UIButton class]]) {
      return;
    }
    
    _userTouchedTable = YES;
  }
  
  [self resignTextViewIfNeeded];
}

- (CGFloat)fetchKeyboardHeight:(NSNotification *)notification {
  
  CGFloat height = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
  
  return height;
}

- (CGFloat)fetchKeyboardY:(NSNotification *)notification {
  CGFloat y = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
  
  return y;
}


- (void)arrangeInputViewYAxis:(NSNotification *)notification {
  CGRect frame = _inputView.frame;
  
  CGFloat keyboardHeight = [self fetchKeyboardHeight:notification];
  
  frame.origin.y -= keyboardHeight;
  
  [self arrangeTableViewAndInputViewWith:frame animated:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
  
  if (!_inputting) {
    
    [self scrollToBottomWithAnimated:YES];
    
    _keyboardY = [self fetchKeyboardY:notification];
    
    CGRect frame = _inputView.frame;
    
    frame.origin.y -= [self fetchKeyboardHeight:notification];
    
    //[self arrangeTableViewAndInputViewWith:frame animated:YES moveUp:YES];
    [self arrangeTableViewAndInputViewWith:frame animated:YES];
    
    if (CURRENT_OS_VERSION >= IOS5) {
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(keyboardHeightChanged:)
                                                   name:UIKeyboardWillChangeFrameNotification
                                                 object:nil];
    }
    
    _inputting = YES;
  }
}

- (void)keyboardHeightChanged:(NSNotification *)notification {
  
  if (_inputting) {
    
    CGRect frame = _inputView.frame;
    
    _keyboardY = [self fetchKeyboardY:notification];
    
    frame.origin.y = _keyboardY - _inputView.frame.size.height;
    frame.origin.y -= SYS_STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT;
    [self arrangeTableViewAndInputViewWith:frame animated:YES];
  }
}

- (void)keyboardWillHide:(NSNotification *)notification {
  _keyboardY = 0;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillChangeFrameNotification
                                                object:nil];
  
  CGRect frame = _inputView.frame;
  frame.origin.y += [self fetchKeyboardHeight:notification];
  
  //[self arrangeTableViewAndInputViewWith:frame animated:YES moveUp:NO];
  [self arrangeTableViewAndInputViewWith:frame animated:YES];
}

#pragma mark - arrange views for input view frame change

- (void)resetInputViewFrame {
  CGRect frame = _inputView.frame;
  frame.origin.y = _keyboardY - INPUT_AREA_INIT_HEIGHT;
  frame.origin.y -= SYS_STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT;
  
  [self arrangeTableViewAndInputViewWith:frame animated:NO];
  
  [_inputView resetToInitialEditingStatus];
}

- (void)arrangeTableViewAndInputViewWith:(CGRect)frame animated:(BOOL)animated {
  [_inputView adjustFrame:frame animated:animated];
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     CGRect tableFrame = _tableView.frame;
                     tableFrame.origin.y = frame.origin.y - _inputViewTopAndTableTopOffset;
                     
                     _tableView.frame = tableFrame;
                   }];
  
}

- (void)arrangeTableViewAndInputViewWith:(CGRect)frame animated:(BOOL)animated moveUp:(BOOL)moveUp {
  
  [_inputView adjustFrame:frame animated:animated];
  
  if ((_tableView.frame.origin.y == 0 && moveUp) ||
      (_tableView.frame.origin.y < 0 && !moveUp)) {
    [UIView animateWithDuration:0.2f
                     animations:^{
                       CGRect tableFrame = _tableView.frame;
                       tableFrame.origin.y = frame.origin.y - _inputViewTopAndTableTopOffset;
                       
                       _tableView.frame = tableFrame;
                     }];
  }
}

#pragma mark - change photo

- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType {
  
  _photoSourceType = sourceType;
  
  self.pickerOverlayVC = [[[ECPhotoPickerOverlayViewController alloc] initWithSourceType:_photoSourceType
                                                                                delegate:self
                                                                        uploaderDelegate:nil
                                                                               takerType:POST_COMPOSER_TY
                                                                                     MOC:_MOC] autorelease];
  
  [self.pickerOverlayVC arrangeViews];
  
  [self presentModalViewController:self.pickerOverlayVC.imagePicker animated:YES];
}

#pragma mark - ChatInputDelegate methods

- (void)takePhoto {
  
  _userTouchedTable = YES;
  [self endInputting:nil];
  
  UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:nil] autorelease];
  
  if (HAS_CAMERA) {
    [as addButtonWithTitle:LocaleStringForKey(NSTakePhotoTitle, nil)];
    [as addButtonWithTitle:LocaleStringForKey(NSChooseExistingPhotoTitle, nil)];
  } else {
    [as addButtonWithTitle:LocaleStringForKey(NSChooseExistingPhotoTitle, nil)];
  }
  
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  
  [as showInView:self.view];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  if ([text isEqualToString:@"\n"]) {
    
    // user trigger send
    [self send];
    
    return NO;
  } else {
    return YES;
  }
}

- (void)textViewDidChange:(UITextView *)textView {
  
  self.content = textView.text;
  
  if (textView.text.length == 0) {
    
    [self resetInputViewFrame];
    
    self.content = NULL_PARAM_VALUE;
    
  } else {
    
    CGFloat currentHeight = textView.contentSize.height;
    [UIView animateWithDuration:0.01f
                     animations:^{
                       
                       CGRect frame = textView.frame;
                       
                       CGFloat currentTextViewHeight = frame.size.height;
                       
                       CGFloat currentRealHeight = currentHeight < MAX_INPUT_VIEW_HEIGHT ? currentHeight : MAX_INPUT_VIEW_HEIGHT;
                       frame.size.height = currentRealHeight;
                       textView.frame = frame;
                       
                       frame = _inputView.frame;
                       CGFloat offset = currentRealHeight - currentTextViewHeight;
                       frame.size.height = _inputView.frame.size.height + offset;
                       frame.origin.y  = _inputView.frame.origin.y - offset;
                       
                       [self arrangeTableViewAndInputViewWith:frame animated:NO];
                       
                     }];
  }
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
        break;
        
      default:
        break;
    }
  } else {
    switch (buttonIndex) {
      case 0:
        [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
        break;
        
      case 1:
        break;
        
      default:
        break;
    }
  }
}

#pragma mark - ECPhotoPickerOverlayDelegate methods

- (void)applyPhotoSelectedStatus:(UIImage *)image {
  
	self.selectedPhoto = image;
  
  [self send];
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

#pragma mark - dismiss pop view
- (void)dismissPopViews {
  if (self.currentHasPopViewCellIndexPath != nil) {
    ChaterBubbleCell *cell = (ChaterBubbleCell *)[_tableView cellForRowAtIndexPath:self.currentHasPopViewCellIndexPath];
    [cell dismissAllPopTipViews];
    
    self.currentHasPopViewCellIndexPath = nil;
  }
}

@end
