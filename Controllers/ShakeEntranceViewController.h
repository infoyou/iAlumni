//
//  ShakeEntranceViewController.h
//  iAlumni
//
//  Created by Adam on 12-12-1.
//
//

#import "WXWRootViewController.h"

@interface ShakeEntranceViewController : WXWRootViewController <UIAccelerometerDelegate> {
  
  BOOL _shaking;
  
  BOOL _processing;
  
  @private
  
  SystemSoundID _shakeSoundID;
 
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

- (void)triggerProcessing;
@end
