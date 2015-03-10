//
//  CouponViewController.h
//  iAlumni
//
//  Created by Adam on 12-8-25.
//
//

#import "BaseListViewController.h"

@class Brand;

@interface CouponViewController : BaseListViewController {
  @private
  Brand *_brand;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC brand:(Brand *)brand;

@end
