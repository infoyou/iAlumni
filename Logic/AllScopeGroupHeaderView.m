//
//  AllScopeGroupHeaderView.m
//  iAlumni
//
//  Created by Adam on 12-10-8.
//
//

#import "AllScopeGroupHeaderView.h"
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIImageButton.h"
#import "UIUtils.h"

#define TEXT_BACKGROUND_WIDTH   300.0f
#define TEXT_BACKGROUND_HEIGHT  60.0f

#define TRENDS_TITLE_HEIGHT     40.0f

#define POST_BTN_WIDTH          80.0f
#define POST_BTN_HEIGHT         30.0f

@implementation AllScopeGroupHeaderView

#pragma mark - user actions
- (void)doPost:(id)sender {
  if (_delegate) {
    [_delegate doPost];
  }
}

#pragma mark - lifecycle methods

- (void)setTitleWithGroupType {
  switch (_groupType) {
    case ALL_ALUMNI_GP_TY:
      _titleLabel.text = LocaleStringForKey(NSForAllAlumnusTitle, nil);
      break;
      
    default:
      break;
  }
}

- (id)initWithFrame:(CGRect)frame
          groupType:(GroupType)groupType
           delegate:(id<ClubManagementDelegate>)delegate {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = CELL_COLOR;
    
    _delegate = delegate;
    
    _groupType = groupType;
    
    _textBackgroundView = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2, TEXT_BACKGROUND_WIDTH, TEXT_BACKGROUND_HEIGHT)] autorelease];
    _textBackgroundView.backgroundColor = TRANSPARENT_COLOR;
    _textBackgroundView.image = [UIImage imageNamed:@"club_detail_bg.png"];
    [self addSubview:_textBackgroundView];
    
    _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                        textColor:[UIColor blackColor]
                                      shadowColor:TRANSPARENT_COLOR] autorelease];
    _titleLabel.font = BOLD_FONT(14);
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = UITextAlignmentCenter;
    [_textBackgroundView addSubview:_titleLabel];
    
    [self setTitleWithGroupType];
    
    CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                               constrainedToSize:CGSizeMake(TEXT_BACKGROUND_WIDTH - MARGIN * 4, TEXT_BACKGROUND_HEIGHT - MARGIN * 4)
                                   lineBreakMode:NSLineBreakByWordWrapping];
    _titleLabel.frame = CGRectMake((TEXT_BACKGROUND_WIDTH - size.width)/2.0f,
                                   (TEXT_BACKGROUND_HEIGHT - size.height)/2.0f,
                                   size.width, size.height);
    
    UIView *trendsTitleBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0,
                                                                                  _textBackgroundView.frame.origin.y + TEXT_BACKGROUND_HEIGHT + MARGIN + 1.0f,
                                                                                  self.frame.size.width
                                                                                  , TRENDS_TITLE_HEIGHT)] autorelease];
    trendsTitleBackgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:trendsTitleBackgroundView];
    
    WXWLabel *trendsTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                      textColor:BASE_INFO_COLOR
                                                    shadowColor:TRANSPARENT_COLOR] autorelease];
    trendsTitleLabel.font = FONT(14);
    trendsTitleLabel.text = LocaleStringForKey(NSNewClubPostTitle, nil);
    size = [trendsTitleLabel.text sizeWithFont:trendsTitleLabel.font
                             constrainedToSize:CGSizeMake(200, TRENDS_TITLE_HEIGHT)
                                 lineBreakMode:NSLineBreakByWordWrapping];
    trendsTitleLabel.frame = CGRectMake(MARGIN * 2, (trendsTitleBackgroundView.frame.size.height - size.height)/2.0f, size.width, size.height);
    [trendsTitleBackgroundView addSubview:trendsTitleLabel];
    
    
    UIImageButton *postButton = [[[UIImageButton alloc]
                               initImageButtonWithFrame:CGRectMake(self.frame.size.width - POST_BTN_WIDTH - MARGIN * 2,
                                                                   (TRENDS_TITLE_HEIGHT - POST_BTN_HEIGHT)/2.0f,
                                                                   POST_BTN_WIDTH,
                                                                   POST_BTN_HEIGHT)
                               target:self
                               action:@selector(doPost:)
                               title:[NSString stringWithFormat: @" %@", LocaleStringForKey(NSPostTitle, nil)]
                               image:[UIImage imageNamed:@"club_post_white.png"]
                               backImgName:@"button_orange.png"
                               selBackImgName:@"button_orange_selected.png"
                               titleFont:BOLD_FONT(14)
                               titleColor:[UIColor whiteColor]
                               titleShadowColor:TRANSPARENT_COLOR
                               roundedType:HAS_ROUNDED
                               imageEdgeInsert:ZERO_EDGE
                               titleEdgeInsert:ZERO_EDGE] autorelease];
    [trendsTitleBackgroundView addSubview:postButton];
  }
  return self;
}

- (void)dealloc {
  
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGFloat y = _textBackgroundView.frame.origin.y + TEXT_BACKGROUND_HEIGHT + MARGIN;
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0, y + 0.5f)
                endPoint:CGPointMake(self.bounds.size.width, y + 0.5f)
                   color:COLOR(230, 230, 230).CGColor
            shadowOffset:CGSizeMake(0, 0)
             shadowColor:TRANSPARENT_COLOR];

  y += TRENDS_TITLE_HEIGHT;
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0, y + 0.5f)
                endPoint:CGPointMake(self.bounds.size.width, y + 0.5f)
                   color:COLOR(230, 230, 230).CGColor
            shadowOffset:CGSizeMake(0, 0)
             shadowColor:TRANSPARENT_COLOR];

}


@end
