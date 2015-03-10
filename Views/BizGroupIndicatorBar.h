//
//  BizGroupIndicatorBar.h
//  iAlumni
//
//  Created by Adam on 13-1-26.
//
//

#import <UIKit/UIKit.h>

@class WXWLabel;

@interface BizGroupIndicatorBar : UIView {
  @private
  
  WXWLabel *_firstPageIndicator;
  WXWLabel *_firstNameLabel;
  UIImageView *_leftArrow;
  
  WXWLabel *_secondPageIndicator;
  WXWLabel *_secondNameLabel;
  UIImageView *_rightArrow;
}

#pragma mark - arrange for page switch
- (void)switchToPageWithIndex:(BizCoopPageIndex)index;


@end
