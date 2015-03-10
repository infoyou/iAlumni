//
//  BizPostListViewController.h
//  iAlumni
//
//  Created by Adam on 12-12-8.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "ECItemUploaderDelegate.h"

@class Club;

@interface BizPostListViewController : BaseListViewController <ECClickableElementDelegate, ECItemUploaderDelegate> {
  @private
  BOOL _autoLoadAfterSent;
  
  CGFloat _currentContentOffset_y;
  
  BOOL _returnFromComposer;
  
  BOOL _selectedFeedBeDeleted;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(Club *)group;

@end
