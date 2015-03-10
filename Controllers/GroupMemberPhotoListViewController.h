//
//  GroupMemberPhotoListViewController.h
//  iAlumni
//
//  Created by Adam on 13-7-29.
//
//

#import "AlumniListViewController.h"
#import "BaseListViewController.h"
#import "BaseFilterListViewController.h"

@class ClubDetail;

@interface GroupMemberPhotoListViewController : BaseFilterListViewController {
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(ClubDetail *)group;

- (void)recoveryMainVC;
//- (void)extendFilterVC;

@end
