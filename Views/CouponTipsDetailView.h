//
//  CouponTipsDetailView.h
//  iAlumni
//
//  Created by Adam on 12-8-25.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface CouponTipsDetailView : UIView {
  @private
  
  id _holder;
}

- (id)initWithFrame:(CGRect)frame holder:(id)holder;

@end
