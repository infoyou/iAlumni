//
//  AlumniRelationshipListViewController.h
//  iAlumni
//
//  Created by Adam on 12-11-28.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@interface AlumniRelationshipListViewController : BaseListViewController <ECClickableElementDelegate> {
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
