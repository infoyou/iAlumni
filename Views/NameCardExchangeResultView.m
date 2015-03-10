//
//  NameCardExchangeResultView.m
//  iAlumni
//
//  Created by Adam on 12-12-4.
//
//

#import "NameCardExchangeResultView.h"
#import "WXWLabel.h"
#import "UIImageButton.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIUtils.h"

#define TOP_VIEW_HEIGHT   44.0f

#define DONE_BTN_WIDTH    70.0f
#define DONE_BTN_HEIGHT   30.0f

#define CHECK_BTN_WIDTH   150.0f
#define CHECK_BTN_HEIGHT  30.0f

@implementation NameCardExchangeResultView

#pragma mark - user action
- (void)close:(id)sender {
  if (_holder && _closeAction) {
    [_holder performSelector:_closeAction];
  }
}

- (void)review:(id)sender {
  if (_holder && _reviewAction) {
    [_holder performSelector:_reviewAction];
  }
}

#pragma mark - lifecycle methods

- (void)initViews {
  _topView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                       self.frame.size.width,
                                                       TOP_VIEW_HEIGHT)] autorelease];
  _topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  [self addSubview:_topView];

  UIImageButton *doneButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake(self.frame.size.width - MARGIN * 2 - DONE_BTN_WIDTH, (TOP_VIEW_HEIGHT - DONE_BTN_HEIGHT)/2.0f, DONE_BTN_WIDTH, DONE_BTN_HEIGHT)
                                                                        target:self
                                                                        action:@selector(close:)
                                                                         title:LocaleStringForKey(NSIKnowTitle, nil)
                                                                         image:nil
                                                                   backImgName:@"club_button.png"
                                                                selBackImgName:@"club_button_selected.png"
                                                                     titleFont:BOLD_FONT(13)
                                                                    titleColor:DARK_TEXT_COLOR
                                                              titleShadowColor:TEXT_SHADOW_COLOR
                                                                   roundedType:HAS_ROUNDED
                                                               imageEdgeInsert:ZERO_EDGE
                                                               titleEdgeInsert:ZERO_EDGE] autorelease];
  [_topView addSubview:doneButton];
  
  WXWLabel *msgLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                            textColor:DARK_TEXT_COLOR
                                          shadowColor:TEXT_SHADOW_COLOR] autorelease];
  msgLabel.font = BOLD_FONT(15);
  msgLabel.numberOfLines = 0;
  msgLabel.text = LocaleStringForKey(NSNameCardExchangeDoneMsg, nil);
  CGSize size = [msgLabel.text sizeWithFont:msgLabel.font
                          constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
  msgLabel.frame = CGRectMake((self.frame.size.width - size.width)/2.0f,
                              TOP_VIEW_HEIGHT + MARGIN * 6,
                              size.width,
                              size.height);
  [self addSubview:msgLabel];
  
  UIImageButton *checkButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake((self.frame.size.width - CHECK_BTN_WIDTH)/2.0f, msgLabel.frame.origin.y + msgLabel.frame.size.height + MARGIN * 4, CHECK_BTN_WIDTH, CHECK_BTN_HEIGHT)
                                                                         target:self
                                                                         action:@selector(review:)
                                                                          title:LocaleStringForKey(NSCheckKnownAlumniTitle, nil)
                                                                          image:nil
                                                                    backImgName:@"button_orange.png"
                                                                 selBackImgName:@"button_orange_selected.png"
                                                                      titleFont:BOLD_FONT(13)
                                                                     titleColor:[UIColor whiteColor]
                                                               titleShadowColor:[UIColor darkGrayColor]
                                                                    roundedType:HAS_ROUNDED
                                                                imageEdgeInsert:ZERO_EDGE
                                                                titleEdgeInsert:ZERO_EDGE] autorelease];
  [self addSubview:checkButton];

}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
             holder:(id)holder
        closeAction:(SEL)closeAction
       reviewAction:(SEL)reviewAction {
  
  self = [super initWithFrame:frame];
  if (self) {

    _holder = holder;
    _closeAction = closeAction;
    _reviewAction = reviewAction;
    
    self.backgroundColor = CELL_COLOR;
    
    [self initViews];
  }
  return self;
}

#pragma mark - arrange views
- (void)drawRect:(CGRect)rect {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0, TOP_VIEW_HEIGHT - 0.5f)
                endPoint:CGPointMake(self.frame.size.width, TOP_VIEW_HEIGHT - 0.5f)
                   color:SEPARATOR_LINE_COLOR.CGColor
            shadowOffset:CGSizeMake(0.0f, 0.5f)
             shadowColor:TEXT_SHADOW_COLOR];
  
}

@end
