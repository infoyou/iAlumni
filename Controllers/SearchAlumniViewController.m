//
//  SearchAlumniViewController.m
//  iAlumni
//
//  Created by Adam on 12-11-30.
//
//

#import "SearchAlumniViewController.h"
#import "UserListViewController.h"
#import "GlobalConstants.h"
#import "ECGradientButton.h"
#import "TextConstants.h"
#import "ClassGroup.h"
#import "Industry.h"
#import "UIUtils.h"
#import "UserCountry.h"
#import "ECAsyncConnectorFacade.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "WXWLabel.h"

@implementation SearchAlumniViewController
@synthesize _DetailArray;
@synthesize _TableCellShowValArray;
@synthesize _TableCellSaveValArray;
@synthesize _SelCheckResult;
@synthesize _textField;
@synthesize classFliters;
@synthesize nameTextField;
@synthesize companyTextField;
@synthesize addressTextField;
@synthesize nameCancel;
@synthesize companyCancel;
@synthesize addressCancel;

#define CONTENT_WIDTH           SCREEN_WIDTH/2
#define CONTENT_X               100

#define VALUE_X                 65
#define FONT_SIZE               18
#define CODE_Y                  15.0f
#define FOOT_HEIGHT             150.0f
#define CELL_SIZE               7
#define LABEL_X             10.0f
#define LABEL_H             30.0f

typedef enum {
    CLASS_TAG = 0,
    NAME_TAG,
    GENDER_TAG,
    COUNTRY_TAG,
    COMPANY_TAG,
    ADDRESS_TAG,
    INDUSTRY_TAG,
} ALUMNI_QUERY_VIEW_TAG;

static int iTableSelectIndex = -1;

- (id)initWithMOC:MOC needAdjustForiOS7:(BOOL)needAdjustForiOS7
{
    self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needGoHome:NO];
    
    if (self) {
        // Custom initialization
        _DetailArray = [[NSMutableArray alloc] init];
        
        _needAdjustForiOS7 = needAdjustForiOS7;
        
        _noNeedDisplayEmptyMsg = YES;
        
        // Class:
        NSMutableArray *line0Array = [[NSMutableArray alloc] init];
        [line0Array insertObject:[NSString stringWithFormat:@"%d",CLASS_TAG] atIndex:0];
        [line0Array insertObject:LocaleStringForKey(NSClassQueryTitle,nil) atIndex:1];
        [line0Array insertObject:[NSString stringWithFormat:@"%d",DEFINE_TYPE_DROPDOWN] atIndex:2];
        [_DetailArray insertObject:line0Array atIndex:CLASS_TAG];
        [line0Array release];
        
        // Name:
        NSMutableArray *line1Array = [[NSMutableArray alloc] init];
        [line1Array insertObject:[NSString stringWithFormat:@"%d",NAME_TAG] atIndex:0];
        [line1Array insertObject:LocaleStringForKey(NSNameTitle,nil) atIndex:1];
        [line1Array insertObject:[NSString stringWithFormat:@"%d",DEFINE_TYPE_TEXT] atIndex:2];
        [_DetailArray insertObject:line1Array atIndex:NAME_TAG];
        [line1Array release];
        
        // Gender
        NSMutableArray *line2Array = [[NSMutableArray alloc] init];
        [line2Array insertObject:[NSString stringWithFormat:@"%d",GENDER_TAG] atIndex:0];
        [line2Array insertObject:LocaleStringForKey(NSGenderTitle,nil) atIndex:1];
        [line2Array insertObject:[NSString stringWithFormat:@"%d",DEFINE_TYPE_DROPDOWN] atIndex:2];
        [_DetailArray insertObject:line2Array atIndex:GENDER_TAG];
        [line2Array release];
        
        // Nationality
        NSMutableArray *line3Array = [[NSMutableArray alloc] init];
        [line3Array insertObject:[NSString stringWithFormat:@"%d",COUNTRY_TAG] atIndex:0];
        [line3Array insertObject:LocaleStringForKey(NSCountryTitle,nil) atIndex:1];
        [line3Array insertObject:[NSString stringWithFormat:@"%d",DEFINE_TYPE_DROPDOWN] atIndex:2];
        [_DetailArray insertObject:line3Array atIndex:COUNTRY_TAG];
        [line3Array release];
        
        // Company
        NSMutableArray *line4Array = [[NSMutableArray alloc] init];
        [line4Array insertObject:[NSString stringWithFormat:@"%d",COMPANY_TAG] atIndex:0];
        [line4Array insertObject:LocaleStringForKey(NSCompanyTitle,nil) atIndex:1];
        [line4Array insertObject:[NSString stringWithFormat:@"%d",DEFINE_TYPE_TEXT] atIndex:2];
        [_DetailArray insertObject:line4Array atIndex:COMPANY_TAG];
        [line4Array release];
        
        // Company Address
        NSMutableArray *line5Array = [[NSMutableArray alloc] init];
        [line5Array insertObject:[NSString stringWithFormat:@"%d",ADDRESS_TAG] atIndex:0];
        [line5Array insertObject:LocaleStringForKey(NSCompanyAddressTitle,nil) atIndex:1];
        [line5Array insertObject:[NSString stringWithFormat:@"%d",DEFINE_TYPE_TEXT] atIndex:2];
        [_DetailArray insertObject:line5Array atIndex:ADDRESS_TAG];
        [line5Array release];
        
        // Industry
        NSMutableArray *line6Array = [[NSMutableArray alloc] init];
        [line6Array insertObject:@"6" atIndex:0];
        [line6Array insertObject:LocaleStringForKey(NSIndustryTitle,nil) atIndex:1];
        [line6Array insertObject:[NSString stringWithFormat:@"%d",DEFINE_TYPE_DROPDOWN] atIndex:2];
        [_DetailArray insertObject:line6Array atIndex:INDUSTRY_TAG];
        [line6Array release];
        
        _TableCellShowValArray = [[NSMutableArray alloc] init];
        _TableCellSaveValArray = [[NSMutableArray alloc] init];
        for (NSUInteger i=0; i<CELL_SIZE; i++) {
            [_TableCellShowValArray addObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]];
            [_TableCellSaveValArray addObject:[NSString stringWithFormat:@"%@",NULL_PARAM_VALUE]];
        }
        
        [super clearPickerSelIndex2Init:4];
        
        [self clearFliter];
    }
    
    return self;
}

- (void)dealloc
{
    RELEASE_OBJ(_DetailArray);
    RELEASE_OBJ(_TableCellSaveValArray);
    RELEASE_OBJ(_TableCellShowValArray);
    
    self.nameTextField = nil;
    self.companyTextField = nil;
    self.addressTextField = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - arrange view
- (void)adjustTableFrameForiOS7 {
    _tableView.frame = CGRectMake(_tableView.frame.origin.x,
                                  SYS_STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT,
                                  _tableView.frame.size.width,
                                  APP_WINDOW.frame.size.height - SYS_STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT);
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableView.backgroundColor = [UIColor whiteColor];
    
    //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (CURRENT_OS_VERSION >= IOS7) {
        _tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    }
    [self firstRefreshSession];
    
    [self addRightBarButtonWithTitle:LocaleStringForKey(NSQueryTitle,nil)
                              target:self
                              action:@selector(refreshSession:)];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return CELL_SIZE;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    UIView *mUIView = [[[UIView alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, FOOT_HEIGHT)] autorelease];
//    [mUIView setBackgroundColor:[UIColor redColor]];
    [mUIView setBackgroundColor:TRANSPARENT_COLOR];
    
    WXWLabel *noteLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(10, 120, 300, 30)
                                                 textColor:COLOR(153, 153, 153)
                                               shadowColor:TRANSPARENT_COLOR] autorelease];
    noteLabel.text = LocaleStringForKey(@"每日搜索次数不能多于20次", nil);
    noteLabel.font = FONT(14);
    noteLabel.textAlignment = NSTextAlignmentCenter;
    [mUIView addSubview:noteLabel];
    
    CGRect clearFrame = CGRectMake(50, 55, 95, 30);
    CGRect submitFrame = CGRectMake(SCREEN_WIDTH-95-50, 55, 95, 30);
    
    ECGradientButton *clearBut = [[[ECGradientButton alloc] initWithFrame:clearFrame
                                                                   target:self
                                                                   action:@selector(doClear:)
                                                                colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                                    title:LocaleStringForKey(NSBlankClearTitle, nil)
                                                                    image:nil
                                                               titleColor:BLUE_BTN_TITLE_SHADOW_COLOR
                                                         titleShadowColor:BLUE_BTN_TITLE_COLOR
                                                                titleFont:BOLD_FONT(14)
                                                              roundedType:HAS_ROUNDED
                                                          imageEdgeInsert:ZERO_EDGE
                                                          titleEdgeInsert:ZERO_EDGE] autorelease];
    clearBut.tag = 101;
    [mUIView addSubview:clearBut];
    
    ECGradientButton *submitBut = [[[ECGradientButton alloc] initWithFrame:submitFrame
                                                                    target:self
                                                                    action:@selector(refreshSession:)
                                                                 colorType:RED_BTN_COLOR_TY
                                                                     title:LocaleStringForKey(NSBlankQueryTitle, nil)
                                                                     image:nil
                                                                titleColor:BLUE_BTN_TITLE_COLOR
                                                          titleShadowColor:BLUE_BTN_TITLE_SHADOW_COLOR
                                                                 titleFont:BOLD_FONT(14)
                                                               roundedType:HAS_ROUNDED
                                                           imageEdgeInsert:ZERO_EDGE
                                                           titleEdgeInsert:ZERO_EDGE] autorelease];
    submitBut.tag = 102;
    [mUIView addSubview:submitBut];
    
    if (CURRENT_OS_VERSION >= IOS7) {
        CGRect signCodeFrame = CGRectMake(15, 1, self.view.frame.size.width - 15, 0.5f);
        UIView *codeLine = [[[UIView alloc] initWithFrame:signCodeFrame] autorelease];
        codeLine.backgroundColor = COLOR(200, 199, 204);
        [mUIView addSubview:codeLine];
    }
    
    return mUIView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return FOOT_HEIGHT;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    // Clear
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    [subviews release];
    
    // Customer
    int row = indexPath.row;
    UILabel *mLabelName = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_X, 12, 100, 30)];
    mLabelName.font = BOLD_FONT(FONT_SIZE);
    mLabelName.backgroundColor = TRANSPARENT_COLOR;
    mLabelName.textColor = [UIColor grayColor];
    UIView *tempView = [[[UIView alloc] init] autorelease];
    [cell setBackgroundView:tempView];
    [cell setBackgroundColor:TRANSPARENT_COLOR];
    NSString *msg = _DetailArray[row][1];
    msg = [msg stringByAppendingString:@" :"];
    mLabelName.text = msg;
    [cell.contentView addSubview:mLabelName];
    [mLabelName release];
    
    // Configure the cell...
    [self configureCell:row aCell:cell];
    
    return cell;
}

#pragma mark - Config Cell
-(void)configureCell:(int)row aCell:(UITableViewCell *)cell
{
    int type;
    type = [_DetailArray[row][2] intValue];
    UITapGestureRecognizer *singleTouch = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(textFieldClear)] autorelease];
    
    if (type == DEFINE_TYPE_DROPDOWN) {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UILabel *mLabelValue = [[[UILabel alloc] initWithFrame:CGRectMake(VALUE_X, 16, CONTENT_WIDTH, 25.f)] autorelease];
        mLabelValue.font = BOLD_FONT(14);
        mLabelValue.backgroundColor = TRANSPARENT_COLOR;
        mLabelValue.textColor = DARK_TEXT_COLOR;
        
        NSString* mName = _TableCellShowValArray[row];
        if ([mName isEqualToString:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]]) {
            mName = NULL_PARAM_VALUE;
        }else{
            int size = [self.DropDownValArray count];
            for (NSUInteger i=0; i<size; i++) {
                if ([(self.DropDownValArray)[i][RECORD_NAME_IDX] isEqualToString:mName]) {
                    mName = (self.DropDownValArray)[i][RECORD_NAME_IDX];
                    break;
                }
            }
        }
        
        mLabelValue.text = mName;
        
        [cell.contentView addSubview:mLabelValue];
        
    } else if (type == DEFINE_TYPE_TEXT) {
        if (row == NAME_TAG) {
            
            CGFloat y = 20;
            CGFloat cancelButtonY = 15;
            if (CURRENT_OS_VERSION >= IOS7) {
                y = 10;
                cancelButtonY = 18;
            }
            
            self.nameTextField = [[[UITextField alloc] initWithFrame:CGRectMake(VALUE_X, y, SCREEN_WIDTH-120, 40)] autorelease];
            self.nameTextField.tag = NAME_TAG;
            self.nameTextField.backgroundColor = TRANSPARENT_COLOR;
            self.nameTextField.adjustsFontSizeToFitWidth = YES;
            self.nameTextField.textColor = DARK_TEXT_COLOR;
            self.nameTextField.keyboardType = UIKeyboardTypeDefault;
            self.nameTextField.borderStyle = UITextBorderStyleNone;
            self.nameTextField.returnKeyType = UIReturnKeyDone;
            self.nameTextField.font = BOLD_FONT(14);
            self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.nameTextField.clearsOnBeginEditing = NO;
            self.nameTextField.textAlignment = UITextAlignmentLeft;
            self.nameTextField.delegate = self;
            //            self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
            [self.nameTextField addTarget:self
                                   action:@selector(hideKeyboard:)
                         forControlEvents:UIControlEventEditingDidEndOnExit];
            NSString* mName = _TableCellShowValArray[row];
            if ([mName isEqualToString:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]]) {
                mName = NULL_PARAM_VALUE;
            }
            self.nameTextField.text = mName;
            [self.nameTextField setEnabled:YES];
            self.nameCancel = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cancel.png"]] autorelease];
            nameCancel.frame = CGRectMake(SCREEN_WIDTH-30, cancelButtonY, 20, 20);
            nameCancel.hidden = YES;
            nameCancel.userInteractionEnabled=YES;
            [nameCancel addGestureRecognizer:singleTouch];
            //            [singleTouch release];
            
            [cell.contentView addSubview:self.nameCancel];
            [cell.contentView addSubview:self.nameTextField];
        } else if (row == COMPANY_TAG) {
            
            CGFloat y = 20;
            CGFloat cancelButtonY = 15;
            if (CURRENT_OS_VERSION >= IOS7) {
                y = 10;
                cancelButtonY = 18;
            }
            
            self.companyTextField = [[[UITextField alloc] initWithFrame:CGRectMake(VALUE_X, y, SCREEN_WIDTH-120, 40)] autorelease];
            self.companyTextField.tag = COMPANY_TAG;
            self.companyTextField.backgroundColor = TRANSPARENT_COLOR;
            self.companyTextField.adjustsFontSizeToFitWidth = YES;
            self.companyTextField.textColor = DARK_TEXT_COLOR;
            self.companyTextField.keyboardType = UIKeyboardTypeDefault;
            self.companyTextField.borderStyle = UITextBorderStyleNone;
            self.companyTextField.returnKeyType = UIReturnKeyDone;
            self.companyTextField.font = BOLD_FONT(14);
            self.companyTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.companyTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.companyTextField.clearsOnBeginEditing = NO;
            self.companyTextField.textAlignment = UITextAlignmentLeft;
            self.companyTextField.delegate = self;
            
            [self.companyTextField addTarget:self
                                      action:@selector(hideKeyboard:)
                            forControlEvents:UIControlEventEditingDidEndOnExit];
            NSString* mName = _TableCellShowValArray[row];
            if ([mName isEqualToString:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]]) {
                mName = NULL_PARAM_VALUE;
            }
            self.companyTextField.text = mName;
            [self.companyTextField setEnabled:YES];
            self.companyCancel = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cancel.png"]] autorelease];
            companyCancel.frame = CGRectMake(SCREEN_WIDTH-30, cancelButtonY, 20, 20);
            companyCancel.hidden = YES;
            companyCancel.userInteractionEnabled=YES;
            [companyCancel addGestureRecognizer:singleTouch];
            
            [cell.contentView addSubview:self.companyCancel];
            [cell.contentView addSubview:self.companyTextField];
            
        } else if (row == ADDRESS_TAG) {
            
            CGFloat y = 20;
            CGFloat cancelButtonY = 15;
            if (CURRENT_OS_VERSION >= IOS7) {
                y = 10;
                cancelButtonY = 18;
            }
            
            self.addressTextField = [[[UITextField alloc] initWithFrame:CGRectMake(VALUE_X, y, SCREEN_WIDTH-120, 40)] autorelease];
            self.addressTextField.tag = ADDRESS_TAG;
            self.addressTextField.backgroundColor = TRANSPARENT_COLOR;
            self.addressTextField.adjustsFontSizeToFitWidth = YES;
            self.addressTextField.textColor = DARK_TEXT_COLOR;
            self.addressTextField.keyboardType = UIKeyboardTypeDefault;
            self.addressTextField.borderStyle = UITextBorderStyleNone;
            self.addressTextField.returnKeyType = UIReturnKeyDone;
            self.addressTextField.font = BOLD_FONT(14);
            self.addressTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.addressTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.addressTextField.clearsOnBeginEditing = NO;
            self.addressTextField.textAlignment = UITextAlignmentLeft;
            self.addressTextField.delegate = self;
            
            [self.addressTextField addTarget:self
                                      action:@selector(hideKeyboard:)
                            forControlEvents:UIControlEventEditingDidEndOnExit];
            NSString* mName = _TableCellShowValArray[row];
            NSLog(@"%@",mName);
            if ([mName isEqualToString:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]]) {
                mName = NULL_PARAM_VALUE;
            }
            self.addressTextField.text = mName;
            [self.addressTextField setEnabled:YES];
            self.addressCancel = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cancel.png"]] autorelease];
            addressCancel.frame = CGRectMake(SCREEN_WIDTH-30, cancelButtonY, 20, 20);
            addressCancel.hidden = YES;
            addressCancel.userInteractionEnabled=YES;
            [addressCancel addGestureRecognizer:singleTouch];
            
            [cell.contentView addSubview:self.addressCancel];
            [cell.contentView addSubview:self.addressTextField];
        }
        
    }
    
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
    gesture.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    [cell.contentView addGestureRecognizer:gesture];
    [gesture release];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self onDropDown:indexPath.row];
}

#pragma mark - UIPickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (iTableSelectIndex == 0) {
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
    } else {
        pickSel0Index = row;
    }
    
    isPickSelChange = YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (iTableSelectIndex == 0) {
        return 2;
    }
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (iTableSelectIndex == 0) {
        if (component == PickerOne)
            return [[AppManager instance].supClassFilterList count];
        return [self.classFliters count];
    }
    return [_PickData count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (iTableSelectIndex == 0) {
        if (component == PickerOne)
            return ([AppManager instance].supClassFilterList)[row][1];
        return (self.classFliters)[row][1];
    }
    return _PickData[row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (iTableSelectIndex == 0) {
        CGFloat componentWidth = 0.0;
        if (component == 0) {
            componentWidth = 95.0f;
        } else {
            componentWidth = 205.0f;
        }
        return componentWidth;
    }
    return 300.0f;
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

- (void)setDropDownValueArray {
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    self.descriptors = [NSMutableArray array];
    self.DropDownValArray = [[[NSMutableArray alloc] init] autorelease];
    switch (iTableSelectIndex) {
        case CLASS_TAG:
        {
            iFliterIndex = 0;
            if ([AppManager instance].classFliterLoaded) {
                pickSel0Index = [super pickerList0Index];
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
                
                NSMutableArray *supClassesArray = [NSMutableArray arrayWithObjects:mClassGroup.enCourse, mClassGroup.cnCourse, nil];
                
                if (nil == mClassGroup || mClassGroup.isFault) {
                    continue;
                }
                
                NSMutableArray *detailArray = [NSMutableArray arrayWithObjects:mClassGroup.classId, mClassGroup.enName, mClassGroup.cnName, nil];
                
                if (![[AppManager instance].supClassFilterList containsObject:supClassesArray]) {
                    [[AppManager instance].supClassFilterList insertObject:supClassesArray atIndex:supIndex];
                    NSMutableArray *classesArray = [NSMutableArray array];
                    
                    if (detailArray.count > 0) {
                        [classesArray insertObject:detailArray atIndex:0];
                    }
                    
                    if (classesArray.count > 0) {
                        [[AppManager instance].classFilterList insertObject:classesArray atIndex:supIndex];
                    }
                    
                    supIndex++;
                } else {
                    int keyIndex = [[AppManager instance].supClassFilterList indexOfObject:supClassesArray];
                    NSMutableArray *classesArray = ([AppManager instance].classFilterList)[keyIndex];
                    
                    if (classesArray.count == 0) {
                        continue;
                    }
                    
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
            
        case GENDER_TAG:
        {
            iFliterIndex = 1;
            NSMutableArray *line0Array = [[NSMutableArray alloc] init];
            [line0Array insertObject:FEMALE atIndex:0];
            [line0Array insertObject:LocaleStringForKey(NSFemaleTitle, nil) atIndex:1];
            [self.DropDownValArray insertObject:line0Array atIndex:0];
            [line0Array release];
            
            NSMutableArray *line1Array = [[NSMutableArray alloc] init];
            [line1Array insertObject:MALE atIndex:0];
            [line1Array insertObject:LocaleStringForKey(NSMaleTitle, nil) atIndex:1];
            [self.DropDownValArray insertObject:line1Array atIndex:1];
            [line1Array release];
        }
            break;
            
        case COUNTRY_TAG:
        {
            iFliterIndex = 2;
            NSSortDescriptor *orderDesc = [[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease];
            [self.descriptors addObject:orderDesc];
            
            self.entityName = @"UserCountry";
            
            NSError *error = nil;
            BOOL res = [[super prepareFetchRC] performFetch:&error];
            if (!res) {
                NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
            }
            
            NSArray *countryDetail = [CommonUtils objectsInMOC:_MOC
                                                    entityName:self.entityName
                                                  sortDescKeys:self.descriptors
                                                     predicate:nil];
            
            int size = [countryDetail count];
            for (NSUInteger i=0; i<size; i++) {
                UserCountry* mCountry = (UserCountry*)countryDetail[i];
                NSMutableArray *mArray = [[NSMutableArray alloc] init];
                [mArray insertObject:mCountry.countryId atIndex:0];
                if ([WXWSystemInfoManager instance].currentLanguageCode == EN_TY) {
                    [mArray insertObject:mCountry.enName atIndex:1];
                }else{
                    [mArray insertObject:mCountry.cnName atIndex:1];
                }
                [self.DropDownValArray insertObject:mArray atIndex:i];
                [mArray release];
            }
        }
            break;
            
        case INDUSTRY_TAG:
        {
            iFliterIndex = 3;
            NSSortDescriptor *nameDesc = [[[NSSortDescriptor alloc] initWithKey:@"industryId" ascending:YES] autorelease];
            [self.descriptors addObject:nameDesc];
            
            self.entityName = @"Industry";
            
            NSError *error = nil;
            BOOL res = [[super prepareFetchRC] performFetch:&error];
            if (!res) {
                NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
            }
            
            NSArray *industryDetail = [CommonUtils objectsInMOC:_MOC
                                                     entityName:self.entityName
                                                   sortDescKeys:self.descriptors
                                                      predicate:nil];
            
            int size = [industryDetail count];
            for (NSUInteger i=0; i<size; i++) {
                Industry* mIndustry = (Industry*)industryDetail[i];
                NSMutableArray *mArray = [[NSMutableArray alloc] init];
                [mArray insertObject:mIndustry.industryId atIndex:0];
                if ([WXWSystemInfoManager instance].currentLanguageCode == EN_TY) {
                    [mArray insertObject:mIndustry.enName atIndex:1];
                }else{
                    [mArray insertObject:mIndustry.cnName atIndex:1];
                }                [self.DropDownValArray insertObject:mArray atIndex:i];
                [mArray release];
            }
            
        }
            break;
    }
}

#pragma mark - Clear View Status
-(void)clearViewStatus
{
    if (_textField != nil) {
        [_textField resignFirstResponder];
        int index = [_textField tag];
        NSString *resultVal = [_textField text];
        
        if (![_TableCellShowValArray[index] isEqualToString:resultVal]) {
            [self setTableCellVal:index aShowVal:resultVal aSaveVal:resultVal isFresh:NO];
        }
        _textField = nil;
    }
}

#pragma mark - Pop Interaction
-(void)onDropDown:(int)sender
{
    [self clearViewStatus];
    iTableSelectIndex = sender;
    
    if (sender == 1){
        [self.nameTextField becomeFirstResponder];
    }else if (sender == 4){
        [self.companyTextField becomeFirstResponder];
    }else if (sender == 5){
        [self.addressTextField becomeFirstResponder];
    }else{
        
        if (sender >2){
            
            CGRect viewFrame = _tableView.frame;
            viewFrame.origin.y -= 140;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
            
            [_tableView setFrame:viewFrame];
        }
        
        [UIView commitAnimations];
        [super setPopView];
        [self closeKeyBoard];
    }
}

-(void)onPopCancle:(id)sender {
    [super onPopCancle];
    
    [_TableCellShowValArray removeObjectAtIndex:iTableSelectIndex];
    [_TableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:iTableSelectIndex];
    
    [_TableCellSaveValArray removeObjectAtIndex:iTableSelectIndex];
    [_TableCellSaveValArray insertObject:NULL_PARAM_VALUE atIndex:iTableSelectIndex];
    
    if (iTableSelectIndex >2){
        
        CGRect viewFrame = _tableView.frame;
        viewFrame.origin.y += 140;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [_tableView setFrame:viewFrame];
    }
    
    [UIView commitAnimations];
}

-(void)onPopOk:(id)sender {
    
    [super onPopSelectedOk];
    int iPickSelectIndex = [super pickerList0Index];
    
    if ( iTableSelectIndex == 0 ) {
        [self setTableCellVal:iTableSelectIndex aShowVal:(self.classFliters)[pickSel1Index][RECORD_NAME_IDX]
                     aSaveVal:(self.classFliters)[pickSel1Index][RECORD_ID_IDX] isFresh:YES];
    } else {
        [self setTableCellVal:iTableSelectIndex aShowVal:(self.DropDownValArray)[iPickSelectIndex][RECORD_NAME_IDX]
                     aSaveVal:(self.DropDownValArray)[iPickSelectIndex][RECORD_ID_IDX] isFresh:YES];
    }
    
    if (iTableSelectIndex > 2){
        
        CGRect viewFrame = _tableView.frame;
        viewFrame.origin.y += 140;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [_tableView setFrame:viewFrame];
    }
    
    [UIView commitAnimations];
}

#pragma mark - Save TableCell Value
-(void)setTableCellVal:(int)index aShowVal:(NSString*)aShowVal aSaveVal:(NSString*)aSaveVal isFresh:(BOOL)isFresh
{
    [_TableCellShowValArray removeObjectAtIndex:index];
    [_TableCellShowValArray insertObject:aShowVal atIndex:index];
    
    [_TableCellSaveValArray removeObjectAtIndex:index];
    [_TableCellSaveValArray insertObject:aSaveVal atIndex:index];
    
    if (isFresh) {
        [_tableView reloadData];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self closeKeyBoard];
}

#pragma mark - action
-(void)doClear:(id)sender
{
    [self._TableCellShowValArray removeAllObjects];
    [self._TableCellSaveValArray removeAllObjects];
    for (NSUInteger i=0; i<CELL_SIZE; i++) {
        [self._TableCellShowValArray addObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]];
        [self._TableCellSaveValArray addObject:[NSString stringWithFormat:@"%@",NULL_PARAM_VALUE]];
    }
    [_tableView reloadData];
    _textField = nil;
}

-(void)textFieldClear
{
    if (iTableSelectIndex == 1)
        nameTextField.text =NULL_PARAM_VALUE;
    else if (iTableSelectIndex == 4)
        companyTextField.text = NULL_PARAM_VALUE;
    else if (iTableSelectIndex == 5)
        addressTextField.text = NULL_PARAM_VALUE;
}

-(BOOL)checkVal
{
    int size = [_TableCellShowValArray count];
    for (NSUInteger i=0; i<size; i++) {
        if (![_TableCellShowValArray[i] isEqualToString:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal]]) {
            return YES;
        }
    }
    return NO;
}

-(void)doQuery:(UIButton*)sender
{
    [self closeKeyBoard];
    [CommonUtils doDelete:_MOC entityName:@"Alumni"];
    
    NSString *param = [NSString stringWithFormat:
                       @"<classId>%@</classId><name>%@</name><gender>%@</gender><nationality>%@</nationality><company>%@</company><companyLocation>%@</companyLocation><industry>%@</industry><page>0</page><grade></grade><course></course>",
                       _TableCellSaveValArray[CLASS_TAG],
                       self.nameTextField.text,
                       _TableCellSaveValArray[GENDER_TAG],
                       _TableCellSaveValArray[COUNTRY_TAG],
                       self.companyTextField.text,
                       self.addressTextField.text,
                       _TableCellSaveValArray[INDUSTRY_TAG]];
    
    UserListViewController *userListVC = [[UserListViewController alloc] initWithType:ALUMNI_TY needGoToHome:YES MOC:_MOC group:nil needAdjustForiOS7:NO];
    userListVC.pageIndex = 0;
    userListVC.requestParam = param;
    userListVC.title = LocaleStringForKey(NSAlumniTitle, nil);
    [self.navigationController pushViewController:userListVC animated:YES];
    RELEASE_OBJ(userListVC);
}

#pragma mark - UIText Interaction
- (void)hideKeyboard:(id)sender {
    _textField = (UITextField *)sender;
    [_textField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_textField != nil) {
        int index = [_textField tag];
        NSString *resultVal = [_textField text];
        
        if (![_TableCellShowValArray[index] isEqualToString:resultVal]) {
            [self setTableCellVal:index aShowVal:resultVal aSaveVal:resultVal isFresh:NO];
        }
        _textField = nil;
    }
    
    _textField = textField;
    iTableSelectIndex = [textField tag];
    
    if (iTableSelectIndex != 1) {
        CGFloat heightFraction = 0.50f;
        
        _animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
        
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y -= _animatedDistance+80;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        
        [UIView commitAnimations];
    }
    if (iTableSelectIndex == 1)
        self.nameCancel.hidden = NO;
    else if (iTableSelectIndex == 4)
        self.companyCancel.hidden = NO;
    else if (iTableSelectIndex == 5)
        self.addressCancel.hidden = NO;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    int index = [textField tag];
    NSString *resultVal = [textField text];
    
    if (![_TableCellShowValArray[index] isEqualToString:resultVal]) {
        [self setTableCellVal:index aShowVal:resultVal aSaveVal:resultVal isFresh:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    nameCancel.hidden = YES;
    companyCancel.hidden = YES;
    addressCancel.hidden = YES;
    
    if (iTableSelectIndex != 1) {
        
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y += _animatedDistance+80;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
        
    }
}

#pragma mark - close key board
- (void)closeKeyBoard {
    
    [self.nameTextField resignFirstResponder];
    [self.companyTextField resignFirstResponder];
    [self.addressTextField resignFirstResponder];
    
}

#pragma mark - Base Data
- (void) getAlumniClass {
    
    NSString *url = ALUMNI_CLASS_REQ_URL;
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:CLASS_TY] autorelease];
    // [self.connDic setObject:connFacade forKey:url];
    [connFacade fetchGets:url];
}

- (void) getAlumniNationality {
    
    NSString *url = ALUMNI_NATION_REQ_URL;
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:COUNTRY_TY] autorelease];
    // [self.connDic setObject:connFacade forKey:url];
    [connFacade fetchGets:url];
}

- (void) getIndustry {
    NSString *url = ALUMNI_INDUSTRY_REQ_URL;
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:INDUSTRY_TY] autorelease];
    // [self.connDic setObject:connFacade forKey:url];
    [connFacade fetchGets:url];
}

- (void)loadAlumniInfoIfNeeded {
    
    if (![AppManager instance].isLoadClassDataOK) {
        [self getAlumniClass];
    } else if (![AppManager instance].isLoadCountryDataOK) {
        [self getAlumniNationality];
    } else if (![AppManager instance].isLoadIndustryDataOK) {
        [self getIndustry];
    }
}

- (void)refreshSession:(id)sender {
    NSString *url = STR_FORMAT(@"%@%@&username=%@&password=%@&locale=%@", [AppManager instance].hostUrl, REFRESH_SESSION_REQ_URL, [[AppManager instance] getUserIdFromLocal], [[AppManager instance] getPasswordFromLocal], [AppManager instance].currentLanguageDesc);
    
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                    interactionContentType:REFRESH_SESSION_TY] autorelease];
    [connFacade fetchGets:url];
}

- (void)firstRefreshSession {
    _firstSessionRefresh = YES;
    
    [self refreshSession:nil];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
    [UIUtils showActivityView:self.view text:LocaleStringForKey(NSLoadingTitle, nil)];
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
    [UIUtils closeActivityView];
    
    switch (contentType) {
            
        case REFRESH_SESSION_TY:
        {
            [XMLParser parserResponseXml:result
                                    type:contentType
                                     MOC:self.MOC
                       connectorDelegate:self
                                     url:url];
            
            if (_firstSessionRefresh) {
                [self loadAlumniInfoIfNeeded];
                
                _firstSessionRefresh = NO;
            } else {
                
                [self doQuery:nil];
            }
            
            break;
        }
            
        case CLASS_TY:
        {
            if([XMLParser parserResponseXml:result
                                       type:contentType
                                        MOC:_MOC
                          connectorDelegate:self
                                        url:url]) {
                [self getAlumniNationality];
            } else {
                [UIUtils showNotificationOnTopWithMsg:@"Failed Msg"
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
            }
        }
            break;
            
        case COUNTRY_TY:
        {
            if([XMLParser parserResponseXml:result
                                       type:contentType
                                        MOC:_MOC
                          connectorDelegate:self
                                        url:url]) {
                [self getIndustry];
            } else {
                [UIUtils showNotificationOnTopWithMsg:@"Failed Msg"
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
        }
            break;
            
        case INDUSTRY_TY:
        {
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
            break;
            
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
    
    if (contentType == REFRESH_SESSION_TY) {
        if (_firstSessionRefresh) {
            [self loadAlumniInfoIfNeeded];
            
            _firstSessionRefresh = NO;
        }
    }
    
    [UIUtils closeActivityView];
    
    [super connectFailed:error url:url contentType:contentType];
}
@end
