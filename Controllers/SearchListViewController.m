//
//  SearchListViewController.m
//  ExpatCircle
//
//  Created by Adam on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SearchListViewController.h"
#import "SearchKeyword.h"
#import "CoreDataUtils.h"
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"

@interface SearchListViewController ()
@property (nonatomic, retain) UISearchDisplayController *itemSearchDisplayController;
@property (nonatomic, copy) NSString *keywords;
@property (nonatomic, retain) NSMutableArray *recentSearchKeywords;
@end

#define SEARCHBAR_HEIGHT  40.0f
#define CELL_HEIGHT       44.0f
//#define TOP_OFFSET        100.0f

@implementation SearchListViewController

@synthesize keywords = _keywords;
@synthesize itemSearchDisplayController = _itemSearchDisplayController;
@synthesize recentSearchKeywords = _recentSearchKeywords;

#pragma mark - user actions
- (void)close {
  [_searchBar resignFirstResponder];
  //[((ECViewController *)_filterListDelegate) dismissModalQuickView];
  [self dismissModalViewControllerAnimated:YES];
  
  self.navigationController.navigationBarHidden = NO;
}

- (void)keepSearchCancelButtonEnabled {
  for (UIView *subView in _searchBar.subviews) {
    if ([subView isKindOfClass:[UIButton class]]) {
      ((UIButton *)subView).enabled = YES;
      break;
    }
  }
}

- (void)triggerSearch {
  [self refreshTable];
}

#pragma mark - lifecycle methods

- (void)initRecentKeywords {
  
  NSMutableArray *sortDescs = [NSMutableArray array];
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                              ascending:NO] autorelease];
  [sortDescs addObject:descriptor];
  self.recentSearchKeywords = [NSMutableArray arrayWithArray:[WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                                                                     entityName:@"SearchKeyword"
                                                                                      predicate:nil
                                                                                      sortDescs:sortDescs]];
}

- (id)initNoSwipeBackWithMOC:(NSManagedObjectContext *)MOC 
                      holder:(id)holder 
            backToHomeAction:(SEL)backToHomeAction
          filterListDelegate:(id<ECFilterListDelegate>)filterListDelegate {
  
  self = [super initWithMOC:MOC
                     holder:nil 
           backToHomeAction:nil 
      needRefreshHeaderView:NO 
      needRefreshFooterView:NO 
                 needGoHome:NO];
  if (self) {
    _filterListDelegate = filterListDelegate;
    
    [self initRecentKeywords];
    
    _noNeedDisplayEmptyMsg = YES;
  }
  return self;
}

- (void)dealloc {
  /*
   self.itemSearchDisplayController.delegate = nil;
   self.itemSearchDisplayController.searchResultsDelegate = nil;
   self.itemSearchDisplayController.searchResultsDataSource = nil;
   self.itemSearchDisplayController = nil;
   */
  self.keywords = nil;
  self.recentSearchKeywords = nil;
  
  [super dealloc];
}

- (void)initSearchBar {
  _searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 
                                                              self.view.frame.size.width,   
                                                              SEARCHBAR_HEIGHT)] autorelease];
  _searchBar.delegate = self;
  _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
  [_searchBar sizeToFit];
  [_searchBar setShowsCancelButton:YES animated:YES];
  [_searchBar becomeFirstResponder];
  _searchBar.tintColor = NAVIGATION_BAR_COLOR;
  _tableView.tableHeaderView = _searchBar;
  
  /*
   self.itemSearchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:searchBar
   contentsController:self] autorelease];
   self.itemSearchDisplayController.delegate = self;
   self.itemSearchDisplayController.searchResultsDataSource = self;
   self.itemSearchDisplayController.searchResultsDelegate = self;
   [self.itemSearchDisplayController setActive:YES animated:YES];
   */
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  /*
  self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - TOP_OFFSET);
  _tableView.frame = CGRectMake(_tableView.frame.origin.x, 
                                _tableView.frame.origin.y, 
                                _tableView.frame.size.width, 
                                self.view.frame.size.height);
   */
  
  self.navigationController.navigationBarHidden = YES;
  
  [self initSearchBar];
  
  [_tableView reloadData];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - set predicate 
- (void)configureMOCFetchConditions {
  self.predicate = [NSPredicate predicateWithFormat:@"((itemName contains[cd] %@) OR (address contains[cd] %@) OR (tagNames contains[cd] %@))", 
                    self.keywords,
                    self.keywords,
                    self.keywords];
  
  self.entityName = @"ServiceItem";
}

#pragma mark - scroll action
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (_searchBar.isFirstResponder) {
    [_searchBar resignFirstResponder];
    
    [self keepSearchCancelButtonEnabled];
  }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  if (_beginSearch) {
    return _fetchedRC.fetchedObjects.count;
  } else {
    
    if (self.recentSearchKeywords.count > 0) {
      return self.recentSearchKeywords.count + 1;
    } else {  
      return 0;
    }
  }
}

- (UITableViewCell *)drawRecentKeywordsCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
  SearchKeyword *keyword = (SearchKeyword *)(self.recentSearchKeywords)[indexPath.row];
  
  cell.textLabel.text = keyword.searchString;
  return cell;
}

- (UITableViewCell *)dequeueTableViewCell {
  static NSString *kCellIdentifier = @"cellIdentifier";
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                   reuseIdentifier:kCellIdentifier] autorelease];
    
    cell.textLabel.font = BOLD_FONT(15);    
    cell.textLabel.shadowOffset = CGSizeMake(1.0f, 1.0f);
    cell.textLabel.shadowColor = [UIColor whiteColor];
    cell.backgroundColor = CELL_COLOR;
  }
  
  return cell;
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
                             (CELL_HEIGHT - size.height)/2.0f, size.width, size.height);
  }
  
  return cell;
}

- (UITableViewCell *)drawSearchResultCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
  // FIXME
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return CELL_HEIGHT;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  UITableViewCell *cell = nil;
  if (_beginSearch) {
    cell = [self drawSearchResultCell:[self dequeueTableViewCell] indexPath:indexPath];
  } else {
    if (indexPath.row == self.recentSearchKeywords.count) {
      cell = [self drawClearHistoryCell];
    } else {
      cell = [self drawRecentKeywordsCell:[self dequeueTableViewCell] indexPath:indexPath];
    }
  }
  
  return cell;
}

- (void)clearSearchingHistory {
  DELETE_OBJS_FROM_MOC(_MOC, @"SearchKeyword", nil);
  
  [self.recentSearchKeywords removeAllObjects];
  
  [_tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  if (!_beginSearch) {
    if (self.recentSearchKeywords.count > 0 && indexPath.row == self.recentSearchKeywords.count) {
      [self clearSearchingHistory];
    }
  }
}

#pragma mark - UISearchBarDelegate method
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  if (_filterListDelegate) {
    
    [self close];
  }
}

- (void)saveRecentKeywordIfNeeded {
  if (![WXWCoreDataUtils objectInMOC:_MOC 
                       entityName:@"SearchKeyword" 
                        predicate:[NSPredicate predicateWithFormat:@"searchString == %@", self.keywords]]) {
    SearchKeyword *searchKeywordObj = (SearchKeyword *)[NSEntityDescription insertNewObjectForEntityForName:@"SearchKeyword"
                                                                                     inManagedObjectContext:_MOC];
    searchKeywordObj.searchString = self.keywords;
    searchKeywordObj.timestamp = @([CommonUtils convertToUnixTS:[NSDate date]]);
    SAVE_MOC(_MOC);
  }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  if (_filterListDelegate) {
    
    [self saveRecentKeywordIfNeeded];
    
    [self close];
    
    [_filterListDelegate searchNearbyWithFilter:ENTIRE_CITY
                                       sortType:SI_SORT_BY_LIKE_COUNT_TY
                                       keywords:self.keywords];
  }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  NSLog(@"searchText: %@", searchText);
  
  if (!_beginSearch) {
    _beginSearch = YES;
  }
  
  self.keywords = searchText;
  
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
  [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
  
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
  
  return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
  
  if (_beginSearch) {
    _beginSearch = NO;
  }
  
  return YES;
}

#pragma mark - UISearchDisplayDelegate methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchString:(NSString *)searchString {
  
  self.keywords = searchString;
  
  return NO;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
  
}
@end
