//
//  EventAlumniListViewController.m
//  iAlumni
//
//  Created by Adam on 12-8-29.
//
//

#import "EventAlumniListViewController.h"
#import "AppManager.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "CoreDataUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "PeopleWithChatCell.h"
#import "Alumni.h"
#import "EventCheckinAlumni.h"
#import "CoreDataUtils.h"
#import "ChatListViewController.h"
#import "AlumniFounder.h"
#import "XMLParser.h"
#import "ECGradientButton.h"
#import "QuickBackForCheckinView.h"
#import "Post.h"
#import "PostListCell.h"
#import "PostDetailViewController.h"
#import "ECHandyImageBrowser.h"
#import "ComposerViewController.h"
#import "WXWNavigationController.h"
#import "Event.h"
#import "AlumniProfileViewController.h"
#import "DMChatViewController.h"

#define PEOPLE_CELL_HEIGHT    90.0f
#define PHOTO_WIDTH           56.0f
#define BUTTON_WIDTH          150.0f
#define BUTTON_HEIGHT         30.0f

#define NAME_LIMITED_WIDTH    144.0f

@interface EventAlumniListViewController ()
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Alumni *alumni;
@property (nonatomic, retain) UIViewController *checkinEntrance;
@property (nonatomic, retain) id<EventCheckinDelegate> checkinResultDelegate;
@end

@implementation EventAlumniListViewController

@synthesize alumni = _alumni;
@synthesize event = _eventDetail;
@synthesize checkinEntrance = _checkinEntrance;
@synthesize checkinResultDelegate = _checkinResultDelegate;

#pragma mark - arrange quick tips
- (BOOL)shouldShowQuickTips {
  
  return NO;
  
  /****** the logic need be clarified further ******
   switch (_checkinResultType) {
   // if check in done, venue is far way or event is overdue, then no need to display the
   // quick tips
   case CHECKIN_NONE_TY:
   case CHECKIN_OK_TY:
   case CHECKIN_FAILED_TY: // this type should not be here actually
   case CHECKIN_FARAWAY_TY:
   case CHECKIN_EVENT_OVERDUE_TY:
   case CHECKIN_EVENT_NOT_BEGIN_TY:
   case CHECKIN_DUPLICATE_ERR_TY:
   return NO;
   
   default:
   return YES;
   }
   */
}

- (void)addQuickBackViewIfNeeded {
  
  if (![self shouldShowQuickTips]) {
    return;
  }
  
  NSString *title = nil;
  switch (_checkinResultType) {
    case CHECKIN_NEED_CONFIRM_TY:
      title = LocaleStringForKey(NSCheckAdminWhetherApprovedMsg, nil);
      break;
      
    case CHECKIN_NO_REG_FEE_TY:
      //case CHECKIN_NOT_SIGNUP_TY:
      title = LocaleStringForKey(NSContinueCheckinTitle, nil);
      break;
      
    default:
      break;
  }
  
  CGSize size = [title sizeWithFont:BOLD_FONT(13)
                  constrainedToSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)
                      lineBreakMode:NSLineBreakByWordWrapping];
  
  CGFloat width = size.width + MARGIN * 4;
  _quickBackView = [[[QuickBackForCheckinView alloc] initWithFrame:CGRectMake(self.view.frame.size.width,
                                                                              380.0f,
                                                                              width,
                                                                              size.height + MARGIN * 2)
                                                   checkinDelegate:self
                                                     directionType:LEFT_DIR_TY
                                                          topColor:COLOR_HSB(360.0f, 100.0f, 78.0f, 1.0f)
                                                       bottomColor:COLOR_HSB(359.0f, 77.0f, 47.0f, 1.0f)] autorelease];
  [_quickBackView setTitle:title];
  
  _quickBackView.alpha = 0.0f;
  
  [self.view addSubview:_quickBackView];
  
}

- (void)showQuichBackViewWithAnimationIfNeeded {
  
  if (![self shouldShowQuickTips]) {
    return;
  }
  
  // if tips view be displayed already, then not need to show it with animation again
  if (_quickBackViewShowed) {
    return;
  }
  
  [UIView animateWithDuration:0.5f
                   animations:^{
                     
                     _quickBackView.alpha = 1.0f;
                     
                     _quickBackView.frame = CGRectMake(self.view.frame.size.width - _quickBackView.frame.size.width,
                                                       _quickBackView.frame.origin.y,
                                                       _quickBackView.frame.size.width,
                                                       _quickBackView.frame.size.height);
                   }];
  
  _quickBackViewShowed = YES;
}

#pragma mark - lifecycle methods

- (id)initWithMOC:(NSManagedObjectContext *)MOC
checkinResultDelegate:(id<EventCheckinDelegate>)checkinResultDelegate
      event:(Event *)event
checkinResultType:(CheckinResultType)checkinResultType
         entrance:(UIViewController *)entrance
         listType:(EventLiveActionType)listType {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:YES
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    
    self.event = event;
    
    _eventId = event.eventId.longLongValue;
    
    DELETE_OBJS_FROM_MOC(_MOC, @"Post", nil);
    
    self.checkinResultDelegate = checkinResultDelegate;
    
    _checkinResultType = checkinResultType;
    
    self.checkinEntrance = entrance;
    
    _listType = listType;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedFeedBeDeleted)
                                                 name:FEED_DELETED_NOTIFY
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  
  self.alumni = nil;
  
  self.event = nil;
  
  self.checkinEntrance = nil;
  
  self.checkinResultDelegate = nil;
  
  [[WXWImageManager instance].imageCache clearAllCachedImages];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:FEED_DELETED_NOTIFY
                                                object:nil];
  
  [super dealloc];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)initTableContainer {
  
  _tableContainer = [[UIView alloc] initWithFrame:CGRectMake(0,0,
                                                             self.view.frame.size.width,
                                                             self.view.frame.size.height)];
  _tableContainer.backgroundColor = TRANSPARENT_COLOR;
  [self.view addSubview:_tableContainer];
  
  // remove table view from self.vew
  [_tableView removeFromSuperview];
  
  // move table view to new container
  _tableView.frame = CGRectMake(0, 0, _tableContainer.frame.size.width, _tableContainer.frame.size.height);
  [_tableContainer addSubview:_tableView];
}

- (void)arrangeRightBarButtonForDiscussionList {
  
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSPostTitle,nil)
                            target:self
                            action:@selector(doPost:)];
}

- (void)arrangeRightBarButtonForAlumniList {
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSDiscussTitle,nil)
                            target:self
                            action:@selector(switchList:)];
}

- (void)initNavigationItemButtons {
  
  switch (_listType) {
    case EVENT_APPEAR_ALUMNUS_TY:
      [self arrangeRightBarButtonForAlumniList];
      break;
      
    case EVENT_DISCUSS_TY:
      [self arrangeRightBarButtonForDiscussionList];
      break;
      
    default:
      break;
  }
}

- (void)viewDidLoad {
  
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  [self initNavigationItemButtons];
  
  [self initTableContainer];
  
  [self addQuickBackViewIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  
  switch (_listType) {
    case EVENT_APPEAR_ALUMNUS_TY:
      
      break;
      
    case EVENT_DISCUSS_TY:
    {
      // if the selected post be deleted, then should not update the cell, because the post has been removed from MOC
      if (!_selectedFeedBeDeleted) {
        [self updateLastSelectedCell];
      } else {
        [self deleteLastSelectedCell];
      }
      break;
    }
      
    default:
      break;
  }
  
}

- (void)handleViewDidAppearForAlumniList {
  if (!_autoLoaded) {
    [self loadAlumus:TRIGGERED_BY_AUTOLOAD
              forNew:YES];
  }
  
}

- (void)handleViewDidAppearForDiscussion {
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
        [self loadDiscussionPosts:TRIGGERED_BY_AUTOLOAD forNew:YES];
      }
      
    } else {
      _selectedFeedBeDeleted = NO;
    }
    
  } else {
    _returnFromComposer = NO;
  }
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  switch (_listType) {
    case EVENT_APPEAR_ALUMNUS_TY:
      
      [self handleViewDidAppearForAlumniList];
      break;
      
    case EVENT_DISCUSS_TY:
      
      [self handleViewDidAppearForDiscussion];
      break;
      
    default:
      break;
  }
}

#pragma mark - composer post
- (void)doPost:(id)sender {
  
  ComposerViewController *composerVC = [[[ComposerViewController alloc] initForEventDiscussWithMOC:_MOC
                                                                                          delegate:self
                                                                                           eventId:[NSString stringWithFormat:@"%lld", _eventId]] autorelease];
  composerVC.title = LocaleStringForKey(NSNewFeedTitle, nil);
  WXWNavigationController *navVC = [[[WXWNavigationController alloc] initWithRootViewController:composerVC] autorelease];
  [self.navigationController presentModalViewController:navVC animated:YES];
  
  _returnFromComposer = YES;
}

#pragma mark - post delete handle
- (void)selectedFeedBeDeleted {
  _selectedFeedBeDeleted = YES;
}

#pragma mark - switch alumni list and discussion list

- (void)clearTable {
  _currentStartIndex = 0;
  
  self.fetchedRC = nil;
  [_tableView reloadData];
}

- (void)switchList:(id)sender {
  
  [UIView beginAnimations:nil
                  context:nil];
  [UIView setAnimationDuration:1.0f];
  UIViewAnimationTransition transition;
  
  [self clearTable];
  
  switch (_listType) {
    case EVENT_DISCUSS_TY:
    {
      transition = UIViewAnimationTransitionFlipFromLeft;
      
      [self loadAlumus:TRIGGERED_BY_AUTOLOAD forNew:YES];
      
      self.title = LocaleStringForKey(NSCheckedinAlumnusListTitle, nil);
      
      _listType = EVENT_APPEAR_ALUMNUS_TY;
      
      break;
    }
      
    case EVENT_APPEAR_ALUMNUS_TY:
    {
      transition = UIViewAnimationTransitionFlipFromRight;
      
      [self loadDiscussionPosts:TRIGGERED_BY_AUTOLOAD forNew:YES];
      
      self.title = LocaleStringForKey(NSEventDiscussionTitle, nil);
      
      _listType = EVENT_DISCUSS_TY;
      
      break;
    }
      
    default:
      break;
  }
  
  [UIView setAnimationTransition:transition
                         forView:_tableContainer
                           cache:YES];
  [UIView commitAnimations];
  
  switch (_listType) {
    case EVENT_DISCUSS_TY:
      [self arrangeRightBarButtonForDiscussionList];
      break;
      
    case EVENT_APPEAR_ALUMNUS_TY:
      [self arrangeRightBarButtonForAlumniList];
      break;
      
    default:
      break;
  }
  
}

#pragma mark - load data
- (void)configureMOCFetchConditions {
  
  self.descriptors = [NSMutableArray array];
  
  self.predicate = nil;
  
  switch (_listType) {
    case EVENT_APPEAR_ALUMNUS_TY:
    {
      self.entityName = @"EventCheckinAlumni";
      self.predicate = [NSPredicate predicateWithFormat:@"(eventId == %lld)", _eventId];
      NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"orderId" ascending:YES] autorelease];
      [self.descriptors addObject:sortDescriptor];
      break;
    }
      
    case EVENT_DISCUSS_TY:
    {
      self.entityName = @"Post";
      NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
      [self.descriptors addObject:sortDescriptor];
      break;
    }
      
    default:
      break;
  }
}

- (void)loadAlumus:(LoadTriggerType)triggerType
            forNew:(BOOL)forNew {
  
  _currentLoadTriggerType = triggerType;
  _loadForNewItem = forNew;
  
  _currentType = CHECKIN_USER_TY;
  
  NSInteger startIndex = 0;
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<event_id>%lld</event_id><page>%d</page><page_size>%@</page_size><is_get_checkin>1</is_get_checkin>", _eventId, startIndex, ITEM_LOAD_COUNT];
  
  NSString *url = [CommonUtils geneUrl:param itemType:CHECKIN_USER_TY];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self interactionContentType:CHECKIN_USER_TY] autorelease];
  (self.connDic)[url] = connFacade;
  
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)loadDiscussionPosts:(LoadTriggerType)type forNew:(BOOL)forNew {
  _currentLoadTriggerType = type;
  
  _loadForNewItem = forNew;
  
  _currentType = EVENT_POST_TY;
  
  NSInteger startIndex = 0;
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
  //SAVE_MOC(_MOC);
  
  NSString *param = [NSString stringWithFormat:@"<event_id>%lld</event_id><sort_type>%d</sort_type><post_type>%d</post_type><page>%d</page><page_size>%@</page_size><is_get_checkin>1</is_get_checkin>",
                     _eventId,
                     SORT_BY_ID_TY,
                     EVENT_DISCUSS_POST_TY,
                     startIndex,
                     ITEM_LOAD_COUNT];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:_currentType] autorelease];
  (self.connDic)[url] = connFacade;
  [connFacade fetchNews:url];
  
}

#pragma mark - ECItemUploaderDelegate methods
- (void)afterUploadFinishAction:(WebItemType)actionType {
  
  [self loadDiscussionPosts:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
            blockCurrentView:NO];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case CHECKIN_USER_TY:
      if ([XMLParser parserEventStuff:result
                             itemType:CHECKIN_USER_TY
                          event:self.event
                                  MOC:_MOC
                    connectorDelegate:self
                                  url:url]) {
        [self refreshTable];
        
        _autoLoaded = YES;
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      break;
      
    case EVENT_POST_TY:
    {
      
      SAVE_MOC(_MOC);
      if ([XMLParser parserEventStuff:result
                             itemType:EVENT_POST_TY
                          event:self.event
                                  MOC:_MOC
                    connectorDelegate:self
                                  url:url]) {
        
        [self refreshTable];
        
        _autoLoaded = YES;
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSLoadFeedFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      break;
    }
      
    default:
      break;
  }
  
  // show the quick back tips view when list data be loaded first time
  [self showQuichBackViewWithAnimationIfNeeded];
  
  //[self adjustQuickTipsIfNeeded];
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  NSString *msg = nil;
  
  switch (contentType) {
    case CHECKIN_USER_TY:
      msg = LocaleStringForKey(NSFetchAlumniFailedMsg, nil);
      break;
      
    case EVENT_POST_TY:
      msg = LocaleStringForKey(NSLoadFeedFailedMsg, nil);
      break;
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - scrolling overrides
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  
  if ([UIUtils shouldLoadNewItems:scrollView
                       headerView:_headerRefreshView
                        reloading:_reloading]) {
    
    //_reloading = YES;
    
    _shouldTriggerLoadLatestItems = YES;
    
    switch (_listType) {
      case EVENT_APPEAR_ALUMNUS_TY:
        [self loadAlumus:TRIGGERED_BY_SCROLL forNew:YES];
        break;
        
      case EVENT_DISCUSS_TY:
        [self loadDiscussionPosts:TRIGGERED_BY_SCROLL forNew:YES];
        break;
        
      default:
        break;
    }
  }

  if ([UIUtils shouldLoadOlderItems:scrollView
                    tableViewHeight:_tableView.contentSize.height
                         footerView:_footerRefreshView
                          reloading:_reloading]) {
    
    _reloading = YES;
    
    switch (_listType) {
      case EVENT_APPEAR_ALUMNUS_TY:
        [self loadAlumus:TRIGGERED_BY_SCROLL forNew:NO];
        break;
        
      case EVENT_DISCUSS_TY:
        [self loadDiscussionPosts:TRIGGERED_BY_SCROLL forNew:NO];
        break;
        
      default:
        break;
    }
  }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  return self.fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)drawAlumniCell:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"kUserCell";
  PeopleWithChatCell *cell = (PeopleWithChatCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[PeopleWithChatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:kCellIdentifier
                             imageDisplayerDelegate:self
                             imageClickableDelegate:self
                                                MOC:_MOC] autorelease];
  }
  
  EventCheckinAlumni *alumni = (EventCheckinAlumni *)[_fetchedRC objectAtIndexPath:indexPath];
  
  [cell drawCell:alumni];
  
  return cell;
}

- (UITableViewCell *)drawDiscussPost:(NSIndexPath *)indexPath {
  Post *post = [_fetchedRC objectAtIndexPath:indexPath];
  
  static NSString *cellIdentifier = @"PostListCell";
  
  PostListCell *cell = (PostListCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    
    cell = [[[PostListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                reuseIdentifier:cellIdentifier
                         imageDisplayerDelegate:self
                         imageClickableDelegate:self
                                       showType:CLUB_SELF_VIEW
                                            MOC:_MOC] autorelease];
  }
  
  [cell drawPost:post];
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return [self drawFooterCell];
  }
  
  switch (_listType) {
    case EVENT_APPEAR_ALUMNUS_TY:
      return [self drawAlumniCell:indexPath];
      
    case EVENT_DISCUSS_TY:
      return [self drawDiscussPost:indexPath];
      
    default:
      return nil;
  }
}

- (CGFloat)discussPostCellHeight:(NSIndexPath *)indexPath {
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return FEED_CELL_HEIGHT;
  } else {
    
    Post *post = [_fetchedRC objectAtIndexPath:indexPath];
    
    CGFloat height = MARGIN * 8;
    
    CGFloat x = MARGIN * 2 + POSTLIST_PHOTO_WIDTH + MARGIN * 2;
    CGFloat width = self.view.frame.size.width - x - MARGIN * 2;
    CGSize size = [[NSString stringWithFormat:@"%@: %@", post.authorName, post.content] sizeWithFont:FONT(15)
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

- (CGFloat)alumniCellHeight:(NSIndexPath *)indexPath {
  if ([self currentCellIsFooter:indexPath]) {
    return PEOPLE_CELL_HEIGHT;
  }
  
  Alumni *alumni = (Alumni *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  CGSize constraint = CGSizeMake(NAME_LIMITED_WIDTH, 20);
  CGSize size = [alumni.name sizeWithFont:Arial_FONT(14)
                        constrainedToSize:constraint
                            lineBreakMode:NSLineBreakByTruncatingTail];
  
  CGFloat height = MARGIN + size.height + MARGIN;
  
  size = [alumni.companyName sizeWithFont:FONT(13)
                        constrainedToSize:CGSizeMake(280 - MARGIN -
                                                     (MARGIN + PHOTO_WIDTH + PHOTO_MARGIN * 2 +
                                                      MARGIN * 2),
                                                     CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByWordWrapping];
  
  height += size.height + MARGIN;
  
  if (height < PEOPLE_CELL_HEIGHT) {
    height = PEOPLE_CELL_HEIGHT;
  }
  
  return height;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (_listType) {
    case EVENT_APPEAR_ALUMNUS_TY:
      return [self alumniCellHeight:indexPath];
      
    case EVENT_DISCUSS_TY:
      return [self discussPostCellHeight:indexPath];
      
    default:
      return 0;
  }
}

- (void)showProfile:(NSString *)personId userType:(NSString *)userType {

  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                    personId:personId
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)beginChat {
  DMChatViewController *chatVC = [[[DMChatViewController alloc] initWithMOC:_MOC
                                                                     alumni:self.alumni] autorelease];
  [self.navigationController pushViewController:chatVC animated:YES];
  
  /*
  [CommonUtils doDelete:_MOC entityName:@"Chat"];
  ChatListViewController *chartVC = [[ChatListViewController alloc] initWithMOC:_MOC
                                                                         alumni:self.alumni];
  [self.navigationController pushViewController:chartVC animated:YES];
  RELEASE_OBJ(chartVC);
   */
}

- (void)selectAlumniCell:(NSIndexPath *)indexPath {
  EventCheckinAlumni *alumni = (EventCheckinAlumni *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  [self showProfile:alumni.personId userType:[NSString stringWithFormat:@"%@", alumni.userType]];
}

- (void)selectDiscussPostCell:(NSIndexPath *)indexPath {
  Post *post = [_fetchedRC objectAtIndexPath:indexPath];
  
  PostDetailViewController *detailVC = [[[PostDetailViewController alloc] initWithMOC:_MOC
                                                                               holder:_holder
                                                                     backToHomeAction:_backToHomeAction
                                                                                 post:post
                                                                             postType:EVENT_DISCUSS_POST_TY] autorelease];
  
  detailVC.title = LocaleStringForKey(NSPostDetailTitle, nil);
  
  [AppManager instance].isPostDetail = YES;
  
  [self.navigationController pushViewController:detailVC animated:YES];
  _lastSelectedIndexPath = indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (_listType) {
    case EVENT_APPEAR_ALUMNUS_TY:
      [self selectAlumniCell:indexPath];
      break;
      
    case EVENT_DISCUSS_TY:
      [self selectDiscussPostCell:indexPath];
      break;
      
    default:
      break;
  }
}

#pragma mark - ECClickableElementDelegate method
- (void)doChat:(Alumni*)aAlumni {
  
  self.alumni = aAlumni;
  
  UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSActionSheetTitle, nil)
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:LocaleStringForKey(NSChatActionSheetTitle, nil)
                                          otherButtonTitles:nil] autorelease];
  
  [as addButtonWithTitle:LocaleStringForKey(NSProfileActionSheetTitle, nil)];
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.navigationController.view];
}

#pragma mark - ECClickableElementDelegate method
- (void)openImageUrl:(NSString *)imageUrl {
  ECHandyImageBrowser *imageBrowser = [[[ECHandyImageBrowser alloc] initWithFrame:CGRectMake(0, 0,
                                                                                             self.view.frame.size.width,
                                                                                             self.view.frame.size.height)
                                                                           imgUrl:imageUrl] autorelease];
  [self.view addSubview:imageBrowser];
  [imageBrowser setNeedsLayout];
}

- (void)openProfile:(NSString*)userId userType:(NSString*)userType {
  
  [self showProfile:userId userType:userType];
}

#pragma mark - Action Sheet
- (void)actionSheet:(UIActionSheet*)aSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case CHAT_SHEET_IDX:
		{
      [self beginChat];
      return;
		}
      
		case DETAIL_SHEET_IDX:
      [self showProfile:self.alumni.personId userType:self.alumni.userType];
			return;
			
    case CANCEL_SHEET_IDX:
      return;
      
		default:
			break;
	}
}

#pragma mark - EventCheckinDelegate methods
- (void)quickCheck {
  switch (_checkinResultType) {
    case CHECKIN_NEED_CONFIRM_TY:
    case CHECKIN_OK_TY:
      [self.navigationController popViewControllerAnimated:YES];
      break;
      
    case CHECKIN_NO_REG_FEE_TY:
      //case CHECKIN_NOT_SIGNUP_TY:
      [self.navigationController popToViewController:self.checkinEntrance
                                            animated:YES];
      break;
      
    default:
      break;
  }
}

@end
