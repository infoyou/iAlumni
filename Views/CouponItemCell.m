//
//  CouponItemCell.m
//  ExpatCircle
//
//  Created by Adam on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CouponItemCell.h"
#import "ServiceItem.h"
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "TextConstants.h"

#define ITEM_IMG_WIDTH				50.0f
#define ITEM_IMG_HEIGHT				50.0f
#define ITEM_NAME_WIDTH				230.0f
#define ITEM_NAME_HEIGHT			20.0f

#define COUPON_TITLE_Y        25.0f

#define STATUS_Y              83.0f

#define COUPON_INFO_MAX_HEIGHT  32.0f

@implementation CouponItemCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
                MOC:(NSManagedObjectContext *)MOC {
  
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];
  if (self) {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.contentView.backgroundColor = CELL_COLOR;
    
    CGFloat backgroundViewSideLength = ITEM_IMG_WIDTH + 10.0f;
    UIView *imageBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN, 
                                                                            (80.0f - backgroundViewSideLength)/2, 
                                                                            backgroundViewSideLength, 
                                                                            backgroundViewSideLength)] autorelease];
    imageBackgroundView.backgroundColor = [UIColor whiteColor];
    imageBackgroundView.layer.borderWidth = 1.0f;
    imageBackgroundView.layer.borderColor = COLOR(227, 227, 227).CGColor;
    [self.contentView addSubview:imageBackgroundView];
    
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN, MARGIN, ITEM_IMG_WIDTH, ITEM_IMG_HEIGHT)];
    _avatarView.backgroundColor = TRANSPARENT_COLOR;
    [imageBackgroundView addSubview:_avatarView];
    
    _nameLabel = [self initLabel:CGRectMake(MARGIN + imageBackgroundView.frame.size.width + MARGIN * 2, 
                                            MARGIN, ITEM_NAME_WIDTH, 0)
                       textColor:DARK_TEXT_COLOR
                     shadowColor:[UIColor whiteColor]];
    _nameLabel.font = FONT(16);
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_nameLabel];
    
    _couponTitleLabel = [self initLabel:CGRectMake(_nameLabel.frame.origin.x,
                                                   COUPON_TITLE_Y,
                                                   0, 
                                                   0)
                              textColor:NAVIGATION_BAR_COLOR
                            shadowColor:[UIColor whiteColor]];
    _couponTitleLabel.font = FONT(13);
    _couponTitleLabel.numberOfLines = 0;
    _couponTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_couponTitleLabel];
    
    _addressLabel = [self initLabel:CGRectMake(_nameLabel.frame.origin.x,
                                               0, 0, 0)
                          textColor:[UIColor blackColor]
                        shadowColor:[UIColor whiteColor]];
    _addressLabel.font = FONT(12);
    _addressLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_addressLabel];
    
    _tagsLabel = [self initLabel:CGRectMake(_nameLabel.frame.origin.x, 
                                            STATUS_Y, 0, 0)
                       textColor:BASE_INFO_COLOR
                     shadowColor:[UIColor whiteColor]];
    _tagsLabel.font = FONT(12);
    _tagsLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_tagsLabel];
    
    _distanceLabel = [self initLabel:CGRectMake(0, STATUS_Y, 0, 0)
                           textColor:BASE_INFO_COLOR
                         shadowColor:[UIColor whiteColor]];
    _distanceLabel.font = FONT(12);
    [self.contentView addSubview:_distanceLabel];
  }
  
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_nameLabel);
  RELEASE_OBJ(_couponTitleLabel);
  RELEASE_OBJ(_addressLabel);
  RELEASE_OBJ(_tagsLabel);
  RELEASE_OBJ(_distanceLabel);
  
  [super dealloc];
}

- (void)drawItem:(ServiceItem *)item index:(NSInteger)index {
  if (nil == item) {
    return;
  }
  
  _nameLabel.text = [NSString stringWithFormat:@"%d. %@", index + 1, item.itemName];
  CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font
                                     forWidth:ITEM_NAME_WIDTH
                                lineBreakMode:NSLineBreakByWordWrapping];
  _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x,
                                _nameLabel.frame.origin.y, 
                                size.width,
                                size.height);
  
  _couponTitleLabel.text = item.couponInfo;
  size = [_couponTitleLabel.text sizeWithFont:_couponTitleLabel.font
                                   constrainedToSize:CGSizeMake(ITEM_NAME_WIDTH, COUPON_INFO_MAX_HEIGHT) 
                                       lineBreakMode:NSLineBreakByWordWrapping];

  CGFloat couponInfoAndAddressHeight = size.height + MARGIN;
  
  _couponTitleLabel.frame = CGRectMake(_couponTitleLabel.frame.origin.x, 
                                       0, 
                                       size.width, size.height);
  
  _addressLabel.text = item.address;
  size = [_addressLabel.text sizeWithFont:_addressLabel.font
                                 forWidth:ITEM_NAME_WIDTH
                            lineBreakMode:NSLineBreakByTruncatingTail];
  
  couponInfoAndAddressHeight += size.height;
  _addressLabel.frame = CGRectMake(_addressLabel.frame.origin.x,
                                   0,
                                   size.width, size.height);
  
  _distanceLabel.text = [NSString stringWithFormat:@"%.2f %@", 
                         item.distance.floatValue, LocaleStringForKey(NSKMTitle, nil)];
  size = [_distanceLabel.text sizeWithFont:_distanceLabel.font
                         constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
  _distanceLabel.frame = CGRectMake(self.frame.size.width - MARGIN - size.width, 
                                    _distanceLabel.frame.origin.y, 
                                    size.width, size.height);
  
  CGFloat tagWidth = _distanceLabel.frame.origin.x - _nameLabel.frame.origin.x - MARGIN;
  _tagsLabel.text = [NSString stringWithFormat:@"%@ | %@", 
                     item.categoryName, item.tagNames];
  size = [_tagsLabel.text sizeWithFont:_tagsLabel.font
                              forWidth:tagWidth
                         lineBreakMode:NSLineBreakByWordWrapping];

  _tagsLabel.frame = CGRectMake(_tagsLabel.frame.origin.x, 
                                _tagsLabel.frame.origin.y, 
                                tagWidth, size.height);
  
  // adjust coupon info and address y location
  CGFloat space = _tagsLabel.frame.origin.y - 
  (_nameLabel.frame.origin.y + _nameLabel.frame.size.height);
  
  CGFloat couponInfo_y = (space - couponInfoAndAddressHeight)/2.0f +
                          _nameLabel.frame.origin.y + _nameLabel.frame.size.height;
  _couponTitleLabel.frame = CGRectMake(_couponTitleLabel.frame.origin.x,
                                       couponInfo_y, 
                                       _couponTitleLabel.frame.size.width, 
                                       _couponTitleLabel.frame.size.height);
  _addressLabel.frame = CGRectMake(_addressLabel.frame.origin.x, 
                                   _couponTitleLabel.frame.origin.y + 
                                   _couponTitleLabel.frame.size.height + MARGIN,
                                   _addressLabel.frame.size.width,
                                   _addressLabel.frame.size.height);
  
  
  if (item.thumbnailUrl && item.thumbnailUrl.length > 0) {
    NSMutableArray *urls = [NSMutableArray array];
    [urls addObject:item.thumbnailUrl];
    [self fetchImage:urls forceNew:NO];
  } else {
    _avatarView.image = nil;
  }
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    _avatarView.image = nil;
  }  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    [_avatarView.layer addAnimation:[self imageTransition] forKey:nil];
    _avatarView.image = [CommonUtils cutPartImage:image
                                            width:ITEM_IMG_WIDTH
                                           height:ITEM_IMG_HEIGHT];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

@end
