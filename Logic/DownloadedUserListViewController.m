//
//  DownloadedUserListViewController.m
//  iAlumni
//
//  Created by Adam on 13-8-22.
//
//

#import "DownloadedUserListViewController.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "UIUtils.h"

@interface DownloadedUserListViewController ()
@property (nonatomic, copy) NSString *itemId;
@end

@implementation DownloadedUserListViewController

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType
              forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = GET_DOWNLOADED_USER_TY;
  
  NSInteger index = 1;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<itemId>%@</itemId><page>%d</page><page_size>30</page_size>", self.itemId, index];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"Alumni";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *namePinyinDesc = [[[NSSortDescriptor alloc] initWithKey:@"orderId"
                                                                  ascending:YES] autorelease];
  [self.descriptors addObject:namePinyinDesc];
}

#pragma mark - life cycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC itemId:(NSString *)itemId
{
  self = [super initResettedWithMOC:MOC];
  if (self) {
    self.itemId = itemId;
  }
  return self;
}

- (void)dealloc {
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Alumni", nil);
  
  self.itemId = nil;
  
  [super dealloc];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
  
  if (!_autoLoaded) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methods

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType {
  
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
