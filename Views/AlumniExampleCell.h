//
//  AlumniExampleCell.h
//  iAlumni
//
//  Created by Adam on 13-1-16.
//
//

#import "BaseUITableViewCell.h"

@class AlumniExampleWallView;

@interface AlumniExampleCell : BaseUITableViewCell {
  @private
  
  AlumniExampleWallView *_wallView;
  
  id _entrance;
  
  SEL _action;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate
                MOC:(NSManagedObjectContext *)MOC
           entrance:(id)entrance
             action:(SEL)action;

#pragma mark - timer controller
- (void)play;

- (void)stopPlay;
@end
