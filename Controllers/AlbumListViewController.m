//
//  AlbumListViewController.m
//  ExpatCircle
//
//  Created by Adam on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AlbumListViewController.h"
#import "AlbumPhoto.h"
#import "AlbumCell.h"
#import "ECImageBrowseViewController.h"
#import "WXWNavigationController.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "CoreDataUtils.h"
#import "HttpUtils.h"

#define ALBUM_CELL_HEIGHT   105.0f

@implementation AlbumListViewController

#pragma mark - load photo objects
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {

  [super loadListData:triggerType forNew:forNew];

  NSString *url = nil;
  NSInteger startIndex = 0;
  
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
  NSString *param = nil;
  switch (_contentType) {
    case LOAD_SERVICE_ITEM_ALBUM_PHOTO_TY:
    {
      
      param = [NSString stringWithFormat:@"<service_id>%lld</service_id><start_index>%d</start_index><count>%@</count>", _itemId, startIndex,ITEM_LOAD_COUNT];
      
      url = [CommonUtils geneUrl:param itemType:_contentType];
      break;      
    }
      /*
    case LOAD_SERVICE_PROVIDER_ALBUM_PHOTO_TY:
    {
     
      requestUrl = [HttpUtils assembleFetchServiceProviderAlbumUrl:LLINT_TO_STRING(_itemId)
                                                        startIndex:INT_TO_STRING(startIndex)
                                                            counts:ITEM_LOAD_COUNT];
      
      url = [CommonUtils assembleXmlRequestUrl:@"service_provider_photo_list" param:requestUrl];
      break;
    }
     */ 
    default:
      break;
  }
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_contentType];
  [connFacade fetchGets:url];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
           itemId:(long long)itemId 
      contentType:(NSInteger)contentType {
  self = [super initWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction 
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    _itemId = itemId;
    
    _contentType = contentType;
  }
  
  return self;
}

- (void)dealloc {
  
  NSMutableArray *sortDescs = [NSMutableArray array];
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" 
                                                              ascending:NO] autorelease];
  [sortDescs addObject:descriptor];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(itemId == %lld)", _itemId];
  
  NSArray *photos = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                            entityName:@"AlbumPhoto"
                                             predicate:predicate
                                             sortDescs:sortDescs];
  if (photos.count > ALBUM_ROW_PHOTO_COUNT) {
    
    NSRange range = {ALBUM_ROW_PHOTO_COUNT, photos.count - ALBUM_ROW_PHOTO_COUNT};
    [WXWCoreDataUtils deleteEntitiesFromMOC:_MOC
                                entities:[photos subarrayWithRange:range]];
  }
  
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
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
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
    
  self.entityName = @"AlbumPhoto";
  self.predicate = [NSPredicate predicateWithFormat:@"(itemId == %lld)", _itemId];
  
  self.descriptors = [NSMutableArray array];  
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
  [self.descriptors addObject:descriptor];
}

#pragma mark - ECClickableElementDelegate methods 
- (void)openImageUrl:(NSString *)imageUrl imageCaption:(NSString *)imageCaption {
  if (imageUrl && [imageUrl length] > 0) {
    
    ECImageBrowseViewController *imgBrowseVC = [[ECImageBrowseViewController alloc] initWithImageUrl:imageUrl 
                                                                                        imageCaption:imageCaption];
    WXWNavigationController *imgBrowseNav = [[WXWNavigationController alloc] initWithRootViewController:imgBrowseVC];
    imgBrowseVC.title = LocaleStringForKey(NSBigPicTitle, nil);
    [self.navigationController presentModalViewController:imgBrowseNav animated:YES];
    
    RELEASE_OBJ(imgBrowseVC)
    RELEASE_OBJ(imgBrowseNav);
  }
}

#pragma mark - UITableViewDataSource and UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // NSInteger division rounding could be as following:
  // If your ints are A and B and you want to have ceil(A/B) just calculate (A+B-1)/B. 
  //NSInteger count = (_fetchedRC.fetchedObjects.count + ALBUM_ROW_PHOTO_COUNT - 1)/ALBUM_ROW_PHOTO_COUNT;
  //return count + 1;
  _rowCount = (_fetchedRC.fetchedObjects.count + ALBUM_ROW_PHOTO_COUNT - 1)/ALBUM_ROW_PHOTO_COUNT;
  return _rowCount + 1;
}

- (void)checkAndSetCurrentOldestPhoto:(NSIndexPath *)indexPath {
	// record the oldest post time    
  //NSInteger count =  (_fetchedRC.fetchedObjects.count + ALBUM_ROW_PHOTO_COUNT - 1)/ALBUM_ROW_PHOTO_COUNT;
  if (indexPath.row == /*count*/_rowCount - 1) {       
      _currentStartIndex = _fetchedRC.fetchedObjects.count;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == _rowCount/*(_fetchedRC.fetchedObjects.count + ALBUM_ROW_PHOTO_COUNT - 1)/ALBUM_ROW_PHOTO_COUNT*/) {  
    return [self drawFooterCell];
  }
  
  //[self checkAndSetCurrentOldestPhoto:indexPath];
  
  NSInteger subLength = _fetchedRC.fetchedObjects.count - indexPath.row * ALBUM_ROW_PHOTO_COUNT;
  NSInteger rangeLength = (subLength >= ALBUM_ROW_PHOTO_COUNT ? ALBUM_ROW_PHOTO_COUNT : subLength);
  NSRange range = {indexPath.row * ALBUM_ROW_PHOTO_COUNT, rangeLength};
  NSArray *objs = [_fetchedRC.fetchedObjects subarrayWithRange:range];
  
  static NSString *cellIdentifier = @"albumCell";
  AlbumCell *cell = (AlbumCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[AlbumCell alloc] initWithStyle:UITableViewCellStyleDefault 
                             reuseIdentifier:cellIdentifier
                      imageDisplayerDelegate:self 
                      imageClickableDelegate:self 
                                         MOC:_MOC] autorelease];
  }
  [cell drawAlbumCell:objs];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return ALBUM_CELL_HEIGHT;
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
                              type:contentType
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
  
  //[self resetUIElementsForConnectDoneOrFailed];
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSLoadPhotoFailedMsg, nil);
  }
    
  _autoLoaded = YES;
  
  //[self resetUIElementsForConnectDoneOrFailed];
  [super connectFailed:error url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

@end
