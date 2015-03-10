#import <UIKit/UIKit.h>
#import "UIExpandingTextView.h"

@protocol UIInputToolbarDelegate <NSObject>
@optional
- (void)inputButtonPressed:(NSString *)inputText;
- (void)notifyTableHeight;
@end

@interface UIInputToolbar : UIToolbar <UIExpandingTextViewDelegate> 
{
    UIExpandingTextView *textView;
    UIBarButtonItem *inputButton;
    NSObject <UIInputToolbarDelegate> *delegate;
}

- (void)drawRect:(CGRect)rect;

@property (nonatomic, retain) UIExpandingTextView *textView;
@property (nonatomic, retain) UIBarButtonItem *inputButton;
@property (assign) NSObject<UIInputToolbarDelegate> *delegate;

@end
