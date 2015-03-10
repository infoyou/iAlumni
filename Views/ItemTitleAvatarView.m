//
//  ItemTitleAvatarView.m
//  iAlumni
//
//  Created by Adam on 12-8-6.
//
//

#import "ItemTitleAvatarView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "ServiceItem.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "TextConstants.h"
#import "UIUtils.h"

#define OVERHEADER_OFFSET 50

#define AVATAR_WIDTH      320.0f
#define AVATAR_HEIGHT     190.0f//240.0f

#define PRICE_ICON_HEIGHT 64.0f
#define PRICE_ICON_WIDTH  64.0f

#define TAG_ICON_SIDE_LENGTH 16.0f

#define TITLE_COLOR       COLOR(93, 83, 83)

@interface ItemTitleAvatarView()
@property (nonatomic, retain) ServiceItem *item;
@property (nonatomic, retain) UIImage *image;
@end

@implementation ItemTitleAvatarView

@synthesize item = _item;
@synthesize image = _image;

#pragma mark - lifecycle methods

- (void)initViews {
  
  _avatarBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0,
                                                                    OVERHEADER_OFFSET * -1,
                                                                    AVATAR_WIDTH,
                                                                    AVATAR_HEIGHT + OVERHEADER_OFFSET)] autorelease];
  _avatarBackgroundView.backgroundColor = CELL_COLOR;
  _avatarBackgroundView.layer.masksToBounds = YES;
  [self addSubview:_avatarBackgroundView];
  
  _avatar = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, AVATAR_WIDTH, AVATAR_WIDTH)] autorelease];
  _avatar.backgroundColor = CELL_COLOR;
  [_avatarBackgroundView addSubview:_avatar];
  
  _priceBackgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
  _priceBackgroundView.layer.cornerRadius = 6.0f;
  _priceBackgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
  [_avatar addSubview:_priceBackgroundView];
  
  WXWLabel *priceNameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                  textColor:[UIColor whiteColor]
                                                shadowColor:TRANSPARENT_COLOR] autorelease];
  priceNameLabel.font = BOLD_FONT(12);
  priceNameLabel.text = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSPriceTitle, nil)];
  CGSize size = [priceNameLabel.text sizeWithFont:priceNameLabel.font
                                constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
  priceNameLabel.frame = CGRectMake(MARGIN, MARGIN * 2 - 1.0f, size.width, size.height);
  [_priceBackgroundView addSubview:priceNameLabel];
  
  _priceLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                      textColor:COLOR(233, 89, 82)
                                    shadowColor:TRANSPARENT_COLOR] autorelease];
  _priceLabel.font = BOLD_FONT(17);
  _priceLabel.text = self.item.headerParamValue;
  size = [_priceLabel.text sizeWithFont:_priceLabel.font
                             constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  
  _priceBackgroundView.frame = CGRectMake(MARGIN,
                                          MARGIN + OVERHEADER_OFFSET,
                                          priceNameLabel.frame.size.width + size.width + MARGIN * 2,
                                          size.height + MARGIN * 2);

  _priceLabel.frame = CGRectMake(priceNameLabel.frame.origin.x + priceNameLabel.frame.size.width,
                                 (_priceBackgroundView.frame.size.height - size.height)/2.0f, size.width, size.height);
  
  
  [_priceBackgroundView addSubview:_priceLabel];
  
  _nameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                     textColor:TITLE_COLOR
                                   shadowColor:[UIColor whiteColor]] autorelease];
  _nameLabel.font = BOLD_FONT(16);
  _nameLabel.numberOfLines = 0;
  _nameLabel.text = self.item.itemName;
  size = [_nameLabel.text sizeWithFont:_nameLabel.font
                     constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4,
                                                  CGFLOAT_MAX)
                         lineBreakMode:NSLineBreakByWordWrapping];
  _nameLabel.frame = CGRectMake(MARGIN * 2,
                                _avatarBackgroundView.frame.origin.y + _avatarBackgroundView.frame.size.height + MARGIN,
                                size.width, size.height);
  [self addSubview:_nameLabel];
  
  _tagIcon = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN * 2,
                                                            _nameLabel.frame.origin.y +
                                                            _nameLabel.frame.size.height + MARGIN,
                                                            TAG_ICON_SIDE_LENGTH,
                                                            TAG_ICON_SIDE_LENGTH)] autorelease];
  _tagIcon.backgroundColor = TRANSPARENT_COLOR;
  _tagIcon.image = [UIImage imageNamed:@"tag"];
  [self addSubview:_tagIcon];
  
  _tagsLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                     textColor:BASE_INFO_COLOR
                                   shadowColor:[UIColor whiteColor]] autorelease];
  _tagsLabel.numberOfLines = 0;
  _tagsLabel.font = FONT(11);
  _tagsLabel.text = self.item.tagNames;
  CGFloat widthLimited = self.frame.size.width - MARGIN * 4 - _tagIcon.frame.size.width - MARGIN;
  size = [_tagsLabel.text sizeWithFont:_tagsLabel.font
                     constrainedToSize:CGSizeMake(widthLimited, CGFLOAT_MAX)
                         lineBreakMode:NSLineBreakByWordWrapping];
  _tagsLabel.frame = CGRectMake(_tagIcon.frame.origin.x + _tagIcon.frame.size.width + MARGIN,
                                _tagIcon.frame.origin.y, size.width, size.height);
  [self addSubview:_tagsLabel];
}

- (id)initWithFrame:(CGRect)frame
               item:(ServiceItem *)item
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate {
  
  self = [super initWithFrame:frame];
  
  if (self) {
    
    self.backgroundColor = CELL_COLOR;
    
    self.item = item;
    
    _imageDisplayerDelegate = imageDisplayerDelegate;
    
    [self initViews];
    
    if (_imageDisplayerDelegate) {
      [_imageDisplayerDelegate registerImageUrl:self.item.imageUrl];
    }
    
    [[WXWImageManager instance].imageCache fetchImage:self.item.imageUrl caller:self forceNew:NO];
  }
  return self;
}

- (void)dealloc {
  
  self.item = nil;
  self.image = nil;
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {

  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0, AVATAR_HEIGHT)
                endPoint:CGPointMake(self.frame.size.width, AVATAR_HEIGHT)
                   color:SEPARATOR_LINE_COLOR.CGColor
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];
}

#pragma mark - adjust scroll speed
- (void)adjustScrollSpeedWithOffset:(CGPoint)offset {
  
  if (offset.y >= 0) {
    return;
  }
  
  CGFloat offsetValue = offset.y/3.0f;
  _avatarBackgroundView.frame = CGRectMake(_avatarBackgroundView.frame.origin.x,
                                           -1 * OVERHEADER_OFFSET + offsetValue,
                                           _avatarBackgroundView.frame.size.width,
                                           (AVATAR_HEIGHT + OVERHEADER_OFFSET) - offsetValue);
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  CATransition *imageFade = [CATransition animation];
  imageFade.duration = FADE_IN_DURATION;
  imageFade.type = kCATransitionFade;
  [_avatar.layer addAnimation:imageFade forKey:nil];
  self.image = [CommonUtils cutMiddlePartImage:image
                                         width:AVATAR_WIDTH + OVERHEADER_OFFSET
                                        height:AVATAR_WIDTH + OVERHEADER_OFFSET];
  _avatar.image = self.image;
  
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

@end
