//
//  GroupFormViewController.m
//  iAlumni
//
//  Created by Adam on 13-7-24.
//
//

#import "GroupFormViewController.h"
#import "PostDetailViewController.h"
#import "ComposerViewController.h"
#import "WXWNavigationController.h"
#import "ECHandyImageBrowser.h"
#import "UserListViewController.h"
#import "ClubEventListViewController.h"
#import "ClubDetailViewController.h"
#import "PostToolView.h"
#import "PostListCell.h"
#import "SortOption.h"
#import "Country.h"
#import "Place.h"
#import "Post.h"
#import "Tag.h"
#import "AllScopeGroupHeaderView.h"
#import "GroupDiscussionCell.h"
#import "Club.h"
#import "ItemPropertiesListViewController.h"
#import "AlumniProfileViewController.h"
#import "GroupMemberListViewController.h"
#import "CoreDataUtils.h"
#import "GroupFormListCell.h"
#import "UIImageButton.h"
#import "ECGradientButton.h"

#define CLUB_HEADER_HEIGHT        (230.0f - 72.0f)
#define ALL_SCOPE_HEADER_HEIGHT   117.0f
#define TAB_H   45.0f

#define FONT_SIZE       15.0f
#define TAG_HEIGHT      20.0f
#define SUBMIT_BUTTON_WIDTH         200.0f
#define SUBMIT_BUTTON_HEIGHT        36.0f

typedef enum {
  NONE_INIT_TAG = 0,
  UP_TAG,
  DOWN_TAG,
} DIRECTION_TAG;

@interface GroupFormViewController ()
{
  int iSize;
  int flag;
  int iHistorySize;
}

@property (nonatomic, copy) NSString *filterCountryId;
@property (nonatomic, copy) NSString *currentTagIds;
@property (nonatomic, copy) NSString *currentFiltersTitle;
@property (nonatomic, copy) NSString *distanceParams;
@property (nonatomic, copy) NSString *filterCityId;
@property (nonatomic, copy) NSString *targetUserId;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, retain) Club *group;
@property (nonatomic, retain) NSString *startPostId;
@property (nonatomic, retain) NSString *endPostId;
@property (nonatomic, retain) UPOMP *cpView;
@property (nonatomic, retain) UIView *promptView;

@end

@implementation GroupFormViewController
@synthesize currentTagIds = _currentTagIds;
@synthesize currentFiltersTitle = _currentFiltersTitle;
@synthesize filterCountryId = _filterCountryId;
@synthesize distanceParams = _distanceParams;
@synthesize filterCityId = _filterCityId;
@synthesize targetUserId = _targetUserId;
@synthesize postListType;

#pragma mark - action
- (void)goClubDetail:(id)sender {
  
  CGRect mFrame = CGRectMake(0, 0, LIST_WIDTH, self.view.bounds.size.height);
  ClubDetailViewController *sponsorDetail = [[[ClubDetailViewController alloc] initWithFrame:mFrame MOC:_MOC parentListVC:nil] autorelease];
  
  sponsorDetail.title = LocaleStringForKey(NSClubDetailTitle, nil);
  [self.navigationController pushViewController:sponsorDetail animated:YES];
}

#pragma mark - ClubManagementDelegate methods
- (void)doPost {
  
  ComposerViewController *composerVC =  [[[ComposerViewController alloc] initForShareWithMOC:_MOC
                                                                                    delegate:self
                                                                                     groupId:LLINT_TO_STRING(self.group.clubId.longLongValue)] autorelease];
  composerVC.title = LocaleStringForKey(NSNewFeedTitle, nil);
  WXWNavigationController *navVC = [[[WXWNavigationController alloc] initWithRootViewController:composerVC] autorelease];
  [self.navigationController presentModalViewController:navVC animated:YES];
  
  _returnFromComposer = YES;
  
  /*
   if (self.group.allowPost.boolValue) {
   ComposerViewController *composerVC =  [[[ComposerViewController alloc] initForShareWithMOC:_MOC
   delegate:self
   groupId:LLINT_TO_STRING(self.group.clubId.longLongValue)] autorelease];
   composerVC.title = LocaleStringForKey(NSNewFeedTitle, nil);
   WXWNavigationController *navVC = [[[WXWNavigationController alloc] initWithRootViewController:composerVC] autorelease];
   [self.navigationController presentModalViewController:navVC animated:YES];
   
   _returnFromComposer = YES;
   
   } else {
   
   // not allowed, then show message to user
   ShowAlertWithOneButton(nil, nil, self.group.forbidPostReason, LocaleStringForKey(NSIKnowTitle, nil));
   }
   */
}

#pragma mark - action
- (void)doJoin2Quit:(BOOL)joinStatus ifAdmin:(NSString*)ifAdmin
{
  /*
   if (!joinStatus) {
   // user wants join
   if (!self.group.allowJoin.boolValue) {
   // but not allowed join
   ShowAlertWithOneButton(nil, nil, self.group.forbidJoinReason, LocaleStringForKey(NSIKnowTitle, nil));
   return;
   }
   
   } else {
   
   // user wants quit
   if (!self.group.allowQuit.boolValue) {
   // but not allowed quit
   ShowAlertWithOneButton(nil, nil, self.group.forbidQuitReason, LocaleStringForKey(NSIKnowTitle, nil));
   return;
   }
   
   }
   */
  
  if (!joinStatus) {
    // TODO by Adam
    _currentType = CLUB_JOIN_TY;
    NSString *param = nil;
    param = [NSString stringWithFormat:@"<host_type>%@</host_type><host_id>%@</host_id><if_admin_submit>%@</if_admin_submit><target_user_id>%@</target_user_id><target_user_type>%@</target_user_type>",
             [AppManager instance].clubType,
             [AppManager instance].clubId,
             ifAdmin,
             [AppManager instance].personId,
             [AppManager instance].userType];
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade fetchGets:url];
  } else {
    
    ShowAlertWithTwoButton(self,LocaleStringForKey(NSNoteTitle, nil),LocaleStringForKey(NSQuitNoteTitle, nil),LocaleStringForKey(NSCancelTitle, nil),LocaleStringForKey(NSSureTitle, nil));
  }
}

- (void)doManage {
  
  [AppManager instance].clubAdmin = YES;
  //[self goClubUserList];
  
  CGRect mFrame = CGRectMake(0, 0, LIST_WIDTH, self.view.bounds.size.height);
  ClubDetailViewController *sponsorDetail = [[[ClubDetailViewController alloc] initWithFrame:mFrame MOC:_MOC parentListVC:nil] autorelease];
  
  sponsorDetail.title = LocaleStringForKey(NSClubDetailTitle, nil);
  [self.navigationController pushViewController:sponsorDetail animated:YES];
}

- (void)goClubActivity {
  ClubEventListViewController *eventListVC = [[ClubEventListViewController alloc] initWithMOC:_MOC];
  eventListVC.title = LocaleStringForKey(NSClubEventTitle, nil);
  [self.navigationController pushViewController:eventListVC animated:YES];
  [eventListVC release];
}

- (void)goClubUserList {
  
  GroupMemberListViewController *groupMembersVC = [[[GroupMemberListViewController alloc] initWithMOC:_MOC group:self.group] autorelease];
  groupMembersVC.title = LocaleStringForKey(NSAlumniTitle, nil);
  [self.navigationController pushViewController:groupMembersVC animated:YES];
}

- (void)showFilters {
  if (_tagsFetched) {
    [self goFliterView];
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchingTagMsg, nil)
                                  msgType:WARNING_TY
                       belowNavigationBar:YES];
  }
}

- (void)payWithOrderId:(NSString *)orderId {
  
  if (orderId.length > 0) {
    NSString *param = [NSString stringWithFormat:@"<order_id>%@</order_id>", orderId];
    NSString *url = [CommonUtils geneUrl:param itemType:PAY_DATA_TY];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:PAY_DATA_TY];
    [connFacade fetchGets:url];
  }
}

- (void)openUnionPay:(NSData *)result {
  self.cpView = [[[UPOMP alloc] init] autorelease];
  self.cpView.viewDelegate = self;
  [((iAlumniAppDelegate*)APP_DELEGATE).window addSubview:self.cpView.view];
  
  [self.cpView setXmlData:result];
  
  NSLog(@"message: %@", [[[NSString alloc] initWithData:result
                                               encoding:NSUTF8StringEncoding] autorelease]);
  
}

#pragma mark - display the tag
- (void)goFliterView {
  _filtersChanged = YES;
  
  ItemPropertiesListViewController *filterListVC = [[[ItemPropertiesListViewController alloc] initWithMOC:_MOC
                                                                                                   holder:_holder
                                                                                         backToHomeAction:_backToHomeAction
                                                                                     parentEditorDelegate:self
                                                                                             propertyType:SHARING_FILTER_TY
                                                                                          filterCountryId:self.filterCountryId.longLongValue
                                                                                                  tagType:SHARE_TY]autorelease];
  
  self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSDoFilterTitle, nil)
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:nil
                                                                           action:nil] autorelease];
  
  [self.navigationController pushViewController:filterListVC animated:YES];
  
  [self clearLastSelectedIndexPath];
}

#pragma mark - load posts

- (void)allTagSelected {
  self.currentTagIds = NULL_PARAM_VALUE;
  self.currentFiltersTitle = LocaleStringForKey(NSAllTitle, nil);
}

- (void)allScopeSearch {
  self.filterCityId = NULL_PARAM_VALUE;
  self.distanceParams = NULL_PARAM_VALUE;
}

- (void)oneTagSelected:(Tag *)selectedTag {
  self.currentTagIds = [NSString stringWithFormat:@"%@", selectedTag.tagId];
  self.currentFiltersTitle = selectedTag.tagName;
}

- (void)parserSelectedTags {
  
  NSArray *tags = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                             entityName:@"Tag"
                                              predicate:SELECTED_PREDICATE];
  if (tags && [tags count] > 0) {
    NSInteger index = 0;
    self.currentTagIds = nil;
    self.currentFiltersTitle = nil;
    
    if (tags.count == 1) {
      
      // only 'All' tag selected
      Tag *selectedTag = (Tag *)tags.lastObject;
      if (selectedTag.tagId.longLongValue == TAG_ALL_ID) {
        [self allTagSelected];
      } else {
        [self oneTagSelected:selectedTag];
      }
      
    } else {
      for (Tag *tag in tags) {
        if (index == 0) {
          [self oneTagSelected:tag];
        } else {
          self.currentTagIds = [NSString stringWithFormat:@"%@,%@", self.currentTagIds, tag.tagId];
          self.currentFiltersTitle = [NSString stringWithFormat:@"%@, %@", self.currentFiltersTitle, tag.tagName];
        }
        
        index++;
      }
    }
  } else {
    [self allTagSelected];
  }
}

- (void)parserSeletedPlace {
  Place *place = (Place *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                    entityName:@"Place"
                                                     predicate:SELECTED_PREDICATE];
  if (place) {
    
    if ([ALL_RADIUS_PLACE_ID isEqualToString:place.placeId]) {
      [self allScopeSearch];
    } else {
      
      if (place.distance.floatValue == 0.0f) {
        // place is city
        self.filterCityId = [NSString stringWithFormat:@"%@", place.cityId];
        self.distanceParams = NULL_PARAM_VALUE;
        
      } else {
        // place is radius search area
        self.filterCityId = NULL_PARAM_VALUE;
        self.distanceParams = @"place.distance.floatValue, [AppManager instance].latitude, [AppManager instance].longitude";
      }
      
      self.currentFiltersTitle = [NSString stringWithFormat:@"%@, %@",
                                  self.currentFiltersTitle,
                                  place.placeName];
    }
    
  } else {
    [self allScopeSearch];
  }
}

- (void)applyFilters {
  
  [self parserSelectedTags];
  
  [self parserSeletedPlace];
}

#pragma mark - override methods
- (void)configureMOCFetchConditions {
  
  switch (_listType) {
    case SENT_ITEM_LIST_TY:
      // filter the posts that sent by a specified user
      self.predicate = [NSPredicate predicateWithFormat:@"(authorId == %@) AND (clubId == %@)", self.targetUserId, self.group.clubId];
      break;
      
    default:
      self.predicate = [NSPredicate predicateWithFormat:@"(clubId == %@)", self.group.clubId];
      
      break;
  }
  
  self.entityName = @"Post";
  self.descriptors = [NSMutableArray array];
  
  switch (_sortType) {
    case SORT_BY_ID_TY:
    {
      NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:YES] autorelease];
      [self.descriptors addObject:descriptor];
      break;
    }
      
    case SORT_BY_PRAISE_COUNT_TY:
    {
      NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"likeCount" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor1];
      NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor2];
      break;
    }
      
    case SORT_BY_COMMENT_COUNT_TY:
    {
      NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"commentCount" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor1];
      NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor2];
      break;
    }
      
    default:
      break;
  }
}

#pragma mark - load posts and tags
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  iHistorySize = iSize;
  
  [super loadListData:triggerType forNew:forNew];
  
  _showNewLoadedItemCount = NO;
  
  _currentType = CLUB_POST_LIST_TY;
  
  NSString *param = [NSString stringWithFormat:@"<page_size>%@</page_size><tag_ids>%@</tag_ids>%@<sort_type>%d</sort_type><post_type>%d</post_type><latitude>%f</latitude><longitude>%f</longitude><host_type>%@</host_type><host_id>%@</host_id><list_type>%@</list_type>",
                     ITEM_LOAD_COUNT,
                     self.currentTagIds,
                     self.distanceParams,
                     _sortType,
                     DISCUSS_POST_TY,
                     [AppManager instance].latitude,
                     [AppManager instance].longitude,
                     self.group.clubType,
                     self.group.clubId,
                     self.postListType];
  
  NSString *requestParam = nil;
  if (forNew) {
    requestParam = param;
  } else {
    NSString *tmpStr = [NSString stringWithFormat:@"<page>%d</page>", self.pageIndex++];
    requestParam = [param stringByReplacingOccurrencesOfString:@"<page>0</page>" withString:tmpStr];
  }
  
  NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade fetchNews:url];
}

- (void)loadTagData
{
  DELETE_OBJS_FROM_MOC(_MOC, @"Tag", nil);
  _currentType = POST_TAG_LIST_TY;
  
  NSString *param = [NSString stringWithFormat:@"<post_type>%d</post_type><item_id>%@</item_id>", GROUP_TAG_TY, self.group.clubId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade fetchGets:url];
}

#pragma mark - load club simple detail
- (void)loadClubSimpleDetail {
  //[CommonUtils doDelete:_MOC entityName:@"ClubSimple"];
  
  NSString *param = [NSString stringWithFormat:@"<host_id>%@</host_id>", [AppManager instance].clubId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:CLUB_DETAIL_SIMPLE_TY];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:CLUB_DETAIL_SIMPLE_TY];
  [connFacade fetchGets:url];
}

#pragma mark - post delete handle
- (void)selectedFeedBeDeleted {
  _selectedFeedBeDeleted = YES;
}

#pragma mark - lifecycle methods

- (void)prepareMetaData {
  [self clearAllPosts];
  DELETE_OBJS_FROM_MOC(_MOC, @"Tag", nil);
  DELETE_OBJS_FROM_MOC(_MOC, @"ClubSimple", nil);
  [CoreDataUtils resetDistance:_MOC];
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
            group:(Club *)group
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
           parent:(id)parent
refreshParentAction:(SEL)refreshParentAction
         listType:(ItemListType)listType
         showType:(ClubViewType)showType {
  
  self = [super initWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:YES
      needRefreshFooterView:NO
                 needGoHome:NO];
  
  if (self) {
    
    isFirst = YES;
    _showType = showType;
    _listType = listType;
    _sortType = SORT_BY_ID_TY;
    
    _parent = parent;
    _refreshParentAction = refreshParentAction;
    
    _noNeedDisplayEmptyMsg = YES;
    
    self.group = group;
    
    self.currentTagIds = NULL_PARAM_VALUE;
    self.filterCountryId = NULL_PARAM_VALUE;
    self.distanceParams = NULL_PARAM_VALUE;
    self.filterCityId = NULL_PARAM_VALUE;
    
    [self prepareMetaData];
    
    _currentContentOffset_y = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedFeedBeDeleted)
                                                 name:FEED_DELETED_NOTIFY
                                               object:nil];
  }
  
  return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
     targetUserId:(NSString *)targetUserId {
  self = [self initWithMOC:MOC
                     group:nil
                    holder:holder
          backToHomeAction:backToHomeAction
                    parent:nil
       refreshParentAction:nil
                  listType:SENT_ITEM_LIST_TY
                  showType:CLUB_POST_VIEW];
  if (self) {
    isFirst = YES;
    self.targetUserId = targetUserId;
  }
  
  return self;
}


- (void)arrangeHeaderViewIfNeeded {
  
  _tableView.frame = CGRectMake(0, 0,
                                _tableView.frame.size.width,
                                _tableView.frame.size.height);
  _tableView.tableHeaderView = nil;
  if (YES) {
    return;
  }
  
  switch (_showType) {
    case CLUB_ALL_ALUMNUS_VIEW:
    {
      if (nil == _allScopeGroupHeaderView) {
        _allScopeGroupHeaderView = [[AllScopeGroupHeaderView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                             SCREEN_WIDTH,
                                                                                             ALL_SCOPE_HEADER_HEIGHT)
                                                                        groupType:ALL_ALUMNI_GP_TY
                                                                         delegate:self];
      }
      
      _tableView.tableHeaderView = _allScopeGroupHeaderView;
      break;
    }
      
    case CLUB_SELF_VIEW:
    {
      if (nil == _clubHeaderView) {
        _clubHeaderView = [[ClubHeadView alloc] initWithFrame:CGRectMake(0.f, 0.f,
                                                                         SCREEN_WIDTH,
                                                                         CLUB_HEADER_HEIGHT)
                                                          MOC:_MOC
                                             clubHeadDelegate:self];
      }
      _tableView.tableHeaderView = _clubHeaderView;
      break;
    }
      
    default:
      break;
  }
}

- (void)setTableProperties {
  
  _tableView.frame = CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, self.view.frame.size.height);
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  //  _tableView.backgroundColor = [UIColor colorWithRed:0.859f green:0.886f blue:0.929f alpha:1.0f];
  //    _tableView.tag = TABLEVIEWTAG;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  if (_showType == CLUB_POST_VIEW) {
    
    [AppManager instance].clubId = NULL_PARAM_VALUE;
    
    self.postListType = [NSString stringWithFormat:@"%d", JOINED_GROUP_LIST_POST_TY];
    _tabView = [[UITabView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TAB_H) tab0Str:LocaleStringForKey(NSMyClassCircleTitle, nil) tab1Str:LocaleStringForKey(NSEntireTitle, nil) delegate:self];
    [self.view addSubview:_tabView];
    
    _tableView.frame = CGRectMake(0, _tableView.frame.origin.y + TAB_H, _tableView.frame.size.width, _tableView.frame.size.height - TAB_H);
    
  } else if (_showType == CLUB_SELF_VIEW){
    
    self.postListType = [NSString stringWithFormat:@"%d", SPECIAL_GROUP_LIST_POST_TY];
    _tableView.frame = CGRectMake(0, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height);
  }
  
  [self arrangeHeaderViewIfNeeded];
  
  // fetch tags firstly for prepare meta data for send post and filtering
  [self loadTagData];
  
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSClubDetailTitle,nil)
                            target:self
                            action:@selector(goClubDetail:)];
  [self setTableProperties];
  [self initBottomToolbar];
  
  [self addPromptView];
}

- (void)addPromptView {
  // Add prompt when no records
  NSString *promptMsg = [NSString stringWithFormat:@"%@", LocaleStringForKey(NSEmptyListMsg, nil)];
  
  CGSize constraint = CGSizeMake(SCREEN_WIDTH-30.f, CGFLOAT_MAX);
  
  CGSize promptSize = [promptMsg sizeWithFont:Arial_FONT(FONT_SIZE)
                            constrainedToSize:constraint
                                lineBreakMode:NSLineBreakByTruncatingTail];
  
  self.promptView = [[[UIView alloc] initWithFrame:CGRectMake(10.f, 20.f, SCREEN_WIDTH-20.f, promptSize.height+10)] autorelease];
  self.promptView.backgroundColor = COLOR(181, 181, 179);
  self.promptView.layer.borderColor = COLOR(202, 202, 202).CGColor;
  
  self.promptView.layer.cornerRadius = 6.0f;
  self.promptView.layer.masksToBounds = YES;
  self.promptView.layer.borderWidth = 1.0f;
  
  UILabel *promptLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5.f, 5.f, SCREEN_WIDTH-30.f, promptSize.height)] autorelease];
  promptLabel.backgroundColor = TRANSPARENT_COLOR;
  promptLabel.font = Arial_FONT(FONT_SIZE);
  promptLabel.textColor = COLOR(252, 252, 252);
  promptLabel.text = promptMsg;
  promptLabel.textAlignment = NSTextAlignmentCenter;
  promptLabel.numberOfLines = 5;
  [self.promptView addSubview:promptLabel];
  
  [self.view addSubview:self.promptView];
  self.promptView.hidden = YES;
}

- (void)clearAllPosts {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(clubId == %@)", self.group.clubId];
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Post", predicate);
}

- (void)clearTableView {
  self.fetchedRC = nil;
  
  [self clearAllPosts];
  
  [_tableView reloadData];
}

- (void)reloadForFiltersChangeIfNecessary {
  if (_filtersChanged) {
    [self applyFilters];
    
    [self clearTableView];
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    
    _filtersChanged = NO;
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if ((_showType == CLUB_SELF_VIEW || _showType == CLUB_ALL_ALUMNUS_VIEW)
      && [AppManager instance].isNeedReLoadClubDetail) {
    
    [self loadClubSimpleDetail];
    
    [AppManager instance].isNeedReLoadClubDetail = NO;
  }
  
  // if the selected post be deleted, then should not update the cell, because the post has been removed from MOC
  if (!_selectedFeedBeDeleted) {
    [self updateLastSelectedCell];
  } else {
    [self deleteLastSelectedCell];
  }
  
  [self reloadForFiltersChangeIfNecessary];
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

- (void)dealloc {
  
  [[WXWImageManager instance].imageCache clearAllCachedImages];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:FEED_DELETED_NOTIFY
                                                object:nil];
  
  RELEASE_OBJ(_allScopeGroupHeaderView);
  RELEASE_OBJ(_clubHeaderView);
  
  self.currentTagIds = nil;
  self.currentFiltersTitle = nil;
  self.filterCountryId = nil;
  self.distanceParams = nil;
  self.filterCityId = nil;
  self.targetUserId = nil;
  self.postListType = nil;
  self.promptView = nil;
  self.group = nil;
  
  DELETE_OBJS_FROM_MOC(_MOC, @"ClubSimple", nil);
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Tag", nil);
  
  [super dealloc];
}

#pragma mark - scrolling overrides

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[super scrollViewDidScroll:scrollView];
  _currentContentOffset_y = scrollView.contentOffset.y;
}

#pragma mark - reset refresh header/footer view status

- (void)resetHeaderOrFooterViewStatus {
  
  if (_loadForNewItem) {
    flag = UP_TAG;
    [self resetHeaderRefreshViewStatus];
  } else {
    flag = DOWN_TAG;
    [self resetFooterRefreshViewStatus];
  }
}

- (void)resetUIElementsForConnectDoneOrFailed {
  
  switch (_currentLoadTriggerType) {
    case TRIGGERED_BY_AUTOLOAD:
      flag = NONE_INIT_TAG;
      _autoLoaded = YES;
      break;
      
    case TRIGGERED_BY_SCROLL:
      [self resetHeaderOrFooterViewStatus];
      break;
      
    default:
      break;
  }
}

#pragma mark - ECConnectorDelegate methoes
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case POST_TAG_LIST_TY:
    {
      [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
      break;
    }
    case CLUB_POST_LIST_TY:
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
    case POST_TAG_LIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        _tagsFetched = YES;
        
      } else {
        _tagsFetched = NO;
      }
      
      [super connectDone:result url:url contentType:contentType closeAsyncLoadingView:NO];
      break;
    }
      
    case PAY_DATA_TY:
    {
      [self openUnionPay:result];
      break;
    }
      
    case CLUB_DETAIL_SIMPLE_TY:
    {
      
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        if (_showType == CLUB_SELF_VIEW) {
          [_clubHeaderView loadData];
        }
      } else {
        _tableView.tableHeaderView = nil;
      }
      
      [super connectDone:result url:url contentType:contentType closeAsyncLoadingView:NO];
      break;
    }
      
    case CLUB_JOIN_TY:
    case CLUB_QUIT_TY:
    {
      if (result == nil || [result length] == 0) {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        return;
      }
      
      ReturnCode ret = [XMLParser handleCommonResult:result showFlag:YES];
      if (ret == RESP_OK) {
        [self loadClubSimpleDetail];
        
        if (_parent && _refreshParentAction) {
          [_parent performSelector:_refreshParentAction];
        }
      }
    }
      break;
      
    case CLUB_POST_LIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self refreshTable];
        
        _tableView.alpha = 1.0f;
        
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
      
      if ((_showType == CLUB_SELF_VIEW || _showType == CLUB_ALL_ALUMNUS_VIEW)
          && isFirst) {
        [self loadClubSimpleDetail];
        isFirst = NO;
      } else {
        // should be called at end of method to clear connFacade instance
        //[super connectDone:result url:url contentType:contentType];
      }
      
      [self restructureList];
      
      [self closeAsyncLoadingView];
    }
      break;
      
    default:
      break;
  }
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  
  // should be called at end of method to clear connFacade instance
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  NSString *msg = nil;
  
  switch (contentType) {
      
    case CLUB_POST_LIST_TY:
    {
      if (_autoLoadAfterSent) {
        _autoLoadAfterSent = NO;
      }
      
      msg = LocaleStringForKey(NSLoadFeedFailedMsg, nil);
      
      [UIUtils showNotificationOnTopWithMsg:msg
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      
      if (_userFirstUseThisList) {
        _userFirstUseThisList = NO;
      }
      
    }
      break;
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  
  // should be called at end of method to clear connFacade instance
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - ECItemUploaderDelegate methods
- (void)afterUploadFinishAction:(WebItemType)actionType {
  
  _autoLoadAfterSent = YES;
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  iSize = _fetchedRC.fetchedObjects.count;
  return _fetchedRC.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *kCellIdentifier = @"GroupFormListCell";
  GroupFormListCell *cell = (GroupFormListCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  
  if (nil == cell) {
    cell = [[[GroupFormListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier imageClickableDelegate:self] autorelease];
    cell.backgroundColor = [UIColor colorWithRed:0.859f green:0.886f blue:0.929f alpha:1.0f];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.parentView = self.view;
  }
  
  // Set up the cell...
	for(UIView *subview in [cell.contentView subviews])
		[subview removeFromSuperview];
  
  Post *post = [self.fetchedRC objectAtIndexPath:indexPath];
	[cell drawPost:post];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  Post *post = [_fetchedRC objectAtIndexPath:indexPath];
  
  if ([indexPath row] == 0) {
    self.startPostId = [post.postId stringValue];
  }
  
  if (iSize-1 == [indexPath row]) {
    self.endPostId = [post.postId stringValue];
  }
  
  CGSize size = [post.content sizeWithFont:FONT(FONT_SIZE) constrainedToSize:CGSizeMake(150.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
  
  return size.height+70.0f;
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

#pragma mark - TabTapDelegate
- (void)tabTap:(int)selIndex {
  
  switch (selIndex) {
      
    case CLUB_MY_POST_SHOW:
    {
      self.postListType = @"2";
      break;
    }
      
    case CLUB_ALL_POST_SHOW:
    {
      self.postListType = @"3";
      break;
    }
      
    default:
      break;
  }
  
  [self clearTableView];
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  if (buttonIndex == 1) {
    NSString *param = nil;
    _currentType = CLUB_QUIT_TY;
    param = [NSString stringWithFormat:@"<host_id>%@</host_id><target_user_id>%@</target_user_id><target_user_type>%@</target_user_type>",
             [AppManager instance].clubId,
             [AppManager instance].personId,
             [AppManager instance].userType];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade fetchGets:url];
    
    return;
  }
}

- (void)goPostClub:(id)sender {
  
  [self goPostView:CLUB_SELF_VIEW];
}

- (void)goPostView:(ClubViewType)showType {
  
  GroupFormViewController *postListVC = [[GroupFormViewController alloc] initWithMOC:_MOC
                                                                               group:nil
                                                                              holder:self
                                                                    backToHomeAction:@selector(backToHomepage:)
                                                                              parent:nil
                                                                 refreshParentAction:nil
                                                                            listType:ALL_ITEM_LIST_TY
                                                                            showType:showType];
  if (showType == CLUB_ALL_POST_SHOW) {
    postListVC.title = LocaleStringForKey(NSClubPostTitle, nil);
  } else {
    postListVC.title = LocaleStringForKey(NSClubTrendTitle, nil);
  }
  
  [self.navigationController pushViewController:postListVC animated:YES];
  RELEASE_OBJ(postListVC);
}

#pragma mark - check payment result
- (BOOL)checkPaymentRecallResult:(NSString *)result {
  if (nil == result || 0 == result.length) {
    return NO;
  }
  
  NSArray *list = [result componentsSeparatedByString:PAYMENT_RESPCODE_START_SEPARATOR];
  if (list.count == 2) {
    NSString *partResult = list[1];
    if (0 == partResult.length) {
      return NO;
    }
    
    NSArray *resultList = [partResult componentsSeparatedByString:PAYMENT_RESPCODE_END_SEPARATOR];
    if (resultList.count == 2) {
      NSString *codeStr = resultList[0];
      if (0 == codeStr.length) {
        return NO;
      }
      
      NSInteger code = codeStr.intValue;
      
      if (code != 0) {
        return NO;
      } else {
        
        return YES;
      }
    }
  }
  
  return NO;
}

#pragma mark - UPOMPDelegate methods

-(void)viewClose:(NSData*)data {
  
  self.cpView.viewDelegate = nil;
  self.cpView = nil;
  
  NSString *resultStr = [[[NSString alloc] initWithData:data
                                               encoding:NSUTF8StringEncoding] autorelease];
  
  if ([self checkPaymentRecallResult:resultStr]) {
    
    // refresh payment successful flag
    [_clubHeaderView updateStatusAfterPaymentDone];
    
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaymentDoneMsg, nil)
                                  msgType:SUCCESS_TY
                       belowNavigationBar:YES];
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaymentErrorMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
  
}

- (void)initBottomToolbar {
  
  CGFloat y = 0;
  if (CURRENT_OS_VERSION >= IOS7) {
    y = self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - TOOLBAR_HEIGHT - SYS_STATUS_BAR_HEIGHT;
  } else {
    y = self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - TOOLBAR_HEIGHT;
  }
  
  UIView *bottomToolbar = [[[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, TOOLBAR_HEIGHT)] autorelease];
  bottomToolbar.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.7f];
  [self.view addSubview:bottomToolbar];
  
  ECGradientButton *submitButton = [[[ECGradientButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - SUBMIT_BUTTON_WIDTH)/2.0f, (TOOLBAR_HEIGHT - SUBMIT_BUTTON_HEIGHT)/2.0f, SUBMIT_BUTTON_WIDTH, SUBMIT_BUTTON_HEIGHT)
                                                                     target:self
                                                                     action:@selector(doPost)
                                                                  colorType:RED_BTN_COLOR_TY
                                                                      title:LocaleStringForKey(NSPostTitle, nil)
                                                                      image:nil
                                                                 titleColor:[UIColor whiteColor]
                                                           titleShadowColor:TRANSPARENT_COLOR
                                                                  titleFont:BOLD_FONT(20)
                                                                roundedType:NO_ROUNDED
                                                            imageEdgeInsert:ZERO_EDGE
                                                            titleEdgeInsert:ZERO_EDGE] autorelease];
  
  [bottomToolbar addSubview:submitButton];
  
  _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y,
                                _tableView.frame.size.width, _tableView.frame.size.height - TOOLBAR_HEIGHT);
}

#pragma mark - ECClickableElementDelegate method

- (void)hideKeyboard {
  
}

- (void)restructureList {
  
  if (iSize-1 < 0) {
    self.promptView.hidden = NO;
    return;
  } else {
    self.promptView.hidden = YES;
  }
  
  switch (flag) {
    case NONE_INIT_TAG:
    {
      [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(iSize-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
      break;
      
    case UP_TAG:
    {
      if (iSize > iHistorySize) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(iSize-iHistorySize-1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
      } else {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
      }
    }
      break;
      
    case DOWN_TAG:
    {
      if (iSize > iHistorySize) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(iHistorySize) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
      } else {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(iSize-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
      }
    }
      break;
      
    default:
      break;
  }
}

@end
