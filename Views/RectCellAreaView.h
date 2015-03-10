//
//  RectCellAreaView.h
//  iAlumni
//
//  Created by Adam on 13-9-8.
//
//

#import <UIKit/UIKit.h>

@class WXWLabel;

@interface RectCellAreaView : UIView {
  @private
  
  BOOL _needBottomLine;
  
  WXWLabel *_titleLabel;
}

- (void)drawWithNeedBottomLine:(BOOL)needBottomLine title:(NSString *)title;

@end
