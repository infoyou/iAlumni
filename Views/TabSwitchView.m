//
//  TabSwitchView.m
//  iAlumni
//
//  Created by Adam on 12-8-29.
//
//

#import "TabSwitchView.h"
#import <QuartzCore/QuartzCore.h>
#import "TabSwitchButton.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIUtils.h"

#define BUTTON_HEIGHT   30.0f

#define INTERSECTION_SID_LENTGTH  2.0f

#define BUTTON_COLOR(BRIGHTNESS)    COLOR_HSB(0.0f, 0.0f, 94.0f, BRIGHTNESS)

@interface TabSwitchView()
@property (nonatomic, retain) NSMutableDictionary *buttonDic;
@end

@implementation TabSwitchView

@synthesize buttonDic = _buttonDic;

#pragma mark - switch action

- (void)arrangeButton:(NSInteger)selectedButtonTag {
    TabSwitchButton *selectedButton = (TabSwitchButton *)(self.buttonDic)[@(selectedButtonTag)];
    
    [self bringSubviewToFront:selectedButton];
    
    for (NSNumber *key in [self.buttonDic allKeys]) {
        
        TabSwitchButton *button = (TabSwitchButton *)(self.buttonDic)[key];
        
        if (key.intValue != selectedButtonTag) {
            button.backgroundColor = [UIColor clearColor];
            [button setTitleColor:COLOR(54, 54, 54) forState:UIControlStateNormal];
        } else {
            button.backgroundColor = COLOR(225, 225, 225);
            [button setTitleColor:COLOR(171, 15, 18) forState:UIControlStateNormal];
        }
        
        [button setNeedsDisplay];
    }
}

- (void)handleSwitch:(NSInteger)tabTag {
    [self arrangeButton:tabTag];
    
    if (_tapSwitchDelegate) {
        [_tapSwitchDelegate selectTapByIndex:tabTag];
    }
}

- (void)switchAction:(id)sender {
    TabSwitchButton *button = (TabSwitchButton *)sender;
    
    [self handleSwitch:button.tag];
}

#pragma mark - lifeycycle methods

- (void)initButton:(NSInteger)index
             title:(NSString *)title
             width:(CGFloat)width
{
    
    CGRect tabFrame = CGRectMake(index * width, 0, width, self.frame.size.height);
    
    TabSwitchButton *button = [[[TabSwitchButton alloc] initWithFrame:tabFrame
                                                                title:title
                                                            titleFont:BOLD_FONT(13)
                                                           titleColor:COLOR(54, 54, 54)
                                                      backgroundColor:[UIColor clearColor]
                                                               target:self
                                                               action:@selector(switchAction:)] autorelease];
    button.tag = index;
    [self addSubview:button];
    (self.buttonDic)[@(index)] = button;
}

- (id)initWithFrame:(CGRect)frame
       buttonTitles:(NSArray *)buttonTitles
  tapSwitchDelegate:(id<TapSwitchDelegate>)tapSwitchDelegate
           tabIndex:(NSInteger)tabIndex {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        UIImageView *_bgBackView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
        _bgBackView.backgroundColor = TRANSPARENT_COLOR;
        
        int tabNums = buttonTitles.count;
        
        switch (tabNums) {
            case 2:
                _bgBackView.image = [UIImage imageNamed:@"tabSwitch2Button.png"];
                break;
            case 3:
                _bgBackView.image = [UIImage imageNamed:@"tabSwitch3Button.png"];
                break;
                
            default:
                break;
        }
        
        [self addSubview:_bgBackView];
        
        _tapSwitchDelegate = tapSwitchDelegate;
        
        self.buttonDic = [NSMutableDictionary dictionary];
        
        _longerSideLength = (self.frame.size.width - MARGIN * 4)/tabNums;
        
        // calculate tab width
        CGFloat tabWidth = self.frame.size.width / tabNums;
        
        for (int i = 0; i < tabNums; i++) {
            [self initButton:i
                       title:buttonTitles[i]
                       width:tabWidth];
        }
        
        [self arrangeButton:tabIndex];
    }
    return self;
}

- (void)dealloc {
    
    self.buttonDic = nil;
    
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [UIUtils draw1PxStroke:context
                startPoint:CGPointMake(0, self.bounds.size.height - 1.0f)
                  endPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height - 1.0f)
                     color:COLOR(218,221,228).CGColor
              shadowOffset:CGSizeMake(0, 0)
               shadowColor:TRANSPARENT_COLOR];
}

#pragma mark - bottom shadow
- (void)displayBottomShadow {
    
    if (_bottomShadowDisplaying) {
        return;
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
                         self.layer.shadowPath = shadowPath.CGPath;
                         self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
                         self.layer.shadowOpacity = 0.9f;
                         self.layer.shadowColor = [UIColor blackColor].CGColor;
                         self.layer.masksToBounds = NO;
                         
                         _bottomShadowDisplaying = YES;
                     }];
}

- (void)hideBottomShadow {
    
    if (!_bottomShadowDisplaying) {
        return;
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.layer.shadowPath = nil;
                         self.layer.shadowColor = TRANSPARENT_COLOR.CGColor;
                         
                         _bottomShadowDisplaying = NO;
                     }];
}

@end
