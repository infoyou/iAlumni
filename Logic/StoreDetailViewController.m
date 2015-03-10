//
//  StoreDetailViewController.m
//  iAlumni
//
//  Created by Adam on 13-8-20.
//
//

#import "StoreDetailViewController.h"
#import "Store.h"
#import "StoreBaseInfoCell.h"
#import "XMLParser.h"
#import "CommonUtils.h"
#import "StoreMapCell.h"
#import "MapViewController.h"
#import "WXWNavigationController.h"
#import "StorePhotoCell.h"

enum {
  BASE_INFO_CELL,
  MAP_CELL,
  PHOTO_CELL,
};

#define CELL_COUNT    3

#define CELL_INNER_MARGIN     8.0f

#define STORE_IMG_SIDE_LEN    56.0f

#define MAP_CELL_HEIGHT       140.0f + WELFARE_CELL_MARGIN * 2

#define PHOTO_CELL_HEIGHT     185.0f + WELFARE_CELL_MARGIN

@interface StoreDetailViewController ()

@end

@implementation StoreDetailViewController

#pragma mark - user action
- (void)callSupport:(id)sender {
  
}

#pragma mark - load data 
- (void)loadStoreDetail {
  _currentType = LOAD_STORE_DETAIL_TY;
  
  NSString *param = STR_FORMAT(@"<storeId>%@</storeId>", _store.storeId);
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *conn = [self setupAsyncConnectorForUrl:url contentType:_currentType];
  
  [conn asyncGet:url showAlertMsg:YES];

}

#pragma mark - life cycle methods
- (id)initWithStore:(Store *)store MOC:(NSManagedObjectContext *)MOC
{
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                                          holder:nil
                                backToHomeAction:nil
                           needRefreshHeaderView:NO
                           needRefreshFooterView:NO
                                      tableStyle:UITableViewStylePlain
                                      needGoHome:NO];
  if (self) {
    _store = store;
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)setTableViewProperties {
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  _tableView.alpha = 0.0f;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	
  [self setTableViewProperties];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_autoLoaded) {
    [self loadStoreDetail];
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
    case LOAD_STORE_DETAIL_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        _store = (Store *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                        entityName:@"Store"
                                                         predicate:[NSPredicate predicateWithFormat:@"(storeId == %@)", _store.storeId]];
        
        _autoLoaded = YES;
        [_tableView reloadData];
        
        _tableView.alpha = 1.0f;
      }
      break;
    }
    default:
      break;
  }
  
  [super connectDone:result
                 url:url
         contentType:contentType];
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
  if (_store.imageList.allObjects.count == 0) {
    return 2;
  } else {
    return 3;
  }
}

- (StoreBaseInfoCell *)drawBaseInfoCell {
  static NSString *kCellIdentifier = @"baseInfoCell";
  
  StoreBaseInfoCell *cell = (StoreBaseInfoCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[StoreBaseInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:kCellIdentifier
                              imageDisplayerDelegate:self
                                                 MOC:_MOC
                                            detailVC:self
                                   callSupportAction:@selector(callSupport:)] autorelease];
  }
  
  [cell drawCellWithStore:_store height:[self baseInfoCellHeight] - WELFARE_CELL_MARGIN];
  
  return cell;
}

- (StoreMapCell *)drawMapCell {
  static NSString *kCellIdentifier = @"mapCell";
  StoreMapCell *cell = (StoreMapCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[StoreMapCell alloc] initWithStyle:UITableViewCellStyleDefault
                                reuseIdentifier:kCellIdentifier] autorelease];
  }
  
  [cell drawCellWithStore:_store];
  
  return cell;
}

- (StorePhotoCell *)drawPhotoCell {
  static NSString *kCellIdentifier = @"photoCell";
  StorePhotoCell *cell = (StorePhotoCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[StorePhotoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:kCellIdentifier
                           imageDisplayerDelegate:self
                                              MOC:_MOC] autorelease];
  }
  
  [cell updateImageList:_store.imageList.allObjects];
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.row) {
    case BASE_INFO_CELL:
      return [self drawBaseInfoCell];
      
    case MAP_CELL:
      return [self drawMapCell];
      
    case PHOTO_CELL:
      return [self drawPhotoCell];
      
    default:
      return nil;
  }
}

- (CGFloat)baseInfoCellHeight {
  
  CGFloat height = CELL_INNER_MARGIN;
  
  CGFloat textLimitedWidth = self.view.frame.size.width - WELFARE_CELL_MARGIN * 2 - CELL_INNER_MARGIN * 2 - STORE_IMG_SIDE_LEN - CELL_INNER_MARGIN * 2;

  CGSize size = [_store.storeName sizeWithFont:BOLD_FONT(20)
                             constrainedToSize:CGSizeMake(textLimitedWidth, CGFLOAT_MAX)];
  height += size.height + MARGIN;
  
  height += 30;
  
  CGFloat imagePhotoBottonY = CELL_INNER_MARGIN + STORE_IMG_SIDE_LEN;
  CGFloat telBottonY = height;
  
  height = imagePhotoBottonY > telBottonY ? imagePhotoBottonY : telBottonY;

  height += CELL_INNER_MARGIN * 2;
  
  textLimitedWidth = self.view.frame.size.width - WELFARE_CELL_MARGIN * 2 - CELL_INNER_MARGIN * 2;
  size = [STR_FORMAT(@"%@:%@", LocaleStringForKey(NSAddressTitle, nil), _store.address) sizeWithFont:BOLD_FONT(13)
                                                                                   constrainedToSize:CGSizeMake(textLimitedWidth, CGFLOAT_MAX)];
  height += size.height + CELL_INNER_MARGIN;
  height += WELFARE_CELL_MARGIN;
  
  return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

  switch (indexPath.row) {
    case BASE_INFO_CELL:
      return [self baseInfoCellHeight];
      
    case MAP_CELL:
      return MAP_CELL_HEIGHT;
      
    case PHOTO_CELL:
      return PHOTO_CELL_HEIGHT;
      
    default:
      return 0;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case MAP_CELL:
    {
      MapViewController *mapVC = [[[MapViewController alloc] initWithLatitude:_store.latitude.doubleValue
                                                                    longitude:_store.longitude.doubleValue allowLaunchGoogleMap:YES] autorelease];
      WXWNavigationController *nav = [[[WXWNavigationController alloc] initWithRootViewController:mapVC] autorelease];
      [self presentModalViewController:nav animated:YES];
      break;
    }
      
    default:
      break;
  }
}

@end
