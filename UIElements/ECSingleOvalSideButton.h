//
//  ECSingleOvalSideButton.h
//  iAlumni
//
//  Created by Adam on 12-1-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface ECSingleOvalSideButton : UIButton {
  @private
  OvalSideDirectionType _directionType;
  
  ButtonColorType _colorType;
}

- (id)initWithFrame:(CGRect)frame 
      directionType:(OvalSideDirectionType)directionType
          colorType:(ButtonColorType)colorType 
              image:(UIImage *)image;
@end
