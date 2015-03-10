//
//  BaseTextField.m
//  iAlumni
//
//  Created by Adam on 13-2-9.
//
//

#import "BaseTextField.h"

@implementation BaseTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)borderRectForBounds:(CGRect)bounds
{
    return bounds;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x+MARGIN, bounds.origin.y, bounds.size.width-MARGIN*2, bounds.size.height);
}

@end
