//
//  ChatInputView.h
//  iAlumni
//
//  Created by Adam on 13-10-18.
//
//

#import <UIKit/UIKit.h>

@class ECTextView;

@protocol ChatInputDelegate <UITextViewDelegate>

- (void)takePhoto;

@end

@interface ChatInputView : UIView {
  @private
  
  UIButton *_takePhotoButton;
  
  ECTextView *_inputTextView;

  CGRect _originalTextViewFrame;
  
  id<ChatInputDelegate> _chatInputDelegate;
}

- (id)initWithFrame:(CGRect)frame
   textViewDelegate:(id<ChatInputDelegate>)textViewDelegate
      needTakePhoto:(BOOL)needTakePhoto;

#pragma mark - reset content
- (void)resetTextContent;

#pragma mark - arrange layout
- (void)adjustFrame:(CGRect)frame animated:(BOOL)animated;
- (void)resetToInitialEditingStatus;

#pragma mark - responder
- (BOOL)isFirstResponder;
- (BOOL)resignFirstResponder;
@end
