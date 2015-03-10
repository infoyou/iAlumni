//
//  CheckinResultHeaderView.h
//  iAlumni
//
//  Created by Adam on 12-8-28.
//
//

#import <UIKit/UIKit.h>
#import "WXWImageFetcherDelegate.h"
#import "GlobalConstants.h"
#import "WXWImageDisplayerDelegate.h"

@class WXWLabel;
@class Event;
@class RegisterationFeeView;

@interface CheckinResultHeaderView : UIView <WXWImageFetcherDelegate> {

  @private
  
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  
  RegisterationFeeView *_resultBoardView;
  
  NSString *_backendMsg;
  
  UIView *_authorPicBackgroundView;
  UIImageView *_authorPic;
  
  WXWLabel *_nameLabel;
  WXWLabel *_classLabel;
  WXWLabel *_signUpStatusLabel;
  
  UIView *_resultBackgroundView;
  WXWLabel *_resultLabel;
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
         backendMsg:(NSString *)backendMsg;

- (void)drawView:(CGFloat)resultBoardHeight event:(Event *)event;

@end
