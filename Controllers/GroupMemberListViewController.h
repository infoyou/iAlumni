//
//  GroupMemberListViewController.h
//  iAlumni
//
//  Created by Adam on 12-12-6.
//
//

#import "AlumniListViewController.h"
#import "PlainTabView.h"

@class Club;

@interface GroupMemberListViewController : AlumniListViewController <TapSwitchDelegate> {
    
  @private
  
  PlainTabView *_tabSwitchView;
  
  NSInteger _selectedIdex;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(Club *)group;

@end
