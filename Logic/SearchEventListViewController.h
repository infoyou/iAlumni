//
//  SearchEventListViewController.h
//  iAlumni
//
//  Created by Adam on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "EventListCell.h"

@interface SearchEventListViewController : BaseListViewController <UISearchBarDelegate> {
    
@private
  
  CGRect _originalTableViewFrame;
  
  BOOL _keepEventsInMOC;
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(UIViewController *)parentVC
         tabIndex:(int)tabIndex;

- (void)clearFliter;

@end
