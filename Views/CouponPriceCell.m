//
//  CouponPriceCell.m
//  ExpatCircle
//
//  Created by Adam on 12-5-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CouponPriceCell.h"
#import "CouponItem.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "WXWLabel.h"

#define DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH  280.0f

@implementation CouponPriceCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    self.backgroundColor = SERVICE_ITEM_CELL_COLOR;
    
    _priceInfoTitleLabel = [[self initLabel:CGRectZero
                                  textColor:BASE_INFO_COLOR
                                shadowColor:[UIColor whiteColor]] autorelease];
    _priceInfoTitleLabel.font = FONT(13);
    _priceInfoTitleLabel.text = [NSString stringWithFormat:@"%@: ", 
                                 LocaleStringForKey(NSPriceDetailTitle, nil)];
    [self.contentView addSubview:_priceInfoTitleLabel];
    
    CGSize size = [_priceInfoTitleLabel.text sizeWithFont:_priceInfoTitleLabel.font
                                        constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                            lineBreakMode:NSLineBreakByWordWrapping];
    _priceInfoTitleLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2, size.width, size.height);
    
    _priceInfoValueLabe = [[self initLabel:CGRectZero
                                 textColor:NAVIGATION_BAR_COLOR
                               shadowColor:[UIColor whiteColor]] autorelease];
    _priceInfoValueLabe.font = BOLD_FONT(15);
    _priceInfoValueLabe.numberOfLines = 0;
    [self.contentView addSubview:_priceInfoValueLabe];
    
    _prpTitleLabel = [[self initLabel:CGRectZero
                            textColor:BASE_INFO_COLOR
                          shadowColor:[UIColor whiteColor]] autorelease];
    _prpTitleLabel.font = FONT(13);
    _prpTitleLabel.text = [NSString stringWithFormat:@"%@: ", 
                           LocaleStringForKey(NSPrpTitle, nil)];
    [self.contentView addSubview:_prpTitleLabel];
    
    _prpValueLabel = [[self initLabel:CGRectZero
                            textColor:BASE_INFO_COLOR
                          shadowColor:[UIColor whiteColor]] autorelease];
    _prpValueLabel.font = FONT(13);
    [self.contentView addSubview:_prpValueLabel];
  }
  return self;
}

- (void)dealloc {
  
  
  [super dealloc];
}

- (void)drawCell:(CouponItem *)couponItem {
  
  CGSize size;
  
  if (couponItem.reducedPrice && couponItem.reducedPrice) {
    _priceInfoTitleLabel.hidden = NO;
    _priceInfoValueLabe.hidden = NO;
    
    size = [_priceInfoTitleLabel.text sizeWithFont:_priceInfoTitleLabel.font
                                 constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
    _priceInfoTitleLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2, size.width, size.height);
    
    _priceInfoValueLabe.text = couponItem.reducedPrice;
    size = [_priceInfoValueLabe.text sizeWithFont:_priceInfoValueLabe.font
                                constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH - (_priceInfoTitleLabel.frame.origin.x + 
                                                                    _priceInfoTitleLabel.frame.size.width + MARGIN), CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    _priceInfoValueLabe.frame = CGRectMake(_priceInfoTitleLabel.frame.origin.x + 
                                           _priceInfoTitleLabel.frame.size.width + MARGIN, 
                                           _priceInfoTitleLabel.frame.origin.y - 2.0f, 
                                           size.width, size.height);
    
  } else {
    _priceInfoTitleLabel.hidden = YES;
    _priceInfoValueLabe.hidden = YES;
  }
  
  if (couponItem.prp && couponItem.prp.length > 0) {
    _prpTitleLabel.hidden = NO;
    _prpValueLabel.hidden = NO;
    
    CGFloat y = MARGIN * 2;
    if (couponItem.reducedPrice && couponItem.reducedPrice.length > 0) {
      y = _priceInfoValueLabe.frame.origin.y + _priceInfoValueLabe.frame.size.height + MARGIN;
    }
    
    size = [_prpTitleLabel.text sizeWithFont:_prpTitleLabel.font
                           constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    _prpTitleLabel.frame = CGRectMake(MARGIN * 2, y, size.width, size.height);
    
    _prpValueLabel.text = couponItem.prp;
    size = [_prpValueLabel.text sizeWithFont:_prpValueLabel.font
                           constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH -
                                                        (_prpTitleLabel.frame.origin.x +
                                                                  _prpTitleLabel.frame.size.width + MARGIN),
                                                        CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    _prpValueLabel.frame = CGRectMake(_prpTitleLabel.frame.origin.x +
                                      _prpTitleLabel.frame.size.width + MARGIN,
                                      _prpTitleLabel.frame.origin.y,
                                      size.width, size.height);
  } else {
    _prpTitleLabel.hidden = YES;
    _prpValueLabel.hidden = YES;
  }
}

@end
