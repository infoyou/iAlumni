//
//  ECInnerShadowTextView.m
//  iAlumni
//
//  Created by Adam on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECInnerShadowTextView.h"
#import <QuartzCore/QuartzCore.h>

#define ADD_COMMENT_ICON_SIDE_LENGTH  16.0f

@implementation ECInnerShadowTextView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _addCommentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN * 2, (self.frame.size.height - ADD_COMMENT_ICON_SIDE_LENGTH)/2.0f, ADD_COMMENT_ICON_SIDE_LENGTH, ADD_COMMENT_ICON_SIDE_LENGTH)];
    _addCommentImageView.backgroundColor = TRANSPARENT_COLOR;
    _addCommentImageView.image = [UIImage imageNamed:@"commentRed.png"];
    [self addSubview:_addCommentImageView];
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_addCommentImageView);
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  
  /*
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                        cornerRadius:self.layer.cornerRadius];
  
  CGMutablePathRef visiblePath = CGPathCreateMutableCopy(bezierPath.CGPath);
  CGMutablePathRef shadowPath = CGPathCreateMutable();
  CGPathAddRect(shadowPath,
                NULL, 
                CGRectInset(self.bounds, -42, -42));
  
  // Add the visible path (so that it gets subtracted for the shadow)
  CGPathAddPath(shadowPath, NULL, visiblePath);
  CGPathCloseSubpath(shadowPath);
  
  // Add the visible paths as the clipping path to the context
  CGContextAddPath(context, visiblePath);
  CGContextClip(context);
  
  // Now setup the shadow properties on the context
  UIColor *color = [UIColor colorWithRed:0
                                   green:0 
                                    blue:0 
                                   alpha:0.6f];
  CGContextSaveGState(context);
  CGContextSetShadowWithColor(context, CGSizeMake(0, 2.0f), 4.0f, color.CGColor);
  
  // Now fill the rectangle, so the shadow gets drawn
  [color setFill];
  CGContextSaveGState(context);
  CGContextAddPath(context, shadowPath);
  CGContextEOFillPath(context);
  
  // Release the paths
  CGPathRelease(shadowPath);
  CGPathRelease(visiblePath);
   */
}

- (void)hideAddCommentIcon {
  _addCommentImageView.alpha = 0.0f;
}

- (void)showAddCommentIcon {
  _addCommentImageView.alpha = 1.0f;
}


@end
