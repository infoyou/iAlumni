//
//  CouponInfoCell.m
//  ExpatCircle
//
//  Created by Adam on 12-1-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CouponInfoCell.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"

#define ICON_SIDE_LENGTH   30.0f

#define LABEL_HEIGHT       34.0f

@implementation CouponInfoCell

- (void)drawCouponIcon {
  _iconBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 
                                                                     ICON_SIDE_LENGTH + 10.0f, 
                                                                     ICON_SIDE_LENGTH + 10.0f)] autorelease];
  _iconBackgroundView.backgroundColor = TRANSPARENT_COLOR;
  _iconBackgroundView.layer.cornerRadius = 10.5f;
  _iconBackgroundView.layer.masksToBounds = YES;
  
  UIImageView *iconImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 
                                                                              ICON_SIDE_LENGTH, 
                                                                              ICON_SIDE_LENGTH)] autorelease];
  iconImageView.image = [UIImage imageNamed:@"coupon.png"];
  iconImageView.backgroundColor = TRANSPARENT_COLOR;

  [_iconBackgroundView addSubview:iconImageView];
  [self.contentView addSubview:_iconBackgroundView];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      
      self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      self.selectionStyle = UITableViewCellSelectionStyleBlue;
      
      self.backgroundColor = SERVICE_ITEM_CELL_COLOR; 
      
      [self drawCouponIcon];
      
      _couponInfoLabel = [[self initLabel:CGRectMake(40.0f, MARGIN, 240.0f, LABEL_HEIGHT) 
                               textColor:BASE_INFO_COLOR
                              shadowColor:[UIColor whiteColor]] autorelease];
      _couponInfoLabel.font = BOLD_FONT(13);
      _couponInfoLabel.numberOfLines = 0;
      _couponInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
      [self.contentView addSubview:_couponInfoLabel];
    }
    return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)drawOutBottomShadow:(CGFloat)height {
  
  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.bounds.origin.x + MARGIN * 2 + 2, 
                                                                          self.bounds.origin.y + MARGIN, 
                                                                          self.bounds.size.width - MARGIN * 5 - 1, 
                                                                          height - (MARGIN + 3.0f))
                                             byRoundingCorners:UIRectCornerAllCorners
                                                   cornerRadii:CGSizeMake(GROUP_STYLE_CELL_CORNER_RADIUS, GROUP_STYLE_CELL_CORNER_RADIUS)];
  
  self.layer.shadowPath = path.CGPath;
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
  self.layer.shadowOpacity = 0.9f;
  self.layer.masksToBounds = NO;
  
}

- (void)drawNoShadowCell:(NSString *)content needCornerRadius:(BOOL)needCornerRadius {
  _couponInfoLabel.text = content;
  CGSize size = [_couponInfoLabel.text sizeWithFont:_couponInfoLabel.font
                                  constrainedToSize:CGSizeMake(_couponInfoLabel.frame.size.width, LABEL_HEIGHT)
                                      lineBreakMode:NSLineBreakByWordWrapping];
  _couponInfoLabel.frame = CGRectMake(_couponInfoLabel.frame.origin.x, 
                                      (self.bounds.size.height - size.height) / 2, size.width, size.height);
  
  if (needCornerRadius) {
    _iconBackgroundView.layer.cornerRadius = 10.5f;
  } else {
    _iconBackgroundView.layer.cornerRadius = 0.0f;
  }
}

- (void)drawShadowCell:(NSString *)content 
                height:(CGFloat)height 
      needCornerRadius:(BOOL)needCornerRadius {
  
  [self drawNoShadowCell:content needCornerRadius:needCornerRadius];
  
  [self drawOutBottomShadow:height];
}

@end
