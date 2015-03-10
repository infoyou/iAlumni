//
//  TagSelectionView.h
//  iAlumni
//
//  Created by Adam on 13-9-16.
//
//

#import <UIKit/UIKit.h>

@interface TagSelectionView : UIView <UITableViewDataSource, UITableViewDelegate> {
  @private
  
  NSInteger _rowCount;
  
  NSManagedObjectContext *_MOC;
  
  id _tagSelector;
  SEL _confirmAction;
}

- (id)initWithFrame:(CGRect)frame
               tags:(NSArray *)tags
                MOC:(NSManagedObjectContext *)MOC
        tagSelector:(id)tagSelector
      confirmAction:(SEL)confirmAction;

@end
