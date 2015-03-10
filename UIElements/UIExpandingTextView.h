#import <UIKit/UIKit.h>
#import "UIExpandingTextViewInternal.h"

@class UIExpandingTextView;

@protocol UIExpandingTextViewDelegate

@optional
- (BOOL)expandingTextViewShouldBeginEditing:(UIExpandingTextView *)expandingTextView;
- (BOOL)expandingTextViewShouldEndEditing:(UIExpandingTextView *)expandingTextView;

- (void)expandingTextViewDidBeginEditing:(UIExpandingTextView *)expandingTextView;
- (void)expandingTextViewDidEndEditing:(UIExpandingTextView *)expandingTextView;

- (BOOL)expandingTextView:(UIExpandingTextView *)expandingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView;

- (void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height;
- (void)expandingTextView:(UIExpandingTextView *)expandingTextView didChangeHeight:(float)height;

- (void)expandingTextViewDidChangeSelection:(UIExpandingTextView *)expandingTextView;
- (BOOL)expandingTextViewShouldReturn:(UIExpandingTextView *)expandingTextView;
@end

@interface UIExpandingTextView : UIView <UITextViewDelegate> 
{
    UIExpandingTextViewInternal *internalTextView;
    UIImageView *textViewBackgroundImage;
    int minimumHeight;
	int maximumHeight;
    int maximumNumberOfLines;
	int minimumNumberOfLines;
	BOOL animateHeightChange;
	NSObject <UIExpandingTextViewDelegate> *delegate;
	NSString *text;
	UIFont *font;
	UIColor *textColor;
	UITextAlignment textAlignment; 
	NSRange selectedRange;
	BOOL editable;
	UIDataDetectorTypes dataDetectorTypes;
	UIReturnKeyType returnKeyType;
    BOOL forceSizeUpdate;
    NSString *placeholder;
    UILabel *placeholderLabel;
}

@property (nonatomic, retain) UITextView *internalTextView;

@property int maximumNumberOfLines;
@property int minimumNumberOfLines;
@property BOOL animateHeightChange;

@property (assign) NSObject<UIExpandingTextViewDelegate> *delegate;
@property (nonatomic,assign) NSString *text;
@property (nonatomic,assign) UIFont *font;
@property (nonatomic,assign) UIColor *textColor;
@property (nonatomic) UITextAlignment textAlignment;
@property (nonatomic) NSRange selectedRange;
@property (nonatomic,getter=isEditable) BOOL editable;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_0);
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic, retain) UIImageView *textViewBackgroundImage;
@property (nonatomic,copy) NSString *placeholder;

- (BOOL)hasText;
- (void)scrollRangeToVisible:(NSRange)range;
- (void)clearText;

@end
