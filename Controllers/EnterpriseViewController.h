//
//  EnterpriseViewController.h
//  iAlumni
//
//  Created by Adam on 12-10-9.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"

@interface EnterpriseViewController : BaseListViewController {
  @private

}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction;

@end
