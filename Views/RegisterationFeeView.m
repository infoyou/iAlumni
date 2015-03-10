//
//  RegisterationFeeView.m
//  iAlumni
//
//  Created by Adam on 12-8-30.
//
//

#import "RegisterationFeeView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIUtils.h"
#import "Event.h"
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "TextConstants.h"

@interface RegisterationFeeView()
@property (nonatomic, retain) Event *event;
@property (nonatomic, copy) NSString *backendMsg;
@end

@implementation RegisterationFeeView

@synthesize event = _event;
@synthesize backendMsg = _backendMsg;

- (void)arrangeResultLabel {
  
  if (nil == _resultLabel) {
    _resultLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:DARK_TEXT_COLOR
                                       shadowColor:[UIColor whiteColor]] autorelease];
    _resultLabel.font = BOLD_FONT(16);
    _resultLabel.textAlignment = UITextAlignmentCenter;
    _resultLabel.numberOfLines = 0;
    [self addSubview:_resultLabel];
  }
  
  _resultLabel.textColor = DARK_TEXT_COLOR;
  
  switch (self.event.checkinResultType.intValue) {
    case CHECKIN_FAILED_TY:
      _resultLabel.text = LocaleStringForKey(NSCheckinFailedMsg, nil);
      break;
      
    case CHECKIN_OK_TY:
    {
      NSLog(@"length: %d", self.event.tableInfo.length);
      if (self.event.tableInfo.length > 0) {
        _resultLabel.text = [NSString stringWithFormat:@"%@. %@", LocaleStringForKey(NSCheckinDoneMsg, nil),
                             self.event.tableInfo];
      } else {
        _resultLabel.text = LocaleStringForKey(NSCheckinDoneMsg, nil);
      }
      
      _resultLabel.textColor = NAVIGATION_BAR_COLOR;
      break;
    }
      
    case CHECKIN_DUPLICATE_ERR_TY:
    {
            NSLog(@"length: %d", self.event.tableInfo.length);
      if (self.event.tableInfo.length > 0) {
        _resultLabel.text = [NSString stringWithFormat:@"%@. %@", LocaleStringForKey(NSEventDuplicateCheckinMsg, nil),
                             self.event.tableInfo];
      } else {
        _resultLabel.text = LocaleStringForKey(NSEventDuplicateCheckinMsg, nil);

      }

      break;
    }
      
    case CHECKIN_FARAWAY_TY:
      _resultLabel.text = LocaleStringForKey(NSAlumniCheckinFarAwayMsg, nil);
      break;
      
    case CHECKIN_EVENT_OVERDUE_TY:
      _resultLabel.text = LocaleStringForKey(NSCheckinFailedEventOverdueMsg, nil);
      break;
      
    case CHECKIN_EVENT_NOT_BEGIN_TY:
      _resultLabel.text = LocaleStringForKey(NSEventNotBeginMsg, nil);
      break;
      
    case CHECKIN_NEED_CONFIRM_TY:
      _resultLabel.text = LocaleStringForKey(NSCheckinNeedConfirmMsg, nil);
      break;
      /*
    case CHECKIN_NOT_SIGNUP_TY:
      _resultLabel.text = LocaleStringForKey(NSNotSignUpMsg, nil);
      break;
      */
    case CHECKIN_NO_REG_FEE_TY:
      _resultLabel.text = LocaleStringForKey(NSNoRegistrationFeeMsg, nil);
      break;
      
    default:
      _resultLabel.text = LocaleStringForKey(NSCheckinFailedMsg, nil);
      break;
  }
  
  if (self.backendMsg && self.backendMsg.length > 0) {
    //_resultLabel.text = self.backendMsg;
  }
  
  CGSize size = [_resultLabel.text sizeWithFont:_resultLabel.font
                              constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 8, CGFLOAT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping];
  
  _resultLabel.frame = CGRectMake((self.frame.size.width - size.width)/2.0f,
                                  MARGIN,
                                  size.width, size.height);
}

- (BOOL)needShowNumber {
  if (self.event.checkinNumber.longLongValue > 0) {
    return YES;
  } else {
    return NO;
  }
}

- (void)arrangeCheckinNumber {
  
  if ([self needShowNumber]) {
    if (nil == _checkinNumberLabel) {
      _checkinNumberLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                  textColor:ORANGE_COLOR
                                                shadowColor:TRANSPARENT_COLOR] autorelease];
      _checkinNumberLabel.font = BOLD_FONT(60);
      [self addSubview:_checkinNumberLabel];
    }
    
    _checkinNumberLabel.hidden = NO;
    
    _checkinNumberLabel.text = [NSString stringWithFormat:@"%@", self.event.checkinNumber];
    CGSize size = [_checkinNumberLabel.text sizeWithFont:_checkinNumberLabel.font
                                       constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    _checkinNumberLabel.frame = CGRectMake((self.frame.size.width - size.width)/2.0f,
                                           _resultLabel.frame.origin.y + _resultLabel.frame.size.height + MARGIN * 2,
                                           size.width, size.height);
  } else {
    if (_checkinNumberLabel) {
      _checkinNumberLabel.hidden = YES;
    }
  }
  
}

- (void)addShadowEffect {
  UIBezierPath *shadowPath = [UIBezierPath bezierPath];
  CGFloat curlFactor = 10.0f;
  CGFloat shadowDepth = 8.0f;
  [shadowPath moveToPoint:CGPointMake(2.0f, MARGIN)];
  [shadowPath addLineToPoint:CGPointMake(self.frame.size.width - 2.0f, MARGIN)];
  [shadowPath addLineToPoint:CGPointMake(self.frame.size.width - 2.0f,
                                         self.frame.size.height + shadowDepth)];
  [shadowPath addCurveToPoint:CGPointMake(2.0f, self.frame.size.height + shadowDepth)
                controlPoint1:CGPointMake(self.frame.size.width - curlFactor,
                                          self.frame.size.height + shadowDepth - curlFactor)
                controlPoint2:CGPointMake(curlFactor,
                                          self.frame.size.height + shadowDepth - curlFactor)];
  self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  self.layer.shadowOpacity = 0.7f;
  self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
  self.layer.shadowRadius = 2.0f;
  self.layer.masksToBounds = NO;
  self.layer.shadowPath = shadowPath.CGPath;
}

- (BOOL)shouldShowFee {
  if (self.event.requirementType.intValue == NEED_FEE_EVENT_TY) {
    return YES;
  } else {
    return NO;
  }
}

- (void)arrangeFeeViews {
  if ([self shouldShowFee]) {
    
    CGFloat halfWidth = self.frame.size.width/2.0f;
    CGFloat nameLabelsY = _checkinNumberLabel.frame.origin.y + _checkinNumberLabel.frame.size.height + MARGIN * 3;
    
    // ----------------------- should payment -----------------------------
    
    if (nil == _shouldPayNameLabel) {
      _shouldPayNameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                  textColor:BASE_INFO_COLOR
                                                shadowColor:TRANSPARENT_COLOR] autorelease];
      _shouldPayNameLabel.font = BOLD_FONT(16);
      [self addSubview:_shouldPayNameLabel];
      
      _shouldPayNameLabel.text = LocaleStringForKey(NSShouldPayTitle, nil);
    }
    CGSize size = [_shouldPayNameLabel.text sizeWithFont:_shouldPayNameLabel.font
                                       constrainedToSize:CGSizeMake(halfWidth, CGFLOAT_MAX)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    _shouldPayNameLabel.frame = CGRectMake((halfWidth - size.width)/2.0f,
                                           nameLabelsY, size.width, size.height);
    
    if (nil == _shouldPayValueLabel) {
      _shouldPayValueLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                   textColor:DARK_TEXT_COLOR
                                                 shadowColor:TRANSPARENT_COLOR] autorelease];
      _shouldPayValueLabel.font = BOLD_FONT(24);
      [self addSubview:_shouldPayValueLabel];
    }
    
    _shouldPayValueLabel.text = [NSString stringWithFormat:@"￥%@", self.event.fee];
    
    size = [_shouldPayValueLabel.text sizeWithFont:_shouldPayValueLabel.font
                                 constrainedToSize:CGSizeMake(halfWidth, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
    _shouldPayValueLabel.frame = CGRectMake((halfWidth - size.width)/2.0f, _shouldPayNameLabel.frame.origin.y + _shouldPayNameLabel.frame.size.height + MARGIN * 2, size.width, size.height);
    
    // ----------------------- actual payment -----------------------------
    
    if (nil == _actualPayNameLabel) {
      _actualPayNameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                  textColor:BASE_INFO_COLOR
                                                shadowColor:TRANSPARENT_COLOR] autorelease];
      _actualPayNameLabel.font = BOLD_FONT(16);
      [self addSubview:_actualPayNameLabel];
      
      _actualPayNameLabel.text = LocaleStringForKey(NSActualPayTitle, nil);
    }
    size = [_actualPayNameLabel.text sizeWithFont:_actualPayNameLabel.font
                                constrainedToSize:CGSizeMake(halfWidth, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    _actualPayNameLabel.frame = CGRectMake(halfWidth + (halfWidth - size.width)/2.0f,
                                           nameLabelsY, size.width, size.height);
    
    if (nil == _actualPayValueLabel) {
      _actualPayValueLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                   textColor:DARK_TEXT_COLOR
                                                 shadowColor:TRANSPARENT_COLOR] autorelease];
      _actualPayValueLabel.font = BOLD_FONT(24);
      [self addSubview:_actualPayValueLabel];
    }
    _actualPayValueLabel.text = [NSString stringWithFormat:@"￥%@", self.event.actualPaid];
    size = [_actualPayValueLabel.text sizeWithFont:_actualPayValueLabel.font
                                 constrainedToSize:CGSizeMake(halfWidth, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
    
    if (nil == _scopeLabel) {
      _scopeLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                          textColor:BASE_INFO_COLOR
                                        shadowColor:TRANSPARENT_COLOR] autorelease];
      _scopeLabel.font = BOLD_FONT(13);
      [self addSubview:_scopeLabel];
      
      _scopeLabel.text = [NSString stringWithFormat:@"(%@)", self.event.membershipScope];
    }
    CGSize scopeSize = [_scopeLabel.text sizeWithFont:_scopeLabel.font
                                    constrainedToSize:CGSizeMake(halfWidth, CGFLOAT_MAX)
                                        lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat actualPayValueWidth = size.width + scopeSize.width;
    
    _actualPayValueLabel.frame = CGRectMake(halfWidth + (halfWidth - actualPayValueWidth)/2.0f,
                                            _actualPayNameLabel.frame.origin.y + _actualPayNameLabel.frame.size.height + MARGIN * 2, size.width, size.height);
    _scopeLabel.frame = CGRectMake(_actualPayValueLabel.frame.origin.x + _actualPayValueLabel.frame.size.width, _actualPayValueLabel.frame.origin.y + (MARGIN + 3.0f), scopeSize.width, scopeSize.height);

  }
}

- (void)arrangeViews:(Event *)event {
  
  self.event = event;
  
  [self arrangeResultLabel];
  
  [self arrangeCheckinNumber];
  
  [self arrangeFeeViews];
  
  [self addShadowEffect];
  
  [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
         backendMsg:(NSString *)backendMsg {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.backendMsg = backendMsg;
    
  }
  return self;
}

- (void)dealloc {
  
  self.event = nil;
  
  self.backendMsg = nil;
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {
  
  if (!self.event.requirementType.intValue == NEED_FEE_EVENT_TY) {
    return;
  }

  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGFloat y = _resultLabel.frame.origin.y + _resultLabel.frame.size.height + MARGIN * 2;
  if ([self needShowNumber]) {
    y = _checkinNumberLabel.frame.origin.y + _checkinNumberLabel.frame.size.height + MARGIN;
  }
  
  CGFloat pattern[2] = {1, 2};
  
  [UIUtils draw1PxDashLine:context
                startPoint:CGPointMake(MARGIN, y + 0.5f)
                  endPoint:CGPointMake(self.frame.size.width - MARGIN, y + 0.5f)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0.0f, 0.0f)
               shadowColor:TRANSPARENT_COLOR
                   pattern:pattern];
  
  [UIUtils draw1PxDashLine:context
                startPoint:CGPointMake(self.frame.size.width/2.0f, y)
                  endPoint:CGPointMake(self.frame.size.width/2.0f, self.frame.size.height - MARGIN)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0, 0)
               shadowColor:TRANSPARENT_COLOR
                   pattern:pattern];
}


@end
