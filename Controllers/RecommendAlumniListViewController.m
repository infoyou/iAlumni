//
//  RecommendAlumniListViewController.m
//  iAlumni
//
//  Created by Adam on 12-12-5.
//
//

#import "RecommendAlumniListViewController.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "AppManager.h"
#import "XMLParser.h"
#import "UIUtils.h"

@interface RecommendAlumniListViewController ()
@property (nonatomic, copy) NSString *alumniPersonId;
@end

@implementation RecommendAlumniListViewController


#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType
              forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = LOAD_ALL_KNOWN_ALUMNUS_TY;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<page_size>100</page_size><page>%d</page><target_user_id>%@</target_user_id>", index, self.alumniPersonId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"RecommendAlumni";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *namePinyinDesc = [[[NSSortDescriptor alloc] initWithKey:@"orderId"
                                                                  ascending:YES] autorelease];
  [self.descriptors addObject:namePinyinDesc];
  
  self.predicate = [NSPredicate predicateWithFormat:@"(ANY links.startAlumniId == %@) AND (ANY links.endAlumniId == %@)", [AppManager instance].personId, self.alumniPersonId];
}

#pragma mark - lifecycle methods

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         listType:(UserListType)listType
   alumniPersonId:(NSString *)alumniPersonId {
  
  self = [super initWithMOC:MOC];
  if (self) {
    self.alumniPersonId = alumniPersonId;
    
  }
  return self;
}

- (void)dealloc {
  
  self.alumniPersonId = nil;
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methods

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  
  if ([XMLParser parserRecommendAlumnusForEndAlumniId:self.alumniPersonId.longLongValue
                                              xmlData:result
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
