//
//  ECTextField.m
//  iAlumni
//
//  Created by Adam on 13-5-30.
//
//

#import "ECTextField.h"

@implementation ECTextField

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, MARGIN * 2, MARGIN);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, MARGIN * 2, MARGIN);
}

@end
