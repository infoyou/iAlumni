//
//  AlumniSurveyViewController.m
//  iAlumni
//
//  Created by Adam on 13-2-9.
//
//

#import "AlumniSurveyViewController.h"
#import "UIUtils.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "AppManager.h"
#import "UIImageButton.h"
#import "WXWLabel.h"
#import "BaseTextField.h"

#define NAME_WIDTH      300.f
#define CONTENT_X       10.f
#define CONTENT_WIDTH   280.f
#define MIDDLE_H        303.f

@interface AlumniSurveyViewController ()
@property (nonatomic, retain) UIView *middleView;
@property (nonatomic, retain) UIView *bottomView;
@property (nonatomic, retain) UITextView *currentTextView;
@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) int inputSize;
@end

@implementation AlumniSurveyViewController

- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
    self = [super initWithMOC:MOC];
    
    if (self) {
        self.baseDataSize = 4;
    }
    
    return self;
}

- (void)dealloc {

    self.middleView = nil;
    self.bottomView = nil;
    self.currentTextView = nil;
    
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_autoLoaded) {
        [self loadDetail];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _noNeedDisplayEmptyMsg = YES;
    [self initTableViewProperties];
    
    [self changeTableStyle];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init view
- (void)initHeadView {
    CGFloat height = 0;
    
    // top height
    height += [self getViewTopHeight];
    
    // middle height
    height += [self getViewMiddleHeight];
    
    // bottom height
    height += [self getViewBottomHeight];
    
    // Head View
    UIView *headView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)] autorelease];
    
    [headView addSubview:self.middleView];
    [headView addSubview:self.bottomView];
    [headView sizeToFit];
    
    // ios4.3 needs reset the frame of table view, otherwise, the y coordinate will be -44.0
    _tableView.frame = CGRectMake(0, 0, _tableView.frame.size.width, _tableView.frame.size.height);
    
    _tableView.tableHeaderView = headView;
    
}

- (void)initTableViewProperties {
    _tableView.alpha = 1.0f;
    _tableView.frame = CGRectMake(_tableView.frame.origin.x,
                                  _tableView.frame.origin.y,
                                  _tableView.frame.size.width, 0);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)changeTableStyle
{
    _tableView.frame = CGRectMake(0, 0, _tableView.frame.size.width, self.view.frame.size.height);
    _tableView.alpha = 0.f;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}

- (void)initViewMiddle {
    
    self.middleView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self.middleView setBackgroundColor:[UIColor whiteColor]];
    self.middleView.layer.borderWidth = 1.f;
    self.middleView.layer.borderColor = COLOR(215, 215, 215).CGColor;
    
    float currentHeight = 5;
    int inputHeight = 0;
    int interval = 18;
    int size = [[AppManager instance].baseDataArray count];
    for (int i=0; i<size; i++) {
        int type;
        type = [[[[AppManager instance].baseDataArray objectAtIndex:i] objectAtIndex:DATA_TYPE] intValue];
        
        inputHeight = [self getInputHeight:type];
        
        NSString *labelStr = [[[AppManager instance].baseDataArray objectAtIndex:i] objectAtIndex:DATA_NAME];
        
        CGSize size = [labelStr sizeWithFont:FONT(15)
                           constrainedToSize:CGSizeMake(NAME_WIDTH, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect labelFrame = CGRectMake(CONTENT_X+MARGIN, currentHeight, CONTENT_WIDTH, size.height+5);
        CGRect inputFrame = CGRectMake(CONTENT_X, currentHeight + size.height + 2*MARGIN, CONTENT_WIDTH, inputHeight);
        
        [self drawUIElements:self.middleView
                   dataArray:[AppManager instance].baseDataArray
                       index:i
                  labelFrame:labelFrame
                  inputFrame:inputFrame
                  isBaseData:YES];
        
        currentHeight += labelFrame.size.height + inputHeight + interval;
    }
    
    self.middleView.frame = CGRectMake(MARGIN * 2, [self getViewTopHeight], NAME_WIDTH, currentHeight+2*MARGIN);
}

- (void)initViewBottom {
    int size = [[AppManager instance].questionsList count];
    if (size == 0) {
        return;
    }
    
    self.bottomView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [self.bottomView setBackgroundColor:[UIColor whiteColor]];
    self.bottomView.layer.borderWidth = 1.f;
    self.bottomView.layer.borderColor = COLOR(215, 215, 215).CGColor;
    
    float currentHeight = 5;
    int inputHeight = 0;
    int interval = 15;
    
    for (int i=0; i<size; i++) {
        int type;
        type = [[[[AppManager instance].questionsList objectAtIndex:i] objectAtIndex:DATA_TYPE] intValue];
        
        inputHeight = [self getInputHeight:type];
        
        NSString *labelStr = [[[AppManager instance].questionsList objectAtIndex:i] objectAtIndex:DATA_NAME];
        
        CGSize size = [labelStr sizeWithFont:FONT(15)
                           constrainedToSize:CGSizeMake(NAME_WIDTH, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect labelFrame = CGRectMake(CONTENT_X+MARGIN, currentHeight, CONTENT_WIDTH, size.height+5);
        CGRect inputFrame = CGRectMake(CONTENT_X, currentHeight + size.height + 2*MARGIN, CONTENT_WIDTH, inputHeight);
        
        [self drawUIElements:self.bottomView
                   dataArray:[AppManager instance].questionsList
                       index:(i+self.baseDataSize)
                  labelFrame:labelFrame
                  inputFrame:inputFrame
                  isBaseData:NO];
        
        currentHeight += labelFrame.size.height + inputHeight + interval;
    }
    
    self.bottomView.frame = CGRectMake(MARGIN * 2, self.middleView.frame.origin.y + self.middleView.frame.size.height + MARGIN*4, NAME_WIDTH, currentHeight+2*MARGIN);
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"EventSignUpCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    [subviews release];
    
    UIImageButton *signBut = [[[UIImageButton alloc]
                               initImageButtonWithFrame:CGRectMake(100.f, 30.f, 120.f, 45.f)
                               target:self
                               action:@selector(doSubmit:)
                               title:LocaleStringForKey(NSSubmitButTitle, nil)
                               image:nil
                               backImgName:@"eventSignupBut.png"
                               selBackImgName:nil
                               titleFont:BOLD_FONT(18.f)
                               titleColor:[UIColor whiteColor]
                               titleShadowColor:TRANSPARENT_COLOR
                               roundedType:NO_ROUNDED
                               imageEdgeInsert:ZERO_EDGE
                               titleEdgeInsert:ZERO_EDGE] autorelease];
    [cell.contentView addSubview:signBut];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

#pragma mark - arrange after detail loaded
- (void)arrangeBaseInfos {
    [self initHeadView];
    
    [UIView animateWithDuration:FADE_IN_DURATION
                     animations:^{
                         _tableView.frame = CGRectMake(_tableView.frame.origin.x,
                                                       _tableView.frame.origin.y,
                                                       _tableView.frame.size.width,
                                                       self.view.frame.size.height);
                         _tableView.alpha = 1.0f;
                     }];
}

#pragma mark - arrange after event detail loaded
- (void)arrangeEventBaseInfos {
    [self initHeadView];
    
    [UIView animateWithDuration:FADE_IN_DURATION
                     animations:^{
                         _tableView.frame = CGRectMake(_tableView.frame.origin.x,
                                                       _tableView.frame.origin.y,
                                                       _tableView.frame.size.width,
                                                       self.view.frame.size.height);
                         _tableView.alpha = 1.0f;
                     }];
}

- (void)arrangeViewsAfterDetailLoaded {
    [super clearPickerSelIndex2Init:[[AppManager instance].questionsOptionsList count]];
    [self initBaseDataArray];
    [self initViewMiddle];
    [self initViewBottom];
    
    [self arrangeEventBaseInfos];
    
    [_tableView reloadData];
    
}

#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
    
    BOOL blockCurrentview = NO;
    if (contentType == SURVEY_DATA_TY) {
        blockCurrentview = YES;
    }
    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
              blockCurrentView:blockCurrentview];
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType{
    
    switch (contentType) {
        case SENT_QUESTIONS_RESULT_TY:
        {
            if ([XMLParser handleCommonResult:result showFlag:NO] == RESP_OK) {
                ShowAlertWithOneButton(self, LocaleStringForKey(NSNoteTitle, nil), LocaleStringForKey(NSSubmitDoneMsg, nil),LocaleStringForKey(NSDoneTitle, nil));
            } else {
                ShowAlertWithOneButton(self, LocaleStringForKey(NSNoteTitle, nil), LocaleStringForKey(NSSubmitFailedMsg, nil), LocaleStringForKey(NSBackBtnTitle, nil));
            }
            break;
        }
            
        case SURVEY_DATA_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:SURVEY_DATA_TY
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                
                [self arrangeViewsAfterDetailLoaded];
                
                _autoLoaded = YES;
            } else {
                [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchEventDetailFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            
            break;
        }
            
        default:
            break;
    }
    
    [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
    
    NSString *msg = nil;
    
    switch (contentType) {
        case SURVEY_DATA_TY:
            msg = LocaleStringForKey(NSLoadBrandsFailedMsg, nil);
            break;
            
        default:
            break;
    }
    
    if ([self connectionMessageIsEmpty:error]) {
        self.connectionErrorMsg = msg;
    }
    
    [super connectFailed:error url:url contentType:contentType];
}


- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
    
    [super connectCancelled:url contentType:contentType];
}

#pragma mark - load data
- (void)loadDetail {
    
    [self clearQuestions];
    
    _currentType = SURVEY_DATA_TY;
    
    NSString *param = [NSString stringWithFormat:@"<questionaire_id>%lli</questionaire_id>",[AppManager instance].questionId];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                             contentType:_currentType];
    [connFacade fetchGets:url];
}

#pragma mark - doSubmit
- (void)doSubmit:(id)sender {
//    self.connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
//                                                 interactionContentType:SEND_COMMENT_TY] autorelease];
    
    if (![self checkInputMsg]) {
        return;
    }
    
    _currentType = SENT_QUESTIONS_RESULT_TY;
    
    NSMutableString *content = [NSMutableString string];
    [content appendString:REQ_XML_HEADER];
    [content appendString:@"<items>"];
    
    // email
    [content appendString:@"<item>"];
    [content appendString:@"<id>email</id>"];
    [content appendString:@"<value>"];
    [content appendString:[AppManager instance].email];
    [content appendString:@"</value>"];
    [content appendString:@"</item>"];
    
    // mobile
    [content appendString:@"<item>"];
    [content appendString:@"<id>mobile</id>"];
    [content appendString:@"<value>"];
    [content appendString:[AppManager instance].userMobile];
    [content appendString:@"</value>"];
    [content appendString:@"</item>"];
    
    int size = [[AppManager instance].questionsList count];
    for (int qustionIndex=0; qustionIndex<size; qustionIndex++) {
        [content appendString:@"<item>"];
        [content appendString:@"<id>"];
        [content appendString:[[[AppManager instance].questionsList objectAtIndex:qustionIndex] objectAtIndex:DATA_ID]];
        [content appendString:@"</id>"];
        [content appendString:@"<value>"];
        [content appendString:[[[AppManager instance].questionsList objectAtIndex:qustionIndex] objectAtIndex:DATA_VALUE]];
        [content appendString:@"</value>"];
        [content appendString:@"</item>"];
    }
    
    [content appendString:@"</items>"];
    
    
    NSString *param = [NSString stringWithFormat:@"<questionaire_id>%lld</questionaire_id>",[AppManager instance].questionId];
    
    NSMutableString *urlStr = [NSMutableString string];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    
    [urlStr appendString:url];
    [urlStr appendFormat:@"&question_results=%@",content];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:urlStr
                                                              contentType:_currentType];
    [connFacade fetchGets:urlStr];
}

#pragma mark - Content Height
- (float)getViewTopHeight {

    return MARGIN * 2;
}

- (float)getViewMiddleHeight {
    
    float currentHeight = 5;
    int inputHeight = 0;
    int interval = 18;
    
    int size = [[AppManager instance].baseDataArray count];
    for (int i=0; i<size; i++) {
        int type;
        type = [[[[AppManager instance].baseDataArray objectAtIndex:i] objectAtIndex:DATA_TYPE] intValue];
        
        inputHeight = [self getInputHeight:type];
        
        NSString *labelStr = [[[AppManager instance].baseDataArray objectAtIndex:i] objectAtIndex:DATA_NAME];
        
        CGSize size = [labelStr sizeWithFont:FONT(15)
                           constrainedToSize:CGSizeMake(NAME_WIDTH, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
        
        currentHeight += size.height+5 + inputHeight + interval;
    }
    
    return currentHeight+2*MARGIN;
}

- (float)getViewBottomHeight {
    int size = [[AppManager instance].questionsList count];
    if (size == 0) {
        return 0.f;
    }
    
    int currentHeight = 5;
    int inputHeight = 0;
    int interval = 15;
    
    for (int i=0; i<size; i++) {
        int type;
        type = [[[[AppManager instance].questionsList objectAtIndex:i] objectAtIndex:DATA_TYPE] intValue];
        
        inputHeight = [self getInputHeight:type];
        
        NSString *labelStr = [[[AppManager instance].questionsList objectAtIndex:i] objectAtIndex:DATA_NAME];
        
        CGSize size = [labelStr sizeWithFont:FONT(15)
                           constrainedToSize:CGSizeMake(NAME_WIDTH, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
        
        currentHeight += size.height+5 + inputHeight + interval;
    }
    
    return currentHeight+2*MARGIN;
}

#pragma mark - UIPickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    pickSel0Index = row;
    isPickSelChange = YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_PickData count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _PickData[row];
}

- (void)setDropDownValueArray
{
    iFliterIndex = [[[AppManager instance].questionDictMutable objectForKey:[NSString stringWithFormat:@"%d", (self.currentIndex-self.baseDataSize)]] intValue];
    
    self.DropDownValArray = [[AppManager instance].questionsOptionsList objectAtIndex:(iFliterIndex)];
}

-(void)onPopCancle:(id)sender {
    [super onPopCancle];
    
    [_tableView reloadData];
}

-(void)onPopOk:(id)sender {
    
    [super onPopSelectedOk];
    int iPickSelectIndex = [super pickerList0Index];
    
    [[[AppManager instance].questionsList objectAtIndex:(self.currentIndex-self.baseDataSize)] insertObject:(self.DropDownValArray)[iPickSelectIndex][RECORD_ID_IDX] atIndex:DATA_VALUE];
    [self initViewBottom];
    
    [self arrangeBaseInfos];
    [_tableView reloadData];
}

- (void)doDropDown:(UIButton *)sender
{
    [self closeKeyboard];
    self.currentIndex = sender.tag;
    [super setPopView];
}

#pragma mark - UITextFieldDelegate method
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [super textFieldDidBeginEditing:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    int tag = textField.tag;
    switch (tag) {
        case MOBILE_FIELD:
            [AppManager instance].userMobile = textField.text;
            break;
            
        case EMAIL_FIELD:
            [AppManager instance].email = textField.text;
            break;
            
        default:
            [[[AppManager instance].questionsList objectAtIndex:(tag-self.baseDataSize)] insertObject:textField.text
                                                                                              atIndex:DATA_VALUE];
            break;
    }
    
    [super textFieldDidEndEditing:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [super textFieldShouldReturn:textField];
    return YES;
}

#pragma mark - UITextViewDelegate method
- (void)textViewDidBeginEditing:(UITextView *)textArea{
    
    [super textViewDidBeginEditing:textArea];
}

- (void)textViewDidEndEditing:(UITextView *)textArea{
    
    [super textViewDidEndEditing:textArea];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [super textViewShouldEndEditing:textView];
    self.inputSize = [textView.text length];
    return YES;
}

@end
