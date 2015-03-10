//
//  BizPostListViewController.m
//  iAlumni
//
//  Created by Adam on 12-12-8.
//
//

#import "BizPostListViewController.h"
#import "Club.h"
#import "ItemComposerViewController.h"
#import "Post.h"
#import "GroupDiscussionCell.h"
#import "PostDetailViewController.h"
#import "AlumniProfileViewController.h"
#import "ECHandyImageBrowser.h"
#import "WXWNavigationController.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "UIUtils.h"

@interface BizPostListViewController ()
@property (nonatomic, retain) Club *group;
@end

@implementation BizPostListViewController

#pragma mark - user actions
- (void)compose:(id)sender {
  
  if (self.group.allowPost.boolValue) {
    ItemComposerViewController *composerVC = [[[ItemComposerViewController alloc] initWithMOC:_MOC
                                                                                        group:self.group
                                                                                  contentType:SEND_BIZ_POST_TY
                                                                             uploaderDelegate:self] autorelease];
    composerVC.title = LocaleStringForKey(NSNewFeedTitle, nil);
    
    WXWNavigationController *navVC = [[[WXWNavigationController alloc] initWithRootViewController:composerVC] autorelease];
    [self.navigationController presentModalViewController:navVC animated:YES];
    
    _returnFromComposer = YES;
    
  } else {
    // not allowed, then show message to user
    ShowAlertWithOneButton(nil, nil, self.group.forbidPostReason, LocaleStringForKey(NSIKnowTitle, nil));
    
  }
}

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = LOAD_BIZ_POST_TY;
  
  NSString *param = [NSString stringWithFormat:@"<page_size>%@</page_size><sort_type>%d</sort_type><post_type>%@</post_type><latitude>%f</latitude><longitude>%f</longitude><host_id>%@</host_id><list_type>%d</list_type>",
                     ITEM_LOAD_COUNT,
                     SORT_BY_ID_TY,
                     self.group.clubType,
                     [AppManager instance].latitude,
                     [AppManager instance].longitude,
                     self.group.clubId,
                     SPECIAL_GROUP_LIST_POST_TY];
  
  NSMutableString *requestParam = [NSMutableString stringWithString:param];
  if (forNew) {
    [requestParam appendString:@"<page>0</page>"];
  } else {
    [requestParam appendFormat:@"<page>%d</page>", _currentStartIndex++];
  }
  
  NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade fetchNews:url];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"Post";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
  [self.descriptors addObject:descriptor];
  
  self.predicate = [NSPredicate predicateWithFormat:@"(clubId == %@)", self.group.clubId];
}

#pragma mark - post delete handle
- (void)selectedFeedBeDeleted {
  _selectedFeedBeDeleted = YES;
}

#pragma mark - lifecycle methods
- (void)clearData {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(clubId == %@)", self.group.clubId];
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Post", predicate);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(Club *)group {
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:YES
      needRefreshFooterView:YES
                 needGoHome:NO];
  if (self) {
    self.group = group;
    
    [self clearData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedFeedBeDeleted)
                                                 name:FEED_DELETED_NOTIFY
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  
  [self clearData];
  
  self.group = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:FEED_DELETED_NOTIFY
                                                object:nil];
  
  [super dealloc];
}

- (void)addComposerButton {
  
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSPostTitle, nil)
                            target:self
                            action:@selector(compose:)];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self addComposerButton];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // if the selected post be deleted, then should not update the cell, because the post has been removed from MOC
  if (!_selectedFeedBeDeleted) {
    [self updateLastSelectedCell];
  } else {
    [self deleteLastSelectedCell];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  
  if (!_returnFromComposer) {
    
    // if the selected post be deleted, then no need to load new post
    if (!_selectedFeedBeDeleted) {
      
      if (!_autoLoaded) {
        
        // check whether this is first time user use this list (user this app first time)
        if ([WXWCoreDataUtils objectInMOC:_MOC entityName:@"Post" predicate:nil]) {
          
          _userFirstUseThisList = NO;
          
          // this is not first time user entered this list, so take following actions:
          
          // 1. load local posts firstly
          [self refreshTable];
          
        } else {
          // this is user first time use this app
          _userFirstUseThisList = YES;
        }
        
        // then load new posts secondly
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
      }
      
    } else {
      
      _selectedFeedBeDeleted = NO;
    }
    
  } else {
    _returnFromComposer = NO;
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methoes
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case LOAD_BIZ_POST_TY:
    {
      BOOL blockCurrentView = NO;
      if (_userFirstUseThisList) {
        blockCurrentView = YES;
      } else {
        blockCurrentView = NO;
      }
      [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
                blockCurrentView:blockCurrentView];
    }
    default:
      break;
  }
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
      
    case LOAD_BIZ_POST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self refreshTable];
        
        if (!_autoLoadAfterSent) {
          // we hope table view keep the position for auto load, so we adjust content offset of table view auto load;
          // if the table view refresh triggered by load new post after post send, then we hope the latest sent post (just be downloaded) could be displayed for user, then we will not adjust the content offset
          
          CGFloat beforeRefreshTableHeight = _tableView.contentSize.height;
          CGPoint offsetPoint = _tableView.contentOffset;
          
          if (_loadForNewItem && beforeRefreshTableHeight > FEED_CELL_HEIGHT) {
            // only keep the table position when user start up app from second time, no need to keep position for user
            // enter news list first time
            // beforeRefreshTableHeight will be larger than 0 if there are news existing in local already
            CGFloat afterRefreshTableHeight = _tableView.contentSize.height;
            _currentContentOffset_y += afterRefreshTableHeight - beforeRefreshTableHeight;
            if (_currentContentOffset_y < 0) {
              _currentContentOffset_y = 0;
            } else {
              _tableView.contentOffset = CGPointMake(offsetPoint.x, _currentContentOffset_y);
            }
          }
        }
        
        if ([AppManager instance].loadedItemCount > 0 && !_autoLoadAfterSent) {
          
          // if table view refresh triggered by new post send, then the load successful message no need to be displayed for user;
          // if table view refresh triggered by auto load, then the new downloaded posts message should be displayed for user
          
          self.connectionResultMessage = [NSString stringWithFormat:LocaleStringForKey(NSNewFeedLoadedMsg, nil), [AppManager instance].loadedItemCount];
          
        } else if (_autoLoadAfterSent) {
          _autoLoadAfterSent = NO;
        }
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSLoadFeedFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      [self resetUIElementsForConnectDoneOrFailed];
      
      if (_userFirstUseThisList) {
        _userFirstUseThisList = NO;
      }
    }
      break;
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
      
    case LOAD_BIZ_POST_TY:
    {
      if (_autoLoadAfterSent) {
        _autoLoadAfterSent = NO;
      }
      
      if ([self connectionMessageIsEmpty:error]) {
        self.connectionErrorMsg = LocaleStringForKey(NSLoadFeedFailedMsg, nil);
      }
      
      if (_userFirstUseThisList) {
        _userFirstUseThisList = NO;
      }
    }
      break;
      
    default:
      break;
  }
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - ECItemUploaderDelegate methods
- (void)afterUploadFinishAction:(WebItemType)actionType {
  
  _autoLoadAfterSent = YES;
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return [self drawFooterCell];
  }
  
  Post *post = [_fetchedRC objectAtIndexPath:indexPath];
  
  static NSString *cellIdentifier = @"PostListCell";
  GroupDiscussionCell *cell = (GroupDiscussionCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    
    cell = [[[GroupDiscussionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellIdentifier
                                imageDisplayerDelegate:self
                                imageClickableDelegate:self
                                                   MOC:_MOC] autorelease];
  }
  
  [cell drawPost:post MOC:_MOC];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return FEED_CELL_HEIGHT;
  } else {
    
    Post *post = [_fetchedRC objectAtIndexPath:indexPath];
    
    CGFloat height = MARGIN * 8;
    
    CGFloat x = MARGIN * 2 + POSTLIST_PHOTO_WIDTH + MARGIN * 2;
    CGFloat width = self.view.frame.size.width - x - MARGIN * 2;
    CGSize size = [post.content sizeWithFont:FONT(15)
                           constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height;
    
    if (post.imageAttached.boolValue) {
      height += MARGIN * 2;
      height += POST_IMG_LONG_SIDE;
      height += MARGIN;
    } else {
      height += MARGIN * 2;
    }
    
    height += CELL_BASE_INFO_HEIGHT;
    
    height += MARGIN * 2;
    
    if (height < FEED_CELL_HEIGHT) {
      return FEED_CELL_HEIGHT;
    } else {
      return height;
    }
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  Post *post = [_fetchedRC objectAtIndexPath:indexPath];
  
  PostDetailViewController *detailVC = [[[PostDetailViewController alloc] initWithMOC:_MOC
                                                                               holder:_holder
                                                                     backToHomeAction:_backToHomeAction
                                                                                 post:post
                                                                             postType:DISCUSS_POST_TY] autorelease];
  
  detailVC.title = LocaleStringForKey(NSPostDetailTitle, nil);
  
  [AppManager instance].isPostDetail = YES;
  
  [self.navigationController pushViewController:detailVC animated:YES];
  _lastSelectedIndexPath = indexPath;
}

#pragma mark - ECClickableElementDelegate method
- (void)openImageUrl:(NSString *)imageUrl {
  ECHandyImageBrowser *imageBrowser = [[[ECHandyImageBrowser alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                                           imgUrl:imageUrl] autorelease];
  [self.view addSubview:imageBrowser];
  [imageBrowser setNeedsLayout];
}

- (void)openProfile:(NSString*)userId userType:(NSString*)userType
{
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                    personId:userId
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

@end
