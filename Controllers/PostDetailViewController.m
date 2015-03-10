//
//  PostDetailViewController.m
//  iAlumni
//
//  Created by Adam on 12-4-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PostDetailViewController.h"
#import "Post.h"
#import "ItemListSectionView.h"
#import "CoreDataUtils.h"
#import "ComposerViewController.h"
#import "WXWNavigationController.h"
#import "ECAsyncConnectorFacade.h"
#import "WXWLabel.h"
#import "CommentListCell.h"
#import "WXWPullRefreshTableFooterView.h"
#import "PostContentCell.h"
#import "ECImageBrowseViewController.h"
#import "MapViewController.h"
#import "PostComment.h"
#import "NoticeableCommentComposerView.h"
#import "ECPhotoPickerOverlayViewController.h"
#import "UserListViewController.h"
#import "UIWebViewController.h"
#import "AlumniProfileViewController.h"

enum {
  CONTENT_SEC = 0,
  COMMENT_SEC,
};

enum {
  DELETE_ITEM_AS_TY,
  DELETE_PHOTO_AS_TY,
  DELETE_COMMENT_AS_TY,
};

#define SECTION_COUNT       2
#define SECTION_VIEW_HEIGHT 18.0f
#define COMMENT_PAGE_COUNT  20

#define COMMENT_COMPOSER_HEIGHT 40.0f

#define TAG_LIST_HEIGHT         40.0f

#define DELETE_BUTTON_HEIGHT    16.0f

@interface PostDetailViewController ()
@property (nonatomic, retain) ItemListSectionView *sectionView;
@property (nonatomic, copy) NSString *lastSectionTitle;
@property (nonatomic, retain) ECPhotoPickerOverlayViewController *pickerOverlayVC;
@property (nonatomic, retain) UIImage *selectedPhoto;
@property (nonatomic, retain) Post *post;
@property (nonatomic, retain) UIImage *postImage;
@end

@implementation PostDetailViewController

@synthesize sectionView = _sectionView;
@synthesize lastSectionTitle = _lastSectionTitle;
@synthesize pickerOverlayVC = _pickerOverlayVC;
@synthesize selectedPhoto = _selectedPhoto;
@synthesize post = _post;

#pragma mark - load comments

- (void)loadComments:(LoadTriggerType)triggerType forNewComment:(BOOL)forNewComment {
  _currentType = COMMENT_LIST_TY;
  
  NSString *param = nil;
  switch (triggerType) {
    case TRIGGERED_BY_AUTOLOAD:
      param = [NSString stringWithFormat:@"<post_id>%@</post_id><page>0</page><page_size>30</page_size>", LLINT_TO_STRING(self.post.postId.longLongValue)];
      break;
      
    case TRIGGERED_BY_SCROLL:
      param = [NSString stringWithFormat:@"<post_id>%@</post_id><page>%@</page><page_size>30</page_size>", LLINT_TO_STRING(self.post.postId.longLongValue),INT_TO_STRING(_currentStartIndex)];
      break;
    default:
      break;
  }
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:_currentType] autorelease];
  // [self.connDic setObject:connFacade forKey:url];
  [connFacade fetchComments:url];
}

#pragma mark - properties
- (ItemListSectionView *)sectionView {
  if (nil == _sectionView) {
    _sectionView = [[ItemListSectionView alloc] initWithFrame:CGRectMake(0, 0,
                                                                         self.view.frame.size.width,
                                                                         SECTION_VIEW_HEIGHT)
                                                        title:nil];
  }
  return _sectionView;
}

#pragma mark - override method
- (void)configureMOCFetchConditions {
  
  self.entityName = @"PostComment";
  
  self.predicate = [NSPredicate predicateWithFormat:@"(parentId == %@)", self.post.postId];
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
  [self.descriptors addObject:descriptor];
}

#pragma mark - reset footer view status

- (void)resetFooterRefreshViewStatus {
	_reloading = NO;
	
	[UIUtils dataSourceDidFinishLoadingOldData:_tableView
                                  footerView:_footerRefreshView];
}

- (void)resetHeaderOrFooterViewStatus {
  [self resetFooterRefreshViewStatus];
}

#pragma mark - display/hide comment composer

- (void)hideCommentComposer {
  if (!_commentComposerView.showed || _commentComposerView.expanded) {
    return;
  }
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     
                     _commentComposerView.frame = CGRectMake(_commentComposerView.frame.origin.x,
                                                             self.view.frame.size.height,
                                                             _commentComposerView.frame.size.width,
                                                             _commentComposerView.frame.size.height);
                     _commentComposerView.showed = NO;
                   }];
}

- (void)showCommentComposer {
  if (_commentComposerView.showed || _commentComposerView.expanded) {
    return;
  }
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     
                     _commentComposerView.frame = CGRectMake(_commentComposerView.frame.origin.x,
                                                             _visibleViewHeight - COMMENT_COMPOSER_HEIGHT,
                                                             _commentComposerView.frame.size.width,
                                                             _commentComposerView.frame.size.height);
                     _commentComposerView.showed = YES;
                   }];
}

- (void)showOrHideCommentComposer {
  switch (_scrollDirectoinType) {
    case SCROLL_UP_TY:
      [self hideCommentComposer];
      break;
      
    case SCROLL_DOWN_TY:
      [self showCommentComposer];
      break;
      
    default:
      break;
  }
  
}

#pragma mark - scrolling overrides

- (void)detectScroll:(UIScrollView *)scrollView {
  
  if (scrollView.contentOffset.y > 0 && (scrollView.contentOffset.y + _tableView.frame.size.height < scrollView.contentSize.height)) {
    
    CGFloat percentScrolled = scrollView.contentOffset.y/scrollView.contentSize.height;
    if (percentScrolled < 0) {
      percentScrolled *= -1;
    }
    
    if (percentScrolled > _scrollPreviousValue) {
      _scrollDirectoinType = SCROLL_UP_TY;
    } else if (percentScrolled < _scrollPreviousValue) {
      _scrollDirectoinType = SCROLL_DOWN_TY;
    } else {
      _scrollDirectoinType = SCROLL_STILL_TY;
    }
    
    _scrollPreviousValue = percentScrolled;
    
    //        [self showOrHideCommentComposer];
    
  }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
  [self detectScroll:scrollView];
  
  // for loading older posts
  if ([UIUtils shouldLoadOlderItems:scrollView
               tableViewHeight:(_tableView.contentSize.height - COMMENT_COMPOSER_HEIGHT)
                    footerView:_footerRefreshView
                          reloading:_reloading]) {
    
    _reloading = YES;
    
    _shouldTriggerLoadLatestItems = YES;
    
    [self loadComments:TRIGGERED_BY_SCROLL forNewComment:NO];
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
  /*
  // for loading older posts
  if (_tableView.contentSize.height - scrollView.contentOffset.y <= (FOOTER_TRIGGER_35_OFFSET_MAX + COMMENT_COMPOSER_HEIGHT) &&
      scrollView.contentOffset.y > 0 &&				// means scroll down, if user scrolls up, no need to load old comment
      !_reloading) {
    _reloading = YES;
    
    [self loadComments:TRIGGERED_BY_SCROLL forNewComment:NO];
  }
  */
  
  if (scrollView.contentOffset.y + _tableView.frame.size.height >= scrollView.contentSize.height - MARGIN * 6) {
    
    // adjust table view height when user scrolls table view to bottom to make the layout more smooth
    
    [UIView animateWithDuration:0.1f
                     animations:^{
                       _tableView.frame = CGRectMake(_tableView.frame.origin.x,
                                                     _tableView.frame.origin.y,
                                                     _tableView.frame.size.width,
                                                     _noCommentComposerTableHeight - COMMENT_COMPOSER_HEIGHT);
                     }];
  }
  
}

#pragma mark - ECConnectorDelegate

- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  switch (contentType) {
    case COMMENT_LIST_TY:
    {
      if (nil == self.sectionView.titleLabel.text) {
        self.lastSectionTitle = [NSString stringWithFormat:@"%@(0)", LocaleStringForKey(NSCommentTitle, nil)];
      } else {
        self.lastSectionTitle = self.sectionView.titleLabel.text;
      }
      self.sectionView.titleLabel.text = LocaleStringForKey(NSLoadingTitle, nil);
      
      _loadingComments = YES;
      break;
    }
      
    case DELETE_FEED_TY:
    case DELETE_COMMENT_TY:
    {
      
      [UIUtils showActivityView:_tableView text:LocaleStringForKey(NSProcessingTitle, nil)];
      
      break;
    }
    case SEND_COMMENT_TY:
    {
      [UIUtils showAsyncLoadingView:LocaleStringForKey(NSSendingTitle, nil)
                    toBeBlockedView:NO];
      break;
    }
      
    default:
      break;
  }
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case COMMENT_LIST_TY:
    {
      if ([XMLParser parserPostComments:result
                                    MOC:_MOC
                                 postId:self.post.postId.longLongValue
                      connectorDelegate:self
                                    url:url]) {
                
        [self refreshTable];
        
        // update latest comment count
        self.post.commentCount = [NSNumber numberWithInt:[_fetchedRC.fetchedObjects count]];
        [WXWCoreDataUtils saveMOCChange:_MOC];
        
      } else {
        
        self.sectionView.titleLabel.text = self.lastSectionTitle;
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSLoadCommentFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      _loadingComments = NO;
      
      _autoLoaded = YES;
      
      break;
    }
      
    case DELETE_FEED_TY:
    {
      [UIUtils closeActivityView];
      if ([XMLParser parserResponseXml:result
                                  type:DELETE_FEED_TY
                                   MOC:nil
                     connectorDelegate:self
                                   url:url]) {
        
        NSString *name = nil;
        switch (_postType) {
          case EVENT_DISCUSS_POST_TY:
          case DISCUSS_POST_TY:
            name = @"Post";
            break;
            
          case SHARE_POST_TY:
            name = @"SharePost";
            break;
            
          default:
            break;
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(postId == %@)", self.post.postId];
        DELETE_OBJS_FROM_MOC(_MOC, name, predicate);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FEED_DELETED_NOTIFY
                                                            object:nil
                                                          userInfo:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSDeleteFeedDoneMsg, nil)
                                      msgType:SUCCESS_TY
                           belowNavigationBar:YES];
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSDeleteFeedFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      break;
    }
      
    case DELETE_COMMENT_TY:
    {
      [UIUtils closeActivityView];
      if ([XMLParser parserResponseXml:result
                                  type:DELETE_COMMENT_TY
                                   MOC:nil
                     connectorDelegate:self
                                   url:url]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(commentId == %lld)", _beDeletedCommentId];
        DELETE_OBJS_FROM_MOC(_MOC, @"PostComment", predicate);
        
        [self refreshTable];
        
        self.post.commentCount = @(self.post.commentCount.intValue - 1);
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSDeleteCommentDoneMsg, nil)
                                      msgType:SUCCESS_TY belowNavigationBar:YES];
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSDeleteCommentFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      break;
    }
      
    case SEND_COMMENT_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:SEND_COMMENT_TY
                                   MOC:nil
                     connectorDelegate:self
                                   url:url]) {
        
        [self loadComments:TRIGGERED_BY_AUTOLOAD forNewComment:YES];
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSSendCommentDoneMsg, nil)
                                      msgType:SUCCESS_TY
                           belowNavigationBar:YES];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSSendCommentFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      [UIUtils closeAsyncLoadingView];
      break;
    }
      
    default:
      break;
  }
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  NSString *msg = nil;
  switch (contentType) {
    case COMMENT_LIST_TY:
    {
      self.sectionView.titleLabel.text = self.lastSectionTitle;
      msg = LocaleStringForKey(NSLoadCommentFailedMsg, nil);
      _loadingComments = NO;
      
      _autoLoaded = YES;
      
      break;
    }
      
    case DELETE_FEED_TY:
    {
      
      [UIUtils closeActivityView];
      
      msg = LocaleStringForKey(NSDeleteFeedFailedMsg, nil);
      break;
    }
      
    case DELETE_COMMENT_TY:
    {
      [UIUtils closeActivityView];
      
      msg = LocaleStringForKey(NSDeleteCommentFailedMsg, nil);
      break;
    }
    case SEND_COMMENT_TY:
    {
      msg = LocaleStringForKey(NSSendCommentFailedMsg, nil);
      
      [UIUtils closeAsyncLoadingView];
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

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case SEND_COMMENT_TY:
      [UIUtils closeAsyncLoadingView];
      break;
      
    default:
      break;
  }
  [super connectCancelled:url contentType:contentType];
}

#pragma mark - adjust content cell height for like people album display/hide
- (void)addLikeAlbum {
  [_tableView reloadData];
}

- (void)removeLikeAlbum {
  [_tableView reloadData];
}

#pragma mark - update post content cell
- (void)updateFeedContentCell:(NSNotification *)notification {
  
  if (self.post.isFault) {
    // avoid core data memory error
    return;
  }
  
  NSDictionary *heightDic = [notification userInfo];
  NSNumber *heightInfo = (NSNumber *)heightDic[TEXT_CONTENT_HEIGHT_KEY];
  
  _textContentHeight = heightInfo.floatValue;
  
  _textContentLoaded = YES;
  
  [_tableView reloadData];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  switch (_actionSheetOwnerType) {
    case DELETE_ITEM_AS_TY:
    {
      if (as.cancelButtonIndex == buttonIndex) {
        return;
      } else if (as.destructiveButtonIndex == buttonIndex) {
        
        _currentType = DELETE_FEED_TY;
        
        
        NSString *param = [NSString stringWithFormat:@"<post_id>%@</post_id>", LLINT_TO_STRING(self.post.postId.longLongValue)];
        
        NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
        
        ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                        interactionContentType:_currentType] autorelease];
        [connFacade deleteFeeds:url];
        
        return;
      }
      break;
    }
      
    case DELETE_COMMENT_AS_TY:
    {
      if (as.cancelButtonIndex == buttonIndex) {
        return;
      } else if (as.destructiveButtonIndex == buttonIndex) {
        
        _currentType = DELETE_COMMENT_TY;
        
        NSString *param = [NSString stringWithFormat:@"<comment_id>%@</comment_id>", LLINT_TO_STRING(_beDeletedCommentId)];
        
        NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
        
        ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                        interactionContentType:_currentType] autorelease];
        [connFacade deleteComment:url];
        
        return;
      }
      
      break;
    }
      
    case DELETE_PHOTO_AS_TY:
    {
      if (as.cancelButtonIndex == buttonIndex) {
				return;
			} else if (as.destructiveButtonIndex == buttonIndex) {
				self.selectedPhoto = nil;
        [_commentComposerView applySelectedPhoto:nil];
        [_commentComposerView setSendButton:NO];
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

#pragma mark - WXWImageDisplayerDelegate methods
- (void)saveDisplayedImage:(UIImage *)image {
  self.postImage = image;
}

#pragma mark - ECClickableElementDelegate methods
- (void)openImage:(UIImage *)image {
  if (image) {
    ECImageBrowseViewController *imgBrowseVC = [[ECImageBrowseViewController alloc] initWithImage:image];
    WXWNavigationController *imgBrowseNav = [[WXWNavigationController alloc] initWithRootViewController:imgBrowseVC];
    imgBrowseVC.title = LocaleStringForKey(NSBigPicTitle, nil);
    [self.navigationController presentModalViewController:imgBrowseNav animated:YES];
    
    RELEASE_OBJ(imgBrowseVC)
    RELEASE_OBJ(imgBrowseNav);
  }
}

- (void)openImageUrl:(NSString *)imageUrl {
  if (imageUrl && [imageUrl length] > 0) {
    ECImageBrowseViewController *imgBrowseVC = [[ECImageBrowseViewController alloc] initWithImageUrl:imageUrl];
    WXWNavigationController *imgBrowseNav = [[WXWNavigationController alloc] initWithRootViewController:imgBrowseVC];
    imgBrowseVC.title = LocaleStringForKey(NSBigPicTitle, nil);
    [self.navigationController presentModalViewController:imgBrowseNav animated:YES];
    
    RELEASE_OBJ(imgBrowseVC)
    RELEASE_OBJ(imgBrowseNav);
  }
}

- (void)openUrl:(NSString *)url {
  
  UIWebViewController *webVC = [[UIWebViewController alloc] initWithNeedAdjustForiOS7:YES];
  UINavigationController *webViewNav = [[UINavigationController alloc] initWithRootViewController:webVC];
  webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
  webVC.strUrl = url;
  webVC.strTitle = NULL_PARAM_VALUE;
  
  [self.parentViewController presentModalViewController:webViewNav
                                               animated:YES];
  RELEASE_OBJ(webVC);
  RELEASE_OBJ(webViewNav);
}

- (void)openProfile:(NSString*)userId userType:(NSString*)userType {
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                    personId:userId
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)openTraceMap {
  MapViewController *mapVC = [[[MapViewController alloc] initWithLatitude:self.post.latitude.doubleValue
                                                                longitude:self.post.longitude.doubleValue
                                                     allowLaunchGoogleMap:NO] autorelease];
  
  WXWNavigationController *navVC = [[[WXWNavigationController alloc] initWithRootViewController:mapVC] autorelease];
  [self.navigationController presentModalViewController:navVC animated:YES];
}

- (void)addComment:(id)sender {
  ComposerViewController *composerVC = [[[ComposerViewController alloc] initWithMOC:_MOC
                                                                           delegate:self
                                                                     originalItemId:[NSString stringWithFormat:@"%@", self.post.postId]] autorelease];
  composerVC.title = LocaleStringForKey(NSNewCommentTitle, nil);
  WXWNavigationController *navVC = [[[WXWNavigationController alloc] initWithRootViewController:composerVC] autorelease];
  [self.navigationController presentModalViewController:navVC animated:YES];
}

- (void)openLikers{
  
  [CommonUtils doDelete:_MOC entityName:@"Alumni"];
  
  NSString *param = [NSString stringWithFormat:@"<post_id>%@</post_id><page>0</page><page_size>10</page_size>", self.post.postId];
  
  UserListViewController *userListVC = [[UserListViewController alloc] initWithType:POST_LIKE_USER_LIST_TY
                                                                       needGoToHome:YES
                                                                                MOC:_MOC
                                                                              group:nil
                                                                  needAdjustForiOS7:NO];
  userListVC.pageIndex = 0;
  userListVC.requestParam = param;
  
  userListVC.title = LocaleStringForKey(NSLikerTitle, nil);
  [self.navigationController pushViewController:userListVC animated:YES];
  RELEASE_OBJ(userListVC);
}

- (void)deletePost {
  
  _actionSheetOwnerType = DELETE_ITEM_AS_TY;
  
  UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSDeleteFeedWarningMsg, nil)
                                                  delegate:self
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
  [as addButtonWithTitle:LocaleStringForKey(NSDeleteActionTitle, nil)];
  as.destructiveButtonIndex = [as numberOfButtons] - 1;
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.view];
  RELEASE_OBJ(as);
}

- (void)deleteComment:(long long)commentId {
  
  _beDeletedCommentId = commentId;
  
  _actionSheetOwnerType = DELETE_COMMENT_AS_TY;
  UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSDeleteCommentWarningMsg, nil)
                                                  delegate:self
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
  [as addButtonWithTitle:LocaleStringForKey(NSDeleteActionTitle, nil)];
  as.destructiveButtonIndex = [as numberOfButtons] - 1;
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.view];
  RELEASE_OBJ(as);
  
}

- (void)editPhoto {
  [self addOrRemovePhoto];
}

- (void)clearPhoto {
  self.selectedPhoto = nil;
}

- (void)sendComment:(NSString *)content {
  
  self.connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                               interactionContentType:SEND_COMMENT_TY] autorelease];
  [(ECAsyncConnectorFacade *)self.connFacade sendComment:content
                originalItemId:[NSString stringWithFormat:@"%@", self.post.postId]
                         photo:self.selectedPhoto];
}

- (void)sharePostToWeChat:(Post *)post {
  if (post) {
    if ([WXApi isWXAppInstalled]) {
      ((iAlumniAppDelegate*)APP_DELEGATE).wxApiDelegate = self;
      
      NSString *url = [NSString stringWithFormat:CONFIGURABLE_DOWNLOAD_URL,
                       [AppManager instance].hostUrl,
                       [WXWSystemInfoManager instance].currentLanguageDesc,
                       [AppManager instance].releaseChannelType];
      [CommonUtils sharePostByWeChat:post
                               scene:WXSceneSession
                                 url:url
                               image:self.postImage];
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                      message:LocaleStringForKey(NSNoWeChatMsg, nil)
                                                     delegate:self
                                            cancelButtonTitle:LocaleStringForKey(NSDonotInstallTitle, nil)
                                            otherButtonTitles:LocaleStringForKey(NSInstallTitle, nil), nil];
      [alert show];
      [alert release];
    }
  }
}

#pragma mark - WXApiDelegate methods
-(void) onResp:(BaseResp*)resp
{
  if([resp isKindOfClass:[SendMessageToWXResp class]]) {
    switch (resp.errCode) {
      case WECHAT_OK_CODE:
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatDoneMsg, nil)
                                      msgType:SUCCESS_TY
                           belowNavigationBar:YES];
        break;
        
      case WECHAT_BACK_CODE:
        break;
        
      default:
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        break;
    }
  }
  
  ((iAlumniAppDelegate*)APP_DELEGATE).wxApiDelegate = nil;
}

#pragma mark - ECItemUploaderDelegate methods
- (void)afterUploadFinishAction:(WebItemType)actionType {
  
  [self loadComments:TRIGGERED_BY_AUTOLOAD forNewComment:YES];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case CONTENT_SEC:
      return 1;
      
    case COMMENT_SEC:
    {
      if (_fetchedRC) {
        return _fetchedRC.fetchedObjects.count + 1;
      } else {
        return 0;
      }
      
    }
    default:
      return 0;
  }
}

- (void)checkAndSetCurrentOldestCommentIndexPath:(NSIndexPath *)indexPath {
  
  // record the oldest comment time
	if (indexPath.section == COMMENT_SEC) {
    
    if (indexPath.row == _fetchedRC.fetchedObjects.count - 1) {
      _currentStartIndex = indexPath.row + 1;
    }
	}
}

- (CommentListCell *)drawCommentCell:(NSIndexPath *)indexPath {
  
  PostComment *comment = (_fetchedRC.fetchedObjects)[indexPath.row];
  
  static NSString *kCommentCellIdentifier = @"CommentListCell";
  CommentListCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
  if (nil == cell) {
    cell = [[[CommentListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:kCommentCellIdentifier
                            imageDisplayerDelegate:self
                            imageClickableDelegate:self
                                               MOC:_MOC] autorelease];
  }
  
  [cell drawComment:comment];
  
  [self checkAndSetCurrentOldestCommentIndexPath:indexPath];
  
  return cell;
}

- (UITableViewCell *)drawContentCell {
  
  static NSString *kContentCellIdentifier = @"PostDetailCell";
  PostContentCell *cell = [_tableView dequeueReusableCellWithIdentifier:kContentCellIdentifier];
  if (nil == cell) {
    cell = [[[PostContentCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:kContentCellIdentifier
                            imageDisplayerDelegate:self
                            clickableElementHolder:self
                   connectionTriggerHolderDelegate:self
                                               MOC:_MOC
                                          postType:_postType] autorelease];
  }
  
  [cell drawPost:self.post];
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case CONTENT_SEC:
    {
      return [self drawContentCell];
    }
      
    case COMMENT_SEC:
    {
      if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return [self drawFooterCell];
      }
      
      return [self drawCommentCell:indexPath];
    }
    default:
      return nil;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  switch (section) {
    case CONTENT_SEC:
      return nil;
      
    case COMMENT_SEC:
    {
      if (!_loadingComments) {
        NSString *title = nil;
        switch ([WXWCommonUtils currentLanguage]) {
          case ZH_HANS_TY:
            title = [NSString stringWithFormat:@"%@(%d)", LocaleStringForKey(NSCommentTitle, nil),
                     [_fetchedRC.fetchedObjects count]];
            break;
            
          case EN_TY:
            if ([_fetchedRC.fetchedObjects count] > 1) {
              title = [NSString stringWithFormat:@"%@(%d)", LocaleStringForKey(NSCommentsTitle, nil),
                       [_fetchedRC.fetchedObjects count]];
            } else {
              title = [NSString stringWithFormat:@"%@(%d)", LocaleStringForKey(NSCommentTitle, nil),
                       [_fetchedRC.fetchedObjects count]];
            }
            
            break;
          default:
            break;
        }
        
        self.sectionView.titleLabel.text = title;
      }
      return self.sectionView;
    }
      
    default:
      return nil;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  switch (section) {
    case CONTENT_SEC:
      return nil;
      
    case COMMENT_SEC:
      return _tableView.tableFooterView;
      
    default:
      return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  switch (section) {
    case CONTENT_SEC:
      return 0;
      
    case COMMENT_SEC:
      return SECTION_VIEW_HEIGHT;
      
    default:
      return 0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  
  switch (section) {
    case CONTENT_SEC:
      return 0.0f;
      
    case COMMENT_SEC:
      return 1.0f;
      
    default:
      return 0.0f;
  }
}

- (CGFloat)imageHeight {
  ImageOrientationType orientationType;
  if (self.post.originalImageWidth.floatValue > self.post.originalImageHeight.floatValue) {
    orientationType = IMG_LANDSCAPE_TY;
  } else if (self.post.originalImageWidth.floatValue < self.post.originalImageHeight.floatValue){
    orientationType = IMG_PORTRAIT_TY;
  } else {
    orientationType = IMG_SQUARE_TY;
  }
  
  CGFloat height = 0;
  
  if (self.post.originalImageWidth.floatValue < FEED_IMG_LONG_LEN_IPHONE) {
    
    height = self.post.originalImageHeight.floatValue;
    
  } else {
    switch (orientationType) {
      case IMG_LANDSCAPE_TY:
        height = self.post.originalImageHeight.floatValue * FEED_IMG_LONG_LEN_IPHONE / self.post.originalImageWidth.floatValue;
        break;
        
      case IMG_PORTRAIT_TY:
        height = FEED_IMG_LONG_LEN_IPHONE * self.post.originalImageHeight.floatValue / self.post.originalImageWidth.floatValue;
        break;
        
      case IMG_SQUARE_TY:
        height = FEED_IMG_LONG_LEN_IPHONE;
        break;
        
      default:
        break;
    }
  }
  
  return (height + MARGIN * 2);
}

- (CGFloat)heightForContentCell {
  
  CGFloat contentHeight = AUTHOR_AREA_HEIGHT + MARGIN * 2 + 2.0f;
    
  if (self.post.imageAttached.boolValue) {
    contentHeight += [self imageHeight];
    contentHeight += MARGIN * 2;
  }
  
  if (_textContentLoaded) {
    contentHeight += _textContentHeight;
  } else {
    CGFloat tempTextHeight = [UIUtils contentHeight:self.post.content width:FEED_DETAIL_CONTENT_WIDTH];
    contentHeight += tempTextHeight;
  }
  //    contentHeight += MARGIN * 2;
  
  if (self.post.locationAttached.boolValue) {
    contentHeight += EMBED_MAP_HEIGHT;
    if (self.post.place.length > 0) {
      NSString *text = [NSString stringWithFormat:@"%@%@", LocaleStringForKey(NSAtTitleMsg, nil), self.post.place];
      CGSize size = [text sizeWithFont:FONT(11)
                     constrainedToSize:CGSizeMake(FEED_DETAIL_CONTENT_WIDTH, CGFLOAT_MAX)
                         lineBreakMode:NSLineBreakByWordWrapping];
      contentHeight += MARGIN + size.height;
    }
    contentHeight += MARGIN * 2;
  }
  
  CGFloat leftPhotoAndToolBarHeight = PHOTO_SIDE_LENGTH * 2 + MARGIN + MARGIN * 2 + PHOTO_SIDE_LENGTH + MARGIN + MARGIN * 2;
  
  CGFloat y = 0;
  
  if (leftPhotoAndToolBarHeight < contentHeight) {
    y = contentHeight + MARGIN * 2;
  } else {
    y = leftPhotoAndToolBarHeight + MARGIN * 2;
  }
  
  if (self.post.isHaveSurvey.boolValue) {
    y += MARGIN;
    y += 25;
  }
  
  if (self.post.likeCount.intValue > 0) {
    //y += CELL_BASE_INFO_HEIGHT;
    y += LIKE_PEOPLE_ALBUM_HEIGHT;
    y += MARGIN * 4;
  }
  
  if (self.post.tagNames && self.post.tagNames.length > 0) {
    y += TAG_LIST_HEIGHT + MARGIN * 2;
  }
  
  y += CELL_BASE_INFO_HEIGHT;
  y += MARGIN * 2;
  
  return y;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case CONTENT_SEC:
    {
      return [self heightForContentCell];
    }
      
    case COMMENT_SEC:
    {
      if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return COMMENT_WITHOUT_IMG_CELL_MIN_HEIGHT;
      } else {
        
        PostComment *comment = (PostComment *)(_fetchedRC.fetchedObjects)[indexPath.row];
        
        if (comment.isFault) {
          // avoid core data memory error
          return COMMENT_WITHOUT_IMG_CELL_MIN_HEIGHT;
        }
        
        CGFloat height = MARGIN * 2;
        BOOL hasImage = [comment.imageAttached boolValue];
        
        CGSize size = [comment.authorName sizeWithFont:FONT(17)
                                     constrainedToSize:CGSizeMake(200, COMMENT_AUTHOR_HEIGHT)
                                         lineBreakMode:NSLineBreakByWordWrapping];
        height += size.height;
        
        height += MARGIN;
        
        CGFloat width = 0;
        if (hasImage) {
          width = self.view.frame.size.width - MARGIN * 2 - IMAGE_SIDE_LENGTH - MARGIN - (MARGIN * 2 + PHOTO_SIDE_LENGTH + MARGIN);
        } else {
          width = self.view.frame.size.width - MARGIN * 2 - (MARGIN * 2 + PHOTO_SIDE_LENGTH + MARGIN);
        }
        size = [comment.content sizeWithFont:FONT(13)
                           constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
        
        if (hasImage) {
          if (size.height < IMAGE_SIDE_LENGTH) {
            height += IMAGE_SIDE_LENGTH;
          } else {
            height += size.height;
          }
        } else {
          height += size.height;
        }
        
        height += MARGIN * 2;
        
        CGFloat minHeight = 0;
        if (hasImage) {
          minHeight = COMMENT_WITH_IMG_CELL_MIN_HEIGHT;
        } else {
          minHeight = COMMENT_WITHOUT_IMG_CELL_MIN_HEIGHT;
        }
        
        if (height < minHeight) {
          if (!hasImage && comment.couldBeDeleted.boolValue) {
            height += MARGIN + DELETE_BUTTON_HEIGHT;
          } else {
            height = minHeight;
          }
          
          return height;
        } else {
          
          if (!hasImage) {
            if (height - minHeight < MARGIN + DELETE_BUTTON_HEIGHT) {
              
              CGFloat gap = height - minHeight;
              gap = MARGIN + DELETE_BUTTON_HEIGHT - gap;
              height += gap;
            }
          }
          
          return height;
        }
      }
    }
    default:
      return 0;
  }
}

#pragma mark - lifecycle methods

- (void)registerNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateFeedContentCell:)
                                               name:TEXT_CONTENT_LOADED_NOTIFY
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(addLikeAlbum)
                                               name:DISPLAY_LIKE_ALBUM_NOTIFY
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(removeLikeAlbum)
                                               name:HIDE_LIKE_ALBUM_NOTIFY
                                             object:nil];
  
}

- (void)parserVisibleViewAreaHeight {
  
  _visibleViewHeight = APP_WINDOW.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - self.navigationController.navigationBar.frame.size.height;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
             post:(Post *)post
         postType:(PostType)postType {
  
  self = [super initWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    self.post = post;
    _postType = postType;
    [self registerNotifications];
    
    _noNeedDisplayEmptyMsg = YES;
  }
  
  return self;
}

- (void)dealloc {
  
  // notify all sub views that the connection be cancelled, stop all network
  // connection stuff
  [[NSNotificationCenter defaultCenter] postNotificationName:CONN_CANCELL_NOTIFY
                                                      object:self
                                                    userInfo:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:TEXT_CONTENT_LOADED_NOTIFY
                                                object:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:DISPLAY_LIKE_ALBUM_NOTIFY
                                                object:nil];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:HIDE_LIKE_ALBUM_NOTIFY
                                                object:nil];
  
  RELEASE_OBJ(_sectionView);
  
  self.postImage = nil;
  
  self.lastSectionTitle = nil;
  
  self.pickerOverlayVC = nil;
  
  // delete the likers from MOC
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(likeItems == 1)"];
  DELETE_OBJS_FROM_MOC(_MOC, @"Member", predicate);
  
  // delete Post Comment
  DELETE_OBJS_FROM_MOC(_MOC, @"PostComment", nil);
  
  self.post = nil;
  
  [super dealloc];
}

- (void)initTableViewProperties {
  _tableView.backgroundColor = CELL_COLOR;
  
  _noCommentComposerTableHeight = _tableView.frame.size.height;
  
  _tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)] autorelease];
  _tableView.tableFooterView.backgroundColor = CELL_BORDER_COLOR;
}

- (void)initHandyCommentComposer {
  
  CGFloat y = 0.0f;
  
  // show by logic
  //    if (_tableView.contentSize.height < _tableView.frame.size.height) {
  //        y = self.view.frame.size.height - COMMENT_COMPOSER_HEIGHT - 44.0f;
  //    } else {
  //        y = self.view.frame.size.height;
  //    }
  
  //y = 376; // by Adam
  
  y = self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - COMMENT_COMPOSER_HEIGHT;
  
  _commentComposerView = [[[NoticeableCommentComposerView alloc] initWithFrame:CGRectMake(0,
                                                                                          y,
                                                                                          self.view.frame.size.width,
                                                                                          COMMENT_COMPOSER_HEIGHT)
                                                                      topColor:COLOR(239, 239, 240)//COLOR(219, 219, 219)
                                                                   bottomColor:COLOR(197, 199, 203)//COLOR(166, 166, 166)
                                                              topSeparatorLine:COLOR(186, 186, 186)
                                                                      itemType:WRITE_COMMENT_ITEM_TY
                                                          itemUploaderDelegate:self
                                                      clickableElementDelegate:self] autorelease];
  [self.view addSubview:_commentComposerView];
  
  
}

- (void)viewDidLoad {
  
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  [self initTableViewProperties];
  
  [self initHandyCommentComposer];
  
  [self parserVisibleViewAreaHeight];
}

- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  
  if (!_autoLoaded) {
    // 1. load local stored comments firstly
    [self refreshTable];
    
    // 2. load new comments secondly
    [self loadComments:TRIGGERED_BY_AUTOLOAD forNewComment:YES];
  } else {
    [_tableView reloadData];
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - WXWConnectionTriggerHolderDelegate
- (void)registerRequestUrl:(NSString *)url connFacade:(ECAsyncConnectorFacade *)connFacade {
  if (url && url.length > 0) {
    // [self.connDic setObject:connFacade forKey:url];
  }
}

#pragma mark - ECPhotoPickerDelegate method

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

- (void)applyPhotoSelectedStatus:(UIImage *)image {
  
	self.selectedPhoto = image;
  
  [_commentComposerView applySelectedPhoto:[CommonUtils cutPartImage:image
                                                               width:60.0f
                                                              height:60.0f]];
  [_commentComposerView setSendButton:YES];
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

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
	
  [self handleFinishPickImage:image
                   sourceType:picker.sourceType];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)showImagePicker {
  
  _photoSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  if (HAS_CAMERA) {
    _photoSourceType = UIImagePickerControllerSourceTypeCamera;
  }
  
  self.pickerOverlayVC = [[[ECPhotoPickerOverlayViewController alloc] initWithSourceType:_photoSourceType
                                                                                delegate:self
                                                                        uploaderDelegate:self
                                                                               takerType:POST_COMPOSER_TY
                                                                                     MOC:_MOC] autorelease];
  
  [self.pickerOverlayVC arrangeViews];
  [self presentModalViewController:self.pickerOverlayVC.imagePicker animated:YES];
}

- (void)addOrRemovePhoto {
  
  if (nil == self.selectedPhoto) {
    [self showImagePicker];
  } else {
    
    _actionSheetOwnerType = DELETE_PHOTO_AS_TY;
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

#pragma mark - alert delegate method
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case 1:
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WECHAT_ITUNES_URL]];
      break;
    default:
      break;
  }
}

@end
