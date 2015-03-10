//
//  GroupListViewController.m
//  iAlumni
//
//  Created by Adam on 12-10-5.
//
//

#import "GroupListViewController.h"
#import "TabSwitchView.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "Club.h"
#import "AppManager.h"
#import "ClubListCell.h"
#import "SearchClubViewController.h"
#import "GroupInfoCell.h"
#import "ShareViewController.h"
#import "GroupChatViewController.h"
#import "XMLParser.h"
#import "UIUtils.h"

enum {
  MY_GP_IDX = 0,
  ALL_GP_IDX,
};

enum {
  ALL_GP_SCOPE = 0,
  MY_GP_SCOPE = 1,
};

#define HEADER_HEIGHT   40.0f

@interface GroupListViewController ()

@end

@implementation GroupListViewController

#pragma mark - user actions
- (void)search:(id)sender {
  if (![AppManager instance].clubFliterLoaded) {
    [self loadOptions];
  } else {
    [self enterSearchView];
  }
}

- (void)enterGroup:(ClubViewType)showType group:(Club *)group {
    
  [AppManager instance].allowSendSMS = NO;
  
  GroupChatViewController *groupChatVC = [[[GroupChatViewController alloc] initWithMOC:_MOC
                                                                                 group:group] autorelease];
  groupChatVC.title = group.clubName;
  
  [self.navigationController pushViewController:groupChatVC animated:YES];
}

- (void)enterAllScopeGroup:(NSString *)title {
  ShareViewController *shareListVC = [[[ShareViewController alloc] initWithMOC:_MOC
                                                                        holder:nil
                                                              backToHomeAction:nil
                                                                      listType:ALL_ITEM_LIST_TY] autorelease];
  shareListVC.title = title;
  
  [self.navigationController pushViewController:shareListVC animated:YES];
}

#pragma mark - load club
- (void)configureMOCFetchConditions {
  self.entityName = @"Club";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder"
                                                            ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];
  
  self.predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", ORDINARY_USAGE_GP_TY];
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _showNewLoadedItemCount = NO;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  NSString *requestParam = [NSString stringWithFormat:@"<keyword></keyword><sort_type>2</sort_type><only_mine>%d</only_mine><host_type_value></host_type_value><host_sub_type_value></host_sub_type_value><page_size>%@</page_size><page>%d</page>", _myGroupFlag, ITEM_LOAD_COUNT, index];
  
  NSString *url = [CommonUtils geneUrl:requestParam itemType:CLUBLIST_TY];
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:CLUBLIST_TY] autorelease];
  (self.connDic)[url] = connFacade;
  [connFacade fetchGets:url];
  
}

- (void)loadOptions {
  NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:CLUB_FLITER_TY];
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:CLUB_FLITER_TY] autorelease];
  (self.connDic)[url] = connFacade;
  [connFacade fetchGets:url];
}

- (void)setTriggerReloadListFlag {
  _needReloadGroups = YES;
}

#pragma mark - show search view
- (void)enterSearchView {
  
  SearchClubViewController *searchClubVC = [[[SearchClubViewController alloc] initWithMOC:_MOC] autorelease];
  searchClubVC.title = LocaleStringForKey(NSSearchTitle, nil);
  [AppManager instance].clubKeyWord = NULL_PARAM_VALUE;
  [AppManager instance].supClubTypeValue = NULL_PARAM_VALUE;
  [AppManager instance].hostTypeValue = NULL_PARAM_VALUE;
  
  [self.navigationController pushViewController:searchClubVC animated:YES];
  
  _needReloadGroups = YES;
  
  [self clearList];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction {
  
  self = [super initWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    _currentStartIndex = 0;
    _startTabIndex = MY_GP_IDX;
    
    _myGroupFlag = MY_GP_SCOPE;
    
    _noNeedDisplayEmptyMsg = YES;
    
    [self clearData];
  }
  
  return self;
}

- (id)initForAllGroupsWithMOC:(NSManagedObjectContext *)MOC {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    _currentStartIndex = 0;
    
    _startTabIndex = ALL_GP_IDX;
    
    _myGroupFlag = ALL_GP_SCOPE;
    
    _noNeedDisplayEmptyMsg = YES;
    
    [self clearData];
  }
  return self;
}

- (void)clearData {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", ORDINARY_USAGE_GP_TY];
  DELETE_OBJS_FROM_MOC(_MOC, @"Club", predicate);
}

- (void)dealloc {
  
  [self clearData];
  
  [super dealloc];
}

- (void)setTableViewProperties {
  _tableView.frame = CGRectMake(0, HEADER_HEIGHT,
                                _tableView.frame.size.width,
                                _tableView.frame.size.height - HEADER_HEIGHT);
}

- (void)addSearchButton {
  
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSSearchTitle, nil)
                            target:self
                            action:@selector(search:)];
}

- (void)initTabSwitchView {
  /*
   NSString *myGroupsTitle = [NSString stringWithFormat:@"%@ (%@)",
   LocaleStringForKey(NSMyGroupsTitle, nil),
   [AppManager instance].myClassNum];
   NSString *allGroupsTitle = [NSString stringWithFormat:@"%@ (%@)",
   LocaleStringForKey(NSAllGroupsTitle, nil),
   @"0"]; // FIXME need set all group count
   */
  
  _tabSwitchView = [[[TabSwitchView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)
                                            buttonTitles:@[LocaleStringForKey(NSMyGroupsTitle, nil), LocaleStringForKey(NSAllGroupsTitle, nil)]
                                       tapSwitchDelegate:self
                                                tabIndex:_startTabIndex] autorelease];

  
  [self.view addSubview:_tabSwitchView];
}

- (void)viewDidLoad {
  [super viewDidLoad];
	
  self.view.backgroundColor = CELL_COLOR;
  
  [self initTabSwitchView];
  
  [self setTableViewProperties];
  
  [self addSearchButton];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (_autoLoaded) {
    [self updateLastSelectedCell];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded || _needReloadGroups) {
    
    [self clearData];
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  
  BOOL blockCurrentView = NO;
  switch (contentType) {
    case CLUBLIST_TY:
      blockCurrentView = YES;
      break;
      
    default:
      break;
  }
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
            blockCurrentView:blockCurrentView];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case CLUBLIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        if (!_autoLoaded) {
          _autoLoaded = YES;
        }
        
        if (_needReloadGroups) {
          _needReloadGroups = NO;
        }
        
        [self refreshTable];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLoadGroupFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];

      }
      
      break;
    }
      
    case CLUB_FLITER_TY:
    {
      BOOL ret = [XMLParser parserResponseXml:result
                                         type:contentType
                                          MOC:_MOC
                            connectorDelegate:self
                                          url:url];
      
      if (ret) {
        [AppManager instance].clubFliterLoaded = YES;
        [self enterSearchView];
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLoadFilterOptionsFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];

      }
      
      [UIUtils closeActivityView];
      break;
    }
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  [UIUtils closeActivityView];
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  
  NSString *msg = nil;
  
  switch (contentType) {
    case CLUBLIST_TY:
    {
      msg = LocaleStringForKey(NSLoadGroupFailedMsg, nil);
      break;
    }
      
    case CLUB_FLITER_TY:
    {
      msg = LocaleStringForKey(NSLoadFilterOptionsFailedMsg, nil);
      
      [UIUtils closeActivityView];
      break;
    }
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - clear list
- (void)clearList {
  self.fetchedRC = nil;
  [_tableView reloadData];
  
  _currentStartIndex = 0;
  _autoLoaded = NO;
}

#pragma mark - TapSwitchDelegate method
- (void)selectTapByIndex:(NSInteger)index {
  
  [self clearData];
  [self clearList];
  
  switch (index) {
    case MY_GP_IDX:
      _myGroupFlag = MY_GP_SCOPE;
      break;
      
    case ALL_GP_IDX:
      _myGroupFlag = ALL_GP_SCOPE;
      break;
      
    default:
      break;
  }
  
  _tableView.frame = CGRectMake(0, HEADER_HEIGHT,
                                _tableView.frame.size.width,
                                self.view.frame.size.height);
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
    return [self drawFooterCell];
	}
  
  // Club Cell
  static NSString *kCellIdentifier = @"ClubListCell";
  
  Club *club = [self.fetchedRC objectAtIndexPath:indexPath];
  
  GroupInfoCell *cell = (GroupInfoCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[GroupInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:kCellIdentifier] autorelease];
  }
  
  [cell drawCell:club];
   
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return CLUB_LIST_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  Club *club = [self.fetchedRC objectAtIndexPath:indexPath];
  
  if (club.clubId.intValue == ALL_SCOPE_GP_ID) {
  
    [self enterAllScopeGroup:club.clubName];
    
  } else {
    [AppManager instance].clubName = [NSString stringWithFormat:@"%@", club.clubName];
    [AppManager instance].clubId = [NSString stringWithFormat:@"%@", club.clubId];
    [AppManager instance].clubType = [NSString stringWithFormat:@"%@", club.clubType];
    [AppManager instance].hostSupTypeValue = club.hostSupTypeValue;
    [AppManager instance].hostTypeValue = club.hostTypeValue;
    
    [AppManager instance].isNeedReLoadClubDetail = YES;
    
    club.badgeNum = NULL_PARAM_VALUE;
    SAVE_MOC(_MOC);
    
    [self enterGroup:CLUB_SELF_VIEW group:club];
  }

}


@end
