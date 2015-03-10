//
//  SortOptionListViewController.h
//  ExpatCircle
//
//  Created by Adam on 11-11-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"

@interface SortOptionListViewController : BaseListViewController {

}

- (id)initWithMOC:(NSManagedObjectContext *)MOC 
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction;

@end
