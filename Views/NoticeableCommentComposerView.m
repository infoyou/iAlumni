//
//  NoticeableCommentComposerView.m
//  iAlumni
//
//  Created by Adam on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NoticeableCommentComposerView.h"
#import <QuartzCore/QuartzCore.h>
#import "TextConstants.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "ECInnerShadowTextView.h"
#import "ECGradientButton.h"
#import "UIUtils.h"

#define ACTION_BUTTON_WIDTH         50.0f
#define ACTION_BUTTON_HEIGHT        20.0f

#define PHOTO_BUTTON_SHORT_LENGTH 40.0f
#define PHOTO_BUTTON_LONG_LENGTH  60.0f
#define PHOTO_BUTTON_MARGIN       2.0f

#define TEXT_VIEW_MAX_WIDTH       310.0f
#define TEXT_VIEW_MIN_WIDTH       235.0f

#define TEXT_VIEW_MAX_HEIGHT      70.0f
#define TEXT_VIEW_MIN_HEIGHT      30.0f

#define VIEW_MAX_HEIGHT           105.0f
#define VIEW_MIN_HEIGHT           40.0f

@interface NoticeableCommentComposerView()
@property (nonatomic, retain) UIColor *topSeparatorLine;
@property (nonatomic, copy) NSString *placeholder;
@end

@implementation NoticeableCommentComposerView

@synthesize topSeparatorLine = _topSeparatorLine;
@synthesize placeholder = _placeholder;
@synthesize expanded = expanded;
@synthesize showed = _showed;

#pragma mark - user actions
- (void)arrangeForCollapse {
  
  self.expanded = NO;
  
  [UIView animateWithDuration:0.3f
                   animations:^{    
                                        
                     CGFloat supviewHeight = APP_WINDOW.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - _navigationBarHeight;
                     
                     self.frame = CGRectMake(self.frame.origin.x, 
                                             supviewHeight - VIEW_MIN_HEIGHT,
                                             self.frame.size.width, 
                                             VIEW_MIN_HEIGHT);              
                     
                     _sendButton.hidden = YES;
                     _sendButton.enabled = NO;
                     
                     _closeButton.hidden = YES;
                     _closeButton.enabled = NO;
                     
                     _photoButtonBackgroundView.hidden = YES;
                     _photoButton.enabled = NO;
                     
                     _textView.frame = CGRectMake(_textView.frame.origin.x, 
                                                  MARGIN, 
                                                  TEXT_VIEW_MAX_WIDTH, 
                                                  TEXT_VIEW_MIN_HEIGHT);
                     _textView.placeholder = self.placeholder;
                     _textView.layer.cornerRadius = TEXT_VIEW_MIN_HEIGHT/2.0f;
                     _textView.text = nil;
                     [_textView showAddCommentIcon];
                     [_textView setNeedsDisplay];                     
                     [_textView resignFirstResponder];
                     
                     [self setNeedsDisplay];
                   }
                   completion:^(BOOL finished){
                   
                     [self applySelectedPhoto:nil];
                     
                     // clear the selected photo in comment item holder view controller
                     if (_clickableElementDelegate) {
                       [_clickableElementDelegate clearPhoto];
                     }
                   }];
}

- (void)send:(id)sender {
  
  if (nil == _textView.text || 0 == _textView.text.length || [_textView.text isEqualToString:@" "]) {
    
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCommentEmptyMsg, nil)
                                  msgType:WARNING_TY
                       belowNavigationBar:YES];
    return;
  }

  if (_clickableElementDelegate) {
    [_clickableElementDelegate sendComment:_textView.text];
  }
  
  [self arrangeForCollapse];
}

- (void)close:(id)sender {
  [self arrangeForCollapse];
}

- (void)editPhoto:(id)sender {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate editPhoto];
  }
}

#pragma mark - compose status 
- (void)setSendButton:(BOOL)hasImage {
  
  _sendButton.enabled = NO;
  
  if (_textView.text && _textView.text.length) {
    _sendButton.enabled = YES;
  } else {
    if (hasImage) {
      _sendButton.enabled = YES;
    }
  }
  
  // keep text view first response
  [_textView becomeFirstResponder];
}

- (void)applySelectedPhoto:(UIImage *)photo {
  
  CGFloat textViewRightSide_x = _textView.frame.origin.x + _textView.frame.size.width;
  CGFloat backgroundSideLength = 0.0f;
  
  if (photo) {
    
    backgroundSideLength = PHOTO_BUTTON_LONG_LENGTH + PHOTO_BUTTON_MARGIN * 2;
    _photoButtonBackgroundView.frame = CGRectMake(textViewRightSide_x + (self.frame.size.width - textViewRightSide_x - backgroundSideLength)/2.0f, 
                                                  _textView.frame.origin.y + (_textView.frame.size.height - backgroundSideLength)/2.0f, 
                                                  backgroundSideLength, 
                                                  backgroundSideLength);
    _photoButton.frame = CGRectMake(PHOTO_BUTTON_MARGIN, 
                                    PHOTO_BUTTON_MARGIN,
                                    PHOTO_BUTTON_LONG_LENGTH,
                                    PHOTO_BUTTON_LONG_LENGTH);
    
    [_photoButton setImage:photo forState:UIControlStateNormal];    
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_photoButtonBackgroundView.bounds];
    _photoButtonBackgroundView.layer.shadowPath = shadowPath.CGPath;
    _photoButtonBackgroundView.backgroundColor = [UIColor whiteColor];
  } else {
    
    backgroundSideLength = PHOTO_BUTTON_SHORT_LENGTH + PHOTO_BUTTON_MARGIN * 2;
    
    _photoButtonBackgroundView.frame = CGRectMake(textViewRightSide_x + (self.frame.size.width - textViewRightSide_x - backgroundSideLength)/2.0f, 
                                                  _textView.frame.origin.y + (_textView.frame.size.height - backgroundSideLength)/2.0f,
                                                  backgroundSideLength, 
                                                  backgroundSideLength);
    _photoButton.frame = CGRectMake(PHOTO_BUTTON_MARGIN, 
                                    PHOTO_BUTTON_MARGIN, 
                                    PHOTO_BUTTON_SHORT_LENGTH, 
                                    PHOTO_BUTTON_SHORT_LENGTH);
    
    [_photoButton setImage:[UIImage imageNamed:@"lightAddPhoto.png"] forState:UIControlStateNormal];    
    
    _photoButtonBackgroundView.layer.shadowPath = nil;
    _photoButtonBackgroundView.backgroundColor = TRANSPARENT_COLOR;
  }
}

#pragma mark - lifecycle methods
- (void)adjustShadow {
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
  self.layer.shadowPath = shadowPath.CGPath;
  self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
  self.layer.shadowOpacity = 0.9f;
  self.layer.shadowColor = [UIColor grayColor].CGColor;
}

- (void)addShadow {
  [self adjustShadow];
}

- (void)parserNavigationBarHeight {
  if (_clickableElementDelegate && [_clickableElementDelegate isKindOfClass:[UIViewController class]]) {
    _navigationBarHeight = ((UIViewController *)_clickableElementDelegate).navigationController.navigationBar.frame.size.height;
  }
}

- (id)initWithFrame:(CGRect)frame 
           topColor:(UIColor *)topColor
        bottomColor:(UIColor *)bottomColor
   topSeparatorLine:(UIColor *)topSeparatorLine
           itemType:(WriteItemType)itemType
itemUploaderDelegate:(id<ECItemUploaderDelegate>)itemUploaderDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate 
{
  self = [super initWithFrame:frame topColor:topColor bottomColor:bottomColor];
  if (self) {
    
    _itemType = itemType;
    
    _collapsed_y = frame.origin.y;
    
    self.topSeparatorLine = topSeparatorLine;
    
    _clickableElementDelegate = clickableElementDelegate;
    _itemUploaderDelegate = itemUploaderDelegate;
    
    [self parserNavigationBarHeight];
    
    if (CURRENT_OS_VERSION >= IOS5) {
      [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(keyboardHeightChanged:)
                                                   name:UIKeyboardDidShowNotification
                                                 object:nil];
    }
    
    _textView = [[[ECInnerShadowTextView alloc] initWithFrame:CGRectMake(MARGIN, 
                                                                         MARGIN, 
                                                                         TEXT_VIEW_MAX_WIDTH, 
                                                                         TEXT_VIEW_MIN_HEIGHT)] autorelease];
    _textView.font = FONT(14);
    _textView.delegate = self;
    _textView.editable = YES;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.font = FONT(14);
    _textView.layer.borderColor = LIGHT_GRAY_BTN_BORDER_COLOR.CGColor;
    _textView.layer.borderWidth = 1.0f;
    _textView.layer.cornerRadius = TEXT_VIEW_MIN_HEIGHT/2.0f;

    switch (_itemType) {
      case WRITE_COMMENT_ITEM_TY:
        self.placeholder = LocaleStringForKey(NSWriteCommentTitle, nil);
        break;
        
      case WRITE_ANSWER_ITEM_TY:
        self.placeholder = LocaleStringForKey(NSWriteAnswerTitle, nil);
        break;
        
      default:
        break;
    }
    
    _textView.placeholder = self.placeholder;
    
    [self addSubview:_textView];
    
    [self addShadow];
  }
  return self;
}

- (void)dealloc {
  
  self.placeholder = nil;
  
  if (CURRENT_OS_VERSION >= IOS5 ) {
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardDidShowNotification 
                                                  object:nil];
  }

  [super dealloc];
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0, 0) 
                endPoint:CGPointMake(self.frame.size.width, 0)
                   color:self.topSeparatorLine.CGColor
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];
}

#pragma mark - adjust vertical position for keyboard chagne

- (CGFloat)calcNoKeyboardAreaHeight:(NSNotification *)notification {
  CGSize size = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
  
  return size.height;
}

- (void)keyboardHeightChanged:(NSNotification*)notification {
  
  CGFloat keyboardHeight = [self calcNoKeyboardAreaHeight:notification];

  [UIView animateWithDuration:0.1f
                   animations:^{
                     CGFloat superViewHeight = APP_WINDOW.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - _navigationBarHeight;                                       
                     
                     self.frame = CGRectMake(self.frame.origin.x, 
                                             superViewHeight - self.frame.size.height - keyboardHeight, 
                                             self.frame.size.width, 
                                             self.frame.size.height);                     
                   }];
}

#pragma mark - arrange elements

- (void)showSendAndCloseButtons {
  if (nil == _sendButton) {
    _sendButton = [[[ECGradientButton alloc] initWithFrame:CGRectZero
                                                    target:self 
                                                    action:@selector(send:) 
                                                 colorType:RED_BTN_COLOR_TY
                                                     title:LocaleStringForKey(NSSendTitle, nil)
                                                     image:nil
                                                titleColor:[UIColor whiteColor]
                                          titleShadowColor:[UIColor blackColor]
                                                 titleFont:BOLD_FONT(12)
                                               roundedType:HAS_ROUNDED
                                           imageEdgeInsert:ZERO_EDGE
                                           titleEdgeInsert:ZERO_EDGE] autorelease];
    
    _sendButton.layer.cornerRadius = ACTION_BUTTON_HEIGHT/2.0f;
    
    [self addSubview:_sendButton];
  }
  _sendButton.frame = CGRectMake(self.frame.size.width - MARGIN - ACTION_BUTTON_WIDTH, 
                                 MARGIN,
                                 ACTION_BUTTON_WIDTH, 
                                 ACTION_BUTTON_HEIGHT);
  _sendButton.hidden = NO;
  _sendButton.enabled = YES;
  
  if (nil == _closeButton) {
    _closeButton = [[[ECGradientButton alloc] initWithFrame:CGRectZero
                                                     target:self 
                                                     action:@selector(close:) 
                                                  colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                      title:LocaleStringForKey(NSCloseTitle, nil)
                                                      image:nil
                                                 titleColor:[UIColor whiteColor]
                                           titleShadowColor:[UIColor darkGrayColor]
                                                  titleFont:BOLD_FONT(12)
                                                roundedType:HAS_ROUNDED
                                            imageEdgeInsert:ZERO_EDGE
                                            titleEdgeInsert:ZERO_EDGE] autorelease];
    _closeButton.layer.cornerRadius = ACTION_BUTTON_HEIGHT/2.0f;
    
    [self addSubview:_closeButton];
  }
  _closeButton.frame = CGRectMake(MARGIN, 
                                  MARGIN,
                                  ACTION_BUTTON_WIDTH, 
                                  ACTION_BUTTON_HEIGHT);
  _closeButton.hidden = NO;
  _closeButton.enabled = YES;
}

- (void)hideSendAndCloseButtons {
  [_sendButton removeFromSuperview];
  [_closeButton removeFromSuperview];
}

- (void)showPhotoButton {
  if (nil == _photoButton) {
    _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _photoButton.frame = CGRectMake(PHOTO_BUTTON_MARGIN, 
                                    PHOTO_BUTTON_MARGIN,
                                    PHOTO_BUTTON_SHORT_LENGTH, 
                                    PHOTO_BUTTON_SHORT_LENGTH);
    [_photoButton addTarget:self 
                     action:@selector(editPhoto:) 
           forControlEvents:UIControlEventTouchUpInside];
    _photoButton.backgroundColor = TRANSPARENT_COLOR;
    [_photoButton setImage:[UIImage imageNamed:@"lightAddPhoto.png"] 
                  forState:UIControlStateNormal];
    [_photoButton setNeedsDisplay];
    
    _photoButtonBackgroundView = [[UIView alloc] init];
    
    _photoButtonBackgroundView.backgroundColor = TRANSPARENT_COLOR;
    
    _photoButtonBackgroundView.layer.shadowOpacity = 0.9f;
    _photoButtonBackgroundView.layer.shadowColor = [UIColor grayColor].CGColor;
    _photoButtonBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);

    [self addSubview:_photoButtonBackgroundView];
    
    [_photoButtonBackgroundView addSubview:_photoButton];
  }
  
  CGFloat backgroundSideLength = PHOTO_BUTTON_SHORT_LENGTH + PHOTO_BUTTON_MARGIN * 2;
  CGFloat textViewRightSide_x = _textView.frame.origin.x + _textView.frame.size.width;

  _photoButtonBackgroundView.frame = CGRectMake(textViewRightSide_x + (self.frame.size.width - textViewRightSide_x - backgroundSideLength)/2.0f, 
                                                _textView.frame.origin.y + (_textView.frame.size.height - backgroundSideLength)/2.0f,
                                                backgroundSideLength, 
                                                backgroundSideLength);
  
  _photoButtonBackgroundView.hidden = NO;
  _photoButton.enabled = YES;
}

- (void)hidePhotoButton {
  _photoButtonBackgroundView.hidden = YES;
  _photoButton.enabled = NO;
}

- (void)arrangeForExpand {
  
  self.expanded = YES;
  
  [UIView animateWithDuration:0.3f
                   animations:^{
                     
                     CGFloat gap = VIEW_MAX_HEIGHT - VIEW_MIN_HEIGHT;
                                         
                     self.frame = CGRectMake(self.frame.origin.x, 
                                             self.frame.origin.y - PORTRAIT_KEYBOARD_HEIGHT - gap,
                                             self.frame.size.width, 
                                             VIEW_MAX_HEIGHT);
                     
                     [self showSendAndCloseButtons];
                     
                     [_textView hideAddCommentIcon];
                     _textView.frame = CGRectMake(_textView.frame.origin.x, 
                                                  _sendButton.frame.origin.y + _sendButton.frame.size.height + MARGIN, 
                                                  TEXT_VIEW_MIN_WIDTH, 
                                                  TEXT_VIEW_MAX_HEIGHT);
                     _textView.placeholder = nil;
                     _textView.layer.cornerRadius = 6.0f;
                     [_textView setNeedsDisplay];             
                     
                     [self showPhotoButton];
                     [self setNeedsDisplay];
                   }];
}

- (void)adjustLayout:(BOOL)keyboardShow {
    
  if (keyboardShow) {
    [self arrangeForExpand];
  } else {
    [self arrangeForCollapse];
  }
}

#pragma mark - UITextViewDelegate methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  
  if (!self.expanded) {
    [self adjustLayout:YES];
  }

  return YES;
}

@end
