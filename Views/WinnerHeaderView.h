//
//  WinnerHeaderView.h
//  iAlumni
//
//  Created by Adam on 12-10-27.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;

@interface WinnerHeaderView : UIView {
  @private
  UIImageView *_backgroundView;
  
  UIImageView *_giftView;
  
  WXWLabel *_infoLabel;
  
  id<ECClickableElementDelegate> _userListDelegate;
}

- (id)initWithFrame:(CGRect)frame
   userListDelegate:(id<ECClickableElementDelegate>)userListDelegate;

- (void)animationGift;

- (void)setWinnerInfo:(NSString *)info winnerType:(WinnerType)winnerType;

@end
