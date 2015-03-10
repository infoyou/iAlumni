//
//  ECEmbedMapView.m
//  iAlumni
//
//  Created by Adam on 11-12-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ECEmbedMapView.h"

@implementation ECEmbedMapView

- (id)initWithFrame:(CGRect)frame clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate {
  self = [super initWithFrame:frame];
  
  if (self) {
    _delegate = clickableElementDelegate;
  }
  return self;
}

#pragma mark - touch event handlers 
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  
  if ([self pointInside:point withEvent:event]) {
    return self;
  } else {
    return [super hitTest:point withEvent:event];
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_delegate) {
    [_delegate openTraceMap];
  }
}

@end
