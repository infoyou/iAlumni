//
//  AlumniJoinedGroupListViewController.h
//  iAlumni
//
//  Created by Adam on 12-12-6.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"

@interface AlumniJoinedGroupListViewController : BaseListViewController {
@private
  
  NSInteger _myGroupFlag;
  
  BOOL _needReloadGroups;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
   alumniPersonId:(NSString *)alumniPersonId
         userType:(NSString *)userType;

@end
