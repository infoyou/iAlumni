//
//  TabSwitchView.h
//  iAlumni
//
//  Created by Adam on 12-8-29.
//
//

#import <UIKit/UIKit.h>
#import "PlainTabView.h"

@interface TabSwitchView : UIView {
  
  @private
  
  id<TapSwitchDelegate> _tapSwitchDelegate;
  
  NSMutableDictionary *_buttonDic;
  
  CGFloat _longerSideLength;
  
  BOOL _bottomShadowDisplaying;
}

- (id)initWithFrame:(CGRect)frame
       buttonTitles:(NSArray *)buttonTitles
  tapSwitchDelegate:(id<TapSwitchDelegate>)tapSwitchDelegate
           tabIndex:(NSInteger)tabIndex;

#pragma mark - handle switch
- (void)handleSwitch:(NSInteger)tabTag;

#pragma mark - bottom shadow
- (void)displayBottomShadow;
- (void)hideBottomShadow;

@end
