//
//  RecommendAlumniListViewController.h
//  iAlumni
//
//  Created by Adam on 12-12-5.
//
//

#import "AlumniListViewController.h"
#import "GlobalConstants.h"

@interface RecommendAlumniListViewController : AlumniListViewController {
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         listType:(UserListType)listType
   alumniPersonId:(NSString *)alumniPersonId;

@end
