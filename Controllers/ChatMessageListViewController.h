//
//  ChatMessageListViewController.h
//  iAlumni
//
//  Created by Adam on 13-10-23.
//
//

#import "WXWRootViewController.h"
#import "ChatInputView.h"
#import "ChaterBubbleCell.h"
#import "ECPhotoPickerOverlayDelegate.h"


@interface ChatMessageListViewController : WXWRootViewController  <UITableViewDataSource, UITableViewDelegate, ChatInputDelegate, ChatterDelegate, ECPhotoPickerOverlayDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate> {
  
  BOOL _autoLoaded;
  BOOL _loadNew;
  
  NSInteger _currentStartIndex;
  
  ChatInputView *_inputView;
  
  BOOL _needAutoScrollToBottom;
  
  UIView *_headerView;
  UIView *_footerView;
  
@private
  
  BOOL _needTakePhoto;
  
  UITapGestureRecognizer *_tapGesture;
  
  BOOL _reloading;
  
  PullFooterRefreshState _footerRefreshStatus;
  PullHeaderRefreshState _headerRefreshStatus;
  
  CGFloat _lastContentOffset;
  
  ScrollDirectionType _scrollDirection;
  
  // input view
  BOOL _inputting;
  CGFloat _keyboardY;
  
  CGFloat _inputViewTopAndTableTopOffset;
  
  BOOL _userTouchedTable;
  
  // photo
  UIImagePickerControllerSourceType _photoSourceType;
  
}

@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, retain) UIImage *selectedPhoto;
@property (nonatomic, retain) NSIndexPath *currentHasPopViewCellIndexPath;

- (id)initWithMOC:(NSManagedObjectContext *)MOC needTakePhoto:(BOOL)needTakePhoto;
- (void)prepare;
- (void)refreshTable;

#pragma mark - reset loading status
- (void)resetLoadingStatus;
- (void)addSpinViewInView:(UIView *)view text:(NSString *)text;

#pragma mark - arrange table view
- (void)scrollToBottomWithAnimated:(BOOL)animated;

#pragma mark - arrange views for input view frame change
- (void)resetInputViewFrame;

#pragma mark - handle keyboard
- (void)closeKeyboard;

@end
