//
//  DMChatterListViewController.h
//  iAlumni
//
//  Created by Adam on 13-10-25.
//
//

#import "BaseListViewController.h"
#import "ECClickableElementDelegate.h"

@interface DMChatterListViewController : BaseListViewController <ECClickableElementDelegate> {
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
