//
//  AlumniEntranceViewController.h
//  iAlumni
//
//  Created by Adam on 13-1-16.
//
//

#import "BaseListViewController.h"
#import "ScrollAutoPlayerDelegate.h"

@class AlumniExampleCell;

@interface AlumniEntranceViewController : BaseListViewController <ScrollAutoPlayerDelegate> {
@private
  
  SEL _refreshBadgesAction;

  CGFloat _viewHeight;
  
  AlumniExampleCell *_exampleCell;
  
  BOOL _noAlumniNews;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
         parentVC:(UIViewController *)parentVC
refreshBadgesAction:(SEL)refreshBadgesAction;

- (void)openDM;
@end
