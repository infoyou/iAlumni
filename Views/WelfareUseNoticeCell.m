//
//  WelfareUseNoticeCell.m
//  iAlumni
//
//  Created by Adam on 13-8-18.
//
//

#import "WelfareUseNoticeCell.h"
#import "WelfareCellBoardView.h"
#import "WXWLabel.h"
#import "Welfare.h"

#define INNER_MARGIN      8.0f

@implementation WelfareUseNoticeCell

#pragma mark - life cycle methods
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
                MOC:(NSManagedObjectContext *)MOC
           detailVC:(id)detailVC
         callAction:(SEL)callAction {
  
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:nil
                          MOC:MOC
                     detailVC:detailVC
                   openAction:callAction];
  
  if (self) {
    _textLimitedWidth = _boardView.frame.size.width - INNER_MARGIN * 2 - MARGIN - MARGIN;
    
    _noticeTextLabel = [[self initLabel:CGRectZero
                              textColor:BASE_INFO_COLOR
                            shadowColor:TRANSPARENT_COLOR] autorelease];
    _noticeTextLabel.numberOfLines = 0;
    _noticeTextLabel.font = BOLD_FONT(13);
    [_boardView addSubview:_noticeTextLabel];
    
    _telLabel = [[self initLabel:CGRectZero
                       textColor:BASE_INFO_COLOR
                     shadowColor:TRANSPARENT_COLOR] autorelease];
    _telLabel.text = LocaleStringForKey(NSContactWelfareSupportMsg, nil);
    _telLabel.font = BOLD_FONT(13);
    CGSize size = [_telLabel.text sizeWithFont:_telLabel.font
                             constrainedToSize:CGSizeMake(_textLimitedWidth, CGFLOAT_MAX)];
    _telLabel.frame = CGRectMake(INNER_MARGIN, 0, size.width, size.height);
    [_boardView addSubview:_telLabel];
    
    _telButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _telButton.backgroundColor = COLOR(233, 100, 73);
    _telButton.titleLabel.font = BOLD_FONT(13);
    _telButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_telButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_telButton addTarget:detailVC action:callAction forControlEvents:UIControlEventTouchUpInside];
    [_boardView addSubview:_telButton];
    
    _useTextDotView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grayDot.png"]] autorelease];
    [_boardView addSubview:_useTextDotView];
    
    _telDotView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grayDot.png"]] autorelease];
    [_boardView addSubview:_telDotView];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - draw cell
- (void)drawCellWithWelfare:(Welfare *)welfare height:(CGFloat)height {
  
  [super drawCellWithWelfare:welfare
                       title:LocaleStringForKey(NSUseNoticeTitle, nil)
                      height:height];
  
  [_boardView arrangeHeight:height];
  
  _useTextDotView.frame = CGRectMake(INNER_MARGIN, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + INNER_MARGIN * 2, MARGIN, MARGIN);
  
  _noticeTextLabel.text = welfare.useInfo;
  CGSize size = [_noticeTextLabel.text sizeWithFont:_noticeTextLabel.font
                                  constrainedToSize:CGSizeMake(_textLimitedWidth, CGFLOAT_MAX)];
  _noticeTextLabel.frame = CGRectMake(INNER_MARGIN + MARGIN + MARGIN, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + INNER_MARGIN, size.width, size.height);
  

  _telDotView.frame = CGRectMake(INNER_MARGIN,
                                 _noticeTextLabel.frame.origin.y + _noticeTextLabel.frame.size.height + INNER_MARGIN * 2, MARGIN, MARGIN);
  _telLabel.frame = CGRectMake(INNER_MARGIN + MARGIN + MARGIN, _noticeTextLabel.frame.origin.y + _noticeTextLabel.frame.size.height + INNER_MARGIN, _telLabel.frame.size.width, _telLabel.frame.size.height);
  
  [_telButton setTitle:welfare.tel forState:UIControlStateNormal];
  size = [welfare.tel sizeWithFont:_telButton.titleLabel.font];
  _telButton.frame = CGRectMake(INNER_MARGIN + MARGIN + MARGIN, _telLabel.frame.origin.y + _telLabel.frame.size.height, size.width + MARGIN * 2, size.height);
 
}

@end
