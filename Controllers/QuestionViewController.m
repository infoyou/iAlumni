//
//  QuestionViewController.m
//  iAlumni
//
//  Created by Adam on 13-2-11.
//
//

#import "QuestionViewController.h"
#import "BaseTextField.h"
#import "AppManager.h"
#import "WXWLabel.h"
#import "UIUtils.h"
#import "CommonUtils.h"

@interface QuestionViewController ()
@end

@implementation QuestionViewController
@synthesize baseDataSize;
@synthesize currentTextField;
@synthesize currentTextView;

#pragma mark - life cycle
- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:NO
        needRefreshFooterView:NO
                   needGoHome:NO];
    
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    self.currentTextField = nil;
    self.currentTextView = nil;
    
    [self clearQuestions];
    
    [super dealloc];
}

#pragma mark - init base data
- (void)initBaseDataArray
{
    [AppManager instance].baseDataArray = [NSMutableArray array];
    
    // Name:
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    [nameArray insertObject:@"1" atIndex:DATA_ID];
    [nameArray insertObject:[NSString stringWithFormat:@"%d", DEFINE_TYPE_TEXT] atIndex:DATA_TYPE];
    [nameArray insertObject:LocaleStringForKey(NSNameTitle,nil) atIndex:DATA_NAME];
    [nameArray insertObject:[AppManager instance].userName atIndex:DATA_VALUE];
    [[AppManager instance].baseDataArray insertObject:nameArray atIndex:0];
    [nameArray release];
    
    // Class:
    NSMutableArray *classArray = [[NSMutableArray alloc] init];
    [classArray insertObject:@"0" atIndex:DATA_ID];
    [classArray insertObject:[NSString stringWithFormat:@"%d", DEFINE_TYPE_TEXT] atIndex:DATA_TYPE];
    [classArray insertObject:LocaleStringForKey(NSClassTitle,nil) atIndex:DATA_NAME];
    [classArray insertObject:[AppManager instance].classGroupId atIndex:DATA_VALUE];
    [[AppManager instance].baseDataArray insertObject:classArray atIndex:1];
    [classArray release];
    
    // Mobile:
    NSMutableArray *mobileArray = [[NSMutableArray alloc] init];
    [mobileArray insertObject:@"2" atIndex:DATA_ID];
    [mobileArray insertObject:[NSString stringWithFormat:@"%d", DEFINE_TYPE_TEXT] atIndex:DATA_TYPE];
    [mobileArray insertObject:LocaleStringForKey(NSMobileTitle,nil) atIndex:DATA_NAME];
    [mobileArray insertObject:[AppManager instance].userMobile atIndex:DATA_VALUE];
    [[AppManager instance].baseDataArray insertObject:mobileArray atIndex:2];
    [mobileArray release];
    
    // EMail:
    NSMutableArray *emailArray = [[NSMutableArray alloc] init];
    [emailArray insertObject:@"3" atIndex:DATA_ID];
    [emailArray insertObject:[NSString stringWithFormat:@"%d", DEFINE_TYPE_TEXT] atIndex:DATA_TYPE];
    [emailArray insertObject:LocaleStringForKey(NSEmailTitle,nil) atIndex:DATA_NAME];
    [emailArray insertObject:[AppManager instance].email atIndex:DATA_VALUE];
    [[AppManager instance].baseDataArray insertObject:emailArray atIndex:3];
    [emailArray release];
}

#pragma mark - Input Height
- (int)getInputHeight:(int)type {
    float inputHeight=0;
    switch (type) {
        case DEFINE_TYPE_TEXT:
        {
            inputHeight = 33;
        }
            break;
            
        case DEFINE_TYPE_AREA:
        {
            inputHeight = 90;
        }
            break;
            
        case DEFINE_TYPE_DROPDOWN:
        {
            inputHeight = 30;
        }
            break;
            
        default:
            break;
    }
    
    return inputHeight;
}

#pragma mark - draw ui elements
- (void)drawUIElements:(UIView *)drawView dataArray:(NSMutableArray *)dataArray index:(int)index labelFrame:(CGRect)labelFrame inputFrame:(CGRect)inputFrame isBaseData:(BOOL)isBaseData
{
    
    int tagIndex = index;
    
    if (!isBaseData) {
        index = index - self.baseDataSize;
    }
    
    int type;
    type = [[[dataArray objectAtIndex:index] objectAtIndex:DATA_TYPE] intValue];
    
    WXWLabel *label = [[[WXWLabel alloc] initWithFrame:labelFrame textColor:COLOR(105, 105, 105) shadowColor:[UIColor clearColor]] autorelease];
    label.font = FONT(15);
    label.text = [[dataArray objectAtIndex:index] objectAtIndex:DATA_NAME];
    label.numberOfLines = 0;
    [drawView addSubview:label];
    
    switch (type) {
        case DEFINE_TYPE_TEXT:
        {
            BaseTextField *mTextField = [[[BaseTextField alloc] initWithFrame:inputFrame] autorelease];
            mTextField.tag = tagIndex;
            mTextField.backgroundColor = COLOR(242, 242, 242);
            mTextField.borderStyle = UITextBorderStyleNone;
            mTextField.layer.borderWidth = 0.5f;
            mTextField.layer.borderColor = COLOR(214, 214, 214).CGColor;
            mTextField.keyboardType = UIKeyboardTypeDefault;
            mTextField.returnKeyType = UIReturnKeyDone;
            mTextField.font = BOLD_FONT(14);
            mTextField.placeholder = LocaleStringForKey(NSInputTextTitle, nil);
            mTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            mTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            mTextField.clearsOnBeginEditing = NO;
            mTextField.textAlignment = UITextAlignmentLeft;
            mTextField.delegate = self;
            mTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            [mTextField addTarget:self
                           action:@selector(hideKeyboard:)
                 forControlEvents:UIControlEventEditingDidEndOnExit];
            NSString *mName = (dataArray)[index][DATA_VALUE];
            if (mName && mName.length > 0) {
                mTextField.text = mName;
                mTextField.textColor = COLOR(50, 50, 50);
            }
            
            [drawView addSubview:mTextField];
            if (tagIndex == 0 || tagIndex == 1) {
                [mTextField setEnabled:NO];
            } else {
                mTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
                [mTextField setEnabled:YES];
            }
        }
            break;
            
        case DEFINE_TYPE_AREA:
        {
            UITextView *mTextView = [[[UITextView alloc] initWithFrame:inputFrame] autorelease];
            mTextView.tag = tagIndex;
            mTextView.font = FONT(14);
            mTextView.delegate = self;
            mTextView.backgroundColor = COLOR(242, 242, 242);
            mTextView.returnKeyType = UIReturnKeyDefault;
            mTextView.keyboardType = UIKeyboardTypeDefault;
            mTextView.layer.borderWidth = 0.5f;
            mTextView.layer.borderColor = COLOR(214, 214, 214).CGColor;
            // use the default type input method (entire keyboard)
            mTextView.scrollEnabled = YES;
            
            NSString *mName = (dataArray)[index][DATA_VALUE];
            if (mName && mName.length > 0) {
                mTextView.text = mName;
                mTextView.textColor = COLOR(50, 50, 50);
            } else {
                mTextView.text = LocaleStringForKey(NSInputTextTitle, nil);
                mTextView.textColor = COLOR(112, 112, 112);
            }
            
            // note: for UITextView, if you don't like autocompletion while typing use:
            mTextView.autocorrectionType = UITextAutocorrectionTypeNo;
            
            // keyboard view add Done Button
            UIToolbar *topView = [[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, NAVIGATION_BAR_HEIGHT)] autorelease];
            
            [topView setBarStyle:UIBarStyleBlack];
            
            UIBarButtonItem *helloButton = [[[UIBarButtonItem alloc]initWithTitle:NULL_PARAM_VALUE style:UIBarButtonItemStylePlain target:self action:nil] autorelease];
            
            UIBarButtonItem *btnSpace = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
            
            UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)] autorelease];
            
            NSArray *buttonsArray = @[helloButton,btnSpace,doneButton];
            
            [topView setItems:buttonsArray];
            [mTextView setInputAccessoryView:topView];
            [drawView addSubview:mTextView];
        }
            break;
            
        case DEFINE_TYPE_DROPDOWN:
        {
            UIButton *mBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            mBtn.tag = tagIndex;
            mBtn.frame = inputFrame;
            mBtn.backgroundColor = COLOR(242, 242, 242);
            mBtn.layer.borderWidth = 0.5f;
            mBtn.layer.borderColor = COLOR(214, 214, 214).CGColor;
            NSString *mName = NULL_PARAM_VALUE;
            
            NSString *idValue = (dataArray)[index][DATA_VALUE];
            
            int optionInt = [[[AppManager instance].questionDictMutable objectForKey:[NSString stringWithFormat:@"%d", index]] intValue];
            NSMutableArray *optionArray = ([AppManager instance].questionsOptionsList)[optionInt];
            
            int optionSize = [optionArray count];
            for (int optionIndex = 0; optionIndex < optionSize; optionIndex ++) {
                if ([idValue isEqualToString:(optionArray)[optionIndex][RECORD_ID_IDX]]) {
                    mName = (optionArray)[optionIndex][RECORD_NAME_IDX];
                    break;
                }
            }
            
            if (![NULL_PARAM_VALUE isEqualToString:mName]) {
                [mBtn setTitleColor:COLOR(50, 50, 50) forState:UIControlStateNormal];
            } else {
                mName = LocaleStringForKey(NSSelectTitle, nil);
                [mBtn setTitleColor:COLOR(112, 112, 112) forState:UIControlStateNormal];
            }
            
            [mBtn setTitle:mName forState:UIControlStateNormal];
            [mBtn.titleLabel setFont:FONT(14)];
            
            [mBtn addTarget:self action:@selector(doDropDown:) forControlEvents:UIControlEventTouchUpInside];
            [mBtn setEnabled:YES];
            [drawView addSubview:mBtn];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate method
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentTextField = textField;
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    } else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        _animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    } else {
        _animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    [self upAnimate];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.currentTextField = textField;
    [self downAnimate];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.currentTextField = textField;
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate method
- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    self.currentTextView = textView;
    
    NSString *temp = LocaleStringForKey(NSInputTextTitle, nil);
	if ([textView.text isEqualToString:temp]) {
		textView.textColor = [UIColor blackColor];
		textView.text = NULL_PARAM_VALUE;
	}
    
    CGRect textViewRect = [self.view.window convertRect:textView.bounds fromView:textView];
    
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textViewRect.origin.y + 0.5 * textViewRect.size.height;
    
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    } else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        _animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    } else {
        _animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    [self upAnimate];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    self.currentTextView = textView;
    
    int tag = textView.tag;
    
	if ([textView.text isEqualToString:NULL_PARAM_VALUE]) {
		textView.textColor = [UIColor grayColor];
		textView.text = LocaleStringForKey(NSInputTextTitle, nil);
	} else {
        [[[AppManager instance].questionsList objectAtIndex:(tag-self.baseDataSize)] insertObject:textView.text atIndex:DATA_VALUE];
    }
    
    [self downAnimate];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.currentTextView = textView;
    return YES;
}

-(void)dismissKeyBoard
{
    [self.currentTextView resignFirstResponder];
}


#pragma mark - animate
- (void)upAnimate
{
    
	CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= _animatedDistance;
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.view.frame = viewFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)downAnimate
{
    CGRect viewFrame = self.view.frame;
	
    viewFrame.origin.y += _animatedDistance;
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.view.frame = viewFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
}

#pragma mark - UIText Interaction
- (void)hideKeyboard:(id)sender {
    UITextField *mTextField = (UITextField *)sender;
    [mTextField resignFirstResponder];
}

#pragma mark - clear questions
- (void)clearQuestions {
    
    [[AppManager instance].questionsList removeAllObjects];
    [AppManager instance].questionsList = nil;
    [[AppManager instance].questionsOptionsList removeAllObjects];
    [AppManager instance].questionsOptionsList = nil;
    [[AppManager instance].questionDictMutable removeAllObjects];
    [AppManager instance].questionDictMutable = nil;
}

- (void)closeKeyboard {
    if (self.currentTextField) {
        [self.currentTextField resignFirstResponder];
    }
    
    if (self.currentTextView) {
        [self.currentTextView resignFirstResponder];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollStartY < scrollView.contentOffset.y) {
        directDown = YES;
    } else {
        directDown = NO;
    }
    
    if (!isScrolling) {
        scrollStartY = scrollView.contentOffset.y;
        isScrolling = YES;
    }
    
    //防止最开始就向上面拖动的时候
    if (scrollView.contentOffset.y < 0) {
        return;
    }
}

// 触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    scrollOffSet = scrollView.contentOffset.y - scrollStartY;
}

// 滚动停止时，触发该函数
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    scrollOffSet = scrollView.contentOffset.y - scrollStartY;  
    isScrolling = NO;
}

#pragma mark - check input Msg
- (BOOL)checkInputMsg
{
    int questionSize = [[AppManager instance].questionsList count];
    
    for (int questionIndex = 0; questionIndex<questionSize; questionIndex++) {
        if (![@"0" isEqualToString:[AppManager instance].questionsList[questionIndex][DATA_ISREQUIRED]] && [NULL_PARAM_VALUE isEqualToString:[AppManager instance].questionsList[questionIndex][DATA_VALUE]]) {
            
            [UIUtils showNotificationOnTopWithMsg:[NSString stringWithFormat:@"%@ %@%@%@", LocaleStringForKey(NSCheckInputMsg, nil), LocaleStringForKey(NSInputIndexMsg, nil), [AppManager instance].questionsList[questionIndex][DATA_SORT], LocaleStringForKey(NSInputItemMsg, nil)]
                                          msgType:INFO_TY
                               belowNavigationBar:YES];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - UIAlertViewDelegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
}

@end
