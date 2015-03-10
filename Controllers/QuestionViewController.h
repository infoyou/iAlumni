//
//  QuestionViewController.h
//  iAlumni
//
//  Created by Adam on 13-2-11.
//
//

#import "BaseListViewController.h"

enum {
    NAME_FIELD = 0,
    CLASS_FIELD,
    MOBILE_FIELD,
    EMAIL_FIELD,
};

@interface QuestionViewController : BaseListViewController <UITextFieldDelegate, UITextViewDelegate>
{
    // base data size
    NSInteger baseDataSize;
    
    float prewMoveY;
    int prewTag;
    
    CGFloat scrollStartY;
    CGFloat scrollOffSet;
    BOOL directDown;
    BOOL isScrolling;

    BOOL keyboardIsVisible;
    
    CGFloat _animatedDistance;
//    CGFloat heightFraction;
    CGPoint originalLocation;
    
    UITextView *currentTextView;
    UITextField *currentTextField;
}

@property (nonatomic, assign) NSInteger baseDataSize;
@property (nonatomic, retain) UITextView *currentTextView;
@property (nonatomic, retain) UITextField *currentTextField;

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

- (void)clearQuestions;
- (void)upAnimate;
- (void)downAnimate;

#pragma mark - draw ui elements
- (void)drawUIElements:(UIView *)drawView dataArray:(NSMutableArray *)dataArray index:(int)index labelFrame:(CGRect)labelFrame inputFrame:(CGRect)inputFrame isBaseData:(BOOL)isBaseData;

#pragma mark - Input Height
- (int)getInputHeight:(int)type;

- (void)initBaseDataArray;
- (void)closeKeyboard;

#pragma mark - check input Msg
- (BOOL)checkInputMsg;

@end
