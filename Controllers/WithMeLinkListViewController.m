//
//  WithMeLinkListViewController.m
//  iAlumni
//
//  Created by Adam on 12-12-1.
//
//

#import "WithMeLinkListViewController.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "AlumniWithMeLink.h"
#import "ListSectionView.h"
#import "ECAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "UIUtils.h"

#define SECTION_VIEW_HEIGHT     20.0f

@interface WithMeLinkListViewController ()

@end

@implementation WithMeLinkListViewController

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {

  [super loadListData:triggerType forNew:forNew];
  
  _currentType = LOAD_WITH_ME_LINK_TY;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<page_size>%@</page_size><page>%d</page>", ITEM_LOAD_COUNT, index];

  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];

  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"AlumniWithMeLink";
  
  self.sectionNameKeyPath = @"classificationType";

  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *elapsedDayDesc = [[[NSSortDescriptor alloc] initWithKey:@"sortKey" ascending:YES] autorelease];
  [self.descriptors addObject:elapsedDayDesc];
}

#pragma mark - lifecycle methods

- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  if (self) {

    DELETE_OBJS_FROM_MOC(_MOC, @"AlumniWithMeLink", nil);
    
    AlumniWithMeLink *link = (AlumniWithMeLink *)[NSEntityDescription insertNewObjectForEntityForName:@"AlumniWithMeLink"
                                                                               inManagedObjectContext:_MOC];
    link.linkId = @(1ll);
    link.linkName = @"一起参加了2012年10月13日的移动互联网协会成立大会";
    link.sortKey = @(1);
    link.classificationName = @"一起参加的活动";
    link.classificationType = @(1);
    
    link = (AlumniWithMeLink *)[NSEntityDescription insertNewObjectForEntityForName:@"AlumniWithMeLink"
                                                                               inManagedObjectContext:_MOC];
    link.linkId = @(2ll);
    link.linkName = @"一起参加了2012年5月10日的足球俱乐部活动";
    link.sortKey = @(2);
    link.classificationName = @"一起参加的聚会";
    link.classificationType = @(2);

    link = (AlumniWithMeLink *)[NSEntityDescription insertNewObjectForEntityForName:@"AlumniWithMeLink"
                                                             inManagedObjectContext:_MOC];
    link.linkId = @(3ll);
    link.linkName = @"一起参加了2012年11月3日的返校日活动";
    link.sortKey = @(3);
    link.classificationName = @"一起参加的聚会";
    link.classificationType = @(2);
    
    link = (AlumniWithMeLink *)[NSEntityDescription insertNewObjectForEntityForName:@"AlumniWithMeLink"
                                                             inManagedObjectContext:_MOC];
    link.linkId = @(4ll);
    link.linkName = @"一起参加了2012年11月30日的创业论坛";
    link.sortKey = @(4);
    link.classificationName = @"一起参加的学术讨论";
    link.classificationType = @(3);

    
    SAVE_MOC(_MOC);
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
    //[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    
    [self refreshTable];
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self.fetchedRC.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRC sections][section];
  if (section == [self.fetchedRC.sections count] - 1) {
    return [sectionInfo numberOfObjects] + 1;
  } else {
    return [sectionInfo numberOfObjects];
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.section == [self.fetchedRC.sections count] - 1) {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRC sections][indexPath.section];
    
    if (indexPath.row == [sectionInfo numberOfObjects]) {
      return [self drawFooterCell];
    }
  }
  
  AlumniWithMeLink *link = (AlumniWithMeLink *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  static NSString *cellIdentifier = @"linkCell";
  return (UITableViewCell *)[self configurePlainCell:cellIdentifier
                                               title:link.linkName
                                          badgeCount:0
                                             content:nil
                                           indexPath:indexPath
                                           clickable:NO
                                      selectionStyle:UITableViewCellSelectionStyleNone];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.section == [self.fetchedRC.sections count] - 1) {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRC sections][indexPath.section];
    
    if (indexPath.row == [sectionInfo numberOfObjects]) {
      return DEFAULT_CELL_HEIGHT;
    }
  }
  
  AlumniWithMeLink *link = (AlumniWithMeLink *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  return [self calculateCommonCellHeightWithTitle:link.linkName
                                          content:nil
                                        indexPath:indexPath
                                        clickable:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return SECTION_VIEW_HEIGHT;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
  
  id <NSFetchedResultsSectionInfo> sectionInfo = [_fetchedRC sections][section];
  
  NSArray *linkList = [sectionInfo objects];
  NSString *name = nil;
  if (linkList.count > 0) {
    AlumniWithMeLink *link = (AlumniWithMeLink *)linkList.lastObject;
    name = link.classificationName;
  }
  
  return [[[ListSectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SECTION_VIEW_HEIGHT)
                                           title:name
                                       titleFont:BOLD_FONT(14)] autorelease];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
            blockCurrentView:NO];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  if ([XMLParser parserResponseXml:result
                              type:contentType
                               MOC:_MOC
                 connectorDelegate:self
                               url:url]) {
    [self refreshTable];
    _autoLoaded = YES;
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
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
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSActionFaildMsg, nil);
  }
    
  [super connectFailed:error url:url contentType:contentType];
}

@end
