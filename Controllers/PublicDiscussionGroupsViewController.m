//
//  PublicDiscussionGroupsViewController.m
//  iAlumni
//
//  Created by Adam on 13-1-28.
//
//

#import "PublicDiscussionGroupsViewController.h"
#import "PublicDiscussionGroupCell.h"
#import "Club.h"

#define CELL_HEIGHT 72.0f

@interface PublicDiscussionGroupsViewController ()

@end

@implementation PublicDiscussionGroupsViewController

#pragma mark - load data from MOC

- (void)configureMOCFetchConditions {
  self.entityName = @"Club";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder"
                                                            ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];
  
  self.predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", BIZ_DISCUSS_USAGE_GP_TY];
}

- (void)loadGroups {
  [self refreshTable];
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

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.fetchedRC.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *kCellIdentifier = @"bizGroupCell";
  
  Club *club = [self.fetchedRC.fetchedObjects objectAtIndex:indexPath.row];
  
  
  PublicDiscussionGroupCell *cell = (PublicDiscussionGroupCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[PublicDiscussionGroupCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:kCellIdentifier
                                      imageDisplayerDelegate:_parentVC
                                                         MOC:_MOC] autorelease];
  }
  
  [cell drawCellWithGroup:club index:indexPath.row];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Club *club = [self.fetchedRC.fetchedObjects objectAtIndex:indexPath.row];
  
  if (_parentVC && _action) {
    [_parentVC performSelector:_action withObject:club];
  }
}

@end
