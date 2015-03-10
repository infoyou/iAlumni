//
//  WelfareBrandEntranceCell.m
//  iAlumni
//
//  Created by Adam on 13-8-18.
//
//

#import "WelfareBrandEntranceCell.h"
#import "WXWLabel.h"
#import "WelfareCellBoardView.h"
#import "Welfare.h"
#import "AppManager.h"

#define INNER_MARGIN      8.0f

#define STORE_IMG_SIDE_LEN  56.0f


@implementation WelfareBrandEntranceCell

#pragma mark - life cycle methods
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
           detailVC:(id)detailVC
    openBrandAction:(SEL)openBrandAction {
  
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC
                     detailVC:detailVC
                   openAction:openBrandAction];
  if (self) {
    
    _textLimitedWidth = _boardView.frame.size.width - INNER_MARGIN * 2 - STORE_IMG_SIDE_LEN - INNER_MARGIN * 2;
    
    _addressLabel = [[self initLabel:CGRectZero
                           textColor:BASE_INFO_COLOR
                         shadowColor:TRANSPARENT_COLOR] autorelease];
    _addressLabel.font = BOLD_FONT(15);
    _addressLabel.numberOfLines = 0;
    [_boardView addSubview:_addressLabel];
    
    _branchLabel = [[self initLabel:CGRectZero
                          textColor:COLOR(233, 100, 73)
                        shadowColor:TRANSPARENT_COLOR] autorelease];
    _branchLabel.font = BOLD_FONT(15);
    _branchLabel.numberOfLines = 0;
    _branchLabel.textAlignment = NSTextAlignmentCenter;
    [_boardView addSubview:_branchLabel];
    
    _storeImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    [_boardView addSubview:_storeImageView];
  }
  
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - draw cell

- (void)fetchStoreImageWithUrl:(NSString *)url {
  if (url.length > 0) {
    [self fetchImage:[NSMutableArray arrayWithObject:url] forceNew:NO];
  }
}

- (void)drawCellWithWelfare:(Welfare *)welfare height:(CGFloat)height {
  
  [self fetchStoreImageWithUrl:welfare.brandLogoUrl];
  
  [super drawCellWithWelfare:welfare
                       title:LocaleStringForKey(NSBrandInfoTitle, nil)
                      height:height];
  
  _storeImageView.frame = CGRectMake(INNER_MARGIN, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + INNER_MARGIN, STORE_IMG_SIDE_LEN, STORE_IMG_SIDE_LEN);
  
  _nameLabel.text = welfare.brandName;
  CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font
                            constrainedToSize:CGSizeMake(_textLimitedWidth, CGFLOAT_MAX)];
  _nameLabel.frame = CGRectMake(_storeImageView.frame.origin.x + STORE_IMG_SIDE_LEN + INNER_MARGIN * 2, _storeImageView.frame.origin.y + INNER_MARGIN, size.width, size.height);
  
  _addressLabel.text = welfare.brandEngName;
  size = [_addressLabel.text sizeWithFont:_addressLabel.font
                        constrainedToSize:CGSizeMake(_textLimitedWidth, CGFLOAT_MAX)];
  _addressLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y + _nameLabel.frame.size.height + INNER_MARGIN, size.width, size.height);
  
  CGFloat imageBottonY = _storeImageView.frame.origin.y + _storeImageView.frame.size.height;
  CGFloat addressBottonY = _addressLabel.frame.origin.y + _addressLabel.frame.size.height;
  
  CGFloat separatorY = (imageBottonY > addressBottonY ? imageBottonY : addressBottonY) + INNER_MARGIN;
  [_boardView arrangeHeight:height lineOrdinate:separatorY];
  
  _branchLabel.text = LocaleStringForKey(NSAlumniWorkedInCompanyTitle, nil);
  size = [_branchLabel.text sizeWithFont:_branchLabel.font constrainedToSize:CGSizeMake(_boardView.frame.size.width - INNER_MARGIN * 2, CGFLOAT_MAX)];
  _branchLabel.frame = CGRectMake((_boardView.frame.size.width - size.width)/2.0f, separatorY + INNER_MARGIN, size.width, size.height);
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if (url && url.length > 0) {
    CATransition *imageFadein = [CATransition animation];
    imageFadein.duration = FADE_IN_DURATION;
    imageFadein.type = kCATransitionFade;
    
    [_storeImageView.layer addAnimation:imageFadein forKey:nil];
    _storeImageView.image = [WXWCommonUtils cutPartImage:image
                                                   width:STORE_IMG_SIDE_LEN
                                                  height:STORE_IMG_SIDE_LEN];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  _storeImageView.image = [WXWCommonUtils cutPartImage:image
                                                 width:STORE_IMG_SIDE_LEN
                                                height:STORE_IMG_SIDE_LEN];
}

@end
