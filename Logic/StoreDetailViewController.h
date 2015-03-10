//
//  StoreDetailViewController.h
//  iAlumni
//
//  Created by Adam on 13-8-20.
//
//

#import "BaseListViewController.h"

@class Store;

@interface StoreDetailViewController : BaseListViewController {
  @private
  
  Store *_store;
}

- (id)initWithStore:(Store *)store MOC:(NSManagedObjectContext *)MOC;

@end
