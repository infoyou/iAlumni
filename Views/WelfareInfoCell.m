//
//  WelfareInfoCell.m
//  iAlumni
//
//  Created by Adam on 13-8-17.
//
//

#import "WelfareInfoCell.h"
#import "WXWLabel.h"
#import "WelfareCellBoardView.h"
#import "Welfare.h"

#define INNER_MARGIN  8.0f

@implementation WelfareInfoCell

#pragma mark - user actions
- (void)openUserList:(UITapGestureRecognizer *)gesture {
  if (_detailVC && _openAction) {
    [_detailVC performSelector:_openAction];
  }
}

#pragma mark - life cycle methods
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
           detailVC:(id)detailVC
         openAction:(SEL)openAction {

  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];

  if (self) {
    
    _detailVC = detailVC;
    _openAction = openAction;
    
    self.backgroundColor = TRANSPARENT_COLOR;
    self.contentView.backgroundColor = TRANSPARENT_COLOR;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self initBoardView];
    
    _titleLabel = [[self initLabel:CGRectZero
                         textColor:ORANGE_COLOR
                       shadowColor:TRANSPARENT_COLOR] autorelease];
    _titleLabel.font = BOLD_FONT(20);
    _titleLabel.text = LocaleStringForKey(NSCouponInfoTitle, nil);
    CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font];
    _titleLabel.frame = CGRectMake(INNER_MARGIN, INNER_MARGIN, size.width, size.height);
    [_boardView addSubview:_titleLabel];
    
    _nameLabel = [[self initLabel:CGRectZero
                        textColor:DARK_TEXT_COLOR
                      shadowColor:TRANSPARENT_COLOR] autorelease];
    _nameLabel.numberOfLines = 0;
    _nameLabel.font = BOLD_FONT(18);
    [_boardView addSubview:_nameLabel];

  }
  
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_boardView);
  
  [super dealloc];
}

- (WelfareCellBoardView *)initBoardView {
  if (nil == _boardView) {
    _boardView = [[WelfareCellBoardView alloc] initWithFrame:CGRectMake(WELFARE_CELL_MARGIN,
                                                                         WELFARE_CELL_MARGIN,
                                                                         self.frame.size.width - WELFARE_CELL_MARGIN * 2,
                                                                         0)];
    _boardView.backgroundColor = [UIColor whiteColor];
    
    [self.contentView addSubview:_boardView];
    
    _textLimitedWidth = _boardView.frame.size.width - INNER_MARGIN * 2;
  }
  
  return _boardView;
}

- (void)drawCellWithWelfare:(Welfare *)welfare
                      title:(NSString *)title
                     height:(CGFloat)height {
  
  // arrange title, name and offer tips
  _titleLabel.text = title;
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font];
  _titleLabel.frame = CGRectMake(INNER_MARGIN, INNER_MARGIN, size.width, size.height);
}

@end
