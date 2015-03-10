//
//  RegisterationFeeView.h
//  iAlumni
//
//  Created by Adam on 12-8-30.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@class Event;
@class WXWLabel;

@interface RegisterationFeeView : UIView {
  @private
  Event *_event;
  
  NSString *_backendMsg;
  
  WXWLabel *_resultLabel;
  
  WXWLabel *_checkinNumberLabel;
  
  WXWLabel *_shouldPayNameLabel;
  WXWLabel *_shouldPayValueLabel;
  WXWLabel *_actualPayNameLabel;
  WXWLabel *_actualPayValueLabel;
  WXWLabel *_scopeLabel;
}

- (id)initWithFrame:(CGRect)frame
         backendMsg:(NSString *)backendMsg;

- (void)arrangeViews:(Event *)event;

@end
