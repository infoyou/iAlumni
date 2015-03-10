//
//  ReviewsListViewController.m
//  ExpatCircle
//
//  Created by Adam on 11-12-25.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ReviewsListViewController.h"
#import "CommonUtils.h"
#import "TextConstants.h"
#import "ECAsyncConnectorFacade.h"
#import "AppManager.h"
#import "ServiceProvider.h"
#import "XMLParser.h"
#import "CoreDataUtils.h"
#import "UIUtils.h"
#import "Comment.h"
#import "CommentCell.h"
//#import "MemberProfileViewController.h"
#import "ECImageBrowseViewController.h"
#import "WXWNavigationController.h"
#import "HttpUtils.h"
#import "ComposerViewController.h"

#define PAGE_COUNT    20

@implementation ReviewsListViewController

#pragma mark - add comment
- (void)addComment:(id)sender {
  
  ComposerViewController *composerVC = [[[ComposerViewController alloc] initServiceProviderCommentComposerWithMOC:_MOC
                                                                                                         delegate:self
                                                                                                   originalItemId:[NSString stringWithFormat:@"%@", _sp.spId]] autorelease];
  composerVC.title = LocaleStringForKey(NSNewReviewTitle, nil);
  WXWNavigationController *navVC = [[[WXWNavigationController alloc] initWithRootViewController:composerVC] autorelease];
  [self.navigationController presentModalViewController:navVC animated:YES];
}

#pragma mark - load comment
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  NSString *requestUrl = nil;
  switch (triggerType) {
    case TRIGGERED_BY_AUTOLOAD:
      requestUrl = [HttpUtils assembleFetchServiceProviderCommentUrl:_sp.spId.longLongValue
                                                          startIndex:INT_TO_STRING(0) 
                                                              counts:INT_TO_STRING(PAGE_COUNT)];
      break;
      
    case TRIGGERED_BY_SCROLL:
      requestUrl = [HttpUtils assembleFetchServiceProviderCommentUrl:_sp.spId.longLongValue
                                                          startIndex:INT_TO_STRING(_currentStartIndex)
                                                              counts:INT_TO_STRING(PAGE_COUNT)];
      break;
    default:
      break;
  }
  NSString *url = [CommonUtils assembleXmlRequestUrl:@"service_provider_comment_list" param:requestUrl];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self 
                                                                  interactionContentType:LOAD_SERVICE_PROVIDER_COMMENT_TY] autorelease];
  (self.connDic)[url] = connFacade;
  [connFacade fetchComments:url];
  
}

#pragma mark - override methods
- (void)configureMOCFetchConditions {
  self.entityName = @"Comment";
  self.predicate = [NSPredicate predicateWithFormat:@"(parentId == %@)", _sp.spId];
  
  self.descriptors = [NSMutableArray array];  
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
  [self.descriptors addObject:descriptor];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC 
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction
               sp:(ServiceProvider *)sp
  allowAddComment:(BOOL)allowAddComment {
  
  self = [super initWithMOC:MOC 
                     holder:holder 
           backToHomeAction:backToHomeAction 
      needRefreshHeaderView:NO 
      needRefreshFooterView:YES
                 needGoHome:NO];
  if (self) {
    _sp = sp;
    
    _allowAddComment = allowAddComment;
  }
  return self;
}

- (void)initAddCommentButton {
  
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSCommentTitle, nil)
                            target:self
                            action:@selector(addComment:)];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _tableView.backgroundColor = CELL_COLOR;
  
  if (_allowAddComment) {
    [self initAddCommentButton];
  }
}

- (void)dealloc {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(parentId == %@)", _sp.spId];
  DELETE_OBJS_FROM_MOC(_MOC, @"Comment", predicate);
  [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  }
}

#pragma mark - ECClickableElementDelegate methods
- (void)openProfile:(NSString *)userId userType:(NSString *)userType {
  /*
  MemberProfileViewController *profileVC = [[[MemberProfileViewController alloc] initWithMOC:_MOC
                                                                                      holder:_holder
                                                                            backToHomeAction:_backToHomeAction
                                                                                      userId:userId] autorelease];
  profileVC.title = LocaleStringForKey(NSUserProfileTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
   */
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

#pragma mark - ECItemUploaderDelegate methods
- (void)afterUploadFinishAction:(WebItemType)actionType {
  
  _sp.commentCount = @(_sp.commentCount.intValue + 1);
  [WXWCoreDataUtils saveMOCChange:_MOC];
      
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result 
                url:(NSString *)url 
        contentType:(NSInteger)contentType {
  
  if ([XMLParser parserResponseXml:result
                              type:LOAD_SERVICE_PROVIDER_COMMENT_TY
                               MOC:_MOC
                 connectorDelegate:self
                               url:url]) {
    [self refreshTable];            
        
  } else {
    
    [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                           alternativeMsg:LocaleStringForKey(NSLoadCommentFailedMsg, nil) 
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
  
  _autoLoaded = YES;
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSLoadCommentFailedMsg, nil);
  }
  
  _autoLoaded = YES;
  
  [super connectFailed:error url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _fetchedRC.fetchedObjects.count + 1;  
}

- (void)checkAndSetCurrentOldestCommentIndexPath:(NSIndexPath *)indexPath {
  
  // record the oldest comment time
  
  id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchedRC sections][indexPath.section];
  if (indexPath.row == [sectionInfo numberOfObjects] - 1) {       
    _currentStartIndex = indexPath.row + 1;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {  
    return [self drawFooterCell];
  }
  
  Comment *comment = (_fetchedRC.fetchedObjects)[indexPath.row];
  
  static NSString *kCommentCellIdentifier = @"CommentCell";
  CommentCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
  if (nil == cell) {
    cell = [[[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:kCommentCellIdentifier
                        imageDisplayerDelegate:self
                        imageClickableDelegate:self
                                           MOC:_MOC] autorelease];
  }
  
  [cell drawComment:comment showLocation:NO];
  
  [self checkAndSetCurrentOldestCommentIndexPath:indexPath];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return COMMENT_WITHOUT_IMG_CELL_MIN_HEIGHT;
  } else {
    
    Comment *comment = (Comment *)(_fetchedRC.fetchedObjects)[indexPath.row];
    
    CGFloat height = MARGIN * 2;
    BOOL hasImage = [comment.imageAttached boolValue];
    
    CGSize size = [comment.authorName sizeWithFont:FONT(17)
                                 constrainedToSize:CGSizeMake(200, COMMENT_AUTHOR_HEIGHT)
                                     lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height;
    
    height += MARGIN;
    
    CGFloat width = 0;
    if (hasImage) {
      width = self.view.frame.size.width - MARGIN * 2 - 
      IMAGE_SIDE_LENGTH - MARGIN - (MARGIN * 2 + PHOTO_SIDE_LENGTH + MARGIN);
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
      return minHeight;
    } else {
      return height;
    }
  }
}

@end
