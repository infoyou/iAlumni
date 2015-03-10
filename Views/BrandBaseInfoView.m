//
//  BrandBaseInfoView.m
//  iAlumni
//
//  Created by Adam on 12-8-21.
//
//

#import "BrandBaseInfoView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Brand.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "UIUtils.h"

#define AVATAR_SIDE_LENGTH  60.0f
#define AVATAR_MARGIN       3.0f

@interface BrandBaseInfoView()
@property (nonatomic, copy) NSString *avatarUrl;
@end

@implementation BrandBaseInfoView

@synthesize avatarUrl = _avatarUrl;

- (void)showBigPhoto {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate showBigPhoto:self.avatarUrl];
  }
}

- (id)initWithFrame:(CGRect)frame
              brand:(Brand *)brand
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
WXWImageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)WXWImageDisplayerDelegate {
  
  self = [super initWithFrame:frame];
  if (self) {
    
    self.avatarUrl = brand.avatarUrl;
    
    _clickableElementDelegate = clickableElementDelegate;
    
    UIView *itemPicBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2,
                                                                              MARGIN * 2,
                                                                              AVATAR_SIDE_LENGTH + AVATAR_MARGIN * 2,
                                                                              AVATAR_SIDE_LENGTH + AVATAR_MARGIN * 2)] autorelease];
    
    itemPicBackgroundView.backgroundColor = [UIColor whiteColor];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(1, 1,
                                                                           itemPicBackgroundView.frame.size.width - 2,
                                                                           itemPicBackgroundView.frame.size.height - 1)];
    
    itemPicBackgroundView.layer.shadowPath = shadowPath.CGPath;
    itemPicBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    itemPicBackgroundView.layer.shadowOpacity = 0.9f;
    itemPicBackgroundView.layer.shadowRadius = 1.0f;
    itemPicBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
    itemPicBackgroundView.layer.masksToBounds = NO;
    [self addSubview:itemPicBackgroundView];
    
    _itemPicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _itemPicButton.backgroundColor = [UIColor whiteColor];
    _itemPicButton.frame = CGRectMake(AVATAR_MARGIN, AVATAR_MARGIN, AVATAR_SIDE_LENGTH, AVATAR_SIDE_LENGTH);
    _itemPicButton.showsTouchWhenHighlighted = YES;
    [_itemPicButton addTarget:self
                      action:@selector(showBigPhoto)
            forControlEvents:UIControlEventTouchUpInside];
    [itemPicBackgroundView addSubview:_itemPicButton];

    
    WXWLabel *nameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                textColor:DARK_TEXT_COLOR
                                              shadowColor:[UIColor whiteColor]] autorelease];
    nameLabel.font = BOLD_FONT(16);
    nameLabel.numberOfLines = 0;
    nameLabel.text = brand.name;
    
    CGFloat limitedWidth = self.frame.size.width - MARGIN * 4 - (AVATAR_SIDE_LENGTH + AVATAR_MARGIN) - MARGIN;
    CGSize size = [nameLabel.text sizeWithFont:nameLabel.font
                              constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    nameLabel.frame = CGRectMake(itemPicBackgroundView.frame.origin.x +
                                  itemPicBackgroundView.frame.size.width + MARGIN,
                                  itemPicBackgroundView.frame.origin.y,
                                  size.width, size.height);
    [self addSubview:nameLabel];
    
    WXWLabel *tagsLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                               textColor:BASE_INFO_COLOR
                                             shadowColor:[UIColor whiteColor]] autorelease];
    tagsLabel.font = FONT(12);
    tagsLabel.numberOfLines = 0;
    tagsLabel.text = brand.tags;
    size = [tagsLabel.text sizeWithFont:tagsLabel.font
                      constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
    tagsLabel.frame = CGRectMake(nameLabel.frame.origin.x,
                                 nameLabel.frame.origin.y + nameLabel.frame.size.height + MARGIN,
                                 size.width, size.height);
    [self addSubview:tagsLabel];
    
    CGFloat height = tagsLabel.frame.origin.y + tagsLabel.frame.size.height + MARGIN;
    CGFloat minHeight = itemPicBackgroundView.frame.origin.y + itemPicBackgroundView.frame.size.height + MARGIN * 2;
    if (height <= minHeight) {
      height = minHeight;
    }
    
    self.frame = CGRectMake(0, 0, self.frame.size.width, height);
    
    // image still being loaded, the process could be cancelled
    [_imageDisplayerDelegate registerImageUrl:brand.avatarUrl];
    
    [[WXWImageManager instance] fetchImage:brand.avatarUrl
                               caller:self
                             forceNew:NO];
  }
  return self;
}

- (void)dealloc {
  
  self.avatarUrl = nil;
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGFloat pattern[2] = {1.0, 2.0};
  
  [UIUtils draw1PxDashLine:context
                startPoint:CGPointMake(0, self.bounds.size.height - 1.5f)
                  endPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height - 1.5f)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0.0f, 1.0f)
               shadowColor:[UIColor whiteColor]
                   pattern:pattern];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  CATransition *imageFadein = [CATransition animation];
  imageFadein.duration = FADE_IN_DURATION;
  imageFadein.type = kCATransitionFade;
  [_itemPicButton.layer addAnimation:imageFadein forKey:nil];
  
  UIImage *avatar = [CommonUtils cutPartImage:image
                                        width:AVATAR_SIDE_LENGTH
                                       height:AVATAR_SIDE_LENGTH];

  if (_clickableElementDelegate) {
    [_clickableElementDelegate saveImage:avatar];
  }
  
  [_itemPicButton setImage:avatar
                  forState:UIControlStateNormal];
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}


@end
