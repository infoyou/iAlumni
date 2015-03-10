//
//  StartupDiscussionViewController.m
//  iAlumni
//
//  Created by Adam on 13-3-5.
//
//

#import "StartupDiscussionViewController.h"
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

#define PEOPLE_CELL_HEIGHT    90.0f
#define PHOTO_WIDTH           56.0f
#define BUTTON_WIDTH          150.0f
#define BUTTON_HEIGHT         30.0f

#define NAME_LIMITED_WIDTH    144.0f

@interface StartupDiscussionViewController ()
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Alumni *alumni;
@property (nonatomic, retain) UIViewController *checkinEntrance;
@property (nonatomic, retain) id<EventCheckinDelegate> checkinResultDelegate;
@end

@implementation StartupDiscussionViewController

@synthesize alumni = _alumni;
@synthesize event = _eventDetail;
@synthesize checkinEntrance = _checkinEntrance;
@synthesize checkinResultDelegate = _checkinResultDelegate;


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
  
  [self arrangeRightBarButtonForDiscussionList];
}

- (void)viewDidLoad {
  
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  [self initNavigationItemButtons];
  
  [self initTableContainer];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  /*
  if (!_autoLoaded) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  }
  */
  
  if (!_selectedFeedBeDeleted) {
    [self updateLastSelectedCell];
  } else {
    [self deleteLastSelectedCell];
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
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
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
  
  
  [self handleViewDidAppearForDiscussion];
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

#pragma mark - load data
- (void)configureMOCFetchConditions {
  
  self.descriptors = [NSMutableArray array];
  
  self.predicate = nil;
  
  self.entityName = @"Post";
  NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
  [self.descriptors addObject:sortDescriptor];
}

- (void)loadListData:(LoadTriggerType)type forNew:(BOOL)forNew {
  
  [super loadListData:type forNew:forNew];
  
  _currentLoadTriggerType = type;
  
  _loadForNewItem = forNew;
  
  _currentType = EVENT_POST_TY;
  
  NSInteger startIndex = 0;
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
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
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
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
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  NSString *msg = nil;
  
  switch (contentType) {
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
  
  return [self drawDiscussPost:indexPath];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  
  return [self discussPostCellHeight:indexPath];
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
  
  [self selectDiscussPostCell:indexPath];
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
