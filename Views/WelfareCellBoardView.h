//
//  WelfareCellBoardView.h
//  iAlumni
//
//  Created by Adam on 13-8-14.
//
//

#import <UIKit/UIKit.h>

@interface WelfareCellBoardView : UIView {
  @private
  
  CGFloat _separatorOrdinate;
  
  BOOL _needLeftRedPad;
}

- (void)arrangeHeight:(CGFloat)height lineOrdinate:(CGFloat)lineOrdinate;

- (void)arrangeHeight:(CGFloat)height;

- (void)arrangeWithoutLeftRedPadHeight:(CGFloat)height lineOrdinate:(CGFloat)lineOrdinate;
@end
