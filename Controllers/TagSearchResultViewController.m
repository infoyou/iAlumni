//
//  TagSearchResultViewController.m
//  iAlumni
//
//  Created by Adam on 13-5-31.
//
//

#import "TagSearchResultViewController.h"
#import "SupplyDemandCell.h"
#import "Post.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "UIUtils.h"


#define CELL_HEIGHT   88.0f

@interface TagSearchResultViewController ()
@property (nonatomic, retain) NSNumber *tagId;
@end

@implementation TagSearchResultViewController

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType
               forNew:forNew];
  
  _currentType = LOAD_SUPPLY_DEMAND_ITEM_TY;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<page_size>%@</page_size><sort_type>%d</sort_type><post_type>%d</post_type><page>%d</page><tag_id>%@</tag_id><latitude></latitude><longitude></longitude>",
                     ITEM_LOAD_COUNT,
                     SORT_BY_ID_TY,
                     SUPPLY_DEMAND_COMBINE_TY,
                     index,
                     self.tagId];
  
  NSMutableString *requestParam = [NSMutableString stringWithString:param];
  
  NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade fetchNews:url];
  
}

- (void)configureMOCFetchConditions {
  self.entityName = @"Post";
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
  [self.descriptors addObject:descriptor];
}

#pragma mark - lifecycle methods

- (id)initWithMOC:(NSManagedObjectContext *)MOC tagId:(NSNumber *)tagId {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  if (self) {
    
    self.tagId = tagId;
    
    DELETE_OBJS_FROM_MOC(MOC, @"Post", nil);
  }
  return self;
}

- (void)dealloc {

  self.tagId = nil;
  
  [super dealloc];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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

#pragma mark - UITableViewDelegate, UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  
  return self.fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)drawItemCellWithIndexPath:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"itemCell";
  
  SupplyDemandCell *cell = (SupplyDemandCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[SupplyDemandCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:kCellIdentifier
                                                MOC:_MOC] autorelease];
  }
  
  Post *item = self.fetchedRC.fetchedObjects[indexPath.row];
  if (item) {
    [cell drawCellWithItem:item];
  }
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return [self drawFooterCell];
  } else {
    
    return [self drawItemCellWithIndexPath:indexPath];
    
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  return CELL_HEIGHT;
}

#pragma mark - ECConnectorDelegate methoes
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  BOOL blockCurrentView = NO;
  if (_userFirstUseThisList) {
    blockCurrentView = YES;
  } else {
    blockCurrentView = NO;
  }
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
            blockCurrentView:blockCurrentView];
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  if ([XMLParser parserResponseXml:result
                              type:contentType
                               MOC:_MOC
                 connectorDelegate:self
                               url:url]) {
    
    [self refreshTable];
    
  } else {
    [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                           alternativeMsg:LocaleStringForKey(NSLoadSupplyDemandFailedMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
  
  _autoLoaded = YES;
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSLoadFeedFailedMsg, nil);
  }
  
  if (_userFirstUseThisList) {
    _userFirstUseThisList = NO;
  }
  
  [super connectFailed:error url:url contentType:contentType];
}

@end
