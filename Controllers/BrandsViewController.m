//
//  BrandsViewController.m
//  iAlumni
//
//  Created by Adam on 12-8-20.
//
//

#import "BrandsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "BrandCell.h"
#import "ECAsyncConnectorFacade.h"
#import "CommonUtils.h"
#import "Brand.h"
#import "VenueListViewController.h"
#import "BrandDetailViewController.h"
#import "AppManager.h"
#import "XMLParser.h"

#define CELL_HEIGHT   80.0f

#define LIMITED_WIDTH 220.0f


#define COUPON_INFO_HEIGHT    15.0f

@interface BrandsViewController ()

@end

@implementation BrandsViewController

#pragma mark - switch nearby venues UI
- (void)searchNearby:(id)sender {
  VenueListViewController *venueListVC = [[[VenueListViewController alloc] initNearbyVenuesWithMOC:_MOC
                                                                                 locationRefreshed:_currentLocationIsLatest] autorelease];
  venueListVC.title = LocaleStringForKey(NSNearbyVenuesTitle, nil);
  [self.navigationController pushViewController:venueListVC animated:YES];
}

#pragma mar - load data
- (void)loadBrands {
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:LOAD_BRANDS_TY] autorelease];
  
  NSString *param = [NSString stringWithFormat:@"<start_index>0</start_index><count>1000</count><category_id></category_id><longitude>%f</longitude><latitude>%f</latitude>", [AppManager instance].longitude, [AppManager instance].latitude];
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_BRANDS_TY];
  (self.connDic)[url] = connFacade;
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)configureMOCFetchConditions {
  
  self.entityName = @"Brand";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"brandId" ascending:YES] autorelease];
  [self.descriptors addObject:sortDesc];
}

#pragma mark - lifecycle methods

- (id)initWithMOC:(NSManagedObjectContext *)MOC {
  self = [super initWithMOC:MOC
                     holder:((iAlumniAppDelegate*)APP_DELEGATE)
           backToHomeAction:@selector(backToHomepage:)
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 needGoHome:NO];
  if (self) {
    DELETE_OBJS_FROM_MOC(_MOC, @"Brand", nil);
  }
  return self;
}

- (void)dealloc {
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Brand", nil);
  
  DELETE_OBJS_FROM_MOC(_MOC, @"ServiceItem", nil);
  
  [super dealloc];
}

- (void)initNavigationItem {
  
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSNearbyVenuesTitle, nil)
                            target:self
                            action:@selector(searchNearby:)];
  
  self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  [self initNavigationItem];
  
  [self forceGetLocation];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methoes
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
    
    _autoLoaded = YES;
    
    [self refreshTable];
  }
  
  // should be called at end of method to clear connFacade instance
  [super connectDone:result url:url contentType:contentType closeAsyncLoadingView:NO];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
  // should be called at end of method to clear connFacade instance
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
    
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSLoadBrandsFailedMsg, nil);
  }
  
  // should be called at end of method to clear connFacade instance
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _fetchedRC.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  static NSString *kCellIdentifier = @"BrandCell";
  
  BrandCell *cell = (BrandCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[BrandCell alloc] initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:kCellIdentifier] autorelease];
  }
  
  Brand *brand = (Brand *)[_fetchedRC objectAtIndexPath:indexPath];
  
  [cell drawCell:brand];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  Brand *brand = (Brand *)[_fetchedRC objectAtIndexPath:indexPath];
  
  CGSize size = [brand.name sizeWithFont:BOLD_FONT(15)
                            constrainedToSize:CGSizeMake(LIMITED_WIDTH, CGFLOAT_MAX)
                                lineBreakMode:NSLineBreakByWordWrapping];
  
  CGFloat height = size.height + MARGIN * 2;

  size = [brand.tags sizeWithFont:FONT(12)
                constrainedToSize:CGSizeMake(LIMITED_WIDTH, CGFLOAT_MAX)
                    lineBreakMode:NSLineBreakByWordWrapping];

  height += MARGIN + size.height;
  
  if (brand.couponInfo && brand.couponInfo.length > 0) {
    height += COUPON_INFO_HEIGHT + MARGIN * 2;
  } else {
    height += MARGIN;
  }
  
  if (height < CELL_HEIGHT) {
    height = CELL_HEIGHT;
  }
  
  return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  Brand *brand = (Brand *)[_fetchedRC objectAtIndexPath:indexPath];
  
  BrandDetailViewController *brandDetailVC = [[[BrandDetailViewController alloc] initWithMOC:_MOC
                                                                                       brand:brand
                                                                           locationRefreshed:_currentLocationIsLatest] autorelease];
  brandDetailVC.title = LocaleStringForKey(NSDetailsTitle, nil);
  [self.navigationController pushViewController:brandDetailVC animated:YES];
}

#pragma mark - ECLocationFetcherDelegate methods

- (void)locationManagerDidReceiveLocation:(WXWLocationManager *)manager
                                 location:(CLLocation *)location {
  
  [super locationManagerDidReceiveLocation:manager
                                  location:location];
  
  [self loadBrands];
  
  self.navigationItem.rightBarButtonItem.enabled = YES;
  
  _currentLocationIsLatest = YES;
  
  [self closeAsyncLoadingView];
}

- (void)locationManagerDidFail:(WXWLocationManager *)manager {
  [super locationManagerDidFail:manager];
  
  [self closeAsyncLoadingView];
}

- (void)locationManagerCancelled:(WXWLocationManager *)manager {
  [super locationManagerCancelled:manager];
  
}

@end
