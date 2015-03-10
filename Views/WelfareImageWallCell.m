//
//  WelfareImageWallCell.m
//  iAlumni
//
//  Created by Adam on 13-8-18.
//
//

#import "WelfareImageWallCell.h"
#import "WelfareItemWallView.h"
#import "Welfare.h"
#import "WXWLabel.h"
#import "Sku.h"

#define WALL_HEIGHT   175.0f

#define PRICE_VIEW_HEIGHT 60.0f

#define BTN_WIDTH         100.0f
#define BTN_HEIGHT        30.0f

@implementation WelfareImageWallCell

#pragma mark - life cycle methods
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
    welfareDetailVC:(id)welfareDetailVC
     favoriteAction:(SEL)favoriteAction
        shareAction:(SEL)shareAction
          buyAction:(SEL)buyAction
    saveImageAction:(SEL)saveImageAction
{
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier];
  if (self) {
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = [UIColor whiteColor];
    
    _itemWallView = [[[WelfareItemWallView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, WALL_HEIGHT)
                                         imageDisplayerDelegate:imageDisplayerDelegate
                                                            MOC:MOC
                                                       welfareDetailVC:welfareDetailVC
                                                 favoriteAction:favoriteAction
                                                    shareAction:shareAction
                                                saveImageAction:saveImageAction] autorelease];
    [self.contentView addSubview:_itemWallView];
    
    _priceInfoView = [[[UIView alloc] initWithFrame:CGRectMake(0, WALL_HEIGHT, self.frame.size.width, PRICE_VIEW_HEIGHT)] autorelease];
    _priceInfoView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_priceInfoView];
    
    
    _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _actionButton.backgroundColor = ORANGE_COLOR;
    _actionButton.titleLabel.font = BOLD_FONT(16);
    _actionButton.frame = CGRectMake(self.frame.size.width - WELFARE_CELL_MARGIN - BTN_WIDTH, (PRICE_VIEW_HEIGHT - BTN_HEIGHT)/2.0f, BTN_WIDTH, BTN_HEIGHT);
    [_actionButton addTarget:welfareDetailVC
                      action:buyAction
            forControlEvents:UIControlEventTouchUpInside];
    [_priceInfoView addSubview:_actionButton];
    
    _moneyFlagLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                            textColor:NAVIGATION_BAR_COLOR
                                          shadowColor:TRANSPARENT_COLOR
                                                 font:BOLD_FONT(18)] autorelease];
    _moneyFlagLabel.text = @"￥";
    CGSize size = [_moneyFlagLabel.text sizeWithFont:_moneyFlagLabel.font];
    _moneyFlagLabel.frame = CGRectMake(MARGIN, WELFARE_CELL_MARGIN + MARGIN, size.width, size.height);
    [_priceInfoView addSubview:_moneyFlagLabel];
    
    _numberLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                          textColor:NAVIGATION_BAR_COLOR
                                        shadowColor:TRANSPARENT_COLOR
                                               font:BOLD_FONT(30)] autorelease];
    [_priceInfoView addSubview:_numberLabel];
    
    _unitLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                        textColor:NAVIGATION_BAR_COLOR
                                      shadowColor:TRANSPARENT_COLOR
                                             font:BOLD_FONT(15)] autorelease];
    [_priceInfoView addSubview:_unitLabel];
    
    _originalPriceLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                 textColor:BASE_INFO_COLOR
                                               shadowColor:TRANSPARENT_COLOR
                                                      font:BOLD_FONT(15)] autorelease];
    [_priceInfoView addSubview:_originalPriceLabel];
    
    _dashIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"welfareLine.png"]] autorelease];
    [_originalPriceLabel addSubview:_dashIcon];
    
  }
  return self;
}

- (void)drawCellWithWelfare:(Welfare *)welfare {
  [_itemWallView updateImageList:welfare.imageList.allObjects
                 favoritedStatus:welfare.favorited.boolValue];
  
  // set price info
  NSArray *skus = welfare.skuList.allObjects;
  Sku *sku = nil;
  if (skus.count > 0) {
    sku = [skus objectAtIndex:0];
    
    switch (welfare.pTypeId.intValue) {
      case COUPON_WF_TY:
      case EXHIBITION_WF_TY:
        _moneyFlagLabel.hidden = YES;
        _numberLabel.text = STR_FORMAT(@"%@", sku.discountRate);
        break;
        
      case BUY_WF_TY:
        _moneyFlagLabel.hidden = NO;
        _numberLabel.text = STR_FORMAT(@"%@", sku.salesPrice);
        break;
        
      default:
        break;
    }
    CGSize size = [_numberLabel.text sizeWithFont:_numberLabel.font];
    _numberLabel.frame = CGRectMake(_moneyFlagLabel.frame.origin.x + _moneyFlagLabel.frame.size.width,
                                    WELFARE_CELL_MARGIN, size.width, size.height);
  }
  
  switch (welfare.pTypeId.intValue) {
    case COUPON_WF_TY:
    case EXHIBITION_WF_TY:
//      [_actionButton setTitle:LocaleStringForKey(NSDownloadNowTitle, nil)
//                     forState:UIControlStateNormal];
      _actionButton.hidden = YES;
      _actionButton.enabled = NO;
      _unitLabel.text = LocaleStringForKey(NSDiscountsTitle, nil);
      break;
      
    case BUY_WF_TY:
      _actionButton.hidden = NO;
      _actionButton.enabled = YES;
      [_actionButton setTitle:welfare.buyTypeDesc forState:UIControlStateNormal];
      _unitLabel.text = LocaleStringForKey(NSYuanTitle, nil);
      break;
      
    default:
      break;
  }
  
  CGSize size = [_unitLabel.text sizeWithFont:_unitLabel.font];
  _unitLabel.frame = CGRectMake(_numberLabel.frame.origin.x + _numberLabel.frame.size.width,
                                _numberLabel.frame.origin.y + 12, size.width, size.height);
  
  if (sku) {
    _originalPriceLabel.text = STR_FORMAT(LocaleStringForKey(NSFormatedPrpTitle, nil), sku.price);
    size = [_originalPriceLabel.text sizeWithFont:_originalPriceLabel.font];
    _originalPriceLabel.frame = CGRectMake(_unitLabel.frame.origin.x + _unitLabel.frame.size.width + MARGIN * 2,
                                           _unitLabel.frame.origin.y, size.width, size.height);
    _dashIcon.frame = CGRectMake(0, 0, size.width, 12);
  }
  
}

- (void)updateFavoritedStatus:(BOOL)status {
  [_itemWallView updateFavoritedStatus:status];
}

- (void)startPlay {
  [_itemWallView play];
}

- (void)stopPlay {
  [_itemWallView stopPlay];
}

- (void)dealloc {
  
  
  [super dealloc];
}
@end
