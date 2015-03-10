//
//  RecommendedItemListViewController.m
//  ExpatCircle
//
//  Created by Adam on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RecommendedItemListViewController.h"
#import "RecommendedItem.h"
#import "ServiceItem.h"
#import "RecommendedItemCell.h"
#import "ECImageBrowseViewController.h"
#import "WXWNavigationController.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "CoreDataUtils.h"
#import "HttpUtils.h"
#import "RecommendedItemDetailViewController.h"

#define ITEM_CELL_HEIGHT   140.0f

#define ITEM_LOAD_MAX_COUNT @"1000"

@implementation RecommendedItemListViewController

#pragma mark - load photo objects
- (void)loadPhoto:(LoadTriggerType)triggerType forNewPhoto:(BOOL)forNewPhoto {
  _currentLoadTriggerType = triggerType;
  

  NSInteger startIndex = 0;
  if (!forNewPhoto) {
    startIndex = ++_currentStartIndex;
  }

  NSString *param = [NSString stringWithFormat:@"<service_id>%lld</service_id><start_index>%d</start_index><count>%@</count>",
                     _serviceItemId, startIndex, ITEM_LOAD_COUNT];

  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_RECOMMENDED_ITEM_TY];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self 
                                                                  interactionContentType:LOAD_RECOMMENDED_ITEM_TY] autorelease];
  (self.connDic)[url] = connFacade;
  [connFacade fetchRecommendedItems:url];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
    serviceItemId:(long long)serviceItemId {
  
  self = [super initWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction 
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    _serviceItemId = serviceItemId;
  }
  
  return self;
}

- (void)dealloc {
    
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];  
  
  self.view.backgroundColor = [[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]] autorelease];
    
   
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded) {
    [self loadPhoto:TRIGGERED_BY_AUTOLOAD forNewPhoto:YES];
  }
}

- (void)viewDidUnload {  
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - override method
- (void)configureMOCFetchConditions {
  self.entityName = @"RecommendedItem";
  self.predicate = [NSPredicate predicateWithFormat:@"(serviceItemId == %lld)", _serviceItemId];
  
  self.descriptors = [NSMutableArray array];  
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"enName"
                                                              ascending:YES] autorelease];
  [self.descriptors addObject:descriptor];
}

#pragma mark - open detail
- (void)openItemDetail:(RecommendedItem *)item {
  RecommendedItemDetailViewController *detailVC = [[[RecommendedItemDetailViewController alloc] initWithMOC:_MOC 
                                                                                                     holder:_holder 
                                                                                           backToHomeAction:_backToHomeAction 
                                                                                                       item:item] autorelease];
  detailVC.title = item.cnName;
  [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - UITableViewDataSource and UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // NSInteger division rounding could be as following:
  // If your ints are A and B and you want to have ceil(A/B) just calculate (A+B-1)/B. 

  _rowCount = (_fetchedRC.fetchedObjects.count + ALBUM_ROW_PHOTO_COUNT - 1)/ALBUM_ROW_PHOTO_COUNT;
  return _rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  NSInteger subLength = _fetchedRC.fetchedObjects.count - indexPath.row * ALBUM_ROW_PHOTO_COUNT;
  NSInteger rangeLength = (subLength >= ALBUM_ROW_PHOTO_COUNT ? 
                           ALBUM_ROW_PHOTO_COUNT : 
                           subLength);
  NSRange range = {indexPath.row * ALBUM_ROW_PHOTO_COUNT, rangeLength};
  NSArray *objs = [_fetchedRC.fetchedObjects subarrayWithRange:range];
  
  static NSString *cellIdentifier = @"recommendedItemCell";
  RecommendedItemCell *cell = (RecommendedItemCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[RecommendedItemCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:cellIdentifier
                                imageDisplayerDelegate:self 
                                                   MOC:_MOC
                                        itemListHolder:self
                                      openDetailAction:@selector(openItemDetail:)] autorelease];
  }
  
  [cell drawRecommendItemCell:objs];

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return ITEM_CELL_HEIGHT;
}

#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result 
                url:(NSString *)url 
        contentType:(NSInteger)contentType {
  
  if ([XMLParser parserResponseXml:result
                              type:LOAD_RECOMMENDED_ITEM_TY
                               MOC:_MOC
                 connectorDelegate:self
                               url:url]) {
    [self refreshTable];            
    
  } else {
    
    [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                           alternativeMsg:LocaleStringForKey(NSLoadPhotoFailedMsg, nil) 
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
  
  _autoLoaded = YES;
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSLoadPhotoFailedMsg, nil);
  }
  
  _autoLoaded = YES;
  
  [super connectFailed:error url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

@end
