//
//  AttendInfoCell.m
//  iAlumni
//
//  Created by Adam on 12-9-7.
//
//

#import "AttendInfoCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIUtils.h"
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"

#define HEIGHT  70.0f

#define BUTTON_WIDTH  159.0f

@implementation AttendInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
             target:(id)target
   signUpInfoAction:(SEL)signUpInfoAction
  checkinInfoAction:(SEL)checkinInfoAction
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self) {
    
    _signUpInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _signUpInfoButton.backgroundColor = CELL_COLOR;
    [_signUpInfoButton addTarget:target
                          action:signUpInfoAction
                forControlEvents:UIControlEventTouchUpInside];
    [_signUpInfoButton setImage:[UIImage imageNamed:@"table_arrow.png"]
                       forState:UIControlStateNormal];
    [_signUpInfoButton setTitleColor:DARK_TEXT_COLOR forState:UIControlStateNormal];
    [_signUpInfoButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _signUpInfoButton.titleLabel.font = BOLD_HK_FONT(26);
    _signUpInfoButton.frame = CGRectMake(0, 0, BUTTON_WIDTH, HEIGHT - 2.0f);
    _signUpInfoButton.imageEdgeInsets = UIEdgeInsetsMake(0, 133, 0, 5);
    _signUpInfoButton.titleEdgeInsets = UIEdgeInsetsMake(40, 0, 0, 0);
    [self.contentView addSubview:_signUpInfoButton];
    
    WXWLabel *signUpLabel = [[self initLabel:CGRectZero
                                  textColor:CELL_TITLE_COLOR
                                shadowColor:[UIColor whiteColor]] autorelease];
    signUpLabel.font = BOLD_FONT(14);
    signUpLabel.text = LocaleStringForKey(NSSignedUpCountTitle, nil);
    CGSize size = [signUpLabel.text sizeWithFont:signUpLabel.font
                               constrainedToSize:CGSizeMake(BUTTON_WIDTH, CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    signUpLabel.frame = CGRectMake((BUTTON_WIDTH - size.width)/2.0f, MARGIN,
                                   size.width, size.height);
    [_signUpInfoButton addSubview:signUpLabel];
    
    _checkinInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _checkinInfoButton.backgroundColor = CELL_COLOR;
    [_checkinInfoButton addTarget:target
                           action:checkinInfoAction
                 forControlEvents:UIControlEventTouchUpInside];
    [_checkinInfoButton setImage:[UIImage imageNamed:@"table_arrow.png"]
                        forState:UIControlStateNormal];
    [_checkinInfoButton setTitleColor:DARK_TEXT_COLOR forState:UIControlStateNormal];
    [_checkinInfoButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _checkinInfoButton.titleLabel.font = BOLD_HK_FONT(26);
    
    _checkinInfoButton.frame = CGRectMake(BUTTON_WIDTH + 2.0f, 0, BUTTON_WIDTH, HEIGHT - 2.0f);
    _checkinInfoButton.imageEdgeInsets = UIEdgeInsetsMake(0, 133, 0, 5);
    _checkinInfoButton.titleEdgeInsets = UIEdgeInsetsMake(40, 0, 0, 0);
    [self.contentView addSubview:_checkinInfoButton];
    
    WXWLabel *checkedinLabel = [[self initLabel:CGRectZero
                                     textColor:CELL_TITLE_COLOR
                                   shadowColor:[UIColor whiteColor]] autorelease];
    checkedinLabel.font = BOLD_FONT(14);
    checkedinLabel.text = LocaleStringForKey(NSCheckedinCountTitle, nil);
    size = [checkedinLabel.text sizeWithFont:checkedinLabel.font
                           constrainedToSize:CGSizeMake(BUTTON_WIDTH, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    checkedinLabel.frame = CGRectMake((BUTTON_WIDTH - size.width)/2.0f, MARGIN,
                                      size.width, size.height);
    [_checkinInfoButton addSubview:checkedinLabel];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)updateSignedUpCount:(NSInteger)signedUpCount
             checkedinCount:(NSInteger)checkedinCount {
  [_signUpInfoButton setTitle:[NSString stringWithFormat:@"%d", signedUpCount]
                     forState:UIControlStateNormal];
  
  [_checkinInfoButton setTitle:[NSString stringWithFormat:@"%d", checkedinCount]
                      forState:UIControlStateNormal];
}

- (void)drawRect:(CGRect)rect {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGFloat pattern[2] = {1, 2};
  
  [UIUtils draw1PxDashLine:context
                startPoint:CGPointMake(BUTTON_WIDTH, 0)
                  endPoint:CGPointMake(BUTTON_WIDTH, HEIGHT - 1.0f)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(1.0f, 0.0f)
               shadowColor:[UIColor whiteColor]
                   pattern:pattern];
  
  [UIUtils draw1PxDashLine:context
                startPoint:CGPointMake(0, HEIGHT - 1.5f)
                  endPoint:CGPointMake(self.frame.size.width, HEIGHT - 1.5f)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0.0f, 1.0f)
               shadowColor:[UIColor whiteColor]
                   pattern:pattern];
}

@end
