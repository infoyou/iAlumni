//
//  LinkEntranceView.h
//  iAlumni
//
//  Created by Adam on 12-11-15.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;

@interface LinkEntranceView : UIView {
  @private
  
  UIImageView *_rightArrow;
  
  WXWLabel *_titleLabel;
  
  WXWLabel *_badgeLabel;

  id<ECClickableElementDelegate> _clickableElementDelegate;
}

- (id)initWithFrame:(CGRect)frame
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

#pragma mark - arrange views
- (void)beginFlicker;
- (void)updateBadge:(NSInteger)count;

@end
