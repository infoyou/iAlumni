//
//  BrandCell.m
//  iAlumni
//
//  Created by Adam on 12-8-20.
//
//

#import "BrandCell.h"
#import "WXWLabel.h"
#import "Brand.h"
#import "CommonUtils.h"
#import "TextConstants.h"
#import "CommonUtils.h"

#define ITEM_IMG_WIDTH				50.0f
#define ITEM_IMG_HEIGHT				50.0f

#define CELL_HEIGHT           80.0f

#define LIMITED_WIDTH         220.0f

#define COUPON_INFO_WIDTH     230.0f
#define BASE_INFO_HEIGHT      15.0f

@implementation BrandCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.contentView.backgroundColor = CELL_COLOR;
    
    CGFloat backgroundViewSideLength = ITEM_IMG_WIDTH + MARGIN * 2;
    _avatarBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN,
                                                                      (CELL_HEIGHT - backgroundViewSideLength)/2,
                                                                      backgroundViewSideLength,
                                                                      backgroundViewSideLength)] autorelease];
    _avatarBackgroundView.backgroundColor = [UIColor whiteColor];
    _avatarBackgroundView.layer.borderWidth = 1.0f;
    _avatarBackgroundView.layer.borderColor = COLOR(227, 227, 227).CGColor;
    [self.contentView addSubview:_avatarBackgroundView];
    
    _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN, MARGIN, ITEM_IMG_WIDTH, ITEM_IMG_HEIGHT)];
    _avatar.backgroundColor = TRANSPARENT_COLOR;
    [_avatarBackgroundView addSubview:_avatar];
    
    _nameLabel = [self initLabel:CGRectMake(MARGIN + _avatarBackgroundView.frame.size.width + MARGIN * 2,
                                            MARGIN * 2, LIMITED_WIDTH, 0)
                       textColor:DARK_TEXT_COLOR
                     shadowColor:[UIColor whiteColor]];
    _nameLabel.numberOfLines = 0;
    _nameLabel.font = BOLD_FONT(15);
    [self.contentView addSubview:_nameLabel];
    
    _distanceLabel = [self initLabel:CGRectZero
                           textColor:BASE_INFO_COLOR
                         shadowColor:[UIColor whiteColor]];
    _distanceLabel.font = FONT(12);
    [self.contentView addSubview:_distanceLabel];
    
    _categoryLabel = [self initLabel:CGRectZero
                           textColor:BASE_INFO_COLOR
                         shadowColor:[UIColor whiteColor]];
    _categoryLabel.font = FONT(12);
    _categoryLabel.numberOfLines = 0;
    [self.contentView addSubview:_categoryLabel];
    
    _companyType = [self initLabel:CGRectZero
                         textColor:BASE_INFO_COLOR
                       shadowColor:[UIColor whiteColor]];
    _companyType.font = FONT(12);
    [self.contentView addSubview:_companyType];
    
    _couponInfoLabel = [self initLabel:CGRectZero
                             textColor:NAVIGATION_BAR_COLOR
                           shadowColor:[UIColor whiteColor]];
    _couponInfoLabel.font = BOLD_FONT(13);
    _couponInfoLabel.numberOfLines = 1;
    _couponInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_couponInfoLabel];
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_nameLabel);
  RELEASE_OBJ(_categoryLabel);
  RELEASE_OBJ(_companyType);
  RELEASE_OBJ(_couponInfoLabel);
  RELEASE_OBJ(_distanceLabel);
  [super dealloc];
}

- (void)drawCell:(Brand *)brand {
  
  CGSize size;
  
  _nameLabel.text = brand.name;
  
  size = [_nameLabel.text sizeWithFont:_nameLabel.font
                     constrainedToSize:CGSizeMake(LIMITED_WIDTH, CGFLOAT_MAX)
                         lineBreakMode:NSLineBreakByWordWrapping];
  _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y,
                                size.width, size.height);
  
  _couponInfoLabel.text = brand.couponInfo;
  size = [_couponInfoLabel.text sizeWithFont:_couponInfoLabel.font
                           constrainedToSize:CGSizeMake(COUPON_INFO_WIDTH, BASE_INFO_HEIGHT)
                               lineBreakMode:NSLineBreakByTruncatingTail];
  _couponInfoLabel.frame = CGRectMake(_nameLabel.frame.origin.x,
                                      _nameLabel.frame.origin.y + _nameLabel.frame.size.height + MARGIN, size.width, size.height);
  
  _categoryLabel.text = brand.tags;
  size = [_categoryLabel.text sizeWithFont:_categoryLabel.font
                         constrainedToSize:CGSizeMake(COUPON_INFO_WIDTH, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
  _categoryLabel.frame = CGRectMake(_nameLabel.frame.origin.x,
                                    _couponInfoLabel.frame.origin.y + _couponInfoLabel.frame.size.height + MARGIN,
                                    size.width, size.height);
  
  _companyType.text = [NSString stringWithFormat:@"| %@", brand.companyType];
  size = [_companyType.text sizeWithFont:_companyType.font
                       constrainedToSize:CGSizeMake(LIMITED_WIDTH, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];
  _companyType.frame = CGRectMake(_categoryLabel.frame.origin.x + _categoryLabel.frame.size.width + MARGIN,
                                  _categoryLabel.frame.origin.y,
                                  size.width, size.height);
  
  if (brand.nearestDistance.floatValue > 0) {
    _distanceLabel.text = STR_FORMAT(LocaleStringForKey(NSNearestVenueDistanceTitle, nil), brand.nearestDistance.floatValue);

    size = [_distanceLabel.text sizeWithFont:_distanceLabel.font
                           constrainedToSize:CGSizeMake(LIMITED_WIDTH, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    _distanceLabel.frame = CGRectMake(310.0f - MARGIN * 2 - size.width,
                                      _categoryLabel.frame.origin.y, size.width, size.height);
  }
  
  if (brand.avatarUrl.length > 0) {
    [self fetchImage:[NSMutableArray arrayWithObject:brand.avatarUrl]
            forceNew:NO];
  }
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    _avatar.image = nil;
  }
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    [_avatar.layer addAnimation:[self imageTransition] forKey:nil];
    _avatar.image = [CommonUtils cutPartImage:image width:ITEM_IMG_WIDTH height:ITEM_IMG_HEIGHT];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  
  if ([self currentUrlMatchCell:url]) {
    _avatar.image = image;
  }
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

@end
