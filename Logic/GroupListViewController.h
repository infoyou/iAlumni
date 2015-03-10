//
//  GroupListViewController.h
//  iAlumni
//
//  Created by Adam on 12-10-5.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "PlainTabView.h"

@class TabSwitchView;

@interface GroupListViewController : BaseListViewController <TapSwitchDelegate> {
  @private
  
  TabSwitchView *_tabSwitchView;
  
  NSInteger _myGroupFlag;
  
  NSInteger _startTabIndex;
  
  BOOL _needReloadGroups;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction;

- (id)initForAllGroupsWithMOC:(NSManagedObjectContext *)MOC;

@end
