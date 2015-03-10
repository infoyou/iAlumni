//
//  StartupListViewController.m
//  iAlumni
//
//  Created by Adam on 13-2-28.
//
//

#import "StartupListViewController.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "StartupProjectCell.h"
#import "StartupProjectViewController.h"

@interface StartupListViewController ()

@end

@implementation StartupListViewController

#pragma mark - load data

- (void)configureMOCFetchConditions {
  self.entityName = @"Event";
  self.descriptors = [NSMutableArray array];
  self.predicate = [NSPredicate predicateWithFormat:@"screenType == %d", STARTUP_PROJECT_TY]; 
  
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder" ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];

  _currentType = EVENTLIST_TY;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  NSMutableString *requestParam = [NSMutableString stringWithFormat:@"<page_size>20</page_size><page>%d</page><longitude>%f</longitude><latitude>%f</latitude><screen_type>%d</screen_type>", index, [AppManager instance].longitude, [AppManager instance].latitude, STARTUP_PROJECT_TY];

  NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade fetchGets:url];
}

#pragma mark - lifecycle methods

- (void)clearEvents {
  DELETE_OBJS_FROM_MOC(_MOC, @"Event", nil);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC {
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  if (self) {
    [self clearEvents];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_autoLoaded) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case EVENTLIST_TY:
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
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        
        [self closeAsyncLoadingView];
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

#pragma mark - UITableViewDelegate, UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  
  return self.fetchedRC.fetchedObjects.count + 1;
}

- (void)updateTable:(NSArray *)indexPaths {
  [_tableView beginUpdates];
  [_tableView reloadRowsAtIndexPaths:indexPaths
                    withRowAnimation:UITableViewRowAnimationNone];
  [_tableView endUpdates];
}

- (StartupProjectCell *)drawLatest:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {

  NSString *kEventCellIdentifier = @"EventCell";
  StartupProjectCell *cell = (StartupProjectCell *)[tableView dequeueReusableCellWithIdentifier:kEventCellIdentifier];
  if (nil == cell) {
    cell = [[[StartupProjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventCellIdentifier] autorelease];
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
  StartupProjectViewController *detailVC = [[[StartupProjectViewController alloc] initWithMOC:_MOC
                                                                                  event:event] autorelease];
  detailVC.title = LocaleStringForKey(NSStartupProjectTitle, nil);
  
  [self.navigationController pushViewController:detailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return EVENT_LIST_CELL_HEIGHT;
}

@end
