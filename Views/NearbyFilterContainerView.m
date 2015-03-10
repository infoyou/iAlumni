//
//  NearbyFilterContainerView.m
//  iAlumni
//
//  Created by Adam on 12-8-2.
//
//

#import "NearbyFilterContainerView.h"
#import "ECNodeFilter.h"
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "FilterOption.h"
#import "CoreDataUtils.h"
#import "UIUtils.h"


#define FILTER_WIDTH   280.0f
#define FILTER_HEIGHT  55.0f

@interface NearbyFilterContainerView()
@property (nonatomic, retain) NSArray *distanceFilterOptions;
@property (nonatomic, retain) NSArray *timeFilterOptions;
@end

@implementation NearbyFilterContainerView

@synthesize distanceFilterOptions = _distanceFilterOptions;
@synthesize timeFilterOptions = _timeFilterOptions;

#pragma mark - user action

- (void)changeDistance:(ECNodeFilter *)sender {
  for (FilterOption *option in self.distanceFilterOptions) {
    option.selected = @NO;
  }
  
  FilterOption *selectedOption = (FilterOption *)(self.distanceFilterOptions)[sender.SelectedIndex];
  selectedOption.selected = @YES;
  
  SAVE_MOC(_MOC);
}

- (void)changeTime:(ECNodeFilter *)sender {
  for (FilterOption *option in self.timeFilterOptions) {
    option.selected = @NO;
  }
  
  FilterOption *selectedOption = (FilterOption *)(self.timeFilterOptions)[sender.SelectedIndex];
  selectedOption.selected = @YES;
  
  SAVE_MOC(_MOC);
}

#pragma mark - lifecycle methods

- (void)initFilterWithFrame:(CGRect)frame
                     action:(SEL)action
                     filter:(ECNodeFilter **)filter
                      nodes:(NSArray *)nodes
                       type:(FilterOptionType)type {
  
  // parse current selected index of option
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((type == %d) AND (selected == 1))", type];
  FilterOption *option = (FilterOption *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                entityName:@"FilterOption"
                                                                 predicate:predicate];
  NSInteger selectedIndex = 0;
  
  switch (type) {
    case DISTANCE_FILTER_TY:
      selectedIndex = [self.distanceFilterOptions indexOfObject:option];
      break;
      
    case TIME_FILTER_TY:
      selectedIndex = [self.timeFilterOptions indexOfObject:option];
      break;
    default:
      break;
  }
  
  (*filter) = [[[ECNodeFilter alloc] initWithFrame:frame
                                            Titles:nodes
                                        allowSwipe:YES
                                 initSelectedIndex:selectedIndex
                              unselectedTitleColor:[UIColor darkGrayColor]] autorelease];
  
  (*filter).progressColor = NAVIGATION_BAR_COLOR;
  //  [(*filter) setTitlesColor:[UIColor darkGrayColor]];
  //[(*filter) setTitlesFont:BOLD_HK_FONT(11)];
  [(*filter) addTarget:self
                action:action
      forControlEvents:UIControlEventTouchUpInside];
  [self addSubview:(*filter)];
}

- (NSArray *)parseNodes:(FilterOptionType)type {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(type == %d)", type];
  NSMutableArray *descriptors = [NSMutableArray array];
  NSSortDescriptor *sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"valueFloat"
                                                            ascending:YES] autorelease];
  [descriptors addObject:sortDesc];
  
  NSArray *options = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                             entityName:@"FilterOption"
                                              predicate:predicate
                                              sortDescs:descriptors];
  switch (type) {
    case DISTANCE_FILTER_TY:
      self.distanceFilterOptions = options;
      break;
      
    case TIME_FILTER_TY:
      self.timeFilterOptions = options;
      break;
      
    default:
      break;
  }

  NSMutableArray *titles = [NSMutableArray array];
  for (FilterOption *option in options) {
    [titles addObject:option.desc];
  }
  
  return titles;  
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
 needDistanceFilter:(BOOL)needDistanceFilter
     needTimeFilter:(BOOL)needTimeFilter {
  self = [super initWithFrame:frame];
  if (self) {
    
    _MOC = MOC;
    
    CGFloat y = MARGIN * 2;
    if (needDistanceFilter) {
      
      WXWLabel *distanceTitle = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                     textColor:[UIColor grayColor]
                                                   shadowColor:[UIColor whiteColor]] autorelease];
      distanceTitle.font = BOLD_FONT(15);
      distanceTitle.text = LocaleStringForKey(NSDistanceTitle, nil);
      CGSize size = [distanceTitle.text sizeWithFont:distanceTitle.font
                                   constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
      distanceTitle.frame = CGRectMake(MARGIN * 2, MARGIN * 2, size.width, size.height);
      [self addSubview:distanceTitle];
            
      [self initFilterWithFrame:CGRectMake(MARGIN * 2,
                                           distanceTitle.frame.origin.y + size.height + MARGIN,
                                           FILTER_WIDTH, FILTER_HEIGHT)
                         action:@selector(changeDistance:)
                         filter:&_distanceFilter
                          nodes:[self parseNodes:DISTANCE_FILTER_TY]
                           type:DISTANCE_FILTER_TY];
      y = _distanceFilter.frame.origin.y + _distanceFilter.frame.size.height + MARGIN * 2;
    }
    
    if (needTimeFilter) {
      WXWLabel *timeTitle = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                 textColor:[UIColor grayColor]
                                               shadowColor:[UIColor whiteColor]] autorelease];
      timeTitle.font = BOLD_FONT(15);
      timeTitle.text = LocaleStringForKey(NSTimeTitle, nil);
      CGSize size = [timeTitle.text sizeWithFont:timeTitle.font
                               constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
      timeTitle.frame = CGRectMake(MARGIN * 2, y, size.width, size.height);
      [self addSubview:timeTitle];
      
      
      [self initFilterWithFrame:CGRectMake(MARGIN * 2, timeTitle.frame.origin.y + size.height + MARGIN,
                                           FILTER_WIDTH, FILTER_HEIGHT)
                         action:@selector(changeTime:)
                         filter:&_timeFilter
                          nodes:[self parseNodes:TIME_FILTER_TY]
                           type:TIME_FILTER_TY];
    }
  }
  return self;
}

- (void)dealloc {
  
  self.distanceFilterOptions = nil;
  self.timeFilterOptions = nil;
  
  [super dealloc];
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
