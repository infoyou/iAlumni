//
//  CoreTextView.m
//  iAlumni
//
//  Created by Adam on 12-10-5.
//
//

#import "CoreTextView.h"


@implementation CoreTextView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = TRANSPARENT_COLOR;
  }
  return self;
}

- (void)dealloc {
  
  
  [super dealloc];
}

- (void)setCTFrame:(id)frame {
  _ctFrame = frame;
}

- (void)drawRect:(CGRect)rect {

  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetTextMatrix(context, CGAffineTransformIdentity);
  CGContextTranslateCTM(context, 0, self.bounds.size.height);
  CGContextScaleCTM(context, 1.0f, -1.0);
  
  CTFrameDraw((CTFrameRef)_ctFrame, context);
}


@end
