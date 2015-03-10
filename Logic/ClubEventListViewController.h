//
//  ClubEventListViewController.h
//  iAlumni
//
//  Created by Adam on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"

@interface ClubEventListViewController : BaseListViewController 
{
    
    BOOL _isPop;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
