//
//  StoreBaseInfoCell.m
//  iAlumni
//
//  Created by Adam on 13-8-20.
//
//

#import "StoreBaseInfoCell.h"
#import "WelfareCellBoardView.h"
#import "WXWLabel.h"
#import "Store.h"

#define INNER_MARGIN  8.0f

#define STORE_IMG_SIDE_LEN  56.0f

#define ICON_SIDE_LEN   15.0f

#define BTN_HEIGHT      30.0f

@implementation StoreBaseInfoCell

#pragma mark - user actions
- (void)callSupport:(id)sender {
  if (_detailVC && _callSupportAction) {
    [_detailVC performSelector:_callSupportAction];
  }
}

#pragma mark - life cycle mentods
- (void )initBoardView {
  if (nil == _boardView) {
    _boardView = [[[WelfareCellBoardView alloc] initWithFrame:CGRectMake(WELFARE_CELL_MARGIN,
                                                                         WELFARE_CELL_MARGIN,
                                                                         self.frame.size.width - WELFARE_CELL_MARGIN * 2,
                                                                         0)] autorelease];
    _boardView.backgroundColor = [UIColor whiteColor];
    
    [self.contentView addSubview:_boardView];
  
  }
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
           detailVC:(id)detailVC
  callSupportAction:(SEL)callSupportAction
{
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];
  if (self) {
    
    _detailVC = detailVC;
    _callSupportAction = callSupportAction;
    
    self.backgroundColor = TRANSPARENT_COLOR;
    self.contentView.backgroundColor = TRANSPARENT_COLOR;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self initBoardView];
    
    _storeImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(INNER_MARGIN, INNER_MARGIN, STORE_IMG_SIDE_LEN, STORE_IMG_SIDE_LEN)] autorelease];
    [_boardView addSubview:_storeImageView];

    _nameLabel = [[self initLabel:CGRectMake(_storeImageView.frame.origin.x + STORE_IMG_SIDE_LEN + INNER_MARGIN, INNER_MARGIN, 0, 0)
                        textColor:DARK_TEXT_COLOR
                      shadowColor:TRANSPARENT_COLOR] autorelease];
    _nameLabel.numberOfLines = 0;
    _nameLabel.font = BOLD_FONT(20);
    [_boardView addSubview:_nameLabel];

    _telButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_telButton setImage:[UIImage imageNamed:@"storeTel.png"]
                forState:UIControlStateNormal];
    [_telButton addTarget:self
                   action:@selector(callSupport:)
         forControlEvents:UIControlEventTouchUpInside];
    _telButton.titleLabel.font = BOLD_FONT(13);
    [_boardView addSubview:_telButton];
    
    _addressLabel = [[self initLabel:CGRectZero
                           textColor:BASE_INFO_COLOR
                         shadowColor:TRANSPARENT_COLOR] autorelease];
    _addressLabel.numberOfLines = 0;
    _addressLabel.font = BOLD_FONT(13);
    [_boardView addSubview:_addressLabel];
    
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)drawCellWithStore:(Store *)store height:(CGFloat)height {
  _nameLabel.text = store.storeName;
  
  CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font
                            constrainedToSize:CGSizeMake(_boardView.frame.size.width - INNER_MARGIN * 3 - STORE_IMG_SIDE_LEN, CGFLOAT_MAX)];
  _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x,
                                _nameLabel.frame.origin.y,
                                size.width, size.height);
  
  if (store.tel.length > 0) {
    [_telButton setTitle:STR_FORMAT(@" %@", store.tel)
                forState:UIControlStateNormal];
    size = [STR_FORMAT(@" %@", store.tel) sizeWithFont:_telButton.titleLabel.font];
    
    _telButton.frame = CGRectMake(_nameLabel.frame.origin.x,
                                  _nameLabel.frame.origin.y + _nameLabel.frame.size.height + MARGIN, size.width + MARGIN * 2 + ICON_SIDE_LEN,  BTN_HEIGHT);
  }
  
  CGFloat imagePhotoBottonY = _storeImageView.frame.origin.y + _storeImageView.frame.size.height;
  CGFloat telBottonY = _telButton.frame.origin.y + _telButton.frame.size.height;
  
  CGFloat lineOrdinate = imagePhotoBottonY > telBottonY ? imagePhotoBottonY : telBottonY;
  
  lineOrdinate += INNER_MARGIN;
  
  [_boardView arrangeHeight:height lineOrdinate:lineOrdinate];
  
  _addressLabel.text = STR_FORMAT(@"%@:%@", LocaleStringForKey(NSAddressTitle, nil), store.address) ;
  size = [_addressLabel.text sizeWithFont:_addressLabel.font
                        constrainedToSize:CGSizeMake(_boardView.frame.size.width - INNER_MARGIN * 2, CGFLOAT_MAX)];
  _addressLabel.frame = CGRectMake(INNER_MARGIN, lineOrdinate + INNER_MARGIN, size.width, size.height);
  
  if (store.imageUrl.length > 0) {
    [self fetchImage:[NSMutableArray arrayWithObject:store.imageUrl]
            forceNew:NO];
  } else {
    _storeImageView.image = nil;
  }
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
