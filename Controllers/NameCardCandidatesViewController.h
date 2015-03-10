//
//  NameCardCandidatesViewController.h
//  iAlumni
//
//  Created by Adam on 12-12-4.
//
//

#import "BaseListViewController.h"
#import "ECClickableElementDelegate.h"

@class ECColorfulButton;

@interface NameCardCandidatesViewController : BaseListViewController <ECClickableElementDelegate> {
  @private
  ECColorfulButton *_exchangeButton;
  
  BOOL _firstSearching;
  BOOL _secondSearching;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
