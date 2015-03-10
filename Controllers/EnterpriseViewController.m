//
//  EnterpriseViewController.m
//  iAlumni
//
//  Created by Adam on 12-10-9.
//
//

#import "EnterpriseViewController.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "Club.h"
#import "JoinedGroup.h"
#import "ListSectionView.h"
#import "GroupInfoCell.h"
#import "GroupChatViewController.h"
#import "ShareViewController.h"
#import "XMLParser.h"
#import "BizPostListViewController.h"
#import "GroupListViewController.h"
#import "BizGroupCell.h"
#import "AppManager.h"
#import "UIUtils.h"

#define EMAIL_BTN_WIDTH   220.0f
#define EMAIL_BTN_HEIGHT  40.0f

#define LIMITED_WIDTH           300.0f

#define SECTION_VIEW_HEIGHT     20.0f

#define SECTION_COUNT     3

#define CELL_HEIGHT       65.0f

enum {
  BIZ_GP_SEC,
  JOINED_CLUB_GP_SEC,
  OTHER_CLUB_GP_SEC,
};

@interface EnterpriseViewController ()
@property (nonatomic, retain) NSFetchedResultsController *bizGroupFetchedRC;
@property (nonatomic, retain) NSFetchedResultsController *clubFetchedRC;
@end

@implementation EnterpriseViewController

#pragma mark - user actions
- (void)enterGroup:(ClubViewType)showType group:(Club *)group {
  
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
}

- (void)loadBizGroups {
  
  _currentType = LOAD_BIZ_GROUPS_TY;
  
  NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)displayGroups {

  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder"
                                                            ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];


  self.entityName = @"Club";
  self.predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", BIZ_DISCUSS_USAGE_GP_TY];
  self.bizGroupFetchedRC = [self performFetchByFetchedRC:self.bizGroupFetchedRC];
  
  self.entityName = @"JoinedGroup";
  self.predicate = [NSPredicate predicateWithFormat:@"(alumniId == %@) AND (usageType == %d)", [AppManager instance].personId, BIZ_JOINED_USAGE_GP_TY];
  self.clubFetchedRC = [self performFetchByFetchedRC:self.clubFetchedRC];
  
  [_tableView reloadData];
}

#pragma mark - lifecycle methods

- (void)clearData {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(usageType == %d) AND (usageType == %d)", BIZ_DISCUSS_USAGE_GP_TY, BIZ_JOINED_USAGE_GP_TY];
  DELETE_OBJS_FROM_MOC(_MOC, @"Club", predicate);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction {
  
  self = [super initWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 needGoHome:NO];
  
  if (self) {
    _currentStartIndex = 0;
    
    _noNeedDisplayEmptyMsg = YES;
    
    [self clearData];
  }
  
  return self;
}

- (void)dealloc {
  
  [self clearData];
  
  self.bizGroupFetchedRC = nil;
  self.clubFetchedRC = nil;
  
  [super dealloc];
}


- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
}

- (void)clearJoinedGroups {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", BIZ_JOINED_USAGE_GP_TY];
  DELETE_OBJS_FROM_MOC(_MOC, @"Club", predicate);
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self clearJoinedGroups];
  
  [self loadBizGroups];
}


- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
            blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case LOAD_BIZ_GROUPS_TY:
    {
      if ([XMLParser parserResponseXml:result
                                 type:contentType
                                  MOC:_MOC
                    connectorDelegate:self
                                  url:url]) {
        if (!_autoLoaded) {
          _autoLoaded = YES;
        }
        
        [self displayGroups];

      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLoadGroupFailedMsg, nil)
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
  [UIUtils closeActivityView];
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
    
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSLoadGroupFailedMsg, nil);
  }

  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (!_autoLoaded) {
    return 0;
  } else {
    return SECTION_COUNT;
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case BIZ_GP_SEC:
      return self.bizGroupFetchedRC.fetchedObjects.count;
      
    case JOINED_CLUB_GP_SEC:
      return self.clubFetchedRC.fetchedObjects.count;
      
    case OTHER_CLUB_GP_SEC:
      return 1;
      
    default:
      return 0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return SECTION_VIEW_HEIGHT;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
  
  NSString *name = nil;
  switch (section) {
    case BIZ_GP_SEC:
      name = LocaleStringForKey(NSPublicDiscussGroupTitle, nil);
      break;
      
    case JOINED_CLUB_GP_SEC:
      name = LocaleStringForKey(NSJoinedDiscussGroupTitle, nil);
      break;
      
    case OTHER_CLUB_GP_SEC:
      name = LocaleStringForKey(NSOtherDiscussGroupTitle, nil);
      break;
      
    default:
      break;
  }
  
  return [[[ListSectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SECTION_VIEW_HEIGHT)
                                           title:name
                                       titleFont:BOLD_FONT(14)] autorelease];
}

- (UITableViewCell *)bizGroupsCell:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"bizGroupCell";
  
  Club *club = [self.bizGroupFetchedRC.fetchedObjects objectAtIndex:indexPath.row];
  
  
  BizGroupCell *cell = (BizGroupCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[BizGroupCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:kCellIdentifier] autorelease];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  [cell drawCell:club];
  
  return cell;
}

- (UITableViewCell *)joinedGroupsCell:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"ClubListCell";
  
  JoinedGroup *group = [self.clubFetchedRC.fetchedObjects objectAtIndex:indexPath.row];
  
  BizGroupCell *cell = (BizGroupCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[BizGroupCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:kCellIdentifier] autorelease];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  [cell drawCell:group];
  
  return cell;
}

- (UITableViewCell *)otherGroupsCell:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"otherClubCell";
  
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:kCellIdentifier] autorelease];
    
    cell.backgroundColor = CELL_COLOR;
    cell.contentView.backgroundColor = CELL_COLOR;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    cell.textLabel.text = LocaleStringForKey(NSCheckMoreTitle, nil);
    
    cell.textLabel.font = BOLD_FONT(15);
    cell.textLabel.textColor = DARK_TEXT_COLOR;
    cell.textLabel.shadowColor = TEXT_SHADOW_COLOR;
  }
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  switch (indexPath.section) {
    case BIZ_GP_SEC:
      
      return [self bizGroupsCell:indexPath];
      
    case JOINED_CLUB_GP_SEC:
      
      return [self joinedGroupsCell:indexPath];
      
    case OTHER_CLUB_GP_SEC:
      
      return [self otherGroupsCell:indexPath];
      
    default:
      return nil;
  }
}

- (CGFloat)groupCellHeight:(Club *)group {
  CGSize size = [group.clubName sizeWithFont:BOLD_FONT(15)
                                 constrainedToSize:CGSizeMake(LIMITED_WIDTH, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat height = MARGIN * 2 + size.height;
  
  if (group.postAuthor && group.postAuthor.length > 0 &&
      group.postDesc && group.postDesc.length > 0 &&
      group.postTime.length && group.postTime.length > 0) {
    
    size = [group.postAuthor sizeWithFont:BOLD_FONT(13)
                         constrainedToSize:CGSizeMake(LIMITED_WIDTH, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];

    size = [group.postDesc sizeWithFont:BOLD_FONT(13)
                      constrainedToSize:CGSizeMake(self.view.frame.size.width - (MARGIN * 2 + size.width + MARGIN + 20 + MARGIN), size.height)
                          lineBreakMode:NSLineBreakByTruncatingTail];
    height += size.height + MARGIN;
    
    size = [group.postTime sizeWithFont:BOLD_FONT(11)
                      constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height + MARGIN;
  } else {
    height += MARGIN * 2;
  }
  
  if (height < DEFAULT_CELL_HEIGHT) {
    return DEFAULT_CELL_HEIGHT;
  } else {
    return height;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  /*
  switch (indexPath.section) {
    case BIZ_GP_SEC:
    {
      Club *group = [self.bizGroupFetchedRC.fetchedObjects objectAtIndex:indexPath.row];
      return [self groupCellHeight:group];
    }
      
    case JOINED_CLUB_GP_SEC:
    {
      JoinedGroup *club = [self.clubFetchedRC.fetchedObjects objectAtIndex:indexPath.row];
      return [self groupCellHeight:club];
    }
      
    case OTHER_CLUB_GP_SEC:
      return DEFAULT_CELL_HEIGHT;
      
    default:
      return 0;
  }
   */
  return CELL_HEIGHT;
}

- (void)selectBizSection:(NSIndexPath *)indexPath {
  Club *group = [self.bizGroupFetchedRC.fetchedObjects objectAtIndex:indexPath.row];
  
  if (group.clubId.intValue == ALL_SCOPE_GP_ID) {
    [self enterAllScopeGroup:group.clubName];
  } else {
    BizPostListViewController *bizPostListVC = [[[BizPostListViewController alloc] initWithMOC:_MOC
                                                                                         group:group] autorelease];
    bizPostListVC.title = group.clubName;
    
    [self.navigationController pushViewController:bizPostListVC animated:YES];
  }

}

- (void)selectJoinedGroupSection:(NSIndexPath *)indexPath {
  JoinedGroup *club = [self.clubFetchedRC.fetchedObjects objectAtIndex:indexPath.row];
  
  if (club.clubId.intValue == ALL_SCOPE_GP_ID) {
    
    [self enterAllScopeGroup:club.clubName];
  } else {
    [self enterGroup:CLUB_SELF_VIEW group:club];
  }
}

- (void)selectOtherGroupSection:(NSIndexPath *)indexPath {
  GroupListViewController *allGroupsVC = [[[GroupListViewController alloc] initForAllGroupsWithMOC:_MOC] autorelease];
  
  allGroupsVC.title = LocaleStringForKey(NSGroupsTitle, nil);
  
  [self.navigationController pushViewController:allGroupsVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (indexPath.section) {
    case BIZ_GP_SEC:      
      [self selectBizSection:indexPath];
      break;
      
    case JOINED_CLUB_GP_SEC:
      [self selectJoinedGroupSection:indexPath];
      break;
      
    case OTHER_CLUB_GP_SEC:
      [self selectOtherGroupSection:indexPath];
      break;
      
    default:
      break;
  }
}

@end
