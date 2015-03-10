//
//  AdminCheckInViewController.m
//  iAlumni
//
//  Created by Adam on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdminCheckInViewController.h"
#import "UpdateUserInfoViewController.h"
#import "ClassGroup.h"
#import "UserListCell.h"
#import "WXWDebugLogOutput.h"
#import "TipsEntranceView.h"
#import "Alumni.h"
#import "Event.h"

#define FONT_SIZE           20.0f
#define CELL_SIZE           3

#define LABEL_X             10.0f
#define LABEL_W             80.0f
#define LABEL_H             30.0f
#define CONTENT_X           80.0f
#define CODE_Y              15.0f
#define NAME_Y              55.0f
#define CLASS_Y             95.0f
#define CLEAR_CLASS_X       260.0f
#define TABLE_H             135.f

typedef enum {
    CODE_TAG,
    NAME_TAG,
    CLASS_TAG,
} CLUB_QUERY_VIEW_TAG;

static int  iTableSelectIndex = -1;
static int  iSize = 0;

@interface AdminCheckInViewController ()
@property (nonatomic,retain) Alumni *alumni;
@property (nonatomic,retain) Event *event;
@property (nonatomic,retain) UITextField *codeField;
@property (nonatomic,retain) UITextField *nameField;
@property (nonatomic,retain) UITextField *classField;
@property (nonatomic,retain) NSMutableArray *TableCellShowValArray;
@property (nonatomic,retain) NSMutableArray *TableCellSaveValArray;
@end

@implementation AdminCheckInViewController
@synthesize TableCellShowValArray = _TableCellShowValArray;
@synthesize TableCellSaveValArray = _TableCellSaveValArray;
@synthesize nameField = _nameField;
@synthesize codeField = _codeField;
@synthesize classField = _classField;
@synthesize _SelCheckResult;
@synthesize classFliters;
@synthesize alumni = _alumni;
@synthesize event = _event;
@synthesize type;

- (id)initWithMOC:(NSManagedObjectContext *)MOC event:(Event*)event
{
    self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needGoHome:NO];
    
    if (self) {
        
        self.event = event;
        
        // Custom initialization
        _TableCellShowValArray = [[NSMutableArray alloc] init];
        _TableCellSaveValArray = [[NSMutableArray alloc] init];
        
        for (NSUInteger i=0; i<CELL_SIZE; i++) {
            [self.TableCellShowValArray addObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]];
            [self.TableCellSaveValArray addObject:[NSString stringWithFormat:@"%@",NULL_PARAM_VALUE]];
        }
        
        [super clearPickerSelIndex2Init:1];
        
        [self clearFliter];
    }
    return self;
}

- (void)dealloc
{
    RELEASE_OBJ(_codeField);
    RELEASE_OBJ(_nameField);
    RELEASE_OBJ(_classField);
    
    self.alumni = nil;
    self.event = nil;
    [super dealloc];
}

#pragma mark - view life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.title = LocaleStringForKey(NSAdminCheckInButTitle, nil);
    
	// Do any additional setup after loading the view.
    [self initView];
    [self refreshView];
    [self initTableView];
    
    if (![AppManager instance].isLoadClassDataOK) {
        [self getAlumniClass];
    } else {
        [self.codeField becomeFirstResponder];
    }
    
  [self addLeftBarButtonWithTitle:LocaleStringForKey(NSBackTitle, nil)
                           target:self
                           action:@selector(doBack:)];
  
  [self addRightBarButtonWithTitle:LocaleStringForKey(LocaleStringForKey(NSQueryTitle, nil), nil)
                            target:self
                            action:@selector(doQuery:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)initTableView {
    
    CGRect mTabFrame = CGRectMake(0, TABLE_H, SCREEN_WIDTH, self.view.frame.size.height-TABLE_H);
	_tableView = [[UITableView alloc] initWithFrame:mTabFrame
                                              style:UITableViewStylePlain];
	
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
	[self.view addSubview:_tableView];
    [super initTableView];
}

- (void)initView
{
    self.codeField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
    self.nameField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
    self.classField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)refreshView
{
    
    UIView *bgView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TABLE_H)] autorelease];
    bgView.backgroundColor = TRANSPARENT_COLOR;
    
    // Sign Code
    CGRect codeFrame = CGRectMake(LABEL_X, CODE_Y, LABEL_W, LABEL_H);
    UILabel *codeLabel = [[[UILabel alloc] initWithFrame:codeFrame] autorelease];
    codeLabel.text = [NSString stringWithFormat:@"%@:", LocaleStringForKey(NSSignCodeTitle, nil)];
    codeLabel.textColor = COLOR(165, 165, 165);
    codeLabel.font = Arial_FONT(FONT_SIZE);
    [bgView addSubview:codeLabel];
    
    CGRect codeFieldFrame = CGRectMake(CONTENT_X, CODE_Y+5, SCREEN_WIDTH-100, LABEL_H);
    self.codeField.frame = codeFieldFrame;
    self.codeField.tag = CODE_TAG;
    self.codeField.returnKeyType = UIReturnKeySearch;
    self.codeField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.codeField.keyboardType = UIKeyboardTypeNumberPad;
    NSString* signCode = (self.TableCellShowValArray)[CODE_TAG];
    if ([signCode isEqualToString:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]]) {
        signCode = NULL_PARAM_VALUE;
    }
    
    self.codeField.text = signCode;
    self.codeField.delegate = self;
    self.codeField.placeholder = LocaleStringForKey(NSPostInputTitle, nil);
    self.codeField.borderStyle = UITextBorderStyleNone;
    [bgView addSubview:self.codeField];
    
    CGRect signCodeFrame = CGRectMake(LABEL_X, CODE_Y+LABEL_H, SCREEN_WIDTH-2*LABEL_X, 1);
    UIView *codeLine = [[[UIView alloc] initWithFrame:signCodeFrame] autorelease];
    codeLine.backgroundColor = COLOR(209, 216, 228);
    [bgView addSubview:codeLine];
    
    // Name
    CGRect nameFrame = CGRectMake(LABEL_X, NAME_Y, LABEL_W, LABEL_H);
    UILabel *nameLabel = [[[UILabel alloc] initWithFrame:nameFrame] autorelease];
    nameLabel.text = [NSString stringWithFormat:@"%@:",LocaleStringForKey(NSNameTitle, nil)];
    nameLabel.textColor = COLOR(165, 165, 165);
    nameLabel.font = Arial_FONT(FONT_SIZE);
    [bgView addSubview:nameLabel];
    
    CGRect nameTextFrame = CGRectMake(CONTENT_X, NAME_Y+5, SCREEN_WIDTH-100, LABEL_H);
    self.nameField.frame = nameTextFrame;
    self.nameField.tag = NAME_TAG;
    self.nameField.returnKeyType = UIReturnKeySearch;
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    NSString* mTextName = (self.TableCellShowValArray)[NAME_TAG];
    if ([mTextName isEqualToString:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]]) {
        mTextName = NULL_PARAM_VALUE;
    }
    
    self.nameField.text = mTextName;
    self.nameField.delegate = self;
    self.nameField.placeholder = LocaleStringForKey(NSSearchConditionTitle, nil);
    self.nameField.borderStyle = UITextBorderStyleNone;
    [bgView addSubview:self.nameField];
    
    CGRect nameLineFrame = CGRectMake(LABEL_X, NAME_Y+LABEL_H, SCREEN_WIDTH-2*LABEL_X, 1);
    UIView *nameLine = [[[UIView alloc] initWithFrame:nameLineFrame] autorelease];
    nameLine.backgroundColor = COLOR(209, 216, 228);
    [bgView addSubview:nameLine];
    
    // Class
    CGRect classFrame = CGRectMake(LABEL_X, CLASS_Y, LABEL_W, LABEL_H);
    UILabel *classLabel = [[[UILabel alloc] initWithFrame:classFrame] autorelease];
    classLabel.text = [NSString stringWithFormat:@"%@:",LocaleStringForKey(NSClassQueryTitle, nil)];
    classLabel.textColor = COLOR(165, 165, 165);
    classLabel.font = Arial_FONT(FONT_SIZE);
    [bgView addSubview:classLabel];
    
    // Class Drop Down
    CGRect classContentFrame = CGRectMake(CONTENT_X, CLASS_Y+4, 150, LABEL_H);
    self.classField.frame = classContentFrame;
    self.classField.tag = CLASS_TAG;
    
    NSString *mName = (self.TableCellShowValArray)[CLASS_TAG];
    if (![mName isEqualToString:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]]) {
        
        int size = [self.DropDownValArray count];
        for (NSUInteger i=0; i<size; i++) {
            if ([(self.DropDownValArray)[i][RECORD_NAME_IDX] isEqualToString:mName]) {
                mName = (self.DropDownValArray)[i][RECORD_NAME_IDX];
                break;
            }
        }
        self.classField.text = mName;
    } else {
        self.classField.text = NULL_PARAM_VALUE;
        
    }
    
    self.classField.placeholder = LocaleStringForKey(NSOptionalTitle, nil);
    UIGestureRecognizer *mClassTap = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(doDropDown:)];
    mClassTap.delegate = self;
    [self.classField addGestureRecognizer:mClassTap];
    [bgView addSubview:self.classField];
    
    // Clear
    CGRect clearClassFrame = CGRectMake(CLEAR_CLASS_X, CLASS_Y, LABEL_W, LABEL_H);
    UILabel *clearClassLabel = [[[UILabel alloc] initWithFrame:clearClassFrame] autorelease];
    clearClassLabel.text = LocaleStringForKey(NSClearTitle, nil);
    clearClassLabel.font = Arial_FONT(FONT_SIZE);
    clearClassLabel.userInteractionEnabled = YES;
    UIGestureRecognizer *mClearClassTap = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(doClearClass:)];
    mClearClassTap.delegate = self;
    [clearClassLabel addGestureRecognizer:mClearClassTap];
    [bgView addSubview:clearClassLabel];
    
    CGRect classLineFrame = CGRectMake(LABEL_X, CLASS_Y+LABEL_H, SCREEN_WIDTH-2*LABEL_X, 1);
    UIView *classLine = [[[UIView alloc] initWithFrame:classLineFrame] autorelease];
    classLine.backgroundColor = COLOR(209, 216, 228);
    [bgView addSubview:classLine];
    
    // Bottom
    TipsEntranceView *_bottomTipsView = [[[TipsEntranceView alloc] initWithFrame:CGRectMake(0, TABLE_H-MARGIN, self.view.frame.size.width, MARGIN)
                                                                        topColor:COLOR(202, 202, 207)
                                                                     bottomColor:COLOR(162, 162, 169)] autorelease];
    _bottomTipsView.tipsTitleLabel.text = NULL_PARAM_VALUE;
    [bgView addSubview:_bottomTipsView];
    
    [self.view addSubview:bgView];
}

#pragma mark - clear class pop list
- (void)clearFliter
{
    // Clear Fliter
    [[AppManager instance].supClassFilterList removeAllObjects];
    [AppManager instance].supClassFilterList = nil;
    [[AppManager instance].classFilterList removeAllObjects];
    [AppManager instance].classFilterList = nil;
    [AppManager instance].classFliterLoaded = NO;
}

- (void)setDropDownValueArray {
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    self.descriptors = [NSMutableArray array];
    
    self.DropDownValArray = [[[NSMutableArray alloc] init] autorelease];
    switch (iTableSelectIndex) {
            
        case CLASS_TAG:
        {
            iFliterIndex = 0;
            
            if ([AppManager instance].classFliterLoaded) {
                self.classFliters = ([AppManager instance].classFilterList)[pickSel0Index];
                return;
            }
            
            NSSortDescriptor *courseDesc = [[[NSSortDescriptor alloc] initWithKey:@"enCourse" ascending:YES] autorelease];
            [self.descriptors addObject:courseDesc];
            
            NSSortDescriptor *classDesc = [[[NSSortDescriptor alloc] initWithKey:@"classId" ascending:YES] autorelease];
            [self.descriptors addObject:classDesc];
            
            self.entityName = @"ClassGroup";
            
            NSError *error = nil;
            BOOL res = [[super prepareFetchRC] performFetch:&error];
            if (!res) {
                NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
            }
            
            NSArray *classDetail = [CommonUtils objectsInMOC:_MOC
                                                  entityName:self.entityName
                                                sortDescKeys:self.descriptors
                                                   predicate:nil];
            
            int size = [classDetail count];
            int supIndex = 0;
            
            [AppManager instance].supClassFilterList = [NSMutableArray array];
            [AppManager instance].classFilterList = [NSMutableArray array];
            
            for (NSUInteger i=0; i<size; i++) {
                ClassGroup* mClassGroup = (ClassGroup*)classDetail[i];
                
                NSMutableArray *supClassesArray = [[[NSMutableArray alloc] initWithObjects:mClassGroup.enCourse, mClassGroup.cnCourse, nil] autorelease];
                
                NSMutableArray *detailArray = [[[NSMutableArray alloc] initWithObjects:mClassGroup.classId, mClassGroup.enName, mClassGroup.cnName, nil] autorelease];
                
                if (![[AppManager instance].supClassFilterList containsObject:supClassesArray]) {
                    [[AppManager instance].supClassFilterList insertObject:supClassesArray atIndex:supIndex];
                    NSMutableArray *classesArray = [NSMutableArray array];
                    [classesArray insertObject:detailArray atIndex:0];
                    [[AppManager instance].classFilterList insertObject:classesArray atIndex:supIndex];
                    supIndex++;
                } else {
                    int keyIndex = [[AppManager instance].supClassFilterList indexOfObject:supClassesArray];
                    NSMutableArray *classesArray = ([AppManager instance].classFilterList)[keyIndex];
                    
                    int targetIndex = [classesArray count];
                    [classesArray insertObject:detailArray atIndex:targetIndex];
                    [[AppManager instance].classFilterList removeObjectAtIndex:keyIndex];
                    [[AppManager instance].classFilterList insertObject:classesArray atIndex:keyIndex];
                }
            }
            
            [AppManager instance].classFliterLoaded = YES;
            self.classFliters = ([AppManager instance].classFilterList)[0];
        }
            break;
    }
}

#pragma mark - Clear View Status
-(void)clearViewStatus
{
    int index = -1;
    NSString *resultVal = NULL_PARAM_VALUE;
    
    if (self.codeField != nil) {
        [self.codeField resignFirstResponder];
        index = [self.codeField tag];
        resultVal = [self.codeField text];
        
        if (![(self.TableCellShowValArray)[index] isEqualToString:resultVal]) {
            [self setTableCellVal:index aShowVal:resultVal aSaveVal:resultVal isFresh:NO];
        }
    }
    
    if (self.nameField != nil) {
        [self.nameField resignFirstResponder];
        index = [self.nameField tag];
        resultVal = [self.nameField text];
        
        if (![(self.TableCellShowValArray)[index] isEqualToString:resultVal]) {
            [self setTableCellVal:index aShowVal:resultVal aSaveVal:resultVal isFresh:NO];
        }
    }
}

#pragma mark - Pop Interaction
-(void)doClearClass:(UIGestureRecognizer *)sender
{
    [self clearViewStatus];
    
    iTableSelectIndex = CLASS_TAG;
    [self onPopCancle:sender];
}

-(void)doDropDown:(UIGestureRecognizer *)sender
{
    [self clearViewStatus];
    
    iTableSelectIndex = [sender.view tag];
    
    [super setPopView];
}

-(void)onPopCancle:(id)sender {
    [super onPopCancle];
    
    [self.TableCellShowValArray removeObjectAtIndex:iTableSelectIndex];
    [self.TableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:iTableSelectIndex];
    
    [self.TableCellSaveValArray removeObjectAtIndex:iTableSelectIndex];
    [self.TableCellSaveValArray insertObject:NULL_PARAM_VALUE atIndex:iTableSelectIndex];
    
    [self refreshView];
}

-(void)onPopOk:(id)sender {
    [super onPopSelectedOk];
    
    [self setTableCellVal:iTableSelectIndex aShowVal:(self.classFliters)[pickSel1Index][1]
                 aSaveVal:(self.classFliters)[pickSel1Index][0] isFresh:YES];
}

#pragma mark - UIPickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == PickerOne) {
        
        pickSel0Index = row;
        self.classFliters = ([AppManager instance].classFilterList)[row];
        [_PickerView selectRow:0 inComponent:PickerTwo animated:YES];
        [_PickerView reloadComponent:PickerTwo];
        pickSel1Index = 0;
    }
    
    if (component == PickerTwo){
        pickSel1Index = row;
    }
    
    isPickSelChange = YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == PickerOne)
        return [[AppManager instance].supClassFilterList count];
    return [self.classFliters count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == PickerOne)
        return ([AppManager instance].supClassFilterList)[row][1];
    return (self.classFliters)[row][1];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat componentWidth = 0.0;
    if (component == 0) {
        componentWidth = 95.0f;
    }else {
        componentWidth = 205.0f;
    }
    return componentWidth;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    iTableSelectIndex = [textField tag];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self doQuery:nil];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark - Save TableCell Value
-(void)setTableCellVal:(int)index aShowVal:(NSString*)aShowVal aSaveVal:(NSString*)aSaveVal isFresh:(BOOL)isFresh
{
    [self.TableCellShowValArray removeObjectAtIndex:index];
    [self.TableCellShowValArray insertObject:aShowVal atIndex:index];
    
    [self.TableCellSaveValArray removeObjectAtIndex:index];
    [self.TableCellSaveValArray insertObject:aSaveVal atIndex:index];
    
    if (isFresh) {
        [self refreshView];
    }
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
    [UIUtils showActivityView:self.view text:LocaleStringForKey(NSLoadingTitle, nil)];
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType{
    
    [UIUtils closeActivityView];
    
    switch (contentType) {
        case CLASS_TY:
        {
          if([XMLParser parserResponseXml:result
                                     type:contentType
                                      MOC:_MOC
                        connectorDelegate:self
                                      url:url]) {
                [self.codeField becomeFirstResponder];
            } else {
                [UIUtils showNotificationOnTopWithMsg:@"Failed Msg"
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            
            break;
        }
            
        case CLUB_MANAGE_QUERY_USER_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {

                
                [self fetchItems];
            } else {
                [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
            }
            
            break;
        }
            
        case ADMIN_CHECK_IN_TY:
        {
            if (result == nil || [result length] == 0) {
                [UIUtils showNotificationOnTopWithMsg:@"result is Null"
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                return;
            }
            
            
            if ([XMLParser parserResponseXml:result
                                        type:ADMIN_CHECK_IN_TY
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                if(type == 1){
                    [AppManager instance].isNeedReLoadUserList = YES;
                    [AppManager instance].isNeedReLoadEventDetail = YES;
                    [AppManager instance].isNeedReLoadUserDetail = YES;
                } else {
                    [AppManager instance].isNeedReLoadEventDetail = YES;
                }
                
                if (!_isCheckedStatus) {
                    [self goUpdateAlumniInfo];
                }
            }
            
            [self doQuery:nil];
            
            break;
        }
            
        default:
            break;
    }
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
    [UIUtils closeActivityView];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
    [UIUtils closeActivityView];
    
    if ([self connectionMessageIsEmpty:error]) {
        self.connectionErrorMsg = LocaleStringForKey(NSLoadFeedFailedMsg, nil);
    }
    
    [super connectFailed:error url:url contentType:contentType];
}

- (BOOL)checkVal
{
    if (![self.codeField.text isEqualToString:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]]  && [self.codeField.text length] >= 1) {
        return YES;
    }
    
    // 班级不为空，直接过去。
    if (![(self.TableCellShowValArray)[CLASS_TAG] isEqualToString:[NSString stringWithFormat:@"%d", iOriginalSelIndexVal]]) {
        return YES;
    }
    
    if (![self.nameField.text isEqualToString:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]] && [self.nameField.text length]>=2) {
        return YES;
    } else {
        ShowAlertWithOneButton(self, LocaleStringForKey(NSNoteTitle, nil),LocaleStringForKey(NSSearchConditionTitle, nil), LocaleStringForKey(NSOKTitle, nil));
        return NO;
    }
    
    ShowAlertWithOneButton(self, LocaleStringForKey(NSNoteTitle, nil),LocaleStringForKey(NSSearchInputTitle, nil), LocaleStringForKey(NSOKTitle, nil));
    return NO;
}

#pragma mark - Get Server Data
- (void)getAlumniClass{
    
    NSString *url = ALUMNI_CLASS_REQ_URL;
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:CLASS_TY] autorelease];
    // [self.connDic setObject:connFacade forKey:url];
    [connFacade fetchGets:url];
}

#pragma mark - action
-(void)doQuery:(UIButton*)sender
{
    [self.codeField resignFirstResponder];
    [self.nameField resignFirstResponder];
    [CommonUtils doDelete:_MOC entityName:@"Alumni"];
    
    if (![self checkVal]) {
        return;
    }
    
    self.entityName = @"Alumni";
    NSString *param = [NSString stringWithFormat:@"<host_id>%@</host_id><host_type>%@</host_type><search_classid>%@</search_classid><search_name>%@</search_name><page>0</page><event_id>%@</event_id><checkin_code>%@</checkin_code>", self.event.hostId, self.event.hostType, (self.TableCellSaveValArray)[CLASS_TAG], self.nameField.text, self.event.eventId, self.codeField.text];
    
    NSString *url = [CommonUtils geneUrl:param itemType:CLUB_MANAGE_QUERY_USER_TY];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:CLUB_MANAGE_QUERY_USER_TY];
    [connFacade fetchGets:url];
}

- (void)doBack:(id)sender {
    if ([AppManager instance].isAddUserList) {
        [AppManager instance].isNeedReLoadUserList = YES;
        [AppManager instance].isAddUserList = NO;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)doAdminCheckIn
{
    
    NSString *param = nil;
    _currentType = ADMIN_CHECK_IN_TY;
    param = [NSString stringWithFormat:@"<is_checkin>%@</is_checkin><target_user_id>%@</target_user_id><target_user_type>%@</target_user_type><event_id>%@</event_id><target_user_name>%@</target_user_name>",
             _isCheckedStatus == NO ? @"1" : @"0",
             self.alumni.personId,
             self.alumni.userType,
             [AppManager instance].eventId,
             self.alumni.name];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade fetchGets:url];
}

- (void)goUpdateAlumniInfo {
    
    UpdateUserInfoViewController *updateVC = [[UpdateUserInfoViewController alloc] init];
    UINavigationController *navigationView = [[UINavigationController alloc] initWithRootViewController:updateVC];
    navigationView.navigationBar.tintColor = TITLESTYLE_COLOR;
    updateVC.userId = self.alumni.personId;
    //    [self.navigationController pushViewController:userProfileVC animated:YES];
    [self presentModalViewController:navigationView animated:YES];
    //    [self performSelector:@selector(presentModalQuickViewController:)
    //               withObject:navigationView
    //               afterDelay:0.1f];
    
    RELEASE_OBJ(updateVC);
    RELEASE_OBJ(navigationView);
}

#pragma mark - core data
- (void)setFetchCondition {
}

- (void)fetchItems {
    
    self.fetchedRC = nil;
    
    self.entityName = @"Alumni";
    self.descriptors = [NSMutableArray array];
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"orderId" ascending:YES] autorelease];
    
    [self.descriptors addObject:dateDesc];
    //    _autoLoaded = YES;
	[NSFetchedResultsController deleteCacheWithName:nil];
	
	NSError *error = nil;
	BOOL success = [[super prepareFetchRC] performFetch:&error];
	if (!success) {
		debugLog(@"Unhandled error performing fetch: %@", [error localizedDescription]);
		NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
	}
    
	[_tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRC sections][section];
    iSize = [sectionInfo numberOfObjects];
    return iSize;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kCellIdentifier = @"AdminCheckInUserList";
    
    UserListCell *cell = [[[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:kCellIdentifier
                                       imageDisplayerDelegate:self
                                       imageClickableDelegate:self
                                                          MOC:_MOC] autorelease];
    
    Alumni *aAlumni = (Alumni *)[self.fetchedRC objectAtIndexPath:indexPath];
    [cell drawCell:aAlumni userListType:ADMIN_CHECK_IN_TY];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return USER_LIST_CELL_WITH_TABLE_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Alumni *aAlumni = (Alumni *)[self.fetchedRC objectAtIndexPath:indexPath];
    self.alumni = aAlumni;
    
    if (!aAlumni.isCheckIn.boolValue) {
        _isCheckedStatus = NO;
        [self doAdminCheckIn];
    } else {
        ShowAlertWithTwoButton(self,LocaleStringForKey(NSNoteTitle, nil),LocaleStringForKey(NSAdminUnCheckInButTitle, nil),LocaleStringForKey(NSCancelTitle, nil),LocaleStringForKey(NSSureTitle, nil));
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        _isCheckedStatus = YES;
        [self doAdminCheckIn];
        
        return;
    }
}

- (void)openProfile:(NSString*)userId userType:(NSString*)userType {
    
}

@end
