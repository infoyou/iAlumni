//
//  CEIBSNewsListViewController.h
//  iAlumni
//
//  Created by Adam on 12-10-25.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"

@interface CEIBSNewsListViewController : BaseListViewController {
  @private
  BOOL _needAdjustForiOS7;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
needAdjustForiOS7:(BOOL)needAdjustForiOS7;

@end
