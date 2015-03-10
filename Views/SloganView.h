//
//  SloganView.h
//  iAlumni
//
//  Created by Adam on 13-11-13.
//
//

#import <UIKit/UIKit.h>

@class WXWLabel;

@interface SloganView : UIView {
  @private
  
  NSManagedObjectContext *_MOC;
  
  WXWLabel *_sloganLabel;
  
  NSInteger _currentIndex;
}

- (id)initWithFrame:(CGRect)frame MOC:(NSManagedObjectContext *)MOC;

- (void)triggerAutoScroll;
@end
