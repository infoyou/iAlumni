//
//  TagSearchResultViewController.h
//  iAlumni
//
//  Created by Adam on 13-5-31.
//
//

#import "BaseListViewController.h"

@interface TagSearchResultViewController : BaseListViewController {
  @private
  
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC tagId:(NSNumber *)tagId;

@end
