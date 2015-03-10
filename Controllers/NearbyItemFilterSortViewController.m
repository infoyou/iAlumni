//
//  NearbyItemFilterSortViewController.m
//  ExpatCircle
//
//  Created by Adam on 11-12-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NearbyItemFilterSortViewController.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "WXWLabel.h"
#import "FilterSortListHeaderView.h"
#import "FiltersContainerCell.h"
#import "ItemListSectionView.h"
#import "SortOption.h"
#import "FilterOption.h"

enum {
  FILTER_SEC,
  SORT_SEC,
};

enum {
  WITHIN_2KM_CELL,
  WITHIN_5KM_CELL,
  WITHIN_10KM_CELL,
  ENTIER_CITY_CELL,
};

enum {
  SORTBY_DISTANCE_CELL,
  SORTBY_MY_CO_RATE_CELL,
  SORTBY_COMMENT_COUNT_CELL,
  SORTBY_COMMON_RATE_CELL,
};

#define SECTION_COUNT 2
#define FILTER_SEC_CELL_COUNT 4
#define SORT_SEC_CELL_COUNT   4

#define TWO_FILTERS_HEIGHT    180.0f
#define ONE_FILTER_HEIGHT     90.0f
#define SORT_CELL_HEIGHT      44.0f

#define SECTION_VIEW_HEIGHT   18.0f

#define FILTER_SELECTED_ICON_TAG  100
#define SORT_SELECTED_ICON_TAG    200

#define ICON_HEIGHT   24.0f
#define ICON_WIDTH    24.0f

#define HEADER_VIEW_HEIGHT        40.0f

#define SECTION_HEADER_HEIGHT     20.0f
#define HEADER_BUTTON_AREA_HEIGHT 40.0f

//#define TOP_OFFSET                100.0f

@interface NearbyItemFilterSortViewController()
@property (nonatomic, copy) NSString *originalSortOptionValue;
@property (nonatomic, retain) NSArray *sortOptions;
@property (nonatomic, retain) NSMutableDictionary *originalFilterOptions;
@end

@implementation NearbyItemFilterSortViewController

@synthesize originalSortOptionValue = _originalSortOptionValue;
@synthesize sortOptions = _sortOptions;
@synthesize originalFilterOptions = _originalFilterOptions;

#pragma mark - save/cancel actions
- (void)filterSort:(id)sender {
  if (_filterListDelegate) {
    //[((ECViewController *)_filterListDelegate) dismissModalQuickView];
    [_filterListDelegate filterSortNearbyItem];
    [self dismissModalViewControllerAnimated:YES];
  }
}

- (void)resetFilterOption:(FilterOptionType)type {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(type == %d)", type];
  NSArray *distanceOptions = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                                     entityName:@"FilterOption"
                                                      predicate:predicate];
  for (FilterOption *option in distanceOptions) {
    option.selected = @NO;
  }
  FilterOption *originalSelectedOption = (FilterOption *)(self.originalFilterOptions)[[NSNumber numberWithInt:type]];
  originalSelectedOption.selected = @YES;
  
  SAVE_MOC(_MOC);
}

- (void)resetSortFilter {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", _itemType];
  
  NSArray *sortOptions = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                                 entityName:@"SortOption"
                                                  predicate:predicate];;
  for (SortOption *option in sortOptions) {
    option.selected = @NO;
  }
  
  predicate = [NSPredicate predicateWithFormat:@"(optionValue == %@)", self.originalSortOptionValue];
  SortOption *option = (SortOption *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                            entityName:@"SortOption"
                                                             predicate:predicate];
  option.selected = @YES;
  
  SAVE_MOC(_MOC);
}

- (void)resetOrignalOptions {
  // reset filter options
  [self resetFilterOption:DISTANCE_FILTER_TY];
  
  if (_itemType == PEOPLE_ITEM_TY) {
    [self resetFilterOption:TIME_FILTER_TY];
  }
  
  // reset sort optins
  [self resetSortFilter];
}

- (void)cancel:(id)sender {
  
  [self resetOrignalOptions];
  
  if (_filterListDelegate) {
    //[((ECViewController *)_filterListDelegate) dismissModalQuickView];
    [self dismissModalViewControllerAnimated:YES];
  }
}

#pragma mark - lifecycle methods

- (void)preloadSortOptions {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", _itemType];
  
  NSMutableArray *descriptors = [NSMutableArray array];
  NSSortDescriptor *sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"optionValue" ascending:YES] autorelease];
  [descriptors addObject:sortDesc];
  
  self.sortOptions = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                             entityName:@"SortOption"
                                              predicate:predicate
                                              sortDescs:descriptors];
}

- (void)saveOriginalSelectedOptions {
  // save original selected sort option
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((usageType == %d) AND (selected == 1))", _itemType];
  SortOption *sortOption = (SortOption *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                entityName:@"SortOption"
                                                                 predicate:predicate];
  if (sortOption) {
    self.originalSortOptionValue = sortOption.optionValue;
  }
  
  // save original selected distance and time filter options  
  self.originalFilterOptions = [NSMutableDictionary dictionary];
  
  predicate = [NSPredicate predicateWithFormat:@"((type == %d) AND (selected == 1))", DISTANCE_FILTER_TY];
  FilterOption *distanceOption = (FilterOption *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                        entityName:@"FilterOption"
                                                                         predicate:predicate];
  if (distanceOption) {
    (self.originalFilterOptions)[@(DISTANCE_FILTER_TY)] = distanceOption;
  }
  
  if (_itemType == PEOPLE_ITEM_TY) {
    predicate = [NSPredicate predicateWithFormat:@"((type == %d) AND (selected == 1))", TIME_FILTER_TY];
    FilterOption *timeOption = (FilterOption *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                      entityName:@"FilterOption"
                                                                       predicate:predicate];
    if (timeOption) {
      (self.originalFilterOptions)[@(TIME_FILTER_TY)] = timeOption;
    }    
  }
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
       filterType:(NearbyDistanceFilter)filterType
         sortType:(ServiceItemSortType)sortType
         itemType:(NearbyItemType)itemType
filterListDelegate:(id<ECFilterListDelegate>)filterListDelegate {
  
  self = [super initWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 needGoHome:NO];
  
  if (self) {
    _filterType = filterType;
    _sortType = sortType;
    
    _itemType = itemType;
    [self preloadSortOptions];
    
    // save original selected filter and sort options for reset option selection status if user cancelled
    [self saveOriginalSelectedOptions];
    
    _filterListDelegate = filterListDelegate;
  }
  
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_filterTitleView);
  RELEASE_OBJ(_sortTitleView);
  RELEASE_OBJ(_filterSectionView);
  RELEASE_OBJ(_sortSectionView);
  
  self.originalSortOptionValue = nil;
  self.sortOptions = nil;
  self.originalFilterOptions = nil;
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  [self addLeftBarButtonWithTitle:LocaleStringForKey(NSGoTitle, nil)
                           target:self
                           action:@selector(filterSort:)];

  [self addRightBarButtonWithTitle:LocaleStringForKey(NSCloseTitle, nil)
                            target:self
                            action:@selector(cancel:)];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  return NO;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  
  switch (section) {
    case FILTER_SEC:
      return 1;//FILTER_SEC_CELL_COUNT;
      
    case SORT_SEC:
      return self.sortOptions.count;
      
    default:
      return 0;
  }
}

- (UITableViewCell *)drawSortCell:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"sortCell";
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:cellIdentifier] autorelease];
    cell.contentView.backgroundColor = TRANSPARENT_COLOR;
    cell.textLabel.textColor = COLOR(110, 110, 110);
    cell.textLabel.shadowColor = [UIColor whiteColor];
    cell.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = BOLD_FONT(14);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *selectedIcon = [[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - ICON_WIDTH - MARGIN * 5,
                                                                               22 - ICON_HEIGHT/2,
                                                                               ICON_WIDTH, ICON_HEIGHT)] autorelease];
    selectedIcon.tag = SORT_SELECTED_ICON_TAG;
    selectedIcon.backgroundColor = TRANSPARENT_COLOR;
    [cell.contentView addSubview:selectedIcon];
  }
  
  UIImageView *icon = (UIImageView *)[cell.contentView viewWithTag:SORT_SELECTED_ICON_TAG];
  
  SortOption *sortOption = (SortOption *)(self.sortOptions)[indexPath.row];
  
  cell.textLabel.text = sortOption.optionName;
  icon.image = (sortOption.selected.boolValue == YES ? RADIO_BUTTON_IMG : UNSELECTED_IMG);
  /*
   switch (indexPath.row) {
   case SORTBY_DISTANCE_CELL:
   if (_sortType == SI_SORT_BY_DISTANCE_TY) {
   icon.image = RADIO_BUTTON_IMG;
   } else {
   icon.image = UNSELECTED_IMG;
   }
   cell.textLabel.text = LocaleStringForKey(NSSortByDistanceTitle, nil);
   break;
   
   case SORTBY_MY_CO_RATE_CELL:
   if (_sortType == SI_SORT_BY_MY_CO_LIKE_TY) {
   icon.image = RADIO_BUTTON_IMG;
   } else {
   icon.image = UNSELECTED_IMG;
   }
   cell.textLabel.text = LocaleStringForKey(NSSortByMyCountryRateTitle, nil);
   break;
   
   case SORTBY_COMMON_RATE_CELL:
   if (_sortType == SI_SORT_BY_LIKE_COUNT_TY) {
   icon.image = RADIO_BUTTON_IMG;
   } else {
   icon.image = UNSELECTED_IMG;
   }
   cell.textLabel.text = LocaleStringForKey(NSSortByCommonRateTitle, nil);
   break;
   
   case SORTBY_COMMENT_COUNT_CELL:
   if (_sortType == SI_SORT_BY_COMMENT_COUNT_TY) {
   icon.image = RADIO_BUTTON_IMG;
   } else {
   icon.image = UNSELECTED_IMG;
   }
   
   cell.textLabel.text = LocaleStringForKey(NSSortByCommentTitle, nil);
   break;
   
   default:
   break;
   }
   */
  return cell;
}

- (UITableViewCell *)drawFiltersContainerCell {
  static NSString *cellIdentifier = @"filterCell";
  
  FiltersContainerCell *cell = (FiltersContainerCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  BOOL needDistanceFilter = YES;
  BOOL needTimeFilter = YES;
  CGFloat height = 0;
  if (_itemType == VENUE_ITEM_TY) {
    needTimeFilter = NO;
    height = ONE_FILTER_HEIGHT;
  } else {
    height = TWO_FILTERS_HEIGHT;
  }
  
  if (nil == cell) {
    cell = [[[FiltersContainerCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:cellIdentifier
                                                    MOC:_MOC
                                     needDistanceFilter:needDistanceFilter
                                         needTimeFilter:needTimeFilter
                                        containerHeight:height] autorelease];
  }
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case FILTER_SEC:
      return [self drawFiltersContainerCell];
      
    case SORT_SEC:
      return [self drawSortCell:indexPath];
      
    default:
      return nil;
  }
}

- (UIView *)sectionTitle:(UIView **)headerView section:(NSInteger)section {
  if (nil == (*headerView)) {
    *headerView = [[UIView alloc] init];
    (*headerView).backgroundColor = TRANSPARENT_COLOR;
    WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:[UIColor grayColor]
                                         shadowColor:[UIColor whiteColor]] autorelease];
    label.font = BOLD_FONT(14);
    [*headerView addSubview:label];
    
    switch (section) {
      case FILTER_SEC:
      {
        (*headerView).frame = CGRectMake(0, 0,
                                         self.view.frame.size.width,
                                         SECTION_HEADER_HEIGHT);
        label.text = LocaleStringForKey(NSFilterTitle, nil);
        label.frame = CGRectMake(MARGIN * 2, MARGIN * 2,
                                 300.0f,
                                 SECTION_HEADER_HEIGHT);
        break;
      }
        
      case SORT_SEC:
      {
        (*headerView).frame = CGRectMake(0, 0,
                                         self.view.frame.size.width,
                                         SECTION_HEADER_HEIGHT);
        label.text = LocaleStringForKey(NSSortTitle, nil);
        label.frame = CGRectMake(MARGIN * 2, 0,
                                 300.0f,
                                 SECTION_HEADER_HEIGHT);
        break;
      }
        
      default:
        label.text = nil;
    }
  }
  
  return *headerView;
}

- (UIView *)arrangeSectionView:(ItemListSectionView **)sectionView
                         title:(NSString *)title {
  if (nil == (*sectionView)) {
    (*sectionView) = [[ItemListSectionView alloc] initWithFrame:CGRectMake(0, 0,
                                                                           self.view.frame.size.width,
                                                                           SECTION_VIEW_HEIGHT)
                                                          title:title];
  }
  return (*sectionView);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
    case FILTER_SEC:
      if (_itemType == VENUE_ITEM_TY) {
        
        return ONE_FILTER_HEIGHT;
      } else {
        return TWO_FILTERS_HEIGHT;
      }
      
    case SORT_SEC:
      return SORT_CELL_HEIGHT;
      
    default:
      return 0;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
  switch (section) {
    case FILTER_SEC:
      return [self arrangeSectionView:&_filterSectionView
                                title:LocaleStringForKey(NSFilterTitle, nil)];
    case SORT_SEC:
      return [self arrangeSectionView:&_sortSectionView
                                title:LocaleStringForKey(NSSortTitle, nil)];
      
    default:
      return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  
  return SECTION_VIEW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (indexPath.section) {
    case FILTER_SEC:
      switch (indexPath.row) {
        case WITHIN_2KM_CELL:
          _filterType = NEARBY_2_KM;
          break;
          
        case WITHIN_5KM_CELL:
          _filterType = NEARBY_5_KM;
          break;
          
        case WITHIN_10KM_CELL:
          _filterType = NEARBY_10_KM;
          break;
          
        case ENTIER_CITY_CELL:
          _filterType = ENTIRE_CITY;
          break;
          
        default:
          break;
      }
      break;
      
    case SORT_SEC:
      /*
       switch (indexPath.row) {
       case SORTBY_DISTANCE_CELL:
       _sortType = SI_SORT_BY_DISTANCE_TY;
       break;
       
       case SORTBY_MY_CO_RATE_CELL:
       _sortType = SI_SORT_BY_MY_CO_LIKE_TY;
       break;
       
       case SORTBY_COMMON_RATE_CELL:
       _sortType = SI_SORT_BY_LIKE_COUNT_TY;
       break;
       
       case SORTBY_COMMENT_COUNT_CELL:
       _sortType = SI_SORT_BY_COMMENT_COUNT_TY;
       break;
       
       default:
       break;
       }
       break;
       */
    {
      SortOption *selectedSortOption = (SortOption *)(self.sortOptions)[indexPath.row];
      for (SortOption *sortOption in self.sortOptions) {
        sortOption.selected = @NO;
      }
      selectedSortOption.selected = @YES;
      
      SAVE_MOC(_MOC);
      break;
    }
      
    default:
      break;
  }
    
  [_tableView beginUpdates];
  [_tableView reloadSections:[NSIndexSet indexSetWithIndex:SORT_SEC] withRowAnimation:UITableViewRowAnimationNone];
  [_tableView endUpdates];
}

@end
