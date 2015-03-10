//
//  SortOptionListViewController.m
//  ExpatCircle
//
//  Created by Adam on 11-11-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SortOptionListViewController.h"
#import "TextConstants.h"
#import "SortOption.h"
#import "SortOptionCell.h"
#import "CoreDataUtils.h"
#import "CommonUtils.h"


@implementation SortOptionListViewController

- (id)initWithMOC:(NSManagedObjectContext *)MOC 
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction {
  
  self = [super initWithMOC:MOC holder:holder backToHomeAction:backToHomeAction needGoHome:NO];
  if (self) {
    
  }
  
  return self;
}

- (void)dealloc {

  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _tableView.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  
  [self refreshTable];
}

#pragma mark - override methods

- (void)configureMOCFetchConditions {
  self.entityName = @"SortOption";
  
  self.predicate = [NSPredicate predicateWithFormat:@"(usageType == %d)", POST_ITEM_TY];
  
  self.descriptors = [NSMutableArray array];  
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"optionId" ascending:YES] autorelease];
  [self.descriptors addObject:descriptor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _fetchedRC.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"kCell";
  SortOptionCell *cell = (SortOptionCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[SortOptionCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                  reuseIdentifier:kCellIdentifier] autorelease];
  }
  
  SortOption *option = [_fetchedRC objectAtIndexPath:indexPath];
  
  [cell drawOption:option];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  for (SortOption *option in _fetchedRC.fetchedObjects) {
    option.selected = @NO;
  }
  
  SortOption *selectedOption = [_fetchedRC objectAtIndexPath:indexPath];
  selectedOption.selected = @YES;
  
  [WXWCoreDataUtils saveMOCChange:_MOC];
  
  [self.navigationController popViewControllerAnimated:YES];
}

@end
