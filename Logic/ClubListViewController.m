//
//  ClubListViewController.m
//  iAlumni
//
//  Created by Adam on 12-8-24.
//
//

#import "ClubListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "iAlumniAppDelegate.h"
#import "SearchClubViewController.h"
#import "WXWDebugLogOutput.h"
#import "TextConstants.h"
#import "ClubListCell.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "EventCity.h"
#import "UIUtils.h"
#import "Club.h"
#import "GroupChatViewController.h"
#import "ClubDetailViewController.h"
#import "GroupFormViewController.h"
#import "XMLParser.h"

@interface ClubListViewController()
@end

@implementation ClubListViewController
@synthesize requestParam = _requestParam;
@synthesize clubFliters;
@synthesize _likeIcon;
@synthesize _likeCountLabel;
@synthesize _commentIcon;
@synthesize _commentCountLabel;
@synthesize onlyMine;
@synthesize sortType;

- (id)initWithMOC:(NSManagedObjectContext *)MOC listType:(ClubListViewType)listType {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 tableStyle:UITableViewStylePlain
                 needGoHome:NO];
  
  if (self) {
    //init value
    [AppManager instance].clubType = NULL_PARAM_VALUE;
    self.pageIndex = 0;
    _listType = listType;
    
    [AppManager instance].needSaveMyClassNum = NO;
    
    switch (_listType) {
        
      case CLUB_LIST_BY_POST_TIME:
      {
        self.sortType = @"2";
        self.onlyMine = @"0";
      }
        break;
        
      case CLUB_LIST_BY_NAME:
      {
        self.sortType = @"1";
        self.onlyMine = @"0";
      }
        break;
        
      default:
        break;
    }
  }
  
  return self;
}

- (void)dealloc {
  
  self.sortType = nil;
  self.onlyMine = nil;
  
  [UIUtils closeActivityView];
  [NSFetchedResultsController deleteCacheWithName:nil];
  
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - load club
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  if (self.pageIndex == 0) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", ORDINARY_USAGE_GP_TY];
    DELETE_OBJS_FROM_MOC(_MOC, @"Club", predicate);
  }
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  self.requestParam = [NSString stringWithFormat:@"<keywords>%@</keywords><sort_type>%@</sort_type><only_mine>%@</only_mine><host_type_value>%@</host_type_value><host_sub_type_value>%@</host_sub_type_value><page_size>30</page_size><page>%d</page>", [AppManager instance].clubKeyWord, self.sortType, self.onlyMine, [AppManager instance].supClubTypeValue, [AppManager instance].hostTypeValue, index];
  
  NSString *tmpStr = [NSString stringWithFormat:@"<page>%d</page>", self.pageIndex++];
  self.requestParam = [self.requestParam stringByReplacingOccurrencesOfString:@"<page>0</page>" withString:tmpStr];
  NSString *url = [CommonUtils geneUrl:self.requestParam itemType:CLUBLIST_TY];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:CLUBLIST_TY];
  [connFacade fetchGets:url];
}

#pragma mark - core data
- (void)configureMOCFetchConditions {
  
  self.predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", ORDINARY_USAGE_GP_TY];
  self.entityName = @"Club";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder" ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  if (_listType == CLUB_LIST_BY_NAME) {
    self.title = LocaleStringForKey(NSSearchResultTitle, nil);
  }
  [self addLeftBarButtonWithTitle:LocaleStringForKey(NSBackBtnTitle, nil)
                           target:self
                           action:@selector(doClose:)];
}

- (void)viewWillAppear:(BOOL)animated {
  
	NSIndexPath *selection = [_tableView indexPathForSelectedRow];
	if (selection) {
		[_tableView deselectRowAtIndexPath:selection animated:YES];
	}
	
	if (!_autoLoaded) {
		[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
  
}

- (void)viewDidUnload
{
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIDeviceOrientationPortrait);
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return self.fetchedRC.fetchedObjects.count + 1;
}

- (void)updateTable:(NSArray *)indexPaths {
  [_tableView beginUpdates];
  [_tableView reloadRowsAtIndexPaths:indexPaths
                    withRowAnimation:UITableViewRowAnimationNone];
  [_tableView endUpdates];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  // Foot Cell
  if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
    return [self drawFooterCell];
	}
    
    // Club Cell
    NSString *kGroupCellIdentifier = @"SearchClubListCell";
    ClubListCell *cell = (ClubListCell *)[_tableView dequeueReusableCellWithIdentifier:kGroupCellIdentifier];
    if (nil == cell) {
        cell = [[[ClubListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGroupCellIdentifier imageClickableDelegate:self] autorelease];
    }
    
    // Clear
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    [subviews release];
    
  Club *club = [self.fetchedRC objectAtIndexPath:indexPath];
  [cell drawClub:club];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  Club *club = [self.fetchedRC objectAtIndexPath:indexPath];
  [AppManager instance].clubId = [NSString stringWithFormat:@"%@", club.clubId];
  [AppManager instance].clubType = [NSString stringWithFormat:@"%@", club.clubType];
  [AppManager instance].hostSupTypeValue = club.hostSupTypeValue;
  [AppManager instance].hostTypeValue = club.hostTypeValue;
  
//  [self goPostView:CLUB_SELF_VIEW group:club];
    [self goClubView:CLUB_SELF_VIEW group:club];
    
  //    self.pageIndex --;
  //    _autoLoaded = NO;
  [super deselectCell];
}

- (void)goClubView:(ClubViewType)showType group:(Club *)group {
    GroupFormViewController *postListVC = [[[GroupFormViewController alloc] initWithMOC:_MOC
                                                                                  group:group
                                                                                 holder:nil
                                                                       backToHomeAction:nil
                                                                                 parent:self
                                                                    refreshParentAction:@selector(setTriggerReloadListFlag)
                                                                               listType:ALL_ITEM_LIST_TY
                                                                               showType:showType] autorelease];
    postListVC.title = group.clubName;
    
    if (self.parentVC) {
        [self.parentVC.navigationController pushViewController:postListVC animated:YES];
    } else {
        [self.navigationController pushViewController:postListVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return CLUB_LIST_CELL_HEIGHT;
}

#pragma mark - load Event list from web

- (void)stopAutoRefreshUserList {
  [timer invalidate];
}

#pragma mark - reset refresh header/footer view status
- (void)resetHeaderRefreshViewStatus {
	_reloading = NO;
	[UIUtils dataSourceDidFinishLoadingNewData:_tableView
                                  headerView:_headerRefreshView];
}

- (void)resetFooterRefreshViewStatus {
	_reloading = NO;
	
	[UIUtils dataSourceDidFinishLoadingOldData:_tableView
                                  footerView:_footerRefreshView];
}

- (void)resetHeaderOrFooterViewStatus {
  
  if (_loadForNewItem) {
    [self resetHeaderRefreshViewStatus];
  } else {
    [self resetFooterRefreshViewStatus];
  }
}

- (void)resetUIElementsForConnectDoneOrFailed {
  switch (_currentLoadTriggerType) {
    case TRIGGERED_BY_AUTOLOAD:
      _autoLoaded = YES;
      break;
      
    case TRIGGERED_BY_SCROLL:
      [self resetHeaderOrFooterViewStatus];
      break;
      
    default:
      break;
  }
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
  
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  
  switch (contentType) {
      
    case CLUBLIST_TY:
    {
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
      break;
    }
      
    default:
      break;
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
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - Post List View
- (void)goPostView:(ClubViewType)showType group:(Club *)group {
  
  GroupChatViewController *groupChatVC = [[[GroupChatViewController alloc] initWithMOC:_MOC
                                                                                 group:group] autorelease];
  groupChatVC.title = group.clubName;
  
  [self.navigationController pushViewController:groupChatVC animated:YES];
  
}

- (void)doUserDetail:(id)sender {
  
}

- (void)doClose:(id)sender {
  
  if (_listType == CLUB_LIST_BY_NAME) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self.navigationController popToRootViewControllerAnimated:YES];
  }
}

- (void)openClubDetail:(id)sender {
    
    UIButton *myBtn=(UIButton *)sender;
    ClubListCell *myCell=(ClubListCell *)[[myBtn superview] superview];
    
    Club *club = [self.fetchedRC objectAtIndexPath:[self.tableView indexPathForCell:myCell]];
    
    [AppManager instance].clubName = [NSString stringWithFormat:@"%@", club.clubName];
    [AppManager instance].clubId = [NSString stringWithFormat:@"%@", club.clubId];
    [AppManager instance].clubType = [NSString stringWithFormat:@"%@", club.clubType];
    [AppManager instance].hostSupTypeValue = club.hostSupTypeValue;
    [AppManager instance].hostTypeValue = club.hostTypeValue;
    
    [AppManager instance].isNeedReLoadClubDetail = YES;
    CGRect mFrame = CGRectMake(0, 0, LIST_WIDTH, self.view.bounds.size.height);
    ClubDetailViewController *sponsorDetail = [[[ClubDetailViewController alloc] initWithFrame:mFrame MOC:_MOC parentListVC:nil] autorelease];
    
    sponsorDetail.title = LocaleStringForKey(NSClubDetailTitle, nil);
    //    [self.navigationController pushViewController:sponsorDetail animated:YES];
    
    if (self.parentVC) {
        [self.parentVC.navigationController pushViewController:sponsorDetail animated:YES];
    } else {
        [self.navigationController pushViewController:sponsorDetail animated:YES];
    }
}

@end