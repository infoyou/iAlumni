//
//  AlumniListViewController.h
//  iAlumni
//
//  Created by Adam on 12-11-22.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class Alumni;

@interface AlumniListViewController : BaseListViewController <ECClickableElementDelegate, UIActionSheetDelegate> {
  @private
  
  BOOL _needSectionIndexTitles;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

- (id)initResettedWithMOC:(NSManagedObjectContext *)MOC;

- (void)showProfile:(Alumni *)alumni;

@end
