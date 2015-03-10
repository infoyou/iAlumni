//
//  SearchClubViewController.h
//  iAlumni
//
//  Created by Adam on 12-8-20.
//
//

#import "WXWRootViewController.h"
#import "UIFilterView.h"

@interface SearchClubViewController : WXWRootViewController <UITableFilterDelegate, UISearchBarDelegate> {
    
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
