//
//  NameCardSearchViewController.m
//  iAlumni
//
//  Created by Adam on 12-11-23.
//
//

#import "NameCardSearchViewController.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "NameCardSearchToolView.h"
#import "IndustryListViewController.h"
#import "Industry.h"
#import "CoreDataUtils.h"
#import "SearchKeyword.h"
#import "ConfigurableTextCell.h"
#import "WXWLabel.h"
#import "ECAsyncConnectorFacade.h"
#import "Alumni.h"
#import "PeopleWithChatCell.h"
#import "ChatListViewController.h"
#import "AlumniProfileViewController.h"
#import "AppManager.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "DMChatViewController.h"

#define SEARCH_TOOL_HEIGHT    80.0f
#define NAME_LIMITED_WIDTH    144.0f
#define PHOTO_WIDTH           56.0f


@interface NameCardSearchViewController ()
@property (nonatomic, retain) Industry *selectedIndustry;
@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, retain) NSMutableArray *recentSearchKeywords;
@property (nonatomic, retain) Alumni *alumni;
@end

@implementation NameCardSearchViewController

#pragma mark - user actions

- (void)doSearch {
  
  if (!_searched) {
    _searched = YES;
  }
  
  [_searchToolView searchBarResignFirstResponder];
  
  [self saveRecentKeywordIfNeeded];
  
  _currentType = CLUB_MANAGE_USER_TY;//SEARCH_NAME_CARD_TY;
  
  NSString *url = [NSString stringWithFormat:@"http://alumniapp.ceibs.edu:8080/ceibs_test//phone_controller?action=host_member_list&ReqContent=<?xml version=\"1.0\" encoding=\"UTF-8\"?><content><locale>zh</locale><plat>iPhone</plat><channel>1</channel><system>6.0.1</system><version>1.3.5</version><device_token>c3dec345e1ed5670536ff9036180246f5e0251ccb40df6c42c667ff82c79e692</device_token><user_id>qronghao.e08sh2</user_id><user_name>邱荣浩</user_name><person_id>210437</person_id><user_type>1</user_type><session_id>%@</session_id><class_id>EMBA08SH2</class_id><class_name>EMBA08SH2</class_name><host_id>137</host_id><host_type>1</host_type><host_type_value>3</host_type_value><host_sub_type_value>3</host_sub_type_value><host_name>EMBA08SH2</host_name><page>0</page><page_size>30</page_size></content>", [AppManager instance].sessionId];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)search:(id)sender {
  
  [self doSearch];
}

- (void)selectIndustry:(Industry *)industry {
  self.selectedIndustry = industry;
  
  [_searchToolView updateIndustryTitle:industry.cnName];
}

- (void)showProfile:(NSString *)personId userType:(NSString *)userType {
  
  Alumni *alumni = (Alumni *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                    entityName:@"Alumni"
                                                     predicate:[NSPredicate predicateWithFormat:@"(personId == %@)", personId]];
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                      alumni:alumni
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)beginChat {
  
  DMChatViewController *chatVC = [[[DMChatViewController alloc] initWithMOC:_MOC
                                                                     alumni:self.alumni] autorelease];
  [self.navigationController pushViewController:chatVC animated:YES];
  
  /*
  [CommonUtils doDelete:_MOC entityName:@"Chat"];
  ChatListViewController *chartVC = [[ChatListViewController alloc] initWithMOC:_MOC
                                                                         alumni:self.alumni];
  [self.navigationController pushViewController:chartVC animated:YES];
  RELEASE_OBJ(chartVC);
   */
}

#pragma mark - load data
- (void)configureMOCFetchConditions {
  self.entityName = @"Alumni";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"orderId" ascending:YES] autorelease];
  [self.descriptors addObject:sortDesc];
  
  //self.predicate = [NSPredicate predicateWithFormat:@"bySearch == 1"];
}

#pragma mark - lifecycle methods

- (void)prepareAllIndustry {
  
  Industry *allIndustry = (Industry *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                             entityName:@"Industry"
                                                              predicate:[NSPredicate predicateWithFormat:@"(industryId == %@)", INDUSTRY_ALL_ID]];
  
  if (nil == allIndustry) {
    allIndustry = (Industry *)[NSEntityDescription insertNewObjectForEntityForName:@"Industry"
                                                            inManagedObjectContext:_MOC];
    allIndustry.industryId = INDUSTRY_ALL_ID;
    allIndustry.cnName = INDUSTRY_ALL_CN_NAME;
    allIndustry.enName = INDUSTRY_ALL_EN_NAME;
  }
  
  self.selectedIndustry = allIndustry;
}

- (void)fetchRecentKeywords {
  
  NSMutableArray *sortDescs = [NSMutableArray array];
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                              ascending:NO] autorelease];
  [sortDescs addObject:descriptor];
  self.recentSearchKeywords = [NSMutableArray arrayWithArray:[WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                                                                     entityName:@"SearchKeyword"
                                                                                      predicate:nil
                                                                                      sortDescs:sortDescs]];
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC {
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 needGoHome:NO];
  if (self) {
    [self prepareAllIndustry];
    
    _noNeedDisplayEmptyMsg = YES;
  }
  return self;
}

- (void)dealloc {
  
  self.selectedIndustry = nil;
  self.keywords = nil;
  self.recentSearchKeywords = nil;
  self.alumni = nil;
  
  [super dealloc];
}

- (void)addSearchButton {
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSGoTitle, nil)
                            target:self
                            action:@selector(search:)];
}

- (void)addSearchTool {
  _searchToolView = [[[NameCardSearchToolView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SEARCH_TOOL_HEIGHT)
                                                 searchBarDelegate:self
                                                     searchManager:self] autorelease];
  [self.view addSubview:_searchToolView];
  
  _tableView.frame = CGRectMake(_tableView.frame.origin.x,
                                SEARCH_TOOL_HEIGHT,
                                _tableView.frame.size.width,
                                _tableView.frame.size.height - SEARCH_TOOL_HEIGHT);
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self addSearchButton];
  
  [self addSearchTool];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECClickableElementDelegate methods
- (void)showIndustries {
  IndustryListViewController *industryListVC = [[[IndustryListViewController alloc] initWithMOC:_MOC
                                                                      currentSelectedIndustryId:self.selectedIndustry.industryId
                                                                                   searchHolder:self
                                                                                   selectAction:@selector(selectIndustry:)] autorelease];
  
  industryListVC.title = LocaleStringForKey(NSIndustryTitle, nil);
  
  [self.navigationController pushViewController:industryListVC animated:YES];
}

- (void)doChat:(Alumni*)aAlumni {
  
  self.alumni = aAlumni;
  
  UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSActionSheetTitle, nil)
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:LocaleStringForKey(NSChatActionSheetTitle, nil)
                                          otherButtonTitles:nil] autorelease];
  
  [as addButtonWithTitle:LocaleStringForKey(NSProfileActionSheetTitle, nil)];
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.navigationController.view];
}

#pragma mark - search key word handlers
- (void)saveRecentKeywordIfNeeded {
  
  if (self.keywords && self.keywords.length > 0) {
    if (![WXWCoreDataUtils objectInMOC:_MOC
                         entityName:@"SearchKeyword"
                          predicate:[NSPredicate predicateWithFormat:@"searchString == %@", self.keywords]]) {
      SearchKeyword *searchKeywordObj = (SearchKeyword *)[NSEntityDescription insertNewObjectForEntityForName:@"SearchKeyword"
                                                                                       inManagedObjectContext:_MOC];
      searchKeywordObj.searchString = self.keywords;
      searchKeywordObj.timestamp = [NSNumber numberWithDouble:[CommonUtils convertToUnixTS:[NSDate date]]];
      SAVE_MOC(_MOC);
    }
  }
}

- (void)clearSearchingHistory {
  DELETE_OBJS_FROM_MOC(_MOC, @"SearchKeyword", nil);
  
  [self.recentSearchKeywords removeAllObjects];
  
  [_tableView reloadData];
}

- (void)displayAvailableKeywords {
  [self fetchRecentKeywords];
  
  [_tableView reloadData];
}

- (void)hideKeyboardIfNeeded {
  if ([_searchToolView searchBarFirstResponse]) {
    [_searchToolView searchBarResignFirstResponder];
  }
}

#pragma mark - scroll action
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self hideKeyboardIfNeeded];
}

#pragma mark - UISearchBarDelegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  
  [self doSearch];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  NSLog(@"searchText: %@", searchText);
  
  self.keywords = searchText;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
  
  if (_searched) {
    _searched = NO;
  }
  
  searchBar.text = nil;
  
  [self displayAvailableKeywords];
  
  return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
  return YES;
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  
  NSString *msg = LocaleStringForKey(NSSearchingTitle, nil);
  [self showAsyncLoadingView:msg
            blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  [UIUtils closeActivityView];
  
  switch (contentType) {
      
    case CLUB_MANAGE_USER_TY://SEARCH_NAME_CARD_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        _searched = YES;
        
        [self refreshTable];
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
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
  
  NSString *message = nil;
  
  switch (contentType) {
      
    case CLUB_MANAGE_USER_TY://SEARCH_NAME_CARD_TY:
    {
      message = LocaleStringForKey(NSFetchAlumnusFailedMsg, nil);
      
      break;
    }
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = message;
  }
  
  [super connectFailed:error
                   url:url
           contentType:contentType];
}

#pragma mark - draw cell
- (UITableViewCell *)drawRecentKeywordsCellAtIndexPath:(NSIndexPath *)indexPath {
  SearchKeyword *keyword = (SearchKeyword *)[self.recentSearchKeywords objectAtIndex:indexPath.row];
  
  static NSString *kCellIdentifier = @"keyCell";
  return [self configurePlainCell:kCellIdentifier
                            title:keyword.searchString
                       badgeCount:0
                          content:0
                        indexPath:indexPath
                        clickable:YES
                   selectionStyle:UITableViewCellSelectionStyleBlue];
}

- (UITableViewCell *)drawClearHistoryCell {
  
  static NSString *kClearHistoryCellIdentifier = @"clearHistoryCellIdentifier";
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kClearHistoryCellIdentifier];
  if (nil == cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:kClearHistoryCellIdentifier] autorelease];
    cell.backgroundColor = CELL_COLOR;
    WXWLabel *title = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:BASE_INFO_COLOR
                                         shadowColor:[UIColor whiteColor]] autorelease];
    title.font = FONT(13);
    title.textAlignment = UITextAlignmentCenter;
    [cell.contentView addSubview:title];
    
    title.text = LocaleStringForKey(NSClearSearchHistoryMsg, nil);
    CGSize size = [title.text sizeWithFont:title.font
                                  forWidth:self.view.frame.size.width
                             lineBreakMode:NSLineBreakByWordWrapping];
    title.frame = CGRectMake((self.view.frame.size.width - size.width)/2.0f,
                             (DEFAULT_CELL_HEIGHT - size.height)/2.0f, size.width, size.height);
  }
  
  return cell;
}

- (UITableViewCell *)drawSearchProcessCell:(NSIndexPath *)indexPath {
  
  UITableViewCell *cell;
  
  if (indexPath.row == self.recentSearchKeywords.count) {
    cell = [self drawClearHistoryCell];
  } else {
    cell = [self drawRecentKeywordsCellAtIndexPath:indexPath];
  }
  
  return cell;
}

- (UITableViewCell *)drawSearchResultCellAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"kUserCell";
  PeopleWithChatCell *cell = (PeopleWithChatCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[PeopleWithChatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:kCellIdentifier
                             imageDisplayerDelegate:self
                             imageClickableDelegate:self
                                                MOC:_MOC] autorelease];
  }
  
  Alumni *alumni = (Alumni *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  [cell drawCell:alumni];
  
  return cell;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  if (_searched) {
    return self.fetchedRC.fetchedObjects.count;
  } else {
    if (self.recentSearchKeywords.count > 0) {
      return self.recentSearchKeywords.count + 1;
    } else {
      return 0;
    }
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  if (_searched) {
    return [self drawSearchResultCellAtIndexPath:indexPath];
  } else {
    return [self drawSearchProcessCell:indexPath];
  }
}

- (void)selectKeywordCell:(NSIndexPath *)indexPath {
  
  if (self.recentSearchKeywords.count > 0 && indexPath.row == self.recentSearchKeywords.count) {
    // select clear history cell
    [self clearSearchingHistory];
  } else {
    
    SearchKeyword *keyword = (SearchKeyword *)[self.recentSearchKeywords objectAtIndex:indexPath.row];
    [_searchToolView selectKeyworkdFromHistory:keyword.searchString];
    
    [self hideKeyboardIfNeeded];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  if (_searched) {
    Alumni *alumni = (Alumni *)[self.fetchedRC objectAtIndexPath:indexPath];
    
    [self showProfile:alumni.personId userType:[NSString stringWithFormat:@"%@", alumni.userType]];
  } else {
    
    [self selectKeywordCell:indexPath];
  }
}

- (CGFloat)alumniCellHeight:(NSIndexPath *)indexPath {
  Alumni *alumni = (Alumni *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  CGSize constraint = CGSizeMake(NAME_LIMITED_WIDTH, 20);
  CGSize size = [alumni.name sizeWithFont:Arial_FONT(14)
                        constrainedToSize:constraint
                            lineBreakMode:NSLineBreakByTruncatingTail];
  
  CGFloat height = MARGIN + size.height + MARGIN;
  
  size = [alumni.companyName sizeWithFont:FONT(13)
                        constrainedToSize:CGSizeMake(280 - MARGIN -
                                                     (MARGIN + PHOTO_WIDTH + PHOTO_MARGIN * 2 +
                                                      MARGIN * 2),
                                                     CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByWordWrapping];
  
  height += size.height + MARGIN;
  
  if (height < PEOPLE_CELL_HEIGHT) {
    height = PEOPLE_CELL_HEIGHT;
  }
  
  return height;
}

- (CGFloat)keywordCellHeight {
  return DEFAULT_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (_searched) {
    return [self alumniCellHeight:indexPath];
  } else {
    return [self keywordCellHeight];
  }
}


#pragma mark - Action Sheet
- (void)actionSheet:(UIActionSheet*)aSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case CHAT_SHEET_IDX:
		{
      [self beginChat];
      return;
		}
      
		case DETAIL_SHEET_IDX:
      [self showProfile:self.alumni.personId userType:self.alumni.userType];
			return;
			
    case CANCEL_SHEET_IDX:
      return;
      
		default:
			break;
	}
}

@end
