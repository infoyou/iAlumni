//
//  ItemListSectionView.m
//  iAlumni
//
//  Created by Adam on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ItemListSectionView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "GlobalConstants.h"
#import "UIUtils.h"

@implementation ItemListSectionView

@synthesize titleLabel = _titleLable;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
  self = [super initWithFrame:frame];
  if (self) {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = TRANSPARENT_COLOR;
    
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;    
		gradientLayer.colors = @[(id)COLOR(168, 168, 168).CGColor, 
                            (id)COLOR(172, 172, 172).CGColor];
    NSArray *locations = [[NSArray alloc] initWithObjects:@0.50f, @1.0f, nil];
    gradientLayer.locations = locations;
    RELEASE_OBJ(locations);
    
    self.titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN * 2, (self.bounds.size.height - 14) / 2, 200, 14)
                                            textColor:[UIColor whiteColor] 
                                          shadowColor:COLOR(136, 136, 136)] autorelease];
    self.titleLabel.backgroundColor = TRANSPARENT_COLOR;
    self.titleLabel.font = BOLD_FONT(12);
    self.titleLabel.text = title;
    [self addSubview:self.titleLabel];
    
  }
  return self;
}

+ (Class)layerClass
{
	return [CAGradientLayer class];
}


- (void)dealloc {
  
  self.titleLabel = nil;
  
  [super dealloc];
}

@end
