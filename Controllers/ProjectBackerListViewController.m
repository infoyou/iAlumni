//
//  ProjectBackerListViewController.m
//  iAlumni
//
//  Created by Adam on 13-3-7.
//
//

#import "ProjectBackerListViewController.h"
#import "AlumniProfileViewController.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "UIUtils.h"

@interface ProjectBackerListViewController ()

@end

@implementation ProjectBackerListViewController

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType
              forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = LOAD_PROJECT_BACKERS_TY;
  
  NSInteger startIndex = 0;
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<page>%d</page><page_size>100</page_size><event_id>%lld</event_id>", startIndex, _eventId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"Alumni";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *namePinyinDesc = [[[NSSortDescriptor alloc] initWithKey:@"orderId"
                                                                  ascending:YES] autorelease];
  [self.descriptors addObject:namePinyinDesc];
  
}

#pragma mark - lifecycle methods

- (id)initWithMOC:(NSManagedObjectContext *)MOC eventId:(long long)eventId {
  self = [super initResettedWithMOC:MOC];
  if (self) {
    _eventId = eventId;
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - override methods
- (void)showProfile:(Alumni *)alumni {
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initHideLocationWithMOC:_MOC
                                                                                                  alumni:alumni
                                                                                                userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}


#pragma mark - ECConnectorDelegate methods
- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  if ([XMLParser parserResponseXml:result
                              type:contentType
                               MOC:_MOC
                 connectorDelegate:self
                               url:url]) {
    _autoLoaded = YES;
    
    [self refreshTable];
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
    
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSFetchAlumnusFailedMsg, nil);
  }
  
  [super connectFailed:error
                   url:url
           contentType:contentType];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.fetchedRC.fetchedObjects.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 0;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
  return nil;
}


@end
