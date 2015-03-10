//
//  UITabView.m
//  iAlumni
//
//  Created by Adam on 12-8-14.
//
//

#import "UITabView.h"
#import "GlobalConstants.h"

#define FONT_SIZE       14

@implementation UITabView

- (id)initWithFrame:(CGRect)frame tab0Str:(NSString*)tab0Str tab1Str:(NSString*)tab1Str delegate:(id<TabTapDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _delegate = delegate;
        
        // Initialization code
        selTapIndex = 0;
        selTabImg = [UIImage imageNamed:@"tab0.png"];
        unSelTabImg = [UIImage imageNamed:@"tab1.png"];
        
        
        tab0View = [[UIImageView alloc] initWithImage:selTabImg];
        tab0View.frame = CGRectMake(0, 0, SCREEN_WIDTH/2, 45.0f);
        
        tab0But = [UIButton buttonWithType:UIButtonTypeCustom];
        tab0But.frame = tab0View.frame;
        [tab0But setTitle:tab0Str forState:UIControlStateNormal];
        tab0But.titleLabel.font = FONT(FONT_SIZE);
        [tab0But setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tab0But addTarget:self action:@selector(doTapTab0:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tab0View];
        [self addSubview:tab0But];
        
        tab1View = [[UIImageView alloc] initWithImage:unSelTabImg];
        tab1View.contentMode = UIViewContentModeScaleToFill;
        tab1View.frame = CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, 45.0f);
        tab1But = [UIButton buttonWithType:UIButtonTypeCustom];
        tab1But.frame = tab1View.frame;

        [tab1But setTitle:tab1Str forState:UIControlStateNormal];
        tab1But.titleLabel.font = FONT(FONT_SIZE);
        [tab1But setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tab1But addTarget:self action:@selector(doTapTab1:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tab1View];
        [self addSubview:tab1But];
    }
    
    return self;
}

- (void)dealloc {
    RELEASE_OBJ(tab0View);
    RELEASE_OBJ(tab1View);
    
    [super dealloc];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)doTapTab0:(id)sender {
    
    if (selTapIndex == 1) {
        tab0View.image = selTabImg;
        tab1View.image = unSelTabImg;
    }
    selTapIndex = 0;
    
    [_delegate tabTap:selTapIndex];
}


- (void)doTapTab1:(id)sender {
    
    if (selTapIndex == 0) {
        tab0View.image = unSelTabImg;
        tab1View.image = selTabImg;
    }
    selTapIndex = 1;
    
    [_delegate tabTap:selTapIndex];
}

@end
