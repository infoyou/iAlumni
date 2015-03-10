//
//  ClubEventListViewController.m
//  iAlumni
//
//  Created by Adam on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ClubEventListViewController.h"
#import "EventListCell.h"
#import "EventDetailViewController.h"
#import "Event.h"

@interface ClubEventListViewController()
{
    int iSize;
}

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *requestParam;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, retain) NSString *selectedSponsorType;
@end

@implementation ClubEventListViewController

- (id)initWithMOC:(NSManagedObjectContext *)MOC {
  
  self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needRefreshHeaderView:NO needRefreshFooterView:YES needGoHome:NO];
  
  _selectedSponsorType = @"0";
  self.pageIndex = 0;
  
  [super clearPickerSelIndex2Init:2];
  
  return self;
}

- (void)dealloc {
  
  self.url = nil;
  [UIUtils closeActivityView];
  [super dealloc];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = EVENTLIST_TY;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  self.requestParam = [NSString stringWithFormat:@"<host_id>%@</host_id><host_type>%@</host_type><host_type_value>%@</host_type_value><host_sub_type_value>%@</host_sub_type_value><page_size>30</page_size><page>%d</page>", [AppManager instance].clubId, [AppManager instance].hostTypeValue, [AppManager instance].hostSupTypeValue, [AppManager instance].hostTypeValue, index];
  
  NSString *tmpStr = [NSString stringWithFormat:@"<page>%d</page>", self.pageIndex++];
  NSString *param = [self.requestParam stringByReplacingOccurrencesOfString:@"<page>0</page>" withString:tmpStr];
    
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  [connFacade fetchGets:url];
}

#pragma mark - core data
- (void)configureMOCFetchConditions {
  
  self.predicate = [NSPredicate predicateWithFormat:@"(hostId == %@)", [AppManager instance].clubId];
  self.entityName = @"Event";
  
  self.descriptors = [NSMutableArray array];
  
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder" ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
  
	NSIndexPath *selection = [_tableView indexPathForSelectedRow];
	if (selection) {
		[_tableView deselectRowAtIndexPath:selection animated:YES];
	}
	
	if (!_autoLoaded) {
		[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
	}
}

- (void)viewDidUnload {
  [super viewDidUnload];
}


#pragma mark - UITableViewDelegate, UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRC sections][section];
	iSize = [sectionInfo numberOfObjects];
	return [sectionInfo numberOfObjects] + 1;
}

- (void)updateTable:(NSArray *)indexPaths {
  [_tableView beginUpdates];
  [_tableView reloadRowsAtIndexPaths:indexPaths
                    withRowAnimation:UITableViewRowAnimationNone];
  [_tableView endUpdates];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  // Foot Cell
  if (indexPath.row == iSize) {
    return [self drawFooterCell];
	}
  
  // Event Cell
  static NSString *kEventCellIdentifier = @"EventCell";
  EventListCell *cell = (EventListCell *)[tableView dequeueReusableCellWithIdentifier:kEventCellIdentifier];
  if (nil == cell) {
    cell = [[[EventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventCellIdentifier] autorelease];
  }
  
  Event *event = [self.fetchedRC objectAtIndexPath:indexPath];
  [cell drawEvent:event];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return;
  }
  
  [AppManager instance].isClub2Event = YES;
  
  Event *event = [self.fetchedRC objectAtIndexPath:indexPath];
  [AppManager instance].eventId = [event.eventId stringValue];
  EventDetailViewController *detailVC = [[[EventDetailViewController alloc] initWithMOC:_MOC
                                                                                  event:event
                                          parentListVC:nil] autorelease];
  detailVC.title = LocaleStringForKey(NSEventDetailTitle, nil);
  [self.navigationController pushViewController:detailVC animated:YES];
  
  [super deselectCell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return EVENT_LIST_CELL_HEIGHT;
}

#pragma mark - load Event list from web

- (void)stopAutoRefreshUserList {
  [timer invalidate];
}

#pragma mark - reset refresh header/footer view status
- (void)resetHeaderRefreshViewStatus {
	_reloading = NO;
	[UIUtils dataSourceDidFinishLoadingNewData:_tableView
                                  headerView:_headerRefreshView];
}

- (void)resetFooterRefreshViewStatus {
	_reloading = NO;
	
	[UIUtils dataSourceDidFinishLoadingOldData:_tableView
                                  footerView:_footerRefreshView];
}

- (void)resetHeaderOrFooterViewStatus {
  
  if (_loadForNewItem) {
    [self resetHeaderRefreshViewStatus];
  } else {
    [self resetFooterRefreshViewStatus];
  }
}

- (void)resetUIElementsForConnectDoneOrFailed {
  switch (_currentLoadTriggerType) {
    case TRIGGERED_BY_AUTOLOAD:
      _autoLoaded = YES;
      break;
      
    case TRIGGERED_BY_SCROLL:
      [self resetHeaderOrFooterViewStatus];
      break;
      
    default:
      break;
  }
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{  
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  
  switch (contentType) {
    case EVENTLIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self refreshTable];
        
        _autoLoaded = YES;
        [self resetUIElementsForConnectDoneOrFailed];
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
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

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  [super connectFailed:error url:url contentType:contentType];
}

@end