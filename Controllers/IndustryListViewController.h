//
//  IndustryListViewController.h
//  iAlumni
//
//  Created by Adam on 12-11-25.
//
//

#import "BaseListViewController.h"

@interface IndustryListViewController : BaseListViewController {
  @private
  
  id _searchHolder;
  SEL _selectAction;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
currentSelectedIndustryId:(NSString *)currentSelectedIndustryId
     searchHolder:(id)searchHolder
     selectAction:(SEL)selectAction;

@end
