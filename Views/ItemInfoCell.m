//
//  ItemInfoCell.m
//  ExpatCircle
//
//  Created by Adam on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ItemInfoCell.h"
#import "ServiceProvider.h"
#import "CommonUtils.h"
#import "TextConstants.h"
#import "WXWLabel.h"

@implementation ItemInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    self.textLabel.textColor = [UIColor blackColor];//COLOR(123, 124, 126);
    self.textLabel.shadowColor = [UIColor whiteColor];
    self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.textLabel.font = BOLD_FONT(15);
    
    _label = [self initLabel:CGRectZero
                   textColor:BASE_INFO_COLOR
                 shadowColor:[UIColor whiteColor]];
    _label.font = BOLD_FONT(14);
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_label];
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_label);
  
  [super dealloc];
}

- (void)drawOutBottomShadow {
  
  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.bounds.origin.x + MARGIN * 2 + 2, 
                                                                          self.bounds.origin.y + MARGIN, 
                                                                          self.bounds.size.width - MARGIN * 5 - 1, 
                                                                          self.bounds.size.height - (MARGIN + 2))
                                             byRoundingCorners:UIRectCornerAllCorners
                                                   cornerRadii:CGSizeMake(GROUP_STYLE_CELL_CORNER_RADIUS, GROUP_STYLE_CELL_CORNER_RADIUS)];
  
  self.layer.shadowPath = path.CGPath;
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
  self.layer.shadowOpacity = 0.9f;
  self.layer.masksToBounds = NO;
}

- (void)removeBottomShadow {
  self.layer.shadowPath = nil;
  self.layer.shadowColor = TRANSPARENT_COLOR.CGColor;
  self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}

- (void)drawInfoCell:(ServiceProvider *)sp 
            infoType:(ServiceProviderInfoType)infoType
    needBottomShadow:(BOOL)needBottomShadow {
  
  if (needBottomShadow) {
    [self drawOutBottomShadow];
  } else {
    [self removeBottomShadow];
  }
  
  switch (infoType) {
    case SP_INTRO_INFO_TY:
      self.textLabel.text = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSIntroTitle, nil)];
      _label.text = sp.bio;
      break;
      
    case SP_MAP_INFO_TY:
      self.textLabel.text = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSMapTitle, nil)];
      _label.text = sp.address;
      break;
      
    case SP_TAXI_INFO_TY:
      self.textLabel.text = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSTaxiTitle, nil)];
      _label.text = LocaleStringForKey(NSShowCardTitle, nil);
      break;
      
    case SP_PHONE_INFO_TY:
      self.textLabel.text = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSPhoneTitle, nil)];
      _label.text = sp.phoneNumber;      
      break;
      
    case SP_WEBSITE_INFO_TY:
      self.textLabel.text = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSWebSiteTitle, nil)];
      _label.text = sp.link;      
      break;
      
    case SP_EMAIL_INFO_TY:
      self.textLabel.text = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSEmailTitle, nil)];
      _label.text = sp.email;
      break;
      
    default:
      break;
  }
   
  CGSize size = [_label.text sizeWithFont:_label.font 
                               constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByWordWrapping];
  
  CGFloat height = MARGIN * 2 + size.height + MARGIN * 2;
  if (height < 44) {
    height = 44;
  }
  _label.frame = CGRectMake(80, (height - size.height)/2, size.width, size.height);

}


@end
