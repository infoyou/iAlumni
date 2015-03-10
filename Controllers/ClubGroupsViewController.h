//
//  ClubGroupsViewController.h
//  iAlumni
//
//  Created by Adam on 13-1-28.
//
//

#import "BaseListViewController.h"

@interface ClubGroupsViewController : BaseListViewController {
@private
  id _parentVC;
  
  SEL _action;
  
  CGRect _frame;
  
  NSInteger _popularGroupCellCount;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(id)parentVC
           action:(SEL)action
            frame:(CGRect)frame;

- (void)loadGroups;


@end
