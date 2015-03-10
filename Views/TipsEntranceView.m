//
//  TipsEntranceView.m
//  ExpatCircle
//
//  Created by Adam on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TipsEntranceView.h"
#import "WXWLabel.h"
#import "ECGradientButton.h"
#import "UIUtils.h"
#import "CommonUtils.h"
#import "TextConstants.h"

#define BTN_SIDE_LENGTH 16.0f//24.0f

#define TOOL_HEIGHT  30.0f
#define TOOL_WIDTH   70.0f

#define IMG_EDGE    UIEdgeInsetsMake(0.0f, 7.0, 0.0, 0.0)
#define TITLE_EDGE  UIEdgeInsetsMake(0.0, -15.0, 0.0, 0.0)

@implementation TipsEntranceView

@synthesize firstTipsTitleLabel = _firstTipsTitleLabel;
@synthesize tipsTitleLabel = _tipsTitleLabel;

- (void)showTipsDetail:(id)sender {
  if (_filterListDelegate) {
    [_filterListDelegate showServiceItemTips];
  }
}

- (void)setTipsTitleLabelText:(NSString *)title {
  self.tipsTitleLabel.text = title;
  
  CGSize size = [self.tipsTitleLabel.text sizeWithFont:self.tipsTitleLabel.font
                                     constrainedToSize:CGSizeMake(200.0f, CGFLOAT_MAX)
                                         lineBreakMode:NSLineBreakByWordWrapping];
  self.tipsTitleLabel.frame = CGRectMake(MARGIN * 2, 
                                         (self.frame.size.height - size.height)/2.0f, 
                                         size.width, size.height);
}

- (id)initWithFrame:(CGRect)frame 
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor
 filterListDelegate:(id<ECFilterListDelegate>)filterListDelegate {
  self = [super initWithFrame:frame 
                     topColor:topColor
                  bottomColor:bottomColor];
  if (self) {
    _filterListDelegate = filterListDelegate;
    
    self.tipsTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                            textColor:[UIColor whiteColor]
                                          shadowColor:COLOR(121, 124, 127)] autorelease];
    self.tipsTitleLabel.font = BOLD_FONT(13);
    [self addSubview:self.tipsTitleLabel];
    
    CGFloat titleEndX = self.tipsTitleLabel.frame.origin.x + self.tipsTitleLabel.frame.size.width;
    self.firstTipsTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(titleEndX, 
                                                                          self.tipsTitleLabel.frame.origin.y, 
                                                                          self.frame.size.width - 
                                                                          (titleEndX + MARGIN * 4), self.tipsTitleLabel.frame.size.height)
                                                     textColor:[UIColor whiteColor]
                                                   shadowColor:COLOR(121, 124, 127)] autorelease];
    self.firstTipsTitleLabel.font = BOLD_FONT(13);
    self.firstTipsTitleLabel.numberOfLines = 1;
    self.firstTipsTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:self.firstTipsTitleLabel];
    
    UIImageView *navigator = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whiteRightArrow.png"]] autorelease];
    navigator.backgroundColor = TRANSPARENT_COLOR;
    navigator.frame = CGRectMake(self.frame.size.width - MARGIN - BTN_SIDE_LENGTH - 1.0f, (self.frame.size.height - BTN_SIDE_LENGTH)/2, BTN_SIDE_LENGTH, BTN_SIDE_LENGTH);
    [self addSubview:navigator];
    
    /*
     UIBarButtonItem *space1 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
     target:nil 
     action:nil] autorelease];
     UIBarButtonItem *showButton = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSWideTipsTitle, nil) 
     style:UIBarButtonItemStyleBordered 
     target:self
     action:@selector(showTipsDetail:)] autorelease];
     
     UIBarButtonItem *space2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
     target:nil 
     action:nil] autorelease];
     
     _tipsToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(self.frame.size.width - MARGIN * 2 - TOOL_WIDTH, MARGIN, TOOL_WIDTH, TOOL_HEIGHT)];
     _tipsToolbar.barStyle = -1;
     _tipsToolbar.tintColor = topColor;
     [_tipsToolbar setItems:[NSArray arrayWithObjects:space1, showButton, space2, nil]];
     [self addSubview:_tipsToolbar];
     */
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_tipsToolbar);
  self.tipsTitleLabel = nil;
  self.firstTipsTitleLabel = nil;
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0, self.bounds.size.height - 1) 
                endPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height - 1)
                   color:SEPARATOR_LINE_COLOR.CGColor
            shadowOffset:CGSizeMake(0.0f, 0.0f) 
             shadowColor:COLOR(201, 200, 206)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_filterListDelegate) {
    [_filterListDelegate showServiceItemTips];
  }
}

@end
