//
//  RecommendedItemListViewController.h
//  ExpatCircle
//
//  Created by Adam on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class RecommendedItem;

@interface RecommendedItemListViewController : BaseListViewController {
@private
  
  long long _serviceItemId;
  
  NSInteger _rowCount;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
    serviceItemId:(long long)serviceItemId;

@end
