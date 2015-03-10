//
//  ServiceItemCell.m
//  ExpatCircle
//
//  Created by Adam on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ServiceItemCell.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Store.h"
#import "TextConstants.h"
#import "AppManager.h"
#import "CommonUtils.h"

#define ITEM_IMG_WIDTH				60.0f
#define ITEM_IMG_HEIGHT				60.0f

#define ITEM_NAME_WIDTH				240.0f
#define ITEM_NAME_HEIGHT			20.0f

#define ADDRESS_Y    					35.0f

#define BASE_INFO_HEIGHT      15.0f

#define ICON_WIDTH            16.0f
#define ICON_HEIGHT           16.0f

#define STATUS_Y              58.0f

#define HOT_IND_X             297.0f
#define HOT_IND_WIDTH         22.0f
#define HOT_IND_HEIGHT        22.0f

#define LABEL_WIDTH           120.0f
#define LABEL_HEIGHT          20.0f

#define COUPON_X              285.0f
#define COUPON_SIDE_LENGTH    32.0f

#define COMMENT_X             140.0f

@interface ServiceItemCell ()
@property (nonatomic, copy) NSString *tel;
@end

@implementation ServiceItemCell

#pragma mark - user action
- (void)callSupport:(id)sender {
  if (_venueListVC && _callAction) {
    [_venueListVC performSelector:_callAction withObject:self.tel];
  }
}

#pragma mark - lifecycle methods
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
                MOC:(NSManagedObjectContext *)MOC
        venueListVC:(id)venueListVC
         callAction:(SEL)callAction {
  
  self = [super initWithStyle:style 
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate 
                          MOC:MOC];
  if (self) {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.contentView.backgroundColor = CELL_COLOR;
    self.backgroundColor = CELL_COLOR;
    
    _venueListVC = venueListVC;
    _callAction = callAction;
    
    CGFloat backgroundViewSideLength = ITEM_IMG_WIDTH + 10.0f;
    UIView *imageBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN, 
                                                                            (90.0f - backgroundViewSideLength)/2,
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
                                            imageBackgroundView.frame.origin.y, ITEM_NAME_WIDTH, ITEM_NAME_HEIGHT)
                       textColor:[UIColor blackColor]
                     shadowColor:[UIColor whiteColor]];
    _nameLabel.numberOfLines = 1;
    _nameLabel.font = FONT(16);
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_nameLabel];
    
    
    _addressLabel = [self initLabel:CGRectMake(_nameLabel.frame.origin.x,
                                               ADDRESS_Y, 0, BASE_INFO_HEIGHT)
                          textColor:DARK_TEXT_COLOR
                        shadowColor:[UIColor whiteColor]];
    _addressLabel.font = FONT(12);
    _addressLabel.numberOfLines = 1;
    _addressLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_addressLabel];
    
    
    _telButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _telButton.titleLabel.font = BOLD_FONT(12);
    [_telButton setTitleColor:NAVIGATION_BAR_COLOR
                     forState:UIControlStateNormal];
    [_telButton addTarget:self
                   action:@selector(callSupport:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_telButton];
        
    _distanceLabel = [self initLabel:CGRectMake(0, STATUS_Y + MARGIN, 0, BASE_INFO_HEIGHT)
                           textColor:BASE_INFO_COLOR
                         shadowColor:[UIColor whiteColor]];
    _distanceLabel.font = FONT(12);
    [self.contentView addSubview:_distanceLabel];
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_avatarView);
  RELEASE_OBJ(_nameLabel);
  RELEASE_OBJ(_addressLabel);

  RELEASE_OBJ(_distanceLabel);
  
  self.tel = nil;
  
  [super dealloc];
}

- (void)prepareForReuse {
  [super prepareForReuse];
  
  _avatarView.image = nil;
}

- (void)drawItem:(Store *)item index:(NSInteger)index {

  _nameLabel.text = [NSString stringWithFormat:@"%d. %@", index + 1, item.storeName];
  
  _addressLabel.text = item.address;
  CGFloat addressWidth = self.frame.size.width - _addressLabel.frame.origin.x - MARGIN * 2;
  _addressLabel.frame = CGRectMake(_addressLabel.frame.origin.x,
                                   _addressLabel.frame.origin.y,
                                   addressWidth, _addressLabel.frame.size.height);
  
  self.tel = item.tel;
  if (item.tel.length > 0) {
    [_telButton setTitle:STR_FORMAT(@" %@", item.tel) forState:UIControlStateNormal];
    [_telButton setImage:[UIImage imageNamed:@"redTel.png"] forState:UIControlStateNormal];
    CGSize size = [_telButton.titleLabel.text sizeWithFont:_telButton.titleLabel.font];
    _telButton.frame = CGRectMake(_nameLabel.frame.origin.x, STATUS_Y + 2,
                                  ICON_WIDTH + MARGIN + size.width, size.height + 4);
  }

  _distanceLabel.text = [NSString stringWithFormat:@"%.2f %@",
                         item.distance.floatValue, 
                         LocaleStringForKey(NSKMTitle, nil)];
  
  CGSize size = [_distanceLabel.text sizeWithFont:_distanceLabel.font
                         constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
  
  _distanceLabel.frame = CGRectMake(self.frame.size.width - MARGIN - size.width,
                                    _distanceLabel.frame.origin.y, 
                                    size.width, _distanceLabel.frame.size.height);
  
  if (item.imageUrl && item.imageUrl.length > 0) {
    NSMutableArray *urls = [NSMutableArray array];
    [urls addObject:item.imageUrl];
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
    _avatarView.image = [CommonUtils cutPartImage:image width:ITEM_IMG_WIDTH height:ITEM_IMG_HEIGHT];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}
@end
