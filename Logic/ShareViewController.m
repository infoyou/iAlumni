//
//  ShareViewController.m
//  iAlumni
//
//  Created by Adam on 12-6-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareViewController.h"
#import "PostDetailViewController.h"
#import "ComposerViewController.h"
#import "WXWNavigationController.h"
#import "ECHandyImageBrowser.h"
#import "ItemPropertiesListViewController.h"
#import "PostToolView.h"
#import "ShareListCell.h"
#import "SortOption.h"
#import "Country.h"
#import "Place.h"
#import "SharePost.h"
#import "Tag.h"
#import "Distance.h"
#import "SortOptionListViewController.h"
#import "WXWDebugLogOutput.h"
#import "AlumniProfileViewController.h"
#import "CoreDataUtils.h"
#import "WXWBarItemButton.h"

#define TAG_HEIGHT      20.0f

@interface ShareViewController ()
@property (nonatomic, copy) NSString *filterCountryId;
@property (nonatomic, copy) NSString *currentTagIds;
@property (nonatomic, copy) NSString *currentFiltersTitle;
@property (nonatomic, copy) NSString *distanceParams;
@property (nonatomic, copy) NSString *filterCityId;
@property (nonatomic, copy) NSString *targetUserId;
@property (nonatomic, assign) NSInteger pageIndex;
@end

@implementation ShareViewController
@synthesize currentTagIds = _currentTagIds;
@synthesize currentFiltersTitle = _currentFiltersTitle;
@synthesize filterCountryId = _filterCountryId;
@synthesize distanceParams = _distanceParams;
@synthesize filterCityId = _filterCityId;
@synthesize targetUserId = _targetUserId;

#pragma mark - init
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
         listType:(ItemListType)listType {
  
  self = [super initWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:YES
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    
    _listType = listType;
    _sortType = SORT_BY_ID_TY;
    _favoriteItemType = ALL_CATEGORY_TY;
    
    self.currentTagIds = NULL_PARAM_VALUE;
    self.filterCountryId = NULL_PARAM_VALUE;
    self.distanceParams = NULL_PARAM_VALUE;
    self.filterCityId = NULL_PARAM_VALUE;
    
    [CoreDataUtils resetSortOptions:_MOC];
    [CoreDataUtils resetDistance:_MOC];
    DELETE_OBJS_FROM_MOC(_MOC, @"Tag", nil);
    
    _currentContentOffset_y = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectedFeedBeDeleted)
                                                 name:FEED_DELETED_NOTIFY
                                               object:nil];
    
    // clear all share post to avoid the deleted post be displayed again
    DELETE_OBJS_FROM_MOC(_MOC, @"SharePost", nil);
    
    // clear 'FavoritedPost' to avoid duplicate item displayed, because FavoritedPost is inherited from
    // SharePost, the fetched objects contains the FavoritedPost and SharePost
    DELETE_OBJS_FROM_MOC(_MOC, @"FavoritedPost", nil);
    
  }
  return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
     targetUserId:(NSString *)targetUserId {
  self = [self initWithMOC:MOC
                    holder:holder
          backToHomeAction:backToHomeAction
                  listType:SENT_ITEM_LIST_TY];
  if (self) {
    self.targetUserId = targetUserId;
  }
  return self;
}

#pragma mark - composer post
- (void)doPost:(id)sender {
  
  if (_tagsFetched) {
    ComposerViewController *composerVC = [[[ComposerViewController alloc] initForShareWithMOC:_MOC
                                                                                     delegate:self
                                                                                      groupId:LLINT_TO_STRING([AppManager instance].feedGroupId.longLongValue)] autorelease];
    composerVC.title = LocaleStringForKey(NSNewFeedTitle, nil);
    WXWNavigationController *navVC = [[[WXWNavigationController alloc] initWithRootViewController:composerVC] autorelease];
    [self.navigationController presentModalViewController:navVC animated:YES];
    
    _returnFromComposer = YES;
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchingTagMsg, nil)
                                  msgType:WARNING_TY
                       belowNavigationBar:YES];
  }
}

- (void)loadTagData
{
  [CommonUtils doDelete:_MOC entityName:@"Tag"];
  _currentType = POST_TAG_LIST_TY;
  
  NSString *param = [NSString stringWithFormat:@"<post_type>%d</post_type>", SHARE_TAG_TY];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  [connFacade fetchGets:url];
}

#pragma mark - load posts
- (void)allTagSelected {
  self.currentTagIds = NULL_PARAM_VALUE;
  self.currentFiltersTitle = LocaleStringForKey(NSAllTitle, nil);
}

- (void)allScopeSearch {
  self.filterCityId = NULL_PARAM_VALUE;
  self.distanceParams = NULL_PARAM_VALUE;
}

- (void)oneTagSelected:(Tag *)selectedTag {
  self.currentFiltersTitle = LocaleStringForKey(NSAllTitle, nil);
}

- (void)parserSelectedTags {
  
  NSArray *tags = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                          entityName:@"Tag"
                                           predicate:SELECTED_PREDICATE];
  self.currentFiltersTitle = nil;
  
  if (tags && [tags count] > 0) {
    NSInteger index = 0;
    self.currentTagIds = nil;
    
    for (Tag *tag in tags) {
      if (index == 0) {
        self.currentFiltersTitle = tag.tagName;
        self.currentTagIds = [NSString stringWithFormat:@"%@", tag.tagId];
      } else {
        self.currentTagIds = [NSString stringWithFormat:@"%@,%@", self.currentTagIds, tag.tagId];
        self.currentFiltersTitle = [NSString stringWithFormat:@"%@, %@", tag.tagName, self.currentFiltersTitle];
      }
      
      index++;
    }
    
  } else {
    [self allTagSelected];
  }
}

- (void)parserSeletedPlace {
  Place *place = (Place *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                 entityName:@"Place"
                                                  predicate:SELECTED_PREDICATE];
  if (place) {
    
    if ([ALL_RADIUS_PLACE_ID isEqualToString:place.placeId]) {
      [self allScopeSearch];
    } else {
      
      if (place.distance.floatValue == 0.0f) {
        // place is city
        self.filterCityId = [NSString stringWithFormat:@"%@", place.cityId];
        self.distanceParams = NULL_PARAM_VALUE;
        
      } else {
        // place is radius search area
        self.filterCityId = NULL_PARAM_VALUE;
        self.distanceParams = @"place.distance.floatValue, [AppManager instance].latitude, [AppManager instance].longitude";
      }
      
      self.currentFiltersTitle = [NSString stringWithFormat:@"%@, %@",
                                  self.currentFiltersTitle,
                                  place.placeName];
    }
    
  } else {
    [self allScopeSearch];
  }
}

#pragma mark - prepare Condition
- (void)prepareCondition
{
  if (![IPHONE_SIMULATOR isEqualToString:[CommonUtils deviceModel]]) {
    [AppManager instance].latitude = 0.0;
    [AppManager instance].longitude = 0.0;
    [AppManager instance].defaultPlace = NULL_PARAM_VALUE;
    [AppManager instance].defaultThing = NULL_PARAM_VALUE;
    
    [self getCurrentLocationInfoIfNecessary];
    //        [UIUtils showActivityView:self.view
    //                             text:LocaleStringForKey(NSShakeLoadingTitle, nil)];
  } else {
    [AppManager instance].latitude = [SIMULATION_LATITUDE doubleValue];
    [AppManager instance].longitude = [SIMULATION_LONGITUDE doubleValue];
    [self parserSelectedDistance];
  }
}

- (void)parserSelectedDistance {
  
  Distance *distance = (Distance *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                          entityName:@"Distance"
                                                           predicate:SELECTED_PREDICATE];
  
  if (distance.valueFloat.floatValue != ALL_LOCATION_RADIUS) {
    if (![self.currentFiltersTitle isEqualToString:LocaleStringForKey(NSAllTitle, nil)]) {
      self.currentFiltersTitle = [NSString stringWithFormat:@"%@, %@", distance.desc, self.currentFiltersTitle];
    } else {
      self.currentFiltersTitle = distance.desc;
    }
  }
  
  self.distanceParams = [NSString stringWithFormat:@"<distance>%@</distance><latitude>%@</latitude><longitude>%@</longitude>",
                         distance.valueString,
                         [NSString stringWithFormat:@"%.8f", [AppManager instance].latitude],
                         [NSString stringWithFormat:@"%.8f", [AppManager instance].longitude]];
}

- (void)parserSelectedCountry {
  Country *country = (Country *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                       entityName:@"Country"
                                                        predicate:SELECTED_PREDICATE];
  if (country) {
    if (country.countryId.longLongValue == CO_ALL_ID) {
      self.filterCountryId = NULL_PARAM_VALUE;
    } else {
      self.filterCountryId = [NSString stringWithFormat:@"%@", country.countryId];
      switch ([WXWCommonUtils currentLanguage]) {
        case ZH_HANS_TY:
          self.currentFiltersTitle = [NSString stringWithFormat:@"%@, %@", self.currentFiltersTitle, country.name];
          break;
          
        case EN_TY:
          self.currentFiltersTitle = [NSString stringWithFormat:@"%@, %@", self.currentFiltersTitle, country.name];
          break;
        default:
          break;
      }
    }
    
  } else {
    self.filterCountryId = NULL_PARAM_VALUE;
  }
}

- (void)parserFavoriteFilter {
  if (_favoriteItemType == FAVORITED_CATEGORY_TY) {
    if (![self.currentFiltersTitle isEqualToString:LocaleStringForKey(NSAllTitle, nil)]) {
      self.currentFiltersTitle = [NSString stringWithFormat:@"%@, %@",
                                  LocaleStringForKey(NSFavoritedTitle, nil),
                                  self.currentFiltersTitle];
    } else {
      self.currentFiltersTitle = LocaleStringForKey(NSFavoritedTitle, nil);
    }
  }
}

- (void)applyFilters {
  
  [self parserSelectedTags];
  
  //[self parserSeletedPlace];
  [self prepareCondition];
  //  [self parserSelectedDistance];
  [self parserFavoriteFilter];
  
  [_toolTitleView setFiltersText:self.currentFiltersTitle];
}

- (void)applySortOption {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((usageType == %d) AND (selected == 1))", POST_ITEM_TY];
  SortOption *option = (SortOption *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                            entityName:@"SortOption"
                                                             predicate:predicate];
  if (option) {
    [_toolTitleView setSortText:option.optionName];
    _sortType = option.optionId.intValue;
  }
}

#pragma mark - override methods
- (void)configureMOCFetchConditions {
  
  switch (_listType) {
    case SENT_ITEM_LIST_TY:
      // filter the posts that sent by a specified user
      self.predicate = [NSPredicate predicateWithFormat:@"(authorId == %@)", self.targetUserId];
      break;
      
    default:
      break;
  }
  
  self.entityName = @"SharePost";
  self.descriptors = [NSMutableArray array];
  
  switch (_sortType) {
    case SORT_BY_ID_TY:
    {
      NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor];
      break;
    }
    case SORT_BY_PRAISE_COUNT_TY:
    {
      NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"likeCount" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor1];
      NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
      [self.descriptors addObject:descriptor2];
      break;
    }
      /*
       case SORT_BY_COMMENT_TIME_TY:
       {
       NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"lastCommentTimestamp" ascending:NO] autorelease];
       [self.descriptors addObject:descriptor1];
       NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
       [self.descriptors addObject:descriptor2];
       break;
       }
       */
    case SORT_BY_COMMENT_COUNT_TY:
    {
      NSSortDescriptor *descriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"commentCount"
                                                                   ascending:NO] autorelease];
      [self.descriptors addObject:descriptor1];
      NSSortDescriptor *descriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"postId"
                                                                   ascending:NO] autorelease];
      [self.descriptors addObject:descriptor2];
      break;
    }
      
    default:
      break;
  }
}

#pragma mark - load posts
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _showNewLoadedItemCount = NO;
  
  _currentType = SHARE_POST_LIST_TY;
  
  NSInteger favoriteFlag = 1;
  if (_favoriteItemType == ALL_CATEGORY_TY) {
    favoriteFlag = 0;
  }
  
  NSString *param = [NSString stringWithFormat:@"<page_size>30</page_size><is_favorite>%d</is_favorite><tag_ids>%@</tag_ids>%@<sort_type>%d</sort_type><post_type>%d</post_type><latitude>%f</latitude><longitude>%f</longitude>",
                     favoriteFlag,
                     self.currentTagIds,
                     self.distanceParams,
                     _sortType,
                     SHARE_POST_TY,
                     [AppManager instance].latitude,
                     [AppManager instance].longitude];
  
  NSMutableString *requestParam = [NSMutableString stringWithString:param];
  if (forNew) {
    [requestParam appendString:@"<page>0</page>"];
  } else {
    [requestParam appendFormat:@"<page>%d</page>", self.pageIndex++];
  }
  
  NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:_currentType];
  [connFacade fetchNews:url];  
}

#pragma mark - post delete handle
- (void)selectedFeedBeDeleted {
  _selectedFeedBeDeleted = YES;
}

#pragma mark - lifecycle methods
- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
    
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSPostTitle,nil)
                            target:self
                            action:@selector(doPost:)];
  
  _toolTitleView = [[PostToolView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TOOL_TITLE_HEIGHT)
                                              topColor:COLOR(246, 246, 246)
                                           bottomColor:COLOR(220, 218, 219)
                                              delegate:self];
  [self.view addSubview:_toolTitleView];
  
  _tableView.frame = CGRectMake(0, _tableView.frame.origin.y + TOOL_TITLE_HEIGHT,
                                _tableView.frame.size.width, _tableView.frame.size.height - TOOL_TITLE_HEIGHT);
  
  // fetch tags firstly for prepare meta data for send post and filtering
  [self loadTagData];
}

- (void)clearAllPosts {
  DELETE_OBJS_FROM_MOC(_MOC, @"SharePost", nil);
}

- (void)clearTableView {
  self.fetchedRC = nil;
  
  [self clearAllPosts];
  
  [_tableView reloadData];
}

- (void)reloadForFiltersChangeIfNecessary {
  if (_filtersChanged) {
    [self applyFilters];
    
    [self clearTableView];
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    
    _filtersChanged = NO;
  }
}

- (void)refreshForSortOptionsChangeIfNecessary {
  if (_sortOptionsChanged) {
    
    [self applySortOption];
    
    [self refreshTable];
    
    _sortOptionsChanged = NO;
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // if the selected post be deleted, then should not update the cell, because the post has been removed from MOC
  if (!_selectedFeedBeDeleted) {
    [self updateLastSelectedCell];
  } else {
    [self deleteLastSelectedCell];
  }
  
  [self reloadForFiltersChangeIfNecessary];
  
  [self refreshForSortOptionsChangeIfNecessary];
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  
  if (!_returnFromComposer) {
    
    // if the selected post be deleted, then no need to load new post
    if (!_selectedFeedBeDeleted) {
      
      if (!_autoLoaded) {
        
        // check whether this is first time user use this list (user this app first time)
        if ([WXWCoreDataUtils objectInMOC:_MOC entityName:@"SharePost" predicate:nil]) {
          
          _userFirstUseThisList = NO;
          
          // this is not first time user entered this list, so take following actions:
          
          // 1. load local posts firstly
          [self refreshTable];
          
        } else {
          // this is user first time use this app
          _userFirstUseThisList = YES;
        }
        
        // then load new posts secondly
        if (_tagsFetched) {
          [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
        }
      }
      
    } else {
      
      _selectedFeedBeDeleted = NO;
    }
    
  } else {
    _returnFromComposer = NO;
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)clearData {
  // delete 'Place' and 'ComposerPlace' instance from MOC firstly
  NSPredicate *placePredicate = [NSPredicate predicateWithFormat:@"(type == %d)", PLACE_TY];
  DELETE_OBJS_FROM_MOC(_MOC, @"Tag", placePredicate);
  DELETE_OBJS_FROM_MOC(_MOC, @"ComposerTag", nil);
  DELETE_OBJS_FROM_MOC(_MOC, @"Place", nil);
}

- (void)dealloc {
  
  [[WXWImageManager instance].imageCache clearAllCachedImages];
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:FEED_DELETED_NOTIFY
                                                object:nil];
  
  RELEASE_OBJ(_toolTitleView);
  
  self.currentTagIds = nil;
  self.currentFiltersTitle = nil;
  self.filterCountryId = nil;
  self.distanceParams = nil;
  self.filterCityId = nil;
  self.targetUserId = nil;
  
  [self clearData];
  
  [super dealloc];
}

#pragma mark - ECFilterListDelegate methods

- (void)showSortOptionList {
  
  _sortOptionsChanged = YES;
  
  SortOptionListViewController *sortOptionListVC = [[[SortOptionListViewController alloc] initWithMOC:_MOC
                                                                                               holder:_holder
                                                                                     backToHomeAction:_backToHomeAction] autorelease];
  
  self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSSortTitle, nil)
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:nil
                                                                           action:nil] autorelease];
  
  [self.navigationController pushViewController:sortOptionListVC animated:YES];
  
}

- (void)showFilterList {
  
  if (_tagsFetched) {
    [self goFliterView];
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchingTagMsg, nil)
                                  msgType:WARNING_TY
                       belowNavigationBar:YES];
  }
}

- (void)goFliterView
{
  _filtersChanged = YES;
  
  ItemPropertiesListViewController *filterListVC = [[[ItemPropertiesListViewController alloc] initWithMOC:_MOC
                                                                                                   holder:_holder
                                                                                         backToHomeAction:_backToHomeAction
                                                                                     parentEditorDelegate:self
                                                                                             propertyType:SHARING_FILTER_TY
                                                                                          filterCountryId:self.filterCountryId.longLongValue
                                                                                                  tagType:SHARE_TY] autorelease];
  
  self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSDoFilterTitle, nil)
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:nil
                                                                           action:nil] autorelease];
  
  [self.navigationController pushViewController:filterListVC animated:YES];
  
  [self clearLastSelectedIndexPath];
}

#pragma mark - ECEditorDelegate method
- (void)chooseFavoriteType:(ItemFavoriteCategory)favoriteType {
  
  _favoriteItemType = favoriteType;
}

#pragma mark - ECItemUploaderDelegate methods
- (void)afterUploadFinishAction:(WebItemType)actionType {
  _autoLoadAfterSent = YES;
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - check latest/oldest post properties
- (void)checkAndSetCurrentLatestFeedTimeline:(NSIndexPath *)indexPath
                                        post:(SharePost *)post {
  
	// record the latest post time
	if (indexPath.section == 0 && indexPath.row == 0) {
    _currentLatestTimeline = [post.timestamp doubleValue];
		_currentLatestFeedId = [post.postId longLongValue];
	}
}

- (void)checkAndSetCurrentOldestFeedTimeline:(NSIndexPath *)indexPath
                                        post:(SharePost *)post {
  
	// record the oldest post time
	if (indexPath.section == [_fetchedRC.sections count] - 1) {
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchedRC sections][indexPath.section];
    if (indexPath.row == [sectionInfo numberOfObjects] - 1) {
      
      _currentOldestTimeline = [post.timestamp doubleValue];
      _currentOldestFeedId = [post.postId longLongValue];
      _currentStartIndex = indexPath.row + 1;
    }
	}
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSLog(@"total count: %d", _fetchedRC.fetchedObjects.count);
  return _fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return [self drawFooterCell];
  }
  
  SharePost *post = [_fetchedRC objectAtIndexPath:indexPath];
  
  [self checkAndSetCurrentLatestFeedTimeline:indexPath post:post];
  [self checkAndSetCurrentOldestFeedTimeline:indexPath post:post];
  
  static NSString *cellIdentifier = @"ShareListCell";
  
  ShareListCell *cell = (ShareListCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    
    cell = [[[ShareListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:cellIdentifier
                          imageDisplayerDelegate:self
                          imageClickableDelegate:self
                                             MOC:_MOC] autorelease];
  }
  
  [cell drawPost:post MOC:_MOC];
  
  return cell;
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return FEED_CELL_HEIGHT;
  } else {
    
    SharePost *post = [_fetchedRC objectAtIndexPath:indexPath];
    
    CGFloat height = MARGIN * 8;
    
    CGFloat x = MARGIN * 2 + POSTLIST_PHOTO_WIDTH + MARGIN * 2;
    CGFloat width = self.view.frame.size.width - x - MARGIN * 2;
    CGSize size = [post.content sizeWithFont:FONT(15)
                           constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    
    height += size.height;
    
    if (post.imageAttached.boolValue) {
      height += MARGIN * 2;
      height += POST_IMG_LONG_SIDE;
      height += MARGIN;
    } else {
      height += MARGIN * 2;
    }
    
    height += CELL_BASE_INFO_HEIGHT;
    height += TAG_HEIGHT;
    height += MARGIN * 2;
    
    if (height < FEED_CELL_HEIGHT) {
      return FEED_CELL_HEIGHT;
    } else {
      return height;
    }
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  SharePost *post = [_fetchedRC objectAtIndexPath:indexPath];
  
  PostDetailViewController *detailVC = [[[PostDetailViewController alloc] initWithMOC:_MOC
                                                                               holder:_holder
                                                                     backToHomeAction:_backToHomeAction
                                                                                 post:(Post*)post
                                                                             postType:SHARE_POST_TY] autorelease];
  
  detailVC.title = LocaleStringForKey(NSPostDetailTitle, nil);
  
  [AppManager instance].isPostDetail = NO;
  [self.navigationController pushViewController:detailVC animated:YES];
  
  _lastSelectedIndexPath = indexPath;
}

#pragma mark - ECClickableElementDelegate method
- (void)openImageUrl:(NSString *)imageUrl {
  ECHandyImageBrowser *imageBrowser = [[[ECHandyImageBrowser alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                                           imgUrl:imageUrl] autorelease];
  [self.view addSubview:imageBrowser];
  [imageBrowser setNeedsLayout];
}


- (void)openProfile:(NSString*)userId userType:(NSString*)userType {

  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                    personId:userId
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - scrolling overrides

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[super scrollViewDidScroll:scrollView];
  _currentContentOffset_y = scrollView.contentOffset.y;
}

#pragma mark - ECConnectorDelegate methoes
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case POST_TAG_LIST_TY:
      [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
      break;
      
    case SHARE_POST_LIST_TY:
      [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:NO];
      break;
    default:
      break;
  }
  /*
   if (_userFirstUseThisList) {
   [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
   } else {
   
   }
   */
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case POST_TAG_LIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        _tagsFetched = YES;
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
        
      } else {
        _tagsFetched = NO;
      }
      
      [super connectDone:result url:url contentType:contentType closeAsyncLoadingView:NO];
    }
      break;
      
    case SHARE_POST_LIST_TY:
    {
      if (_loadForNewItem) {
        // clear all share post to avoid the deleted post be displayed again
        DELETE_OBJS_FROM_MOC(_MOC, @"SharePost", nil);
      }
      
      
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self refreshTable];
        
        if (!_autoLoadAfterSent) {
          // we hope table view keep the position for auto load, so we adjust content offset of table view auto load;
          // if the table view refresh triggered by load new post after post send, then we hope the latest sent post (just be downloaded) could be displayed for user, then we will not adjust the content offset
          
          CGFloat beforeRefreshTableHeight = _tableView.contentSize.height;
          CGPoint offsetPoint = _tableView.contentOffset;
          
          if (_loadForNewItem && beforeRefreshTableHeight > FEED_CELL_HEIGHT) {
            // only keep the table position when user start up app from second time, no need to keep position for user
            // enter news list first time
            // beforeRefreshTableHeight will be larger than 0 if there are news existing in local already
            CGFloat afterRefreshTableHeight = _tableView.contentSize.height;
            _currentContentOffset_y += afterRefreshTableHeight - beforeRefreshTableHeight;
            if (_currentContentOffset_y < 0) {
              _currentContentOffset_y = 0;
            } else {
              _tableView.contentOffset = CGPointMake(offsetPoint.x, _currentContentOffset_y);
            }
          }
        }
        
        if ([AppManager instance].loadedItemCount > 0 && !_autoLoadAfterSent) {
          
          // if table view refresh triggered by new post send, then the load successful message no need to be displayed for user;
          // if table view refresh triggered by auto load, then the new downloaded posts message should be displayed for user
          
          self.connectionResultMessage = [NSString stringWithFormat:LocaleStringForKey(NSNewFeedLoadedMsg, nil), [AppManager instance].loadedItemCount];
          /*
           [UIUtils showNotificationOnTopWithMsg:msg
           msgType:SUCCESS_TY
           belowNavigationBar:YES];
           */
        } else if (_autoLoadAfterSent) {
          _autoLoadAfterSent = NO;
        }
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSLoadFeedFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      if (_userFirstUseThisList) {
        _userFirstUseThisList = NO;
      }
      
      [super connectDone:result url:url contentType:contentType];
    }
      break;
      
    default:
      break;
  }
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  
  // should be called at end of method to clear connFacade instance
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  if (_autoLoadAfterSent) {
    _autoLoadAfterSent = NO;
  }
    
  if (_userFirstUseThisList) {
    _userFirstUseThisList = NO;
  }
  
  switch (contentType) {
    case POST_TAG_LIST_TY:
      _tagsFetched = NO;
      break;
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSLoadFeedFailedMsg, nil);
  }
  
  // should be called at end of method to clear connFacade instance
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - location result
- (void)locationResult:(LocationResultType)type{
  NSLog(@"shake type is %d", type);
  
  [UIUtils closeActivityView];
  
  switch (type) {
    case LOCATE_SUCCESS_TY:
    {
      [self parserSelectedDistance];
    }
      break;
      
    case LOCATE_FAILED_TY:
    {
      [UIUtils showNotificationOnTopWithMsg:@"定位失败"
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      
    }
      break;
      
    default:
      break;
  }
  
}

@end
