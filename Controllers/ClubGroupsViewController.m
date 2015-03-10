//
//  ClubGroupsViewController.m
//  iAlumni
//
//  Created by Adam on 13-1-28.
//
//

#import "ClubGroupsViewController.h"
#import "Club.h"
#import "ClubGroupCell.h"
#import "AppManager.h"
#import "WXWLabel.h"

#define GRID_HEIGHT       100
#define GRID_CELL_HEIGHT  GRID_HEIGHT + MARGIN * 2
#define ROW_ITEM_COUNT    2

#define SECTION_VIEW_HEIGHT 20.0f

#define SECTION_COUNT       2

enum {
  JOINED_SEC,
  POPULAR_SEC,
};

@interface ClubGroupsViewController ()
@property (nonatomic, retain) NSFetchedResultsController *joinedGroupFetchedRC;
@property (nonatomic, retain) NSFetchedResultsController *popularGroupFetchedRC;
@end

@implementation ClubGroupsViewController

#pragma mark - user action
- (void)openLeftClubGroup:(Club *)leftGroup  {
  if (_parentVC && _action && leftGroup) {
    [_parentVC performSelector:_action withObject:leftGroup];
  }
}

- (void)openRightClubGroup:(Club *)rightGroup {
  if (_parentVC && _action && rightGroup) {
    [_parentVC performSelector:_action withObject:rightGroup];
  }
}

#pragma mark - load data from MOC

- (void)configureMOCFetchConditions {
  self.entityName = @"Club";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder"
                                                            ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];
  
  self.predicate = [NSPredicate predicateWithFormat:@"(usageType == %d) OR (usageType == %d)", BIZ_JOINED_USAGE_GP_TY, BIZ_POPULAR_USAGE_GP_TY];
  
  /*
  NSPredicate *joinedPredicate = [NSPredicate predicateWithFormat:@"(alumniId == %@) AND (usageType == %d)", [AppManager instance].personId, BIZ_JOINED_USAGE_GP_TY];
  
  NSPredicate *popularPredicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", BIZ_POPULAR_USAGE_GP_TY];
  
  self.predicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:joinedPredicate, popularPredicate, nil]];
  */
  
}

- (void)loadGroups {
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder"
                                                            ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];
  
  self.entityName = @"JoinedGroup";
  self.predicate = [NSPredicate predicateWithFormat:@"(alumniId == %@) AND (usageType == %d)", [AppManager instance].personId, BIZ_JOINED_USAGE_GP_TY];
  self.joinedGroupFetchedRC = [self performFetchByFetchedRC:self.joinedGroupFetchedRC];
  
  self.entityName = @"Club";
  self.predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", BIZ_POPULAR_USAGE_GP_TY];
  self.popularGroupFetchedRC = [self performFetchByFetchedRC:self.popularGroupFetchedRC];
  
  [_tableView reloadData];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(id)parentVC
           action:(SEL)action
            frame:(CGRect)frame {
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 needGoHome:NO];
  if (self) {
    _parentVC = parentVC;
    
    _action = action;
    
    _frame = frame;
    
    _noNeedDisplayEmptyMsg = YES;
    
  }
  return self;
}

- (void)dealloc {
  
  self.joinedGroupFetchedRC = nil;
  self.popularGroupFetchedRC = nil;
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.frame = _frame;
  
  self.view.backgroundColor = TRANSPARENT_COLOR;
  
  _tableView.frame = CGRectMake(_tableView.frame.origin.x,
                                _tableView.frame.origin.y,
                                _tableView.frame.size.width,
                                _frame.size.height);
  
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  _tableView.backgroundColor = TRANSPARENT_COLOR;
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - section view
- (UIView *)sectionView:(NSString *)title {
  
  WXWLabel *titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                textColor:COLOR(50, 50, 50)
                                              shadowColor:TRANSPARENT_COLOR] autorelease];
  titleLabel.text = title;
  titleLabel.font = BOLD_FONT(13);
  
  CGSize size = [title sizeWithFont:titleLabel.font
                  constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 2, SECTION_VIEW_HEIGHT)
                      lineBreakMode:NSLineBreakByWordWrapping];
  titleLabel.frame = CGRectMake(MARGIN * 2, (SECTION_VIEW_HEIGHT - size.height)/2.0f,
                                size.width, size.height);
  
  UIView *sectionView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                  self.view.frame.size.width,
                                                                  SECTION_VIEW_HEIGHT)] autorelease];
  sectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  [sectionView addSubview:titleLabel];
  return sectionView;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

  switch (section) {
    case JOINED_SEC:
      return (self.joinedGroupFetchedRC.fetchedObjects.count + ROW_ITEM_COUNT - 1) / ROW_ITEM_COUNT;
      
    case POPULAR_SEC:
    {
      NSInteger rowCount = (self.popularGroupFetchedRC.fetchedObjects.count + ROW_ITEM_COUNT - 1) / ROW_ITEM_COUNT;
      
      _popularGroupCellCount = rowCount + 1;
      return _popularGroupCellCount;
    }
      
    default:
      return 0;
  }
}

- (UITableViewCell *)drawCell:(NSIndexPath *)indexPath
                    fetchedRC:(NSFetchedResultsController *)fetchedRC
               cellIdentifier:(NSString *)cellIdentifier {
  
  ClubGroupCell *cell = (ClubGroupCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[ClubGroupCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:cellIdentifier] autorelease];
  }
  
  NSInteger leftIndex = indexPath.row * 2;
  NSInteger rightIndex = indexPath.row * 2 + 1;
  
  if (leftIndex < fetchedRC.fetchedObjects.count) {
    Club *leftGroup = [fetchedRC.fetchedObjects objectAtIndex:leftIndex];
    
    if (leftGroup) {
      [cell drawLeftItem:indexPath.row
                   group:leftGroup
                entrance:self
                  action:@selector(openLeftClubGroup:)];
    } else {
      [cell hideLeftItem];
    }
  } else {
    
    [cell hideLeftItem];
  }
  
  if (rightIndex < fetchedRC.fetchedObjects.count) {
    Club *rightGroup = [fetchedRC.fetchedObjects objectAtIndex:rightIndex];
    
    if (rightGroup) {
      [cell drawRightItem:indexPath.row
                    group:rightGroup
                 entrance:self
                   action:@selector(openRightClubGroup:)];
    } else {
      [cell hideRightItem];
    }
  } else {
    [cell hideRightItem];
  }
  
  return cell;
}

- (UITableViewCell *)moreGroupCell {
  static NSString *kCellIdentifier = @"moreCell";
  
  UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  
  if (nil == cell) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:kCellIdentifier] autorelease];
    
    UIView *backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2,
                                                                       0,
                                                                       self.view.frame.size.width - MARGIN * 4,
                                                                       DEFAULT_CELL_HEIGHT)] autorelease];
    backgroundView.backgroundColor = COLOR(47, 47, 47);
    
    WXWLabel *titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                  textColor:[UIColor whiteColor]
                                                shadowColor:TRANSPARENT_COLOR] autorelease];
    titleLabel.font = BOLD_FONT(20);
    titleLabel.text = LocaleStringForKey(NSOtherDiscussGroupTitle, nil);
    CGSize size = [titleLabel.text sizeWithFont:titleLabel.font
                              constrainedToSize:CGSizeMake(backgroundView.frame.size.width - MARGIN * 4,
                                                           backgroundView.frame.size.height - MARGIN * 2)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    titleLabel.frame = CGRectMake((backgroundView.frame.size.width - size.width)/2.0f,
                                  (backgroundView.frame.size.height - size.height)/2.0f,
                                  size.width, size.height);
    [backgroundView addSubview:titleLabel];
    
    [cell.contentView addSubview:backgroundView];
    
    cell.backgroundColor = TRANSPARENT_COLOR;
    cell.contentView.backgroundColor = TRANSPARENT_COLOR;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case JOINED_SEC:
    
      return [self drawCell:indexPath
                  fetchedRC:self.joinedGroupFetchedRC
             cellIdentifier:@"joinedGroupCell"];
    
      
    case POPULAR_SEC:
    {
      if (indexPath.row < _popularGroupCellCount - 1) {
        return [self drawCell:indexPath
                    fetchedRC:self.popularGroupFetchedRC
               cellIdentifier:@"popularGroupCell"];
      } else {
        return [self moreGroupCell];
      }
    }
      
    default:
      return nil;
  }
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == POPULAR_SEC) {
    if (indexPath.row == _popularGroupCellCount - 1) {
      return DEFAULT_CELL_HEIGHT;
    }
  }

  return GRID_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return SECTION_VIEW_HEIGHT;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
  switch (section) {
    case JOINED_SEC:
    {
      return [self sectionView:LocaleStringForKey(NSJoinedDiscussGroupTitle, nil)];
    }
      
    case POPULAR_SEC:
    {
      return [self sectionView:LocaleStringForKey(NSPopularGroup, nil)];
    }
      
    default:
      return nil;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == POPULAR_SEC) {
    if (indexPath.row == _popularGroupCellCount - 1) {
      if (_parentVC && _action) {
        [_parentVC performSelector:_action withObject:nil];
      }
    }
  }
}

@end
