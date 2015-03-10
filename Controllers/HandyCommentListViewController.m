//
//  HandyCommentListViewController.m
//  ExpatCircle
//
//  Created by Adam on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HandyCommentListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HandyCommentComposerView.h"
#import "News.h"
#import "ECTextView.h"
#import "CommentCell.h"
#import "UIUtils.h"
#import "HttpUtils.h"
#import "TextConstants.h"
#import "XMLParser.h"
#import "Comment.h"
#import "ECImageBrowseViewController.h"
#import "WXWNavigationController.h"
#import "CoreDataUtils.h"
#import "AlumniProfileViewController.h"

@interface HandyCommentListViewController()
@end

@implementation HandyCommentListViewController

#pragma mark - load comment
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  NSString *requestUrl = nil;
  NSString *url = nil;
  switch (_contentType) {
    case SEND_COMMENT_TY:
    {
      switch (triggerType) {
        case TRIGGERED_BY_AUTOLOAD:
          requestUrl = [HttpUtils assembleFetchCommentUrl:LLINT_TO_STRING(_itemId)
                                               startIndex:INT_TO_STRING(0) 
                                                   counts:ITEM_LOAD_COUNT];
          break;
          
        case TRIGGERED_BY_SCROLL:
          requestUrl = [HttpUtils assembleFetchCommentUrl:LLINT_TO_STRING(_itemId)
                                               startIndex:INT_TO_STRING(_currentStartIndex)
                                                   counts:ITEM_LOAD_COUNT];
          break;
          
        default:
          break;
      }
      
      url = [CommonUtils assembleXmlRequestUrl:@"comments_get" param:requestUrl];
      
      ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self 
                                                                      interactionContentType:LOAD_COMMENT_TY] autorelease];
      (self.connDic)[url] = connFacade;
      [connFacade fetchComments:url];

      break;
    }
      
    case SEND_SERVICE_ITEM_COMMENT_TY:
    {
     
      NSInteger startIndex = 0;
      if (!forNew) {
        startIndex = ++_currentStartIndex;
      }

      NSString *param = [NSString stringWithFormat:@"<service_id>%lld</service_id><start_index>%d</start_index><count>%@</count>",
                         _itemId,
                         startIndex,
                         ITEM_LOAD_COUNT];
      url = [CommonUtils geneUrl:param itemType:LOAD_SERVICE_ITEM_COMMENT_TY];
      
      ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self 
                                                                      interactionContentType:LOAD_SERVICE_ITEM_COMMENT_TY] autorelease];
      (self.connDic)[url] = connFacade;
      [connFacade fetchComments:url];
      
      break;
    }
      
    case SEND_BRAND_COMMENT_TY:
    {
      NSInteger startIndex = 0;
      if (!forNew) {
        startIndex = ++_currentStartIndex;
      }
      
      NSString *param = [NSString stringWithFormat:@"<channel_id>%lld</channel_id><start_index>%d</start_index><count>%@</count>",
                         _brandId,
                         startIndex,
                         ITEM_LOAD_COUNT];
      url = [CommonUtils geneUrl:param itemType:LOAD_BRAND_COMMENT_TY];
      
      ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                      interactionContentType:LOAD_BRAND_COMMENT_TY] autorelease];
      (self.connDic)[url] = connFacade;
      [connFacade fetchComments:url];

      break;
    }
      
    default:
      break;
  }
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
           itemId:(long long )itemId
          brandId:(long long)brandId
      contentType:(NSInteger)contentType
itemUploaderDelegate:(id<ECItemUploaderDelegate>)itemUploaderDelegate {
  
  self = [super initWithMOC:MOC 
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:NO 
      needRefreshFooterView:YES
                 needGoHome:NO];
  if (self) {
    
    _itemId = itemId;
    
    _brandId = brandId;
    
    _itemUploaderDelegate = itemUploaderDelegate;
    
    _contentType = contentType;
    
    _currentStartIndex = 0;
  }
  return self;
}

- (NSInteger)commentCount {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(parentId == %lld)", _itemId];
  return [WXWCoreDataUtils objectCountsFromMOC:_MOC entityName:@"Comment" predicate:predicate];
}

- (void)initCommentComposerView {
  _commentComposerView = [[[HandyCommentComposerView alloc] initWithFrame:CGRectMake(0, 
                                                                                     0, 
                                                                                     self.view.frame.size.width, 76.0f) 
                                                                    count:[self commentCount]
                                                              contentType:_contentType
                                                 clickableElementDelegate:self] autorelease];
  _commentComposerView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
  _commentComposerView.layer.shadowOpacity = 0.9f;
  _commentComposerView.layer.shadowColor = [UIColor grayColor].CGColor;
  _commentComposerView.layer.masksToBounds = NO;
  
  [self.view addSubview:_commentComposerView];
  
  _tableView.frame = CGRectMake(0, _commentComposerView.frame.origin.y + _commentComposerView.frame.size.height, 
                                self.view.frame.size.width, 
                                self.view.frame.size.height - _commentComposerView.frame.size.height);
}

- (void)dealloc {
  
  _oneTapRecoginzer.delegate = nil;
  
  [super dealloc];
}

- (void)initOneTapRecoginzer:(UIView *)gestureHolder {
	_oneTapRecoginzer = [[[UITapGestureRecognizer alloc] initWithTarget:self 
                                                               action:@selector(oneTapHandle:)] autorelease];
	_oneTapRecoginzer.numberOfTapsRequired = 1;
	_oneTapRecoginzer.numberOfTouchesRequired = 1;
	[gestureHolder addGestureRecognizer:_oneTapRecoginzer];
	_oneTapRecoginzer.delegate = self;	
}


- (void)viewDidLoad {
  [super viewDidLoad];
  
  _tableView.backgroundColor = CELL_COLOR;
  
  [self initCommentComposerView];
  
  [self initOneTapRecoginzer:self.view];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  }
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

#pragma mark - tap handler
- (void)tapGestureHandler {
  _tableView.frame = CGRectMake(0, _commentComposerView.frame.origin.y + _commentComposerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - _commentComposerView.frame.size.height);
}

- (void)oneTapHandle:(UIGestureRecognizer *)gesture {
  if (_commentComposerView.enlarged) {
    [_commentComposerView adjustLayout:NO];
  }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
  
  if ([touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[ECTextView class]]) {
    return NO;
  } else {
    return YES;
  }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}

#pragma mark - override methods
- (void)configureMOCFetchConditions {
  self.entityName = @"Comment";
  self.predicate = [NSPredicate predicateWithFormat:@"(parentId == %lld)", _itemId];
  
  self.descriptors = [NSMutableArray array];  
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
  [self.descriptors addObject:descriptor];
}

#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)handleLoadComments:(WebItemType)contentType {
  
  if (_itemUploaderDelegate) {
    [_itemUploaderDelegate afterUploadFinishAction:contentType];
  }
  
  // update news list
  [self refreshTable];
  
  // update comment count for composer view
  [_commentComposerView updateCommentCount:[self commentCount]];

  
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case LOAD_BRAND_COMMENT_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url
                          parentItemId:_itemId]) {
        [self handleLoadComments:contentType];
      
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSLoadCommentFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      break;
    }
      
    case SEND_COMMENT_TY:
    case SEND_SERVICE_ITEM_COMMENT_TY:
    case SEND_BRAND_COMMENT_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSSendCommentFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      break;
    }
      
    case LOAD_COMMENT_TY:
    case LOAD_SERVICE_ITEM_COMMENT_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {

        [self handleLoadComments:contentType];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSLoadCommentFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      break;
    }
    default:
      break;
  }

  _autoLoaded = YES;
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url 
          contentType:(NSInteger)contentType {
  
  NSString *msg = LocaleStringForKey(NSLoadCommentFailedMsg, nil);
  switch (contentType) {
    case SEND_SERVICE_ITEM_COMMENT_TY:
    case SEND_BRAND_COMMENT_TY:
      msg = LocaleStringForKey(NSLoadReviewsFailedMsg, nil);
      break;
      
    default:
      break;
  }

  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  
  _autoLoaded = YES;
  
  [super connectFailed:error url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  return NO;
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
  
  if (_contentType == SEND_BRAND_COMMENT_TY) {
    [cell drawComment:comment showLocation:YES];
  } else {
    [cell drawComment:comment showLocation:NO];
  }

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
      width = self.view.frame.size.width - MARGIN * 2 - IMAGE_SIDE_LENGTH - MARGIN - (MARGIN * 2 + PHOTO_SIDE_LENGTH + MARGIN);
    } else {
      width = self.view.frame.size.width - MARGIN * 2 - (MARGIN * 2 + PHOTO_SIDE_LENGTH + MARGIN);
    }
    
    if (_contentType == SEND_BRAND_COMMENT_TY && comment.locationName.length > 0) {
      size = [comment.locationName sizeWithFont:BOLD_FONT(13)
                              constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping];
      height += size.height + MARGIN;
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

#pragma mark - ECClickableElementDelegate methods
- (void)openProfile:(NSString *)userId userType:(NSString *)userType {
    
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                    personId:userId
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];

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

- (void)sendComment:(NSString *)content {
  self.connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                               interactionContentType:_contentType] autorelease];  
  switch (_contentType) {
    case SEND_COMMENT_TY:
      [(ECAsyncConnectorFacade *)self.connFacade sendComment:content
                    originalItemId:[NSString stringWithFormat:@"%lld", _itemId]
                             photo:nil];
      break;
      
    case SEND_SERVICE_ITEM_COMMENT_TY:
      [self.connFacade sendServiceItemComment:content
                                       itemId:[NSString stringWithFormat:@"%lld", _itemId]
                                      brandId:[NSString stringWithFormat:@"%lld", _brandId]];
      break;
      
    case SEND_BRAND_COMMENT_TY:
      [self.connFacade sendBrandComment:content
                                brandId:[NSString stringWithFormat:@"%lld", _brandId]];
      break;
      
    default:
      break;
  }
}

@end
