//
//  CouponInfoHeaderView.m
//  ExpatCircle
//
//  Created by Adam on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CouponInfoHeaderView.h"
#import "CouponItem.h"
#import "PhoneNumber.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "CouponImageView.h"
#import "WXWLabel.h"

#define IMAGE_AREA_WIDTH   320.0f
#define IMAGE_AREA_HEIGHT  220.0f

@implementation CouponInfoHeaderView

- (void)initLables {
  _nameLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN * 2, 
                                                          _imageView.frame.origin.y + _imageView.frame.size.height + 
                                                          MARGIN,
                                                          0, 0)
                                     textColor:NAVIGATION_BAR_COLOR
                                   shadowColor:[UIColor whiteColor]] autorelease];
  _nameLabel.font = BOLD_FONT(13);
  _nameLabel.text = _item.name;
  _nameLabel.numberOfLines = 0;
  _nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
  CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font
                            constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                                lineBreakMode:NSLineBreakByWordWrapping];
  _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, 
                                _nameLabel.frame.origin.y, 
                                size.width, size.height);
  [self addSubview:_nameLabel];
  
  if (_item.validity && _item.validity.length > 0) {
    _validityTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN * 2, 
                                                                     _nameLabel.frame.origin.y +
                                                                     _nameLabel.frame.size.height + MARGIN, 0, 0)
                                                textColor:BASE_INFO_COLOR
                                              shadowColor:[UIColor whiteColor]] autorelease];
    _validityTitleLabel.font = BOLD_FONT(13);
    _validityTitleLabel.text = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSValidityTitle, nil)];
    size = [_validityTitleLabel.text sizeWithFont:_validityTitleLabel.font
                                         forWidth:self.frame.size.width - MARGIN * 4
                                    lineBreakMode:NSLineBreakByWordWrapping];
    _validityTitleLabel.frame = CGRectMake(_validityTitleLabel.frame.origin.x, 
                                           _validityTitleLabel.frame.origin.y, 
                                           size.width, size.height);
    [self addSubview:_validityTitleLabel];
    
    _validityValueLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(_validityTitleLabel.frame.origin.x + 
                                                                     _validityTitleLabel.frame.size.width,
                                                                     _validityTitleLabel.frame.origin.y, 0, 0)
                                                textColor:BASE_INFO_COLOR
                                              shadowColor:[UIColor whiteColor]] autorelease];
    _validityValueLabel.font = BOLD_FONT(13);
    _validityValueLabel.numberOfLines = 0;
    _validityValueLabel.text = _item.validity;
    size = [_validityValueLabel.text sizeWithFont:_validityValueLabel.font
                                constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 2 - 
                                                             (_validityTitleLabel.frame.origin.x +
                                                              _validityTitleLabel.frame.size.width), CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
    _validityValueLabel.frame = CGRectMake(_validityValueLabel.frame.origin.x, 
                                           _validityValueLabel.frame.origin.y, 
                                           size.width, size.height);
    [self addSubview:_validityValueLabel];
  }
}

- (id)initWithFrame:(CGRect)frame 
               item:(CouponItem *)item
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate {
  
  self = [super initWithFrame:frame];
  
  if (self) {
    _item = item;
    
    _clickableElementDelegate = clickableElementDelegate;
    
    self.backgroundColor = CELL_COLOR;
    
    _imageView = [[[CouponImageView alloc] initWithFrame:CGRectMake(0, 0, 
                                                                    IMAGE_AREA_WIDTH, 
                                                                    IMAGE_AREA_HEIGHT) 
                                                imageUrl:_item.imageUrl
                                  imageDisplayerDelegate:imageDisplayerDelegate
                                clickableElementDelegate:clickableElementDelegate] autorelease];
    [self addSubview:_imageView];
    
    [self initLables];
    
  }
  return self;
}

- (void)dealloc {
  
  
  
  [super dealloc];
}



@end
