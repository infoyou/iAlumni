//
//  ChatInputView.m
//  iAlumni
//
//  Created by Adam on 13-10-18.
//
//

#import "ChatInputView.h"
#import "CommonUtils.h"
#import "ECTextView.h"

#define TAKE_PHOTO_BTN_SIDE_LEN 38.0f

#define INPUT_VIEW_HEIGHT       35.0f

#define MAX_INPUT_VIEW_HEIGHT   80.0f

@interface ChatInputView ()

@end

@implementation ChatInputView

#pragma mark - user action
- (void)takePhotoAction:(id)sender {
  if (_chatInputDelegate) {
    [_chatInputDelegate takePhoto];
  }
}

#pragma mark - life cycle methods

- (void)addTakePhotoButton {
  _takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _takePhotoButton.frame = CGRectMake(MARGIN, (self.frame.size.height - TAKE_PHOTO_BTN_SIDE_LEN)/2.0f, TAKE_PHOTO_BTN_SIDE_LEN, TAKE_PHOTO_BTN_SIDE_LEN);
  [_takePhotoButton addTarget:self
                       action:@selector(takePhotoAction:)
             forControlEvents:UIControlEventTouchUpInside];
  [_takePhotoButton setImage:IMAGE_WITH_NAME(@"addPic.png") forState:UIControlStateNormal];
  [self addSubview:_takePhotoButton];
}

- (void)addInputViewWithDelegate:(id<UITextViewDelegate>)textViewDelegate {
  
  CGFloat x = _takePhotoButton.frame.origin.x + _takePhotoButton.frame.size.width + MARGIN * 2;
  
  _inputTextView = [[[ECTextView alloc] initWithFrame:CGRectMake(x,
                                                             (self.frame.size.height - INPUT_VIEW_HEIGHT)/2.0f,
                                                             (self.frame.size.width - x - MARGIN * 2),
                                                             INPUT_VIEW_HEIGHT)] autorelease];
  _inputTextView.font = FONT(16);
  _inputTextView.placeholder = LocaleStringForKey(NSPostInputTitle, nil);
  _inputTextView.textColor = [UIColor whiteColor];
  _inputTextView.backgroundColor = [UIColor blackColor];
  _inputTextView.delegate = textViewDelegate;
  _inputTextView.returnKeyType = UIReturnKeySend;
  _inputTextView.enablesReturnKeyAutomatically = YES;
  [self addSubview:_inputTextView];
  
  _originalTextViewFrame = _inputTextView.frame;
}

- (id)initWithFrame:(CGRect)frame
   textViewDelegate:(id<ChatInputDelegate>)textViewDelegate
      needTakePhoto:(BOOL)needTakePhoto {
  
  self = [super initWithFrame:frame];
  
  if (self) {
    self.backgroundColor = COLOR(88, 88, 88);
    
    _chatInputDelegate = textViewDelegate;
    
    if (needTakePhoto) {
      [self addTakePhotoButton];
    }
    
    [self addInputViewWithDelegate:textViewDelegate];
  }
  return self;
}

- (void)dealloc {
  
  _inputTextView.delegate = nil;
  
  [super dealloc];
}

#pragma mark - reset content
- (void)resetTextContent {
  _inputTextView.text = nil;
}

#pragma mark - arrange layout 
- (void)adjustFrame:(CGRect)frame animated:(BOOL)animated {
  
  if (animated) {
    [UIView animateWithDuration:0.1f
                     animations:^{
                       self.frame = frame;
                     }];
  } else {
    self.frame = frame;
  }
}

- (void)resetToInitialEditingStatus {
  _inputTextView.frame = _originalTextViewFrame;
}

#pragma mark - responder
- (BOOL)isFirstResponder {
  return [_inputTextView isFirstResponder];
}

- (BOOL)resignFirstResponder {
  return [_inputTextView resignFirstResponder];
}

@end
