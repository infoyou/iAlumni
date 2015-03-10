//
//  UIImage+Alpha.h
//  ExpatCircle
//
//  Created by Mobguang on 12-1-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

@interface UIImage (Alpha)
- (BOOL)hasAlpha;
- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
@end
