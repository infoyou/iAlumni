#import "AlumniWelfareViewCell.h"
#import "ECAsyncConnectorFacade.h"
#import "WXWConnectorDelegate.h"
#import "GlobalConstants.h"
#import "Welfare.h"

#define HIGH_CELL_H                 205
#define LOW_CELL_H                  174
#define FONT_SIZE                   13.f
#define TEXT_X                      5

@interface AlumniWelfareViewCell() <WXWConnectorDelegate>
{
  CGFloat _photoImgW;
  CGFloat _photoImgH;
}

@property (nonatomic, retain) UIImageView *bgView;
@property (nonatomic, retain) UIImageView *photoView;
@property (nonatomic, retain) UIImageView *typeView;
@property (nonatomic, retain) UIImageView *discountView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *markLabel;
@property (nonatomic, retain) UILabel *discountLabel;
@property (nonatomic, retain) UILabel *priceLabel;
@property (nonatomic, copy) NSString *photoUrl;

@property (nonatomic, retain) id<WXWImageDisplayerDelegate> imageDisplayerDelegate;
@end

@implementation AlumniWelfareViewCell

- (void)dealloc {
  self.bgView = nil;
  self.photoView = nil;
  self.typeView = nil;
  self.discountView = nil;
  self.titleLabel = nil;
  self.markLabel = nil;
  self.discountLabel = nil;
  self.priceLabel = nil;
  self.photoUrl = nil;

  self.imageDisplayerDelegate = nil;
  
  [super dealloc];
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
{
  self = [super initWithReuseIdentifier:reuseIdentifier];
  if (self) {
    self.backgroundColor = TRANSPARENT_COLOR;
    [self addSubview:self.bgView];
  }
  return self;
}

- (UIImageView *)bgView {
  if (!_bgView) {
    _bgView = [[UIImageView alloc] init];
    _bgView.contentMode = UIViewContentModeScaleAspectFill;
    _bgView.clipsToBounds = YES;
    _bgView.image = [UIImage imageNamed:@"welfareItem.png"];
    [self addSubview:_bgView];
  }
  return _bgView;
}

- (UIImageView *)photoView {
  if (!_photoView) {
    _photoView = [[UIImageView alloc] init];
    _photoView.contentMode = UIViewContentModeScaleAspectFill;
    _photoView.clipsToBounds = YES;
    [self addSubview:_photoView];
  }
  return _photoView;
}

- (UIImageView *)typeView {
  if (!_typeView) {
    _typeView = [[UIImageView alloc] init];
    _typeView.contentMode = UIViewContentModeScaleAspectFill;
    _typeView.clipsToBounds = YES;
    [self addSubview:_typeView];
  }
  return _typeView;
}

- (UIImageView *)discountView {
  if (!_discountView) {
    _discountView = [[UIImageView alloc] init];
    _discountView.contentMode = UIViewContentModeScaleAspectFill;
    _discountView.clipsToBounds = YES;
    _discountView.image = [UIImage imageNamed:@"welfareLine.png"];
    [self addSubview:_discountView];
  }
  return _discountView;
}

- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = TRANSPARENT_COLOR;
    _titleLabel.textColor = COLOR(139, 139, 139);
    _titleLabel.font = FONT(FONT_SIZE-1);
    [self addSubview:_titleLabel];
  }
  return _titleLabel;
}

- (UILabel*)markLabel {
  if (!_markLabel) {
    _markLabel = [[UILabel alloc] init];
    _markLabel.backgroundColor = TRANSPARENT_COLOR;
    _markLabel.textColor = COLOR(191, 0, 0);
    _markLabel.font = BOLD_FONT(FONT_SIZE);
    [self addSubview:_markLabel];
  }
  return _markLabel;
}
- (UILabel *)priceLabel {
  if (!_priceLabel) {
    _priceLabel = [[UILabel alloc] init];
    _priceLabel.backgroundColor = TRANSPARENT_COLOR;
    _priceLabel.textColor = COLOR(152, 152, 152);
    _priceLabel.font = FONT(FONT_SIZE-2);
    [self addSubview:_priceLabel];
  }
  return _priceLabel;
}

- (UILabel *)discountLabel {
  if (!_discountLabel) {
    _discountLabel = [[UILabel alloc] init];
    _discountLabel.backgroundColor = TRANSPARENT_COLOR;
    _discountLabel.textColor = COLOR(191, 0, 0);
    _discountLabel.font = BOLD_FONT(20);
    _discountLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_discountLabel];
  }
  return _discountLabel;
}

- (void)layoutSubviews {
  
  // bg view
  self.bgView.frame = self.bounds;
  [self.bgView setFrame:CGRectMake(self.bgView.frame.origin.x, self.bgView.frame.origin.y, self.bgView.frame.size.width, self.bgView.frame.size.height + MARGIN)];
  
  // photo view
  self.photoView.frame = self.bounds;
  [self.photoView setFrame:CGRectMake(self.photoView.frame.origin.x, self.photoView.frame.origin.y, self.bounds.size.width, self.bounds.size.height - 46.f)];
  
  // type view
  [self.typeView setFrame:CGRectMake(self.photoView.frame.origin.x+5, self.photoView.frame.origin.y-1.5, 26.f, 33.f)];
  
  // title
  self.titleLabel.frame = CGRectMake(MARGIN*2, self.bounds.size.height - 43,
                                     self.bounds.size.width - 4 * TEXT_X, 20);
  
  // price
  [self.priceLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x+5, self.bounds.size.height - 20, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height)];
  
  // discount
  [self.discountLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x+70.f, self.bounds.size.height - 25, 50.f, self.titleLabel.frame.size.height)];
}

- (void)resetLabels {
  self.titleLabel.text = NULL_PARAM_VALUE;
  self.priceLabel.text = NULL_PARAM_VALUE;
  self.markLabel.text = NULL_PARAM_VALUE;
  self.discountLabel.text = NULL_PARAM_VALUE;
}

- (void)drawWelfare:(Welfare *)welfare index:(int)index {
  
  [self resetLabels];
  
  int height = HIGH_CELL_H;
  if (index %2 == 0) {
    height = LOW_CELL_H;
  }
  
  _photoImgW = 145;
  _photoImgH = height - 46.f;
  [self drawImage:welfare.imageUrl];
  
  height -= 10;
  
  // discount View
  [self.discountView setFrame:CGRectMake(self.photoView.frame.origin.x+12, height-4.8, 63.f, 5.77f)];
  
  self.titleLabel.text = welfare.itemName;
  self.priceLabel.text = [NSString stringWithFormat:@"%@%@", LocaleStringForKey(NSPrpTitle, nil), welfare.price];
  
  self.markLabel.frame = CGRectMake(128.f, height-10, 12.f, 12.f);
  
  switch ([welfare.pTypeId intValue]) {
    case EXHIBITION_WF_TY:
    {
      self.markLabel.text = NULL_PARAM_VALUE;
      self.typeView.image = nil;
    }
      break;
      
    case COUPON_WF_TY:
    {
      self.discountLabel.text = welfare.discountRate;
      self.markLabel.text = LocaleStringForKey(NSDiscountsTitle, nil);
      self.typeView.image = [UIImage imageNamed:@"welfareJuan.png"];
    }
      break;
      
    case BUY_WF_TY:
    {
      self.discountLabel.text = welfare.salesPrice;
      self.markLabel.text = LocaleStringForKey(NSYuanTitle, nil);
      self.typeView.image = [UIImage imageNamed:@"welfareTuan.png"];
    }
      break;
      
    default:
      break;
  }
  
}

- (void)drawImage:(NSString *)imageUrl
{
  UIImage *image = nil;
  if (imageUrl && [imageUrl length] > 0 ) {
    self.photoUrl = imageUrl;
    
    image = [[WXWImageManager instance].imageCache getImage:self.photoUrl];
    if (nil == image) {
      ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                      interactionContentType:IMAGE_TY] autorelease];
      [connFacade fetchGets:self.photoUrl];

    } else {
      
      self.photoView.image = image;
    }
  } else {
    self.photoView.image = [UIImage imageNamed:@"clubDetailTopBG.png"];
  }
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
  self.photoView.image = [UIImage imageNamed:@"clubDetailTopBG.png"];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  if (url && url.length > 0) {
    UIImage *image = [UIImage imageWithData:result];
    if (image) {
      [[WXWImageManager instance].imageCache saveImageIntoCache:url image:image];
    }
    
    if ([url isEqualToString:self.photoUrl]) {
      self.photoView.image = image;
    }
  }
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType closeAsyncLoadingView:(BOOL)closeAsyncLoadingView {
  
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  
}

@end
