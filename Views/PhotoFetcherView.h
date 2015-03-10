//
//  PhotoFetcherView.h
//  iAlumni
//
//  Created by Adam on 11-11-18.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface PhotoFetcherView : UIView {
  @private
  UIButton *_photoButton;
  
  id _target;
  SEL _photoManagementAction;

  UIBezierPath *_shadowPath;
}

- (id)initWithFrame:(CGRect)frame
             target:(id)target 
photoManagementAction:(SEL)photoManagementAction
userInteractionEnabled:(BOOL)userInteractionEnabled;

- (void)applySelectedPhoto:(UIImage *)image;

@end
