//
//  AlumniProfileTopBackgroundView.h
//  iAlumni
//
//  Created by Adam on 12-11-13.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@class WXWLabel;
@class Alumni;
@class CircularAvatarBackgroundView;

@interface AlumniProfileTopBackgroundView : UIView {
@private
  WXWLabel *_nameLabel;
  WXWLabel *_classLabel;
  
  CircularAvatarBackgroundView *_circularAvatarBackgroundView;
}

- (id)initWithFrame:(CGRect)frame alumni:(Alumni *)alumni;

- (void)refreshAfterAlumniLoaded:(Alumni *)alumni;
@end
