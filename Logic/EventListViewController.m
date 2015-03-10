//
//  EventListViewController.m
//  iAlumni
//
//  Created by Adam on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "EventListViewController.h"
#import "EventListCell.h"
#import "Event.h"
#import "EventDetailViewController.h"
#import "HomeContainerController.h"
#import "NaviButton.h"
#import "EventCity.h"
#import "EventToolView.h"
#import "ClubListCell.h"
#import "GroupListViewController.h"
#import "Club.h"
#import "GroupFormViewController.h"
#import "ClubDetailViewController.h"
#import "ILBarButtonItem.h"
#import "SearchClubViewController.h"
#import "SearchEventListViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "WXWNavigationController.h"
#import "QuartzCore/QuartzCore.h"
#import "FilterScrollViewController.h"
#import "GroupChatViewController.h"

#define defaultFont               18
#define HEADER_HEIGHT             32.0f
#define FILTER_SPACE_H            400.f
#define BUTTON_SEGMENT_WIDTH      202.f
#define CAP_WIDTH                 5.0

enum {
  EVENT_TY_IDX,
  CITY_TY_IDX,
  SORT_TY_IDX,
  MY_EVENT_TY_IDX,
};

@interface EventListViewController ()

@end

@interface EventListViewController() <UIGestureRecognizerDelegate>
{
  BOOL isClickSearch;
  
  int viewHeight;
  int eventPageIndex;
  int groupPageIndex;
  
  int eventFilterIndex;
  int groupFilterIndex;

}

@property (nonatomic, retain) FilterScrollViewController *filterScrollViewController;

@property (nonatomic, copy) NSString *groupSupType;
@property (nonatomic, copy) NSString *groupType;

@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSMutableArray *clubFilters;

@property (nonatomic, retain) NSMutableArray *eventFliterShowArray;
@property (nonatomic, retain) NSMutableArray *eventFliterSaveArray;

@property (nonatomic, retain) NSMutableArray *groupFliterShowArray;
@property (nonatomic, retain) NSMutableArray *groupFliterSaveArray;

@property (nonatomic, retain) EventToolView *eventToolTitleView;
@property (nonatomic, retain) EventToolView *groupToolTitleView;
@property (nonatomic, retain) NSArray *segmentControlTitles;

@property (nonatomic, retain) UINavigationController *filterNavVC;
@property (nonatomic, retain) UIView *filterViewOverlay;
@end

@implementation EventListViewController

- (void)clearDatas {
  DELETE_OBJS_FROM_MOC(_MOC, @"Event", nil);
  DELETE_OBJS_FROM_MOC(_MOC, @"Club", nil);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(WXWRootViewController *)pVC
         tabIndex:(EventGroupTabIndex)tabIndex
{
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 tableStyle:UITableViewStylePlain
                 needGoHome:NO];
  
  self.parentVC = pVC;

  [self clearState];
  [self clearDatas];
  
  _tabType = tabIndex;
  
  [self resetFilter];
  [super clearPickerSelIndex2Init:3];
  
  return self;
}

- (void)dealloc {
  
  [NSFetchedResultsController deleteCacheWithName:nil];
  [self resetFilter];
  
  self.eventFliterShowArray = nil;
  self.eventFliterSaveArray = nil;
  self.groupFliterShowArray = nil;
  self.groupFliterSaveArray = nil;
  
  self.groupSupType = nil;
  self.groupType = nil;
  
  self.cityId = nil;
  self.clubFilters = nil;
  self.filterNavVC = nil;
  
  self.eventToolTitleView = nil;
  self.groupToolTitleView = nil;
  self.segmentControlTitles = nil;
  
  self.filterViewOverlay = nil;
  
  [AppManager instance].loadedEventFilterOK = NO;
  [AppManager instance].eventTypeList = nil;
  [AppManager instance].eventCityList = nil;
  [AppManager instance].eventSortList = nil;
  
  [AppManager instance].loadedGroupFilterOK = NO;
  [AppManager instance].clubFilterList = nil;
  [AppManager instance].groupSortList = nil;
  [AppManager instance].groupTypeList = nil;
  
  [super dealloc];
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  NSMutableString *requestParam = nil;
  
  switch (_tabType) {
    case EVENT_TAB_IDX:
      _currentType = EVENTLIST_TY;
      
      NSInteger index = 0;
      if (!forNew) {
        index = ++ eventPageIndex;
      }
      
      requestParam = [NSMutableString stringWithFormat:@"<keywords>%@</keywords><screen_type>%@</screen_type><city_id>%@</city_id><sort_type>%@</sort_type><page_size>20</page_size><page>%d</page><longitude>%f</longitude><latitude>%f</latitude>", [AppManager instance].searchKeyWords, self.eventFliterSaveArray[EVENT_TY_IDX], self.eventFliterSaveArray[CITY_TY_IDX], self.eventFliterSaveArray[SORT_TY_IDX], index, [AppManager instance].longitude, [AppManager instance].latitude];
      break;
      
    case GROUP_TAB_IDX:
    {
      _currentType = CLUBLIST_TY;
      
      NSInteger index = 0;
      if (!forNew) {
        index = ++ groupPageIndex;
      }
      
      NSInteger topLevel = ((NSString *)self.groupFliterSaveArray[0]).intValue;
      if (topLevel == 5) {
        if (((NSString *)self.groupFliterSaveArray[2]).intValue == 2) {
          _onlyMine = 1;
        } else {
          _onlyMine = 0;
        }
      }
      
      requestParam = [NSMutableString stringWithFormat:@"<keywords>%@</keywords><sort_type>%@</sort_type><only_mine>%d</only_mine><host_type_value>%@</host_type_value><host_sub_type_value>%@</host_sub_type_value><page_size>%@</page_size><page>%d</page>", [AppManager instance].searchKeyWords, self.groupFliterSaveArray[1], _onlyMine, self.groupFliterSaveArray[0], self.groupFliterSaveArray[2], ITEM_LOAD_COUNT, index];

      break;
    }
      
    default:
      break;
  }
  
  NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade fetchGets:url];
}

- (void)resetMutableArray:(NSMutableArray *)contentList index:(NSInteger)index {
  if (contentList.count > 0) {
    if (contentList.count >= RECORD_SELECTION_IDX + 1) {
      
      if (index > 0) {
        contentList[RECORD_SELECTION_IDX] = @(UNSELECTED_TY);
      } else {
        contentList[RECORD_SELECTION_IDX] = @(SELECTED_TY);
      }
    }
  }
}

- (void)resetEventFilters {
  for (NSInteger i = 0; i < [AppManager instance].eventCityList.count; i++) {
    [self resetMutableArray:(NSMutableArray *)[AppManager instance].eventCityList[i] index:i];
  }
  
  for (NSInteger i = 0; i < [AppManager instance].eventTypeList.count; i++) {
    [self resetMutableArray:(NSMutableArray *)[AppManager instance].eventTypeList[i] index:i];
  }
  
  for (NSInteger i = 0; i < [AppManager instance].eventSortList.count; i++) {
    [self resetMutableArray:(NSMutableArray *)[AppManager instance].eventSortList[i] index:i];
  }
  
  self.eventFliterSaveArray[EVENT_TY_IDX] = ([AppManager instance].eventTypeList)[0][RECORD_ID_IDX];
  self.eventFliterSaveArray[CITY_TY_IDX] = ([AppManager instance].eventCityList)[0][RECORD_ID_IDX];
  self.eventFliterSaveArray[SORT_TY_IDX] = ([AppManager instance].eventSortList)[0][RECORD_ID_IDX];
}

- (void)resetFilter {

  [AppManager instance].filterSupIndex = 0;
  [AppManager instance].filterIndex = 0;
  
  // reset event filter stuff
  [self resetEventFilters];
  
  // reset group filter stuff
  [self resetGroupFilters];
}

- (void)setTriggerReloadListFlag {
  _needRefresh = YES;
}

#pragma mark - core data

- (void)configureMOCFetchConditions {
  
  
  switch (_tabType) {
    case EVENT_TAB_IDX:
    {
      self.entityName = @"Event";
      self.descriptors = [NSMutableArray array];
      self.predicate = nil;
      
      NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder" ascending:YES] autorelease];
      [self.descriptors addObject:dateDesc];

      break;
    }
      
    case GROUP_TAB_IDX:
    {
      self.entityName = @"Club";
      
      self.descriptors = [NSMutableArray array];
      NSSortDescriptor *dateDesc = nil;
      int clubSize = [[AppManager instance].supClubFilterList count];
      
      if ([AppManager instance].filterSupIndex == clubSize) {
        switch ([AppManager instance].filterIndex) {
          case 0:
            dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder"
                                                    ascending:YES] autorelease];
            break;
            
          case 1:
            dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"member"
                                                    ascending:NO] autorelease];
            break;
            
          case 2:
            dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"activity"
                                                    ascending:NO] autorelease];
            break;
        }
      } else {
        dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder"
                                                ascending:YES] autorelease];
      }
      
      if (dateDesc != nil) {
        [self.descriptors addObject:dateDesc];
      }
      
      self.predicate = nil;
      break;
    }
      
    default:
      break;
  }
  
}

#pragma mark - View lifecycle

- (void)addFilterButton {
  _searchBtn =
  [[ILBarButtonItem barItemWithImage:[UIImage imageNamed:@"btnSearchWhite.png"]
                       selectedImage:[UIImage imageNamed:@"btnSearchWhite.png"]
                              target:self
                              action:@selector(clickFilterMenu:)] autorelease];
  
  [self setViewMoveWayType:1];
  
  self.parentVC.navigationItem.rightBarButtonItem = _searchBtn;
}

- (void)addEventFliterView {
  
  self.eventFliterShowArray = [[[NSMutableArray alloc] init] autorelease];
  self.eventFliterSaveArray = [[[NSMutableArray alloc] init] autorelease];
  
  self.eventFliterShowArray[0] = ([AppManager instance].eventTypeList)[0][RECORD_NAME_IDX];
  self.eventFliterShowArray[1] = ([AppManager instance].eventCityList)[0][RECORD_NAME_IDX];
  self.eventFliterShowArray[2] = ([AppManager instance].eventSortList)[0][RECORD_NAME_IDX];
  
  [self resetEventFilters];
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)resetGroupFilters {
  for (NSInteger i = 0; i < [AppManager instance].supClubFilterList.count; i++) {
    [self resetMutableArray:(NSMutableArray *)[AppManager instance].supClubFilterList[i] index:i];
  }
  
  for (NSInteger i = 0; i < [AppManager instance].clubFilterList.count; i++) {
    NSMutableArray *list = [AppManager instance].clubFilterList[i];
    for (NSInteger j = 0; j < list.count; j++) {
      [self resetMutableArray:(NSMutableArray *)list[j] index:j];
    }
  }
  
  for (NSInteger i = 0; i < [AppManager instance].groupSortList.count; i++) {
    [self resetMutableArray:(NSMutableArray *)[AppManager instance].groupSortList[i] index:i];
  }
  
  self.groupFliterSaveArray[0] = NULL_PARAM_VALUE;
  self.groupFliterSaveArray[1] = ([AppManager instance].groupSortList)[0][RECORD_ID_IDX];
  self.groupFliterSaveArray[2] = NULL_PARAM_VALUE;
}

- (void)addGroupFliterView {
  
  [AppManager instance].searchKeyWords = NULL_PARAM_VALUE;
  
  self.groupFliterShowArray = [[[NSMutableArray alloc] init] autorelease];
  self.groupFliterSaveArray = [[[NSMutableArray alloc] init] autorelease];
  
  int groupSize = [[AppManager instance].supClubFilterList count];
  
  for (int i=0; i<groupSize; i++) {
    self.groupFliterShowArray[i] = ([AppManager instance].supClubFilterList)[i][RECORD_NAME_IDX];
  }
  self.groupFliterShowArray[groupSize] = ([AppManager instance].groupSortList)[0][RECORD_NAME_IDX];
  
  [self resetGroupFilters];
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)setTableViewProperties {
  
  _tableView.frame = CGRectMake(0, TOOLBAR_HEIGHT,
                                _tableView.frame.size.width,
                                _tableView.frame.size.height - HOMEPAGE_TAB_HEIGHT - TOOLBAR_HEIGHT + 20);
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}

- (void)hideView {
  
  _originalTableViewFrame = _tableView.frame;
  _tableView.alpha = 0.0f;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  viewHeight = _tableView.frame.size.height;
  
  [self addTopToolBar];
  
  if ([AppManager instance].loadedEventFilterOK) {
    [self addEventFliterView];
  }
  
  [self setTableViewProperties];
  
  [self hideView];
  
}

- (void)viewWillAppear:(BOOL)animated {
	[super deselectCell];
	
  if (![AppManager instance].loadedEventFilterOK) {
    [self getEventFilterData];
  }
  
  if (!_autoLoaded) {
    [_tabSwitchView selectButtonWithIndex:EVENT_TAB_IDX];
  }
  
  if (_needRefresh) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    _needRefresh = NO;
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super deselectCell];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)addTopToolBar {
  
  CGFloat y = 0;
  CGFloat height = TOOLBAR_HEIGHT;
  CGFloat contentStartY = 0;
  if (CURRENT_OS_VERSION >= IOS7) {
    y = -20;
    height += SYS_STATUS_BAR_HEIGHT;
    contentStartY = SYS_STATUS_BAR_HEIGHT;
  }
  
  UIView *tool = [[[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, height)] autorelease];
  tool.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationBarBackground.png"]];
  [self.view addSubview:tool];
  
  self.segmentControlTitles = [NSArray arrayWithObjects:LocaleStringForKey(NSEventTitle, nil), LocaleStringForKey(NSProfAssocTitle, nil), nil];
  
  _tabSwitchView = [[[PlainTabView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - BUTTON_SEGMENT_WIDTH)/2.0f,
                                                                   contentStartY + (TOOLBAR_HEIGHT - HEADER_HEIGHT)/2.0f,
                                                                   BUTTON_SEGMENT_WIDTH, HEADER_HEIGHT) buttonTitles:@[LocaleStringForKey(NSEventTitle, nil), LocaleStringForKey(NSProfAssocTitle, nil)]
                                      tapSwitchDelegate:self] autorelease];
  [tool addSubview:_tabSwitchView];
  
  _btn = [UIButton buttonWithType:UIButtonTypeCustom];
  _btn.tag = MOVE_TO_LEFT_TY;
  _btn.showsTouchWhenHighlighted = YES;
  [_btn setTitle:LocaleStringForKey(NSFilterTitle, nil) forState:UIControlStateNormal];
  _btn.titleLabel.font = BOLD_FONT(15);
  CGSize size = [CommonUtils sizeForText:_btn.titleLabel.text
                                    font:_btn.titleLabel.font];
  
  _btn.frame = CGRectMake(tool.frame.size.width - size.width - MARGIN * 2,
                          contentStartY + (TOOLBAR_HEIGHT - size.height)/2.0f, size.width, size.height);
  [_btn addTarget:self
           action:@selector(clickFilterMenu:)
 forControlEvents:UIControlEventTouchUpInside];
  
  [tool addSubview:_btn];
}

#pragma mark - set navigation button item
- (void)displayNavigationItemBar {
  if (self.parentVC) {
    [(WXWNavigationController *)self.parentVC.parentViewController setNavigationBarHidden:NO];
  }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  
  return self.fetchedRC.fetchedObjects.count + 1;
}

- (void)updateTable:(NSArray *)indexPaths {
  [_tableView beginUpdates];
  [_tableView reloadRowsAtIndexPaths:indexPaths
                    withRowAnimation:UITableViewRowAnimationNone];
  [_tableView endUpdates];
}

- (ClubListCell *)drawGroupCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
  
  // Club Cell
  NSString *kGroupCellIdentifier = @"ClubListCell";
  ClubListCell *cell = (ClubListCell *)[_tableView dequeueReusableCellWithIdentifier:kGroupCellIdentifier];
  if (nil == cell) {
    cell = [[[ClubListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                reuseIdentifier:kGroupCellIdentifier
                         imageDisplayerDelegate:self
                                            MOC:_MOC
                                         target:self
                            displayDetailAction:@selector(openClubDetail:)] autorelease];
  }
  
  Club *club = (Club *)[self.fetchedRC objectAtIndexPath:indexPath];
  [cell drawClub:club];
  return cell;
}

- (EventListCell *)drawEventCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
  
  // Event Cell
  NSString *kEventCellIdentifier = @"EventCell";
  EventListCell *cell = (EventListCell *)[tableView dequeueReusableCellWithIdentifier:kEventCellIdentifier];
  if (nil == cell) {
    cell = [[[EventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventCellIdentifier] autorelease];
  }
  
  Event *event = (Event *)[self.fetchedRC objectAtIndexPath:indexPath];
  [cell drawEvent:event];
  
  cell.selectionStyle = UITableViewCellSelectionStyleGray;
  
  return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
    return [self drawFooterCell];
  } else {
    
    switch (_tabType) {
      case EVENT_TAB_IDX:
        return [self drawEventCell:tableView indexPath:indexPath];
        
      case GROUP_TAB_IDX:
        return [self drawGroupCell:tableView indexPath:indexPath];
        
      default:
        return nil;
    }
  }
}

- (void)gotoEventDetailWithDetailVC:(EventDetailViewController *)detailVC {
  detailVC.title = LocaleStringForKey(NSEventDetailTitle, nil);
  
  if (self.parentVC) {
    [self.parentVC.navigationController pushViewController:detailVC animated:YES];
  } else {
    [self.navigationController pushViewController:detailVC animated:YES];
  }
}

- (void)gotoEventDetailWithEventId:(NSString *)eventId {
  [AppManager instance].eventId = eventId;
  EventDetailViewController *detailVC = [[[EventDetailViewController alloc] initWithMOC:_MOC
                                                                                eventId:eventId.longLongValue
                                                                           parentListVC:self] autorelease];
  [self gotoEventDetailWithDetailVC:detailVC];
}

- (void)gotoEventDetailWithEvent:(Event *)event {
  [AppManager instance].eventId = [event.eventId stringValue];
  EventDetailViewController *detailVC = [[[EventDetailViewController alloc] initWithMOC:_MOC
                                                                                  event:event
                                                                           parentListVC:self] autorelease];
  [self gotoEventDetailWithDetailVC:detailVC];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count || _showingFilter) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (_tabType) {
    case EVENT_TAB_IDX:
    {
      [super tableView:tableView didSelectRowAtIndexPath:indexPath];
      
      [AppManager instance].isClub2Event = NO;
      
      Event *event = [self.fetchedRC objectAtIndexPath:indexPath];
      
      [self gotoEventDetailWithEvent:event];

      break;
    }
      
    case GROUP_TAB_IDX:
    {
      Club *club = [self.fetchedRC objectAtIndexPath:indexPath];
      club.badgeNum = @"";
      SAVE_MOC(_MOC);
          
      GroupChatViewController *groupChatVC = [[[GroupChatViewController alloc] initWithMOC:_MOC
                                                                                     group:club] autorelease];
      groupChatVC.title = club.clubName;
      if (self.parentVC) {
        [self.parentVC.navigationController pushViewController:groupChatVC animated:YES];
      } else {
        [self.navigationController pushViewController:groupChatVC animated:YES];
      }
    
      break;
    }
      
    default:
      break;
  }
  
  if (CURRENT_OS_VERSION >= IOS7) {
    [self displayNavigationItemBar];
  } else {
    [self performSelector:@selector(displayNavigationItemBar) withObject:nil afterDelay:0.1f];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (_tabType) {
    case EVENT_TAB_IDX:
      return EVENT_LIST_CELL_HEIGHT;
      
    case GROUP_TAB_IDX:
      return CLUB_LIST_CELL_HEIGHT;
      
    default:
      return 0;
  }
}

#pragma mark - load Event list from web
- (void)stopAutoRefreshUserList {
  [timer invalidate];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  _tabSwitchView.userInteractionEnabled = NO;
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case EVENT_FILTER_TY:
    {
      ReturnCode ret = [XMLParser handleEventFilterData:result MOC:_MOC];
      if (ret == RESP_OK){
        
        [self addEventFliterView];
      } else {
        
        _btn.enabled = NO;
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
        [self closeAsyncLoadingView];
      }
    }
      break;
      
    case EVENTLIST_TY:
    {
      
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self refreshTable];
        
        if (!_autoLoaded) {
          _keepEventsInMOC = YES;
          _autoLoaded = YES;
        }
        _tableView.alpha = 1.0f;
        //_tabSwitchView.alpha = 1.0f;
        
        [self closeAsyncLoadingView];
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
        [self closeAsyncLoadingView];
      }
      
      break;
    }
      
    case GROUP_FILTER_TY:
    {
      ReturnCode ret = [XMLParser handleGroupFilterData:result MOC:_MOC];
      if (ret == RESP_OK){
        
        [self addGroupFliterView];
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
        [self closeAsyncLoadingView];
      }
    }
      break;
      
    case CLUBLIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        if (!_autoLoaded) {
          _autoLoaded = YES;
        }
        
        [self refreshTable];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLoadGroupFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      [self closeAsyncLoadingView];
      break;
    }
      
    case EVENT_CITY_LIST_TY:
    {
      BOOL ret = [XMLParser parserResponseXml:result
                                         type:contentType
                                          MOC:_MOC
                            connectorDelegate:self
                                          url:url];
      
      if (ret) {
        [super setPopView];
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
      }
      
      [self closeAsyncLoadingView];
      break;
    }
      
    default:
      break;
  }
  
  [self resetUIElementsForConnectDoneOrFailed];
  
  _tabSwitchView.userInteractionEnabled = YES;
  
  [super connectDone:result
                 url:url
         contentType:contentType
closeAsyncLoadingView:NO];
  
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  if (contentType == EVENT_FILTER_TY) {
    _btn.enabled = NO;
  }
  
  _tabSwitchView.userInteractionEnabled = YES;
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - clear list
- (void)clearList {
  
  self.fetchedRC = nil;
  [_tableView reloadData];
}

#pragma mark - clear unread event count
- (void)clearComingLectureCount {
  if (self.parentVC && [self.parentVC respondsToSelector:@selector(clearComingLectureCount)]) {
    [self.parentVC performSelector:@selector(clearComingLectureCount)];
  }
}

- (void)clearComingEntertainmentCount {
  if (self.parentVC && [self.parentVC respondsToSelector:@selector(clearComingEntertainmentCount)]) {
    [self.parentVC performSelector:@selector(clearComingEntertainmentCount)];
  }
}

#pragma mark - TapSwitchDelegate method
- (void)selectTapByIndex:(NSInteger)index {
  
  if (index == _tabType) {
    return;
  }
  
  _currentStartIndex = 0;
  
  _tabType = index;
  
  [self clearList];
  
  //[self removeEmptyMessageIfNeeded];
  
  [self clearState];
  
  BOOL isEvent = NO;
  if (_tabType == EVENT_TAB_IDX) {
    isEvent = YES;
  }
  
  if (self.delegate) {
    [self.delegate setCurrentEventFlag:isEvent];
  }
  
  [super clearPickerSelIndex2Init:3];
  if (isEvent) {
    
    DELETE_OBJS_FROM_MOC(_MOC, @"Event", nil);
    
    if ([AppManager instance].loadedEventFilterOK && [[AppManager instance].eventTypeList count] > 1) {
      [self addEventFliterView];
    } else {
      [self getEventFilterData];
    }
  } else {
    
    DELETE_OBJS_FROM_MOC(_MOC, @"Club", nil);
    
    if ([AppManager instance].loadedGroupFilterOK && [[AppManager instance].groupTypeList count] > 1) {
      [self addGroupFliterView];
    } else {
      [self getGroupFilterData];
    }
  }
}

#pragma mark - Filter Data
- (void)getEventFilterData {
  
  _currentType = EVENT_FILTER_TY;
  NSString *url = [CommonUtils geneUrl:@"" itemType:_currentType];
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:_currentType] autorelease];
  [connFacade fetchGets:url];
}

- (void)getGroupFilterData {
  
  _currentType = GROUP_FILTER_TY;
  NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:_currentType];
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:_currentType] autorelease];
  [connFacade fetchGets:url];
}

- (void)saveFilterParam {
  
  switch (_tabType) {
    case EVENT_TAB_IDX:
    {
      eventPageIndex = _currentStartIndex;
      
      if (![AppManager instance].eventParam0List) {
        [[AppManager instance].eventParam0List removeAllObjects];
        [AppManager instance].eventParam0List = nil;
      }
      
      if (![AppManager instance].eventParam1List) {
        [[AppManager instance].eventParam1List removeAllObjects];
        [AppManager instance].eventParam1List = nil;
      }
      
      [AppManager instance].eventParam0List = [NSMutableArray array];
      [AppManager instance].eventParam1List = [NSMutableArray array];
      
      [AppManager instance].eventParam0List = [WXWSystemInfoManager instance].pickerSel0IndexList;
      [AppManager instance].eventParam1List = [WXWSystemInfoManager instance].pickerSel1IndexList;

      break;
    }
      
    case GROUP_TAB_IDX:
    {
      groupPageIndex = _currentStartIndex;
      
      if (![AppManager instance].groupParam0List) {
        [[AppManager instance].groupParam0List removeAllObjects];
        [AppManager instance].groupParam0List = nil;
      }
      
      if (![AppManager instance].groupParam1List) {
        [[AppManager instance].groupParam1List removeAllObjects];
        [AppManager instance].groupParam1List = nil;
      }
      
      [AppManager instance].groupParam0List = [NSMutableArray array];
      [AppManager instance].groupParam1List = [NSMutableArray array];
      
      [AppManager instance].groupParam0List = [WXWSystemInfoManager instance].pickerSel0IndexList;
      [AppManager instance].groupParam1List = [WXWSystemInfoManager instance].pickerSel1IndexList;
      break;
    }
      
    default:
      break;
  }
}

- (void)enterGroup:(ClubViewType)showType group:(Club *)group {
  
  [AppManager instance].allowSendSMS = NO;
  
  GroupFormViewController *postListVC = [[[GroupFormViewController alloc] initWithMOC:_MOC
                                                                                group:group
                                                                               holder:nil
                                                                     backToHomeAction:nil
                                                                               parent:self
                                                                  refreshParentAction:@selector(setTriggerReloadListFlag)
                                                                             listType:ALL_ITEM_LIST_TY
                                                                             showType:showType] autorelease];
  postListVC.title = group.clubName;
  
  if (self.parentVC) {
    [self.parentVC.navigationController pushViewController:postListVC animated:YES];
  } else {
    [self.navigationController pushViewController:postListVC animated:YES];
  }
  
}

- (void)openClubDetail:(id)sender {
  
  if (_showingFilter) {
    return;
  }
  
  [self displayNavigationItemBar];
  
  UIButton *myBtn=(UIButton *)sender;
  
  UIView *v = myBtn;
  while (v != nil && ![v isKindOfClass:[ClubListCell class]]) {
    v = v.superview;
  }
  
  Club *club = [self.fetchedRC objectAtIndexPath:[self.tableView indexPathForCell:(ClubListCell *)v]];
  
  [AppManager instance].clubName = [NSString stringWithFormat:@"%@", club.clubName];
  [AppManager instance].clubId = [NSString stringWithFormat:@"%@", club.clubId];
  [AppManager instance].clubType = [NSString stringWithFormat:@"%@", club.clubType];
  [AppManager instance].hostSupTypeValue = club.hostSupTypeValue;
  [AppManager instance].hostTypeValue = club.hostTypeValue;
  
  [AppManager instance].isNeedReLoadClubDetail = YES;
  CGRect mFrame = CGRectMake(0, 0, LIST_WIDTH, self.view.bounds.size.height);
  ClubDetailViewController *sponsorDetail = [[[ClubDetailViewController alloc] initWithFrame:mFrame
                                                                                         MOC:_MOC
                                                                                parentListVC:self] autorelease];
  sponsorDetail.title = LocaleStringForKey(NSClubDetailTitle, nil);
  
  if (self.parentVC) {
    [self.parentVC.navigationController pushViewController:sponsorDetail animated:YES];
  } else {
    [self.navigationController pushViewController:sponsorDetail animated:YES];
  }
}

#pragma mark - do search
- (void)doSearch:(id)sender {
  _autoLoaded = NO;
  
  switch (_tabType) {
    case EVENT_TAB_IDX:
    {
      SearchEventListViewController *searchEventListVC = [[[SearchEventListViewController alloc] initWithMOC:_MOC parentVC:self tabIndex:ACADEMIC_EVENT_TY] autorelease];
      searchEventListVC.title = LocaleStringForKey(NSEventTitle, nil);
      
      if (self.parentVC) {
        [self.parentVC.navigationController pushViewController:searchEventListVC animated:YES];
      } else {
        [self.navigationController pushViewController:searchEventListVC animated:YES];
      }
      break;
    }
      
    case GROUP_TAB_IDX:
    {
      SearchClubViewController *searchClubVC = [[[SearchClubViewController alloc] initWithMOC:_MOC] autorelease];
      searchClubVC.title = LocaleStringForKey(NSSearchTitle, nil);
      [AppManager instance].clubKeyWord = @"";
      [AppManager instance].supClubTypeValue = @"";
      [AppManager instance].hostTypeValue = @"";
      
      if (self.parentVC) {
        [self.parentVC.navigationController pushViewController:searchClubVC animated:YES];
      } else {
        [self.navigationController pushViewController:searchClubVC animated:YES];
      }
      break;
    }
      
    default:
      break;
  }
  
}

- (void)clearState {
  
  _currentStartIndex = 0;
  
  [self resetFilter];
}

#pragma mark - click Filter Menu
-(void)clickFilterMenu:(id)sender {
  
  [AppManager instance].searchKeyWords = @"";
  
  if (self.delegate) {
    
    switch (_btn.tag) {
      case RESET_MAIN_TY:
        [self.delegate resetPanelPosition];
        break;
        
      case MOVE_TO_LEFT_TY:
        [self.delegate movePanelLeft];
        break;
        
      default:
        break;
    }
  }
  isClickSearch = !isClickSearch;
}

#pragma mark - handle vc

- (void)setShowingFilter:(BOOL)flag {
  _showingFilter = flag;
}

- (void)setViewMoveWayType:(ScrollMoveWayType)tag {
  
  _btn.tag = tag;
}

- (void)extendFilterVC
{
  
  [self.parentVC.navigationController.view setFrame:CGRectMake(0-SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
  [self.filterNavVC.view setFrame:CGRectMake(0.f, 0.f, SCREEN_WIDTH, SCREEN_HEIGHT)];
  [self removeFilterView];
  
}

- (void)recoveryMainVC
{
  // main vc
  [self.parentVC.navigationController.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
  
  isClickSearch = !isClickSearch;
  
  int listSupIndex = [AppManager instance].filterSupIndex;
  int listIndex = [AppManager instance].filterIndex;
  
  switch (_tabType) {
    case EVENT_TAB_IDX:
    {
      eventPageIndex = 0;
      [CommonUtils doDelete:_MOC entityName:@"Event"];
      
      switch (listSupIndex) {
        case EVENT_TY_IDX:
        {
          self.eventFliterSaveArray[EVENT_TY_IDX] = ([AppManager instance].eventTypeList)[listIndex][RECORD_ID_IDX];
        }
          break;
          
        case CITY_TY_IDX:
        {
          self.eventFliterSaveArray[CITY_TY_IDX] = ([AppManager instance].eventCityList)[listIndex][RECORD_ID_IDX];
        }
          break;
          
        case SORT_TY_IDX:
        {
          self.eventFliterSaveArray[SORT_TY_IDX] = ([AppManager instance].eventSortList)[listIndex][RECORD_ID_IDX];
        }
          break;
          
        case MY_EVENT_TY_IDX:
        {
          // “3”是后台定义的“我的活动”的type id
          self.eventFliterSaveArray[EVENT_TY_IDX] = STR_FORMAT(@"%d",3);
        }
          break;
          
        default:
          break;
      }
      break;
    }
      
    case GROUP_TAB_IDX:
    {
      groupPageIndex = 0;
      [CommonUtils doDelete:_MOC entityName:@"Club"];
      
      int clubSize = [[AppManager instance].supClubFilterList count];
      
      if (listSupIndex == clubSize) {
        self.groupFliterSaveArray[1] = ([AppManager instance].groupSortList)[listIndex][RECORD_ID_IDX];
      } else {
        self.groupFliterSaveArray[0] = [AppManager instance].supClubFilterList[listSupIndex][RECORD_ID_IDX];
        
        self.groupFliterSaveArray[2] = [[AppManager instance].clubFilterList objectAtIndex:listSupIndex][listIndex][RECORD_ID_IDX];
      }
      break;
    }
      
    default:
      break;
  }
  
  [self hideFilterView:nil];
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)disableTableScroll {
  _tableView.scrollEnabled = NO;
  _tableView.userInteractionEnabled = NO;
}

- (void)enableTableScroll {
  _tableView.scrollEnabled = YES;
  _tableView.userInteractionEnabled = YES;
}

- (BOOL)tableScrolling {
  return _scrolling;
}

#pragma mark - Filter View option
- (void)initFilterView:(CGRect)frame {
  self.filterViewOverlay = [[[UIView alloc]
                             initWithFrame:frame] autorelease];
  self.filterViewOverlay.backgroundColor = [UIColor clearColor];
  self.filterViewOverlay.alpha = 0;
  [self addTapGestureRecognizer];
}

- (void)showFilterView {
  self.filterViewOverlay.alpha = 0;
  [self.view addSubview:self.filterViewOverlay];
  
  [UIView beginAnimations:@"FadeIn" context:nil];
  [UIView setAnimationDuration:0.5];
  self.filterViewOverlay.alpha = 0.6;
  self.filterViewOverlay.userInteractionEnabled = YES;
  [UIView commitAnimations];
  
  if (self.parentVC) {
    [(HomeContainerController*)self.parentVC hideTabBar];
  }
}

- (void)removeFilterView {
  if (self.delegate) {
    [self.delegate resetPanelPosition];
  }
}

- (void)addTapGestureRecognizer {
  UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideFilterView:)] autorelease];
  [self.filterViewOverlay addGestureRecognizer:tap];
}

- (void)hideFilterView:(id)sender {
  
  [self enableTableScroll];
  
  [UIView animateWithDuration:0.5 animations:^(void){
    if (self.filterNavVC) {
      [self.filterNavVC removeFromParentViewController];
      [self.filterNavVC.view removeFromSuperview];
    }
  } completion:^(BOOL finished) {
    self.parentVC.navigationController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self removeFilterView];
  }];
}

#pragma mark - Scroll

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  _scrolling = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  _scrolling = NO;
}

#pragma mark - open shared event

- (void)openSharedEventById:(long long)eventId {
  
  [AppManager instance].isClub2Event = NO;
  
  [self gotoEventDetailWithEventId:STR_FORMAT(@"%lld", eventId)];
  
  [self performSelector:@selector(displayNavigationItemBar) withObject:nil afterDelay:0.1f];
}

@end