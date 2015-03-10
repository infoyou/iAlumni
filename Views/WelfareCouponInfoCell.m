//
//  WelfareCouponInfoCell.m
//  iAlumni
//
//  Created by Adam on 13-8-14.
//
//

#import "WelfareCouponInfoCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Welfare.h"
#import "WXWLabel.h"
#import "WelfareCellBoardView.h"
#import "AlbumPhoto.h"
#import "WXWCommonUtils.h"
#import "Alumni.h"

#define FLAG_ICON_WIDTH   28.0f
#define FLAG_ICON_HEIGHT  34.0f

#define INNER_MARGIN      8.0f

#define USER_PHOTO_SIDE_LEN 26.0f

#define ICON_SIDE_LEN     16.0f

@interface WelfareCouponInfoCell ()
@property (nonatomic, retain) NSMutableDictionary *photoDic;
@end

@implementation WelfareCouponInfoCell


#pragma mark - life cycle methods
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
           detailVC:(id)detailVC
openUserListAction:(SEL)openUserListAction {

  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC
                     detailVC:detailVC
                   openAction:openUserListAction];
  
  if (self) {
        
    _descLabel = [[self initLabel:CGRectZero
                        textColor:BASE_INFO_COLOR
                      shadowColor:TRANSPARENT_COLOR] autorelease];
    _descLabel.numberOfLines = 0;
    _descLabel.font = BOLD_FONT(13);
    [_boardView addSubview:_descLabel];
    
    _downloadLabel = [[self initLabel:CGRectZero
                            textColor:BASE_INFO_COLOR
                          shadowColor:TRANSPARENT_COLOR] autorelease];
    _downloadLabel.font = BOLD_FONT(13);
    [_boardView addSubview:_downloadLabel];
    
    _dateLabel = [[self initLabel:CGRectZero
                        textColor:BASE_INFO_COLOR
                      shadowColor:TRANSPARENT_COLOR] autorelease];
    _dateLabel.font = BOLD_FONT(13);
    [_boardView addSubview:_dateLabel];
    
    _flagIcon = [[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - WELFARE_CELL_MARGIN - MARGIN - FLAG_ICON_WIDTH, _boardView.frame.origin.y - 3.0f, FLAG_ICON_WIDTH, FLAG_ICON_HEIGHT)] autorelease];
    [self.contentView addSubview:_flagIcon];
    
    _alumniIcon = [[[UIImageView alloc] initWithImage:nil] autorelease];
    _alumniIcon.image = [UIImage imageNamed:@"couponDownloadUser.png"];
    [_boardView addSubview:_alumniIcon];
    
    _arrowIcon = [[[UIImageView alloc] initWithImage:nil] autorelease];
    _arrowIcon.image = [UIImage imageNamed:@"solidRightArrow.png"];
    _arrowIcon.hidden = YES; // temp hide
    [_boardView addSubview:_arrowIcon];
    
    _timeIcon = [[[UIImageView alloc] initWithImage:nil] autorelease];
    _timeIcon.image = [UIImage imageNamed:@"couponTimeline.png"];
    [_boardView addSubview:_timeIcon];
    
    _userListView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    _userListView.backgroundColor = TRANSPARENT_COLOR;
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUserList:)];
    [_userListView addGestureRecognizer:_tapGesture];
    [_boardView addSubview:_userListView];
  }
  
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_tapGesture);
  
  [super dealloc];
}

#pragma mark - draw cell
- (void)fetchDownloadUserList:(NSSet *)images {
  NSArray *alumnus = [images allObjects];
  if (alumnus.count > 0) {
    self.photoDic = [NSMutableDictionary dictionary];
  }
  
  NSInteger maxCount = 5;
  NSInteger i = 0;
  NSMutableArray *urls = [NSMutableArray array];
  for (Alumni *alumni in alumnus) {
    if (i++ < maxCount) {
      if (alumni.imageUrl.length > 0) {
        [urls addObject:alumni.imageUrl];
        
        UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(_arrowIcon.frame.origin.x - (MARGIN + USER_PHOTO_SIDE_LEN) * i, 0, USER_PHOTO_SIDE_LEN, USER_PHOTO_SIDE_LEN)] autorelease];
        [_userListView addSubview:imageView];
        [self.photoDic setObject:imageView forKey:alumni.imageUrl];
      }
      
    } else {
      break;
    }
  }
  
  [self fetchImage:urls forceNew:NO];
}

- (void)drawCellWithWelfare:(Welfare *)welfare height:(CGFloat)height {
  
  // fetch user list photo
  [self fetchDownloadUserList:welfare.salesUserList];
  
  // arrange flag icon
  switch (welfare.pTypeId.intValue) {
    case COUPON_WF_TY:
      _flagIcon.image = [UIImage imageNamed:@"welfareJuan.png"];
      _downloadLabel.text = [NSString stringWithFormat:@"%@%@", welfare.downloadPersonCount,LocaleStringForKey(NSDownloadUserInfoMsg, nil)];
      _dateLabel.text = STR_FORMAT(LocaleStringForKey(NSEndTimeTipsMsg, nil), welfare.endTime);
      break;
      
    case BUY_WF_TY:
      _flagIcon.image = [UIImage imageNamed:@"welfareTuan.png"];
      _downloadLabel.text = [NSString stringWithFormat:@"%@%@", welfare.salesPersonCount,LocaleStringForKey(NSBoughtUserInfoMsg, nil)];
      _dateLabel.text = STR_FORMAT(LocaleStringForKey(NSOverCountTitle, nil), welfare.overCount);
      break;
      
    default:
      break;
  }
  
  // arrange title, name and offer tips
  [super drawCellWithWelfare:welfare title:LocaleStringForKey(NSCouponInfoTitle, nil) height:height];
  
  _nameLabel.text = welfare.itemName;
  CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font
                            constrainedToSize:CGSizeMake(_textLimitedWidth, CGFLOAT_MAX)];
  _nameLabel.frame = CGRectMake(INNER_MARGIN,
                                _titleLabel.frame.origin.y + _titleLabel.frame.size.height + INNER_MARGIN,
                                size.width, size.height);
  
  // adjust separator ordinate
  CGFloat separatorY = _nameLabel.frame.origin.y + _nameLabel.frame.size.height + INNER_MARGIN;
  
  [_boardView arrangeHeight:height lineOrdinate:separatorY];

  CGFloat photoY = 0;
  if (welfare.offersTips.length > 0) {
    _descLabel.text = welfare.offersTips;
    size = [_descLabel.text sizeWithFont:_descLabel.font
                       constrainedToSize:CGSizeMake(_textLimitedWidth, CGFLOAT_MAX)];
    _descLabel.frame = CGRectMake(INNER_MARGIN, separatorY + INNER_MARGIN, size.width, size.height);
    
    photoY = _descLabel.frame.origin.y + _descLabel.frame.size.height + INNER_MARGIN;
  } else {
    photoY = separatorY + INNER_MARGIN;
  }
  
  // arrange user list
  _userListView.frame = CGRectMake(0, photoY, _boardView.frame.size.width, USER_PHOTO_SIDE_LEN);
  _alumniIcon.frame = CGRectMake(INNER_MARGIN, photoY + (USER_PHOTO_SIDE_LEN -  ICON_SIDE_LEN)/2.0f, ICON_SIDE_LEN, ICON_SIDE_LEN);
  
  _arrowIcon.frame = CGRectMake(_boardView.frame.size.width - INNER_MARGIN - MARGIN - ICON_SIDE_LEN, _alumniIcon.frame.origin.y, ICON_SIDE_LEN, ICON_SIDE_LEN);
  
  size = [_downloadLabel.text sizeWithFont:_downloadLabel.font];
  _downloadLabel.frame = CGRectMake(_alumniIcon.frame.origin.x + _alumniIcon.frame.size.width + MARGIN,
                                    photoY + (USER_PHOTO_SIDE_LEN - size.height)/2.0f, size.width, size.height);
  
  // arrange time
  _timeIcon.frame = CGRectMake(INNER_MARGIN, photoY + USER_PHOTO_SIDE_LEN + INNER_MARGIN, ICON_SIDE_LEN, ICON_SIDE_LEN);

  size = [_dateLabel.text sizeWithFont:_dateLabel.font];
  _dateLabel.frame = CGRectMake(_timeIcon.frame.origin.x + ICON_SIDE_LEN + MARGIN, _timeIcon.frame.origin.y + (_timeIcon.frame.size.height - size.height)/2.0f, size.width, size.height);
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if (url && url.length > 0) {
    CATransition *imageFadein = [CATransition animation];
    imageFadein.duration = FADE_IN_DURATION;
    imageFadein.type = kCATransitionFade;
    
    UIImageView *imageView = (UIImageView *)[self.photoDic objectForKey:url];
    [imageView.layer addAnimation:imageFadein forKey:nil];
    imageView.image = [WXWCommonUtils cutPartImage:image
                                             width:USER_PHOTO_SIDE_LEN
                                            height:USER_PHOTO_SIDE_LEN];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  UIImageView *imageView = (UIImageView *)[self.photoDic objectForKey:url];
  imageView.image = [WXWCommonUtils cutPartImage:image
                                           width:USER_PHOTO_SIDE_LEN
                                          height:USER_PHOTO_SIDE_LEN];
}



@end
