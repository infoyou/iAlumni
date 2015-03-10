//
//  QuickBackForCheckinView.h
//  iAlumni
//
//  Created by Adam on 12-8-31.
//
//

#import "WXWGradientView.h"
#import "GlobalConstants.h"
#import "EventCheckinDelegate.h"

@class WXWLabel;

@interface QuickBackForCheckinView : UIView {
  @private
  
  WXWLabel *_titleLabel;
  
  UIColor *_topColor;
  UIColor *_bottomColor;
  
  OvalSideDirectionType _directionType;
  
  id<EventCheckinDelegate> _checkinDelegate;
}

- (id)initWithFrame:(CGRect)frame
    checkinDelegate:(id<EventCheckinDelegate>)checkinDelegate
      directionType:(OvalSideDirectionType)directionType
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor;

- (void)setTitle:(NSString *)title;

@end
