//
//  MyEventListViewController.m
//  iAlumni
//
//  Created by Adam on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MyEventListViewController.h"
#import "EventListCell.h"
#import "Event.h"
#import "EventDetailViewController.h"
#import "NaviButton.h"
#import "EventCity.h"

#define defaultFont     18

#define HEADER_HEIGHT   40.0f

@interface MyEventListViewController()
@end

@implementation MyEventListViewController
@synthesize _hostTypeValue;
@synthesize _hostSubTypeValue;
@synthesize cityId = _cityId;

- (void)clearEvents {
  DELETE_OBJS_FROM_MOC(_MOC, @"Event", nil);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(WXWRootViewController *)parentVC
         tabIndex:(int)tabIndex
{
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 tableStyle:UITableViewStylePlain
                 needGoHome:NO];
  
  _parentVC = parentVC;
  
  _currentStartIndex = 0;
  
  [self clearEvents];
  
  _eventCategory = tabIndex;
  
  [self clearFliter];
  [self clearPickerSelIndex2Init:2];
  
  return self;
}

- (void)dealloc {
  
  [NSFetchedResultsController deleteCacheWithName:nil];
  [self clearFliter];
  self.cityId = NULL_PARAM_VALUE;
  [super dealloc];
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = MY_EVENT_TY;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  NSMutableString *requestParam = [NSMutableString stringWithFormat:@"<page_size>20</page_size><page>%d</page>", index];
  
  switch (_eventCategory) {
    case ACADEMIC_EVENT_TY:
      [requestParam appendString:@"<date_type>1</date_type>"];
      break;
      
    case LOHHAS_EVENT_TY:
      [requestParam appendString:@"<date_type>2</date_type>"];
      break;
      
    default:
      self.predicate = nil;
      break;
  }
  
  NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade fetchGets:url];
}

- (void)clearFliter {
  // Clear Fliter
  [[AppManager instance].supClubFilterList removeAllObjects];
  [AppManager instance].supClubFilterList = nil;
  [[AppManager instance].clubFilterList removeAllObjects];
  [AppManager instance].clubFilterList = nil;
  [AppManager instance].clubFliterLoaded = NO;
}

#pragma mark -
#pragma mark - core data

- (void)configureMOCFetchConditions {
  self.entityName = @"Event";
  self.descriptors = [NSMutableArray array];
  self.predicate = [NSPredicate predicateWithFormat:@"screenType == %d", _eventCategory+1];
  
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder" ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];
}

#pragma mark - View lifecycle

- (void)initTabSwitchView {
  _tabSwitchView = [[[PlainTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)
                                            buttonTitles:@[LocaleStringForKey(NSMySignUpEventMsg, nil), LocaleStringForKey(NSMyCheckInEventMsg, nil)]
                                       tapSwitchDelegate:self] autorelease];
  
  [self.view addSubview:_tabSwitchView];
}

- (void)setTableViewProperties {
  
  _tableView.frame = CGRectMake(0, HEADER_HEIGHT,
                                _tableView.frame.size.width,
                                _tableView.frame.size.height - HEADER_HEIGHT);
  
  _tableView.separatorStyle = NO;
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}

- (void)hideView {
  _originalTableViewFrame = _tableView.frame;
  _tableView.alpha = 0.0f;
  _tabSwitchView.alpha = 0.0f;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  //    [self setNaviBarButtonItem:@"全部"];
  
  [self initTabSwitchView];
  
  [self setTableViewProperties];
  
  [self hideView];
}

- (void)doFliter:(id)sender
{
  if (_isPop) {
    return;
  }else{
    _isPop = YES;
  }
  
  if (![AppManager instance].eventCityLoaded) {
    NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:EVENT_CITY_LIST_TY];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:EVENT_CITY_LIST_TY];
    [connFacade fetchGets:url];
  } else {
    [super setPopView];
  }
}

- (void)viewWillAppear:(BOOL)animated {
	[super deselectCell];
	
	if (!_autoLoaded) {
		[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
	}
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super deselectCell];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - set navigation button item
- (void)setNaviBarButtonItem:(NSString*)cityStr
{
  NaviButton *naviButton = [[[NaviButton alloc] initWithFrame:CGRectMake(240.f, 0, 80.f, NAVIGATION_BAR_HEIGHT) title:cityStr titleFont:FONT(15) titleColor:COLOR(254, 249, 253) backgroundColor:[UIColor clearColor] target:self action:@selector(doFliter:)] autorelease];
  
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:naviButton] autorelease];
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

- (EventListCell *)drawLatest:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
  
  // Event Cell
  NSString *kEventCellIdentifier = @"EventCell";
  EventListCell *cell = (EventListCell *)[tableView dequeueReusableCellWithIdentifier:kEventCellIdentifier];
  if (nil == cell) {
    cell = [[[EventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventCellIdentifier] autorelease];
  }
  
  Event *event = [self.fetchedRC objectAtIndexPath:indexPath];
  [cell drawEvent:event];
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
    return [self drawFooterCell];
  } else {
    return [self drawLatest:tableView indexPath:indexPath];
  }
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  [AppManager instance].isClub2Event = NO;
  
  Event *event = [self.fetchedRC objectAtIndexPath:indexPath];
  [AppManager instance].eventId = [event.eventId stringValue];
  EventDetailViewController *detailVC = [[[EventDetailViewController alloc] initWithMOC:_MOC
                                                                                  event:event
                                                                           parentListVC:nil] autorelease];
  detailVC.title = LocaleStringForKey(NSEventDetailTitle, nil);
  
  if (_parentVC) {
    [_parentVC.navigationController pushViewController:detailVC animated:YES];
  } else {
    [self.navigationController pushViewController:detailVC animated:YES];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return EVENT_LIST_CELL_HEIGHT;
}

#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	pickSel0Index = row;
  
  isPickSelChange = YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [_PickData count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  return _PickData[row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
  return 300.0f;
}

-(void)onPopCancle:(id)sender {
  
  [super onPopCancle];
  _isPop = NO;
}

-(void)onPopOk:(id)sender {
  [super onPopSelectedOk];
  int iPickSelectIndex = [super pickerList0Index];
  
  [self clearEvents];
  
  [_PopBGView removeFromSuperview];
  
  [self setNaviBarButtonItem:(self.DropDownValArray)[iPickSelectIndex][RECORD_NAME_IDX]];
  self.cityId = (self.DropDownValArray)[iPickSelectIndex][RECORD_ID_IDX];
  _currentStartIndex = 0;
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  _isPop = NO;
}

#pragma mark - set drop Value
- (void)setDropDownValueArray {
  
  [NSFetchedResultsController deleteCacheWithName:nil];
  
  self.descriptors = [NSMutableArray array];
  self.DropDownValArray = [[[NSMutableArray alloc] init] autorelease];
  
  NSSortDescriptor *orderDesc = [[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease];
  [self.descriptors addObject:orderDesc];
  
  self.entityName = @"EventCity";
  
  NSError *error = nil;
  BOOL res = [[super prepareFetchRC] performFetch:&error];
  if (!res) {
    NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
  }
  
  NSArray *eventCitys = [CommonUtils objectsInMOC:_MOC
                                       entityName:self.entityName
                                     sortDescKeys:self.descriptors
                                        predicate:nil];
  
  int size = [eventCitys count];
  for (NSUInteger i=0; i<size; i++) {
    EventCity* mEventCity = (EventCity*)eventCitys[i];
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    [mArray insertObject:mEventCity.cityId atIndex:0];
    if ([WXWSystemInfoManager instance].currentLanguageCode == EN_TY) {
      [mArray insertObject:mEventCity.enName atIndex:1];
    } else {
      [mArray insertObject:mEventCity.cnName atIndex:1];
    }
    [self.DropDownValArray insertObject:mArray atIndex:i];
    [mArray release];
  }
}

#pragma mark - load Event list from web
- (void)stopAutoRefreshUserList {
  [timer invalidate];
}

#pragma mark - scrolling override
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if ([UIUtils shouldLoadOlderItems:scrollView
                    tableViewHeight:_tableView.contentSize.height + HEADER_HEIGHT
                         footerView:_footerRefreshView
                          reloading:_reloading]) {
    
    _reloading = YES;
    
    _shouldTriggerLoadLatestItems = YES;
    
    [self loadListData:TRIGGERED_BY_SCROLL forNew:NO];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  
  if (_userJustSwitched) {
    _userJustSwitched = NO;
    
    [self resetFooterRefreshViewStatus];
  }
  
}

#pragma mark - arrange tab after events loaded

- (void)checkTodayEventWhetherExisting {
  
  if ([WXWCoreDataUtils objectInMOC:_MOC
                         entityName:@"Event"
                          predicate:nil]) {
    
    // today event existing
    [_tabSwitchView selectButtonWithIndex:_eventCategory];
    
    [UIView animateWithDuration:FADE_IN_DURATION
                     animations:^{
                       _tableView.frame = _originalTableViewFrame;
                       _tableView.alpha = 1.0f;
                       _tabSwitchView.alpha = 1.0f;
                     }];
    
    _tableViewDisplayed = YES;
    
  } else {
    
    // today has no event, then switch to next tab automactially
    [_tabSwitchView selectButtonWithIndex:LOHHAS_EVENT_TY];
  }
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case MY_EVENT_TY:
    {
      
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self refreshTable];
        
        if (!_autoLoaded) {
          
          _keepEventsInMOC = YES;
          
          // if today has event, then display today's events default; otherwise, display the
          // "Academica and Lecture" events
          [self checkTodayEventWhetherExisting];
          
          _autoLoaded = YES;
          
        } else {
          
          if (!_tableViewDisplayed) {
            [UIView animateWithDuration:FADE_IN_DURATION
                             animations:^{
                               _tableView.frame = _originalTableViewFrame;
                               _tableView.alpha = 1.0f;
                               _tabSwitchView.alpha = 1.0f;
                             }];
            
            _tableViewDisplayed = YES;
          }
        }
        
        if (_tableViewDisplayed) {
          [self closeAsyncLoadingView];
        }
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
        [self closeAsyncLoadingView];
      }
      
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
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - clear list
- (void)clearList {
  
  if (!_keepEventsInMOC) {
    [self clearEvents];
  }
  _keepEventsInMOC = NO;
  
  self.fetchedRC = nil;
  [_tableView reloadData];
  
}

#pragma mark - switch date category for event
- (void)switchDateCateogry {
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - TapSwitchDelegate method
- (void)selectTapByIndex:(NSInteger)index {
  
  if (index == _eventCategory) {
    return;
  }
  
  _currentStartIndex = 0;
  
  _eventCategory = index;
  
  [self clearList];
  
  _tableView.frame = CGRectMake(0, HEADER_HEIGHT,
                                _tableView.frame.size.width,
                                _tableView.frame.size.height);
  
  [self switchDateCateogry];
  
  _userJustSwitched = YES;
}

@end