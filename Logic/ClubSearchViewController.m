//
//  ClubSearchViewController.m
//  iAlumni
//
//  Created by Adam on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ClubSearchViewController.h"
#import "UserListViewController.h"
#import "ClassGroup.h"
#import "Club.h"
#import "AppManager.h"
#import "ECAsyncConnectorFacade.h"
#import "CommonUtils.h"
#import "UIUtils.h"
#import "XMLParser.h"

#define FONT_SIZE           20.0f
#define CELL_SIZE           2

#define LABEL_X             20.0f
#define LABEL_W             60.0f
#define LABEL_H             30.0f
#define CONTENT_X           80.0f
#define NOTE_Y              20.0f
#define NAME_Y              80.0f
#define CLASS_Y             150.0f
#define CLEAR_CLASS_X       260.0f

typedef enum {
    NAME_TAG,
    CLASS_TAG,
} CLUB_QUERY_VIEW_TAG;

static int iTableSelectIndex = -1;

@interface ClubSearchViewController ()
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *classField;
@property (nonatomic, retain) Club *group;
@end

@implementation ClubSearchViewController
@synthesize _TableCellShowValArray;
@synthesize _TableCellSaveValArray;
@synthesize nameField = _nameField;
@synthesize classField = _classField;
@synthesize _SelCheckResult;
@synthesize classFliters;

#pragma mark - init
- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(Club *)group
{
    self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needGoHome:NO];
    if (self) {
      
      self.group = group;
      
        _TableCellShowValArray = [[NSMutableArray alloc] init];
        _TableCellSaveValArray = [[NSMutableArray alloc] init];
        for (NSUInteger i=0; i<CELL_SIZE; i++) {
            [_TableCellShowValArray addObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]];
            [_TableCellSaveValArray addObject:[NSString stringWithFormat:@"%@",NULL_PARAM_VALUE]];
        }
        
        [super clearPickerSelIndex2Init:1];
        
        [self clearFliter];
    }
    return self;
}

- (void)dealloc
{
    RELEASE_OBJ(_nameField);
    RELEASE_OBJ(_classField);
    
    [super dealloc];
}

- (void)clearFliter
{
    // Clear Fliter
    [[AppManager instance].supClassFilterList removeAllObjects];
    [AppManager instance].supClassFilterList = nil;
    [[AppManager instance].classFilterList removeAllObjects];
    [AppManager instance].classFilterList = nil;
    [AppManager instance].classFliterLoaded = NO;
}

- (void)getAlumniClass{
    
    NSString *url = ALUMNI_CLASS_REQ_URL;
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self 
                                                                    interactionContentType:CLASS_TY] autorelease];
    // [self.connDic setObject:connFacade forKey:url];
    [connFacade fetchGets:url];
}

- (void)initView
{
    self.nameField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
    self.classField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)refreshView
{
    
    UIView *bgView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 45)] autorelease];
    bgView.backgroundColor = TRANSPARENT_COLOR;
    
    // Note
    CGRect noteFrame = CGRectMake(LABEL_X, NOTE_Y, SCREEN_WIDTH-2*LABEL_X, LABEL_H);
    UILabel *noteLabel = [[[UILabel alloc] initWithFrame:noteFrame] autorelease];
    noteLabel.text = LocaleStringForKey(NSSearchInputTitle, nil);
    noteLabel.font = Arial_FONT(FONT_SIZE);
    noteLabel.textColor = COLOR(165, 165, 165);
    [bgView addSubview:noteLabel];
    
    // Name
    CGRect nameFrame = CGRectMake(LABEL_X, NAME_Y, LABEL_W, LABEL_H);
    UILabel *nameLabel = [[[UILabel alloc] initWithFrame:nameFrame] autorelease];
    nameLabel.text = [NSString stringWithFormat:@"%@:",LocaleStringForKey(NSNameTitle, nil)];
    nameLabel.textColor = COLOR(165, 165, 165);
    nameLabel.font = Arial_FONT(FONT_SIZE);
    [bgView addSubview:nameLabel];
    
    CGRect nameTextFrame = CGRectMake(CONTENT_X, NAME_Y+5, 200.f, LABEL_H);
    self.nameField.frame = nameTextFrame;
    self.nameField.tag = NAME_TAG;
    self.nameField.returnKeyType = UIReturnKeyDone;
    NSString* mTextName = _TableCellShowValArray[NAME_TAG];
    if ([mTextName isEqualToString:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]]) {
        mTextName = NULL_PARAM_VALUE;
    }
    
    self.nameField.text = mTextName;
    self.nameField.delegate = self;
    self.nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameField.placeholder = LocaleStringForKey(NSNamePlaceholder, nil);
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

    NSString* mName = _TableCellShowValArray[CLASS_TAG];
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
    self.classField.backgroundColor = TRANSPARENT_COLOR;
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
    
    [self.view addSubview:bgView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = LocaleStringForKey(NSAlumniSearchTitle, nil);
    [self initView];
    [self refreshView];
    
    if (![AppManager instance].isLoadClassDataOK) {
        [self getAlumniClass];
    }
  
  [self addLeftBarButtonWithTitle:LocaleStringForKey(NSBackTitle, nil)
                           target:self
                           action:@selector(doBack:)];

  [self addRightBarButtonWithTitle:LocaleStringForKey(NSQueryTitle, nil)
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
    if (self.nameField != nil) {
        [self.nameField resignFirstResponder];
        int index = [self.nameField tag];
        NSString *resultVal = [self.nameField text];
        
        if (![_TableCellShowValArray[index] isEqualToString:resultVal]) {
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
    
    [_TableCellShowValArray removeObjectAtIndex:iTableSelectIndex];
    [_TableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:iTableSelectIndex];
    
    [_TableCellSaveValArray removeObjectAtIndex:iTableSelectIndex];
    [_TableCellSaveValArray insertObject:NULL_PARAM_VALUE atIndex:iTableSelectIndex];
    
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
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark - Save TableCell Value
-(void)setTableCellVal:(int)index aShowVal:(NSString*)aShowVal aSaveVal:(NSString*)aSaveVal isFresh:(BOOL)isFresh
{
    [_TableCellShowValArray removeObjectAtIndex:index];
    [_TableCellShowValArray insertObject:aShowVal atIndex:index];
    
    [_TableCellSaveValArray removeObjectAtIndex:index];
    [_TableCellSaveValArray insertObject:aSaveVal atIndex:index];
    
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
    
  if([XMLParser parserResponseXml:result
                             type:contentType
                              MOC:_MOC
                connectorDelegate:self
                              url:url]) {
    } else {
      [UIUtils showNotificationOnTopWithMsg:@"Failed Msg"
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];

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
  
  [super connectFailed:error url:url contentType:contentType];
}

-(BOOL)checkVal
{
    // 班级不为空，直接过去。
    if (![_TableCellShowValArray[CLASS_TAG] isEqualToString:[NSString stringWithFormat:@"%d", iOriginalSelIndexVal]]) {
        return YES;
    }
    
    if (![self.nameField.text isEqualToString:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]] && [self.nameField.text length]>=2) {
        return YES;
    }else {
        
        ShowAlertWithOneButton(self, LocaleStringForKey(NSNoteTitle, nil),LocaleStringForKey(NSSearchConditionTitle, nil), LocaleStringForKey(NSOKTitle, nil));
        return NO;
    }
    
    ShowAlertWithOneButton(self, LocaleStringForKey(NSNoteTitle, nil),LocaleStringForKey(NSSearchInputTitle, nil), LocaleStringForKey(NSOKTitle, nil));
    return NO;
}

#pragma mark - query
-(void)doQuery:(UIButton*)sender
{
    [self.nameField resignFirstResponder];
    
    [CommonUtils doDelete:self.MOC entityName:@"Alumni"];
    
    if (![self checkVal]) {
        return;
    }
    
    NSString *param = [NSString stringWithFormat:@"<host_id>%@</host_id><host_type>%@</host_type><search_classid>%@</search_classid><search_name>%@</search_name><event_id>%@</event_id><page>0</page>", [AppManager instance].clubId, [AppManager instance].clubType, _TableCellSaveValArray[CLASS_TAG], self.nameField.text, [AppManager instance].eventId];
    
    UserListViewController *userListVC = [[UserListViewController alloc] initWithType:CLUB_MANAGE_QUERY_USER_TY needGoToHome:YES MOC:self.MOC group:self.group needAdjustForiOS7:NO];
    
    userListVC.pageIndex = 0;
    userListVC.requestParam = [NSString stringWithFormat:@"%@", param];
    userListVC.title = LocaleStringForKey(NSAlumniTitle, nil);
    [self.navigationController pushViewController:userListVC animated:YES];
    RELEASE_OBJ(userListVC);
    
}

- (void)doBack:(id)sender {
    if ([AppManager instance].isAddUserList) {
        [AppManager instance].isNeedReLoadUserList = YES;
        [AppManager instance].isAddUserList = NO;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
