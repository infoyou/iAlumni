//
//  FriendCategoryViewController.m
//  iAlumni
//
//  Created by Adam on 13-5-22.
//
//

#import "FriendCategoryViewController.h"
#import "AppManager.h"
#import "WXWNumberBadge.h"
#import "KnownAlumniListViewController.h"
#import "AttractiveAlumniListViewController.h"
#import "UserListViewController.h"
#import "WXWLabel.h"
#import "ECColorfulButton.h"
#import "ShakeForNameCardViewController.h"
#import "CommonUtils.h"
#import "XMLParser.h"

enum {
  KNOWN_ALUMNUS_SECTION,
  WANT_KNOW_ALUMNUS_SECTION,
};

#define COUNT         2

#define CELL_HEIGHT   72.0f

#define BADGE_HEIGHT  16.0f

#define BIZCARD_CELL_CONTENT_HEIGHT 100.0f

@interface FriendCategoryViewController ()
@property (nonatomic, retain) WXWNumberBadge *unreadDMCountBadge;
@end

@implementation FriendCategoryViewController

#pragma mark - user action
- (void)openExchangeBizCard:(id)sender {
  ShakeForNameCardViewController *exchangeNameCardVC = [[[ShakeForNameCardViewController alloc] initWithMOC:_MOC] autorelease];
  exchangeNameCardVC.title = LocaleStringForKey(NSShakeNameCardTitle, nil);

  [self.navigationController pushViewController:exchangeNameCardVC animated:YES];
}

#pragma mark - load data
- (void)loadConnectedAlumnusCount {
  NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:LOAD_CONNECTED_ALUMNUS_COUNT_TY];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:LOAD_CONNECTED_ALUMNUS_COUNT_TY];
  [connFacade asyncGet:url showAlertMsg:YES];
}


#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                                          holder:nil
                                backToHomeAction:nil
                           needRefreshHeaderView:NO
                           needRefreshFooterView:NO
                                      tableStyle:UITableViewStyleGrouped
                                      needGoHome:NO];
  if (self) {

  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)addTableViewHeader {
  
  UIView *tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, BIZCARD_CELL_CONTENT_HEIGHT + MARGIN * 4)] autorelease];
  
  ECColorfulButton *btn = [[[ECColorfulButton alloc] initPlainButtonWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2, SCREEN_WIDTH - MARGIN * 4, BIZCARD_CELL_CONTENT_HEIGHT)
                                                                       target:self
                                                                       action:@selector(openExchangeBizCard:)
                                                                        title:LocaleStringForKey(NSShakeExchangeNameCardTitle, nil)
                                                                    tintColor:YELLOW_BLOCK_COLOR
                                                                    titleFont:BOLD_FONT(18)
                                                                  roundedType:NO_ROUNDED] autorelease];
  
  [btn setImage:[UIImage imageNamed:@"whiteShakeNamecard.png"]
       forState:UIControlStateNormal];
  
  btn.imageEdgeInsets = UIEdgeInsetsMake(-20, 96, 0, 5);
  btn.titleEdgeInsets = UIEdgeInsetsMake(70, -82, 0, 0);
  
  [tableHeaderView addSubview:btn];

  _tableView.tableHeaderView = tableHeaderView;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

  //[self addTableViewHeader];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_autoLoaded) {
    [self loadConnectedAlumnusCount];
  } 
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return COUNT;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  
  switch (indexPath.section) {      
    
    case KNOWN_ALUMNUS_SECTION:
      return [self configureWithTitleImageCell:@"knownAlumnusCell"
                                         title:LocaleStringForKey(NSKnownAlumnusTitle, nil)
                                    badgeCount:[AppManager instance].knownAlumnusCount.intValue
                                       content:nil
                                         image:[UIImage imageNamed:@"knownAlumni.png"]
                                     indexPath:indexPath
                                     clickable:YES
                                    dropShadow:YES
                                  cornerRadius:GROUPED_CELL_CORNER_RADIUS];
      
    case WANT_KNOW_ALUMNUS_SECTION:
      
      return [self configureWithTitleImageCell:@"wantKnowCell"
                                         title:LocaleStringForKey(NSWantToKnowAlumniTitle, nil)
                                    badgeCount:[AppManager instance].wantToKnowAlumnusCount.intValue
                                       content:nil
                                         image:[UIImage imageNamed:@"wantKnowAlumni.png"]
                                     indexPath:indexPath
                                     clickable:YES
                                    dropShadow:YES
                                  cornerRadius:GROUPED_CELL_CORNER_RADIUS];
      
    default:
      return nil;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (indexPath.section) {
      
    case KNOWN_ALUMNUS_SECTION:
    {
      KnownAlumniListViewController *alumniListVC = [[[KnownAlumniListViewController alloc] initWithMOC:_MOC] autorelease];
      alumniListVC.title = LocaleStringForKey(NSKnownAlumnusTitle, nil);

      [self.navigationController pushViewController:alumniListVC animated:YES];
      break;
    }
      
    case WANT_KNOW_ALUMNUS_SECTION:
    {
      AttractiveAlumniListViewController *alumniListVC = [[[AttractiveAlumniListViewController alloc] initResettedWithMOC:_MOC] autorelease];
      alumniListVC.title = LocaleStringForKey(NSWantToKnowAlumniTitle, nil);
      [self.navigationController pushViewController:alumniListVC animated:YES];
      break;
    }
      
    default:
      break;
  }
}

#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
            blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  
  switch (contentType) {
    case LOAD_CONNECTED_ALUMNUS_COUNT_TY:
    {
      [XMLParser parserResponseXml:result
                              type:contentType
                               MOC:_MOC
                 connectorDelegate:self
                               url:url];
      
      _autoLoaded = YES;
      
      [_tableView reloadData];
      break;
    }
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  [super connectFailed:error url:url contentType:contentType];
}

@end
