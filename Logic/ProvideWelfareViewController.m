//
//  ProvideWelfareViewController.m
//  iAlumni
//
//  Created by Adam on 13-8-14.
//
//

#import "ProvideWelfareViewController.h"
#import "ECAsyncConnectorFacade.h"
#import "WXWLabel.h"
#import "UIImageButton.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "CommonUtils.h"

#define FOOT_HEIGHT         50.0f
#define FIELD_CELL_H        47.f
#define TEXT_VIEW_CELL_H    110.f

#define CELL_IMG_W          288.f
#define LABEL_W             90.f
#define LABEL_Y             14.f
#define CONTENT_OFFSET_Y    23.f
#define CONTENT_VIEW_W      244.f
#define CONTENT_VIEW_H      60.f
#define CONTENT_Y           11.f
#define CONTENT_W           148.f
#define CONTENT_H           28.f
#define FONT_SIZE           15.0f
#define VIEW_W              243.f

@interface ProvideWelfareViewController () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate>
{
  int inputSize;
  CGFloat _animatedDistance;
  CGSize noteSize;
}

@property (nonatomic, retain) NSArray *contractLabelArray;
@property (nonatomic, retain) NSMutableArray *contractValueArray;

@property (nonatomic, retain) UITextField *nameTextField;
@property (nonatomic, retain) UITextField *mobileTextField;
@property (nonatomic, retain) UITextField *emailTextField;
@property (nonatomic, retain) UITextField *weixinTextField;
@property (nonatomic, retain) UITextField *brandTextField;

@property (nonatomic, retain) UITextView *companyDescTextView;
@property (nonatomic, retain) UITextView *companyScaleTextView;
@property (nonatomic, retain) UITextView *welfareDescTextView;

@end

@implementation ProvideWelfareViewController

- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
  self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needGoHome:NO];
  
  if (self) {

    if (CURRENT_OS_VERSION >= IOS7) {
      _labelX = 35.0f;
      _fieldX = 127.f;
      _startX = 24.0f;
    } else {
      _labelX = 25.0f;
      _fieldX = 117.f;
      _startX = 14.0f;
    }

  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_headerView);
  
  [super dealloc];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  [self loadViewDetail];
  [self initTableView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - load detail
- (void)loadViewDetail {
  
  // Cell Array
  self.contractLabelArray = [[[NSArray alloc] initWithObjects:
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSProvideName, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSProvideTel, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSProvideMail, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSProvideWeixin, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSProvideBrand, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSProvideCompanyDesc, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSProvideCompanyScale, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSProvideWelfareDesc, nil)],nil] autorelease];
  
  int size = [self.contractLabelArray count];
  self.contractValueArray = [NSMutableArray array];
  for (int i=0; i<size; i++) {
    [self.contractValueArray insertObject:NULL_PARAM_VALUE atIndex:i];
  }
  
  noteSize = [LocaleStringForKey(NSProvideBenefitNoteTitle, nil) sizeWithFont:BOLD_FONT(15)
                                                            constrainedToSize:CGSizeMake(286, CGFLOAT_MAX)
                                                                lineBreakMode:NSLineBreakByWordWrapping];
}

- (void)initTableView {
  if (self.tableView == nil) {
    
    CGFloat y = 0;
    if (CURRENT_OS_VERSION >= IOS7) {
      y = SYS_STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT;
    }
    CGRect mTabFrame = CGRectMake(0, y, SCREEN_WIDTH, self.view.frame.size.height - y);
    self.tableView = [[[UITableView alloc] initWithFrame:mTabFrame
                                                   style:UITableViewStyleGrouped] autorelease];
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = TRANSPARENT_COLOR;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    
  }
  
	[self.view addSubview:_tableView];
  [super initTableView];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section) {
    case 0:
      return 4;
      break;
      
    case 1:
      return 4;
      break;
      
    default:
      break;
  }
  
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  switch (section) {
    case 0:
    {
      return noteSize.height + 20;
    }
      break;
      
    case 1:
    {
      return 5;
    }
      break;
      
    default:
      break;
  }
  
  return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  int row = [indexPath row];
  switch ([indexPath section]) {
    case 0:
    {
      return FIELD_CELL_H;
    }
      break;
      
    case 1:
    {
      if (row == 0) {
        return FIELD_CELL_H;
      } else {
        return TEXT_VIEW_CELL_H;
      }
    }
      break;
      
    default:
      break;
  }
  
  return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  switch (section) {
    case 0:
    {
      if (nil == _headerView) {
        
        // group Name
        WXWLabel *orderTitle = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                      textColor:COLOR(86, 86, 86)
                                                    shadowColor:TRANSPARENT_COLOR] autorelease];
        orderTitle.font = BOLD_FONT(15);
        orderTitle.numberOfLines = 0;
        orderTitle.text = LocaleStringForKey(NSProvideBenefitNoteTitle, nil);
        
        orderTitle.frame = CGRectMake(16, 11,
                                      noteSize.width, noteSize.height);
        
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, noteSize.height)];
        [_headerView addSubview:orderTitle];
        
      }
      
      return _headerView;
    }
      break;
  }
  
  return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
  if (section == 1) {
    UIView *mUIView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FOOT_HEIGHT)] autorelease];
    [mUIView setBackgroundColor:TRANSPARENT_COLOR];
    
    CGRect submitOrderFrame = CGRectMake(15, 15, 285, 48);
    
    // submit order
    UIImageButton *submitOrderButton = [[[UIImageButton alloc]
                                         initImageButtonWithFrame:submitOrderFrame
                                         target:self
                                         action:@selector(submitOrder:)
                                         title:LocaleStringForKey(NSSubmitButTitle, nil)
                                         image:nil
                                         backImgName:@"joinGroupLongBut.png"
                                         selBackImgName:@"joinGroupLongButSel.png"
                                         titleFont:BOLD_FONT(15)
                                         titleColor:[UIColor whiteColor]
                                         titleShadowColor:TRANSPARENT_COLOR
                                         roundedType:HAS_ROUNDED
                                         imageEdgeInsert:ZERO_EDGE
                                         titleEdgeInsert:ZERO_EDGE] autorelease];
    
    [mUIView addSubview:submitOrderButton];
    
    return mUIView;
  }
  
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
  if (section == 1) {
    return FOOT_HEIGHT + 20;
  }
  return 0.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"OrderCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
  for (UIView *subview in subviews) {
    [subview removeFromSuperview];
  }
  [subviews release];
  
  // Configure the cell...
  [self configureCell:indexPath aCell:cell];
  
  return cell;
}

- (void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell
{
  int row = [indexPath row];
  [cell setBackgroundColor:[UIColor whiteColor]];
  [cell setBackgroundColor:TRANSPARENT_COLOR];
  
  switch ([indexPath section]) {
    case 0:
    {
      int cellHeight = FIELD_CELL_H;
      UIImage *cellBGImage = [UIImage imageNamed:@"provideWelfareCellTop.png"];
      if (row > 2){
        cellBGImage = [UIImage imageNamed:@"provideWelfareCellBottom.png"];
      } else if (row > 0) {
        cellBGImage = [UIImage imageNamed:@"provideWelfareCellMiddle.png"];
      }
      
      CGFloat imageX = 0;
      if (CURRENT_OS_VERSION >= IOS7) {
        imageX = MARGIN * 3;
      } else {
        imageX = 5.0f;
      }
      
      UIImageView *cellImageView = [[[UIImageView alloc] initWithImage:cellBGImage] autorelease];
      cellImageView.frame = CGRectMake(imageX, 0, CELL_IMG_W, cellHeight);
      
      [cell.contentView addSubview:cellImageView];
      
      // * Label
      UILabel *markLable = [[UILabel alloc] init];
      markLable.text = @"*";
      markLable.font = BOLD_FONT(FONT_SIZE);
      CGSize markSize = [markLable.text sizeWithFont:markLable.font];
      
      markLable.frame = CGRectMake(_startX, LABEL_Y+3, 20.f, markSize.height);
      markLable.textColor = COLOR(255, 8, 8);
      [markLable setBackgroundColor:TRANSPARENT_COLOR];
      markLable.tag = row + 10;
      [cell.contentView addSubview:markLable];
      [markLable release];
      
      // Label
      NSString *mText = self.contractLabelArray[row];
      UILabel *mUILable = [[UILabel alloc] init];
      mUILable.text = mText;
      mUILable.font = BOLD_FONT(FONT_SIZE);
      CGSize mDescSize = [mUILable.text sizeWithFont:mUILable.font];
      mUILable.frame = CGRectMake(_labelX, LABEL_Y, LABEL_W, mDescSize.height);
      mUILable.textColor = COLOR(82, 82, 82);
      [mUILable setBackgroundColor:TRANSPARENT_COLOR];
      mUILable.tag = row + 40;
      [cell.contentView addSubview:mUILable];
      [mUILable release];
      
      // contact Msg
      NSString *contactMsg = self.contractValueArray[row];
      switch (row) {
        case 0:
        {
          self.nameTextField = [[[UITextField alloc] initWithFrame:CGRectMake(_fieldX, CONTENT_Y, CONTENT_W, CONTENT_H)] autorelease];
          self.nameTextField.tag = row;
          self.nameTextField.backgroundColor = COLOR(247, 247, 247);
          self.nameTextField.adjustsFontSizeToFitWidth = YES;
          self.nameTextField.textColor = COLOR(113, 113, 113);
          self.nameTextField.keyboardType = UIKeyboardTypeDefault;
          self.nameTextField.borderStyle = UITextBorderStyleLine;
          self.nameTextField.returnKeyType = UIReturnKeyDone;
          self.nameTextField.font = FONT(FONT_SIZE);
          self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
          self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
          self.nameTextField.clearsOnBeginEditing = NO;
          self.nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
          self.nameTextField.textAlignment = UITextAlignmentLeft;
          self.nameTextField.delegate = self;
          [self.nameTextField addTarget:self
                                 action:@selector(hideKeyboard:)
                       forControlEvents:UIControlEventEditingDidEndOnExit];
          self.nameTextField.text = contactMsg;
          [self.nameTextField setEnabled:YES];
          
          // board
          self.nameTextField.layer.backgroundColor = [[UIColor clearColor] CGColor];
          self.nameTextField.layer.borderColor = COLOR(212, 212, 212).CGColor;
          self.nameTextField.layer.borderWidth = 1.0;
          self.nameTextField.layer.cornerRadius = 3.f;
          [self.nameTextField.layer setMasksToBounds:YES];
          [cell.contentView addSubview:self.nameTextField];
        }
          break;
          
        case 1:
        {
          self.mobileTextField = [[[UITextField alloc] initWithFrame:CGRectMake(_fieldX, CONTENT_Y, CONTENT_W, CONTENT_H)] autorelease];
          self.mobileTextField.tag = row;
          self.mobileTextField.backgroundColor = COLOR(247, 247, 247);
          self.mobileTextField.adjustsFontSizeToFitWidth = YES;
          self.mobileTextField.textColor = COLOR(113, 113, 113);
          self.mobileTextField.keyboardType = UIKeyboardTypeDefault;
          self.mobileTextField.borderStyle = UITextBorderStyleLine;
          self.mobileTextField.returnKeyType = UIReturnKeyDone;
          self.mobileTextField.font = FONT(FONT_SIZE);
          self.mobileTextField.autocorrectionType = UITextAutocorrectionTypeNo;
          self.mobileTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
          self.mobileTextField.clearsOnBeginEditing = NO;
          self.mobileTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
          self.mobileTextField.textAlignment = UITextAlignmentLeft;
          self.mobileTextField.delegate = self;
          [self.mobileTextField addTarget:self
                                   action:@selector(hideKeyboard:)
                         forControlEvents:UIControlEventEditingDidEndOnExit];
          self.mobileTextField.text = contactMsg;
          [self.mobileTextField setEnabled:YES];
          
          // board
          self.mobileTextField.layer.backgroundColor = [[UIColor clearColor] CGColor];
          self.mobileTextField.layer.borderColor = COLOR(212, 212, 212).CGColor;
          self.mobileTextField.layer.borderWidth = 1.0;
          self.mobileTextField.layer.cornerRadius = 3.f;
          [self.mobileTextField.layer setMasksToBounds:YES];
          [cell.contentView addSubview:self.mobileTextField];
          
        }
          break;
          
        case 2:
        {
          markLable.hidden = YES;
          
          self.emailTextField = [[[UITextField alloc] initWithFrame:CGRectMake(_fieldX, CONTENT_Y, CONTENT_W, CONTENT_H)] autorelease];
          self.emailTextField.tag = row;
          self.emailTextField.backgroundColor = COLOR(247, 247, 247);
          self.emailTextField.adjustsFontSizeToFitWidth = YES;
          self.emailTextField.textColor = COLOR(113, 113, 113);
          self.emailTextField.keyboardType = UIKeyboardTypeDefault;
          self.emailTextField.borderStyle = UITextBorderStyleLine;
          self.emailTextField.returnKeyType = UIReturnKeyDone;
          self.emailTextField.font = FONT(FONT_SIZE);
          self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
          self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
          self.emailTextField.clearsOnBeginEditing = NO;
          self.emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
          self.emailTextField.textAlignment = UITextAlignmentLeft;
          self.emailTextField.delegate = self;
          [self.emailTextField addTarget:self
                                  action:@selector(hideKeyboard:)
                        forControlEvents:UIControlEventEditingDidEndOnExit];
          self.emailTextField.text = contactMsg;
          [self.emailTextField setEnabled:YES];
          
          // board
          self.emailTextField.layer.backgroundColor = [[UIColor clearColor] CGColor];
          self.emailTextField.layer.borderColor = COLOR(212, 212, 212).CGColor;
          self.emailTextField.layer.borderWidth = 1.0;
          self.emailTextField.layer.cornerRadius = 3.f;
          [self.emailTextField.layer setMasksToBounds:YES];
          
          [cell.contentView addSubview:self.emailTextField];
        }
          break;
          
        case 3:
        {
          markLable.hidden = YES;
          self.weixinTextField = [[[UITextField alloc] initWithFrame:CGRectMake(_fieldX, CONTENT_Y, CONTENT_W, CONTENT_H)] autorelease];
          self.weixinTextField.tag = row;
          self.weixinTextField.backgroundColor = COLOR(247, 247, 247);
          self.weixinTextField.adjustsFontSizeToFitWidth = YES;
          self.weixinTextField.textColor = COLOR(113, 113, 113);
          self.weixinTextField.keyboardType = UIKeyboardTypeDefault;
          self.weixinTextField.borderStyle = UITextBorderStyleLine;
          self.weixinTextField.returnKeyType = UIReturnKeyDone;
          self.weixinTextField.font = FONT(FONT_SIZE);
          self.weixinTextField.autocorrectionType = UITextAutocorrectionTypeNo;
          self.weixinTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
          self.weixinTextField.clearsOnBeginEditing = NO;
          self.weixinTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
          self.weixinTextField.textAlignment = UITextAlignmentLeft;
          self.weixinTextField.delegate = self;
          [self.weixinTextField addTarget:self
                                   action:@selector(hideKeyboard:)
                         forControlEvents:UIControlEventEditingDidEndOnExit];
          self.weixinTextField.text = contactMsg;
          [self.weixinTextField setEnabled:YES];
          
          // board
          self.weixinTextField.layer.backgroundColor = [[UIColor clearColor] CGColor];
          self.weixinTextField.layer.borderColor = COLOR(212, 212, 212).CGColor;
          self.weixinTextField.layer.borderWidth = 1.0;
          self.weixinTextField.layer.cornerRadius = 3.f;
          [self.weixinTextField.layer setMasksToBounds:YES];
          
          [cell.contentView addSubview:self.weixinTextField];
        }
          break;
          
        default:
          break;
      }
    }
      break;
      
    case 1:
    {
      int cellHeight = FIELD_CELL_H;
      UIImage *cellBGImage = [UIImage imageNamed:@"provideWelfareTop.png"];
      if (row > 2){
        cellBGImage = [UIImage imageNamed:@"provideWelfareBottom.png"];
        cellHeight = TEXT_VIEW_CELL_H;
      } else if(row > 0){
        cellBGImage = [UIImage imageNamed:@"provideWelfareMiddle.png"];
        cellHeight = TEXT_VIEW_CELL_H;
      }
      
      CGFloat x = 0;
      if (CURRENT_OS_VERSION >= IOS7) {
        x = MARGIN * 3;
      } else {
        x = MARGIN;
      }
      UIImageView *cellImageView = [[[UIImageView alloc] initWithImage:cellBGImage] autorelease];
      cellImageView.frame = CGRectMake(x, 0, CELL_IMG_W, cellHeight);
      
      [cell.contentView addSubview:cellImageView];
      
      // * Label
      UILabel *markLable = [[[UILabel alloc] init] autorelease];
      markLable.text = @"*";
      markLable.font = BOLD_FONT(FONT_SIZE);
      CGSize markSize = [markLable.text sizeWithFont:markLable.font];
      markLable.frame = CGRectMake(_startX, LABEL_Y+3, 20.f, markSize.height);
      markLable.textColor = COLOR(255, 8, 8);
      [markLable setBackgroundColor:TRANSPARENT_COLOR];
      markLable.tag = row + 30;
      [cell.contentView addSubview:markLable];
      
      // Label
      NSString *mText = self.contractLabelArray[row+4];
      UILabel *mUILable = [[UILabel alloc] init];
      mUILable.text = mText;
      mUILable.font = BOLD_FONT(FONT_SIZE);
      CGSize mDescSize = [mUILable.text sizeWithFont:mUILable.font];
      if (row > 0) {
        mUILable.frame = CGRectMake(_labelX, LABEL_Y, VIEW_W, mDescSize.height);
      } else {
        mUILable.frame = CGRectMake(_labelX, LABEL_Y, LABEL_W, mDescSize.height);
      }
      mUILable.textColor = COLOR(82, 82, 82);
      [mUILable setBackgroundColor:TRANSPARENT_COLOR];
      mUILable.tag = row + 50;
      [cell.contentView addSubview:mUILable];
      [mUILable release];
      
      // contact Msg
      NSString *contactMsg = self.contractValueArray[row];
      switch (row) {
        case 0:
        {
          self.brandTextField = [[[UITextField alloc] initWithFrame:CGRectMake(_fieldX, CONTENT_Y, CONTENT_W, CONTENT_H)] autorelease];
          self.brandTextField.tag = row;
          self.brandTextField.backgroundColor = COLOR(247, 247, 247);
          self.brandTextField.adjustsFontSizeToFitWidth = YES;
          self.brandTextField.textColor = COLOR(113, 113, 113);
          self.brandTextField.keyboardType = UIKeyboardTypeDefault;
          self.brandTextField.borderStyle = UITextBorderStyleLine;
          self.brandTextField.returnKeyType = UIReturnKeyDone;
          self.brandTextField.font = FONT(FONT_SIZE);
          self.brandTextField.autocorrectionType = UITextAutocorrectionTypeNo;
          self.brandTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
          self.brandTextField.clearsOnBeginEditing = NO;
          self.brandTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
          self.brandTextField.textAlignment = UITextAlignmentLeft;
          self.brandTextField.delegate = self;
          [self.brandTextField addTarget:self
                                  action:@selector(hideKeyboard:)
                        forControlEvents:UIControlEventEditingDidEndOnExit];
          self.brandTextField.text = contactMsg;
          [self.brandTextField setEnabled:YES];
          
          // board
          self.brandTextField.layer.backgroundColor = [[UIColor clearColor] CGColor];
          self.brandTextField.layer.borderColor = COLOR(212, 212, 212).CGColor;
          self.brandTextField.layer.borderWidth = 1.0;
          self.brandTextField.layer.cornerRadius = 3.f;
          [self.brandTextField.layer setMasksToBounds:YES];
          [cell.contentView addSubview:self.brandTextField];
        }
          break;
          
        case 1:
        {
          CGRect textFrame = CGRectMake(_labelX, LABEL_Y+CONTENT_OFFSET_Y, CONTENT_VIEW_W, CONTENT_VIEW_H);
          self.companyDescTextView = [[[UITextView alloc] initWithFrame:textFrame] autorelease];
          self.companyDescTextView.tag = row;
          self.companyDescTextView.textColor = COLOR(113, 113, 113);
          self.companyDescTextView.font = FONT(FONT_SIZE);
          self.companyDescTextView.delegate = self;
          self.companyDescTextView.text = LocaleStringForKey(NSOrderDescPromptTitle, nil);
          self.companyDescTextView.returnKeyType = UIReturnKeyDefault;
          self.companyDescTextView.keyboardType = UIKeyboardTypeDefault;
          // use the default type input method (entire keyboard)
          self.companyDescTextView.scrollEnabled = YES;
          // this will cause automatic vertical resize when the table is resized
          //        self.descTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
          // note: for UITextView, if you don't like autocompletion while typing use:
          self.companyDescTextView.autocorrectionType = UITextAutocorrectionTypeNo;
          
          // board
          self.companyDescTextView.layer.backgroundColor = [[UIColor clearColor] CGColor];
          self.companyDescTextView.layer.borderColor = COLOR(212, 212, 212).CGColor;
          self.companyDescTextView.layer.borderWidth = 1.0;
          self.companyDescTextView.layer.cornerRadius = 3.f;
          [self.companyDescTextView.layer setMasksToBounds:YES];
          self.companyDescTextView.backgroundColor = COLOR(247, 247, 247);
          
          // keyboard view add Done Button
          UIToolbar * topView = [[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
          
          [topView setBarStyle:UIBarStyleBlack];
          
          UIBarButtonItem * helloButton = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:LocaleStringForKey(NSKeyboardTitle, nil), inputSize] style:UIBarButtonItemStylePlain target:self action:nil];
          
          UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
          
          UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard:)];
          
          NSArray * buttonsArray = @[helloButton,btnSpace,doneButton];
          
          [doneButton release];
          [btnSpace release];
          [helloButton release];
          [topView setItems:buttonsArray];
          
          [self.companyDescTextView setInputAccessoryView:topView];
          [cell.contentView addSubview:self.companyDescTextView];
        }
          break;
          
        case 2:
        {
          CGRect textFrame = CGRectMake(_labelX, LABEL_Y+CONTENT_OFFSET_Y, CONTENT_VIEW_W, CONTENT_VIEW_H);
          self.companyScaleTextView = [[[UITextView alloc] initWithFrame:textFrame] autorelease];
          self.companyScaleTextView.tag = row;
          self.companyScaleTextView.textColor = COLOR(113, 113, 113);
          self.companyScaleTextView.font = FONT(FONT_SIZE);
          self.companyScaleTextView.delegate = self;
          self.companyScaleTextView.text = LocaleStringForKey(NSOrderDescPromptTitle, nil);
          self.companyScaleTextView.returnKeyType = UIReturnKeyDefault;
          self.companyScaleTextView.keyboardType = UIKeyboardTypeDefault;
          // use the default type input method (entire keyboard)
          self.companyScaleTextView.scrollEnabled = YES;
          // this will cause automatic vertical resize when the table is resized
          //        self.descTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
          // note: for UITextView, if you don't like autocompletion while typing use:
          self.companyScaleTextView.autocorrectionType = UITextAutocorrectionTypeNo;
          
          // board
          self.companyScaleTextView.layer.backgroundColor = [[UIColor clearColor] CGColor];
          self.companyScaleTextView.layer.borderColor = COLOR(212, 212, 212).CGColor;
          self.companyScaleTextView.layer.borderWidth = 1.0;
          self.companyScaleTextView.layer.cornerRadius = 3.f;
          [self.companyScaleTextView.layer setMasksToBounds:YES];
          self.companyScaleTextView.backgroundColor = COLOR(247, 247, 247);
          
          // keyboard view add Done Button
          UIToolbar * topView = [[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
          
          [topView setBarStyle:UIBarStyleBlack];
          
          UIBarButtonItem * helloButton = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:LocaleStringForKey(NSKeyboardTitle, nil), inputSize] style:UIBarButtonItemStylePlain target:self action:nil];
          
          UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
          
          UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard:)];
          
          NSArray * buttonsArray = @[helloButton,btnSpace,doneButton];
          
          [doneButton release];
          [btnSpace release];
          [helloButton release];
          [topView setItems:buttonsArray];
          
          [self.companyScaleTextView setInputAccessoryView:topView];
          [cell.contentView addSubview:self.companyScaleTextView];
          
        }
          break;
          
        case 3:
        {
          CGRect textFrame = CGRectMake(_labelX, LABEL_Y+CONTENT_OFFSET_Y, CONTENT_VIEW_W, CONTENT_VIEW_H);
          self.welfareDescTextView = [[[UITextView alloc] initWithFrame:textFrame] autorelease];
          self.welfareDescTextView.tag = row;
          self.welfareDescTextView.textColor = COLOR(113, 113, 113);
          self.welfareDescTextView.font = FONT(FONT_SIZE);
          self.welfareDescTextView.delegate = self;
          self.welfareDescTextView.text = LocaleStringForKey(NSOrderDescPromptTitle, nil);
          self.welfareDescTextView.returnKeyType = UIReturnKeyDefault;
          self.welfareDescTextView.keyboardType = UIKeyboardTypeDefault;
          self.welfareDescTextView.scrollEnabled = YES;
          self.welfareDescTextView.autocorrectionType = UITextAutocorrectionTypeNo;
          
          // board
          self.welfareDescTextView.layer.backgroundColor = [[UIColor clearColor] CGColor];
          self.welfareDescTextView.layer.borderColor = COLOR(212, 212, 212).CGColor;
          self.welfareDescTextView.layer.borderWidth = 1.0;
          self.welfareDescTextView.layer.cornerRadius = 3.f;
          [self.welfareDescTextView.layer setMasksToBounds:YES];
          self.welfareDescTextView.backgroundColor = COLOR(247, 247, 247);
          
          // keyboard view add Done Button
          UIToolbar * topView = [[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
          
          [topView setBarStyle:UIBarStyleBlack];
          
          UIBarButtonItem * helloButton = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:LocaleStringForKey(NSKeyboardTitle, nil), inputSize] style:UIBarButtonItemStylePlain target:self action:nil];
          
          UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
          
          UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard:)];
          
          NSArray * buttonsArray = @[helloButton,btnSpace,doneButton];
          
          [doneButton release];
          [btnSpace release];
          [helloButton release];
          [topView setItems:buttonsArray];
          
          [self.welfareDescTextView setInputAccessoryView:topView];
          [cell.contentView addSubview:self.welfareDescTextView];
        }
          break;
          
        default:
          break;
      }
    }
      break;
      
    default:
      break;
  }
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - UIText Interaction
- (void)hideKeyboard:(id)sender {
  UITextField *textField = (UITextField *)sender;
  [textField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
  
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  NSLog(@"textFieldShouldReturn");
  [textField resignFirstResponder];
  
  return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
  if (textField.text.length > 0) {
    [self.contractValueArray insertObject:textField.text atIndex:textField.tag];
  }
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  [self downAnimate];
}

- (void)rebackView {
  CGRect viewFrame = self.view.frame;
  viewFrame.origin.y += _animatedDistance+80;
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationBeginsFromCurrentState:YES];
  [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
  
  [self.view setFrame:viewFrame];
  [UIView commitAnimations];
}

#pragma mark - close key board
- (void)closeKeyBoard {
  
  [self.nameTextField resignFirstResponder];
  [self.mobileTextField resignFirstResponder];
  [self.emailTextField resignFirstResponder];
  [self.weixinTextField resignFirstResponder];
  [self.brandTextField resignFirstResponder];
}

#pragma mark - UITextViewDelegate method
- (void)textViewDidBeginEditing:(UITextView *)textView{
  NSString *temp = LocaleStringForKey(NSOrderDescPromptTitle, nil);
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

- (void)textViewDidEndEditing:(UITextView *)textArea{
	if (textArea.text.length > 0) {
    [self.contractValueArray insertObject:textArea.text atIndex:textArea.tag];
	} else {
		textArea.textColor = [UIColor grayColor];
		textArea.text = LocaleStringForKey(NSOrderDescPromptTitle, nil);
  }
  
  [self downAnimate];
}

- (void)dismissKeyBoard:(id)sender
{
  
  [self.companyDescTextView resignFirstResponder];
  [self.companyScaleTextView resignFirstResponder];
  [self.welfareDescTextView resignFirstResponder];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
  return YES;
}

- (void)drawSplitLine:(CGRect)lineFrame color:(UIColor *)color inView:(UIView*)inView{
  
  UIView *splitLine = [[[UIView alloc] initWithFrame:lineFrame] autorelease];
  splitLine.backgroundColor = color;
  
  [inView addSubview:splitLine];
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

- (BOOL)checkValue {
  if (self.nameTextField.text.length == 0 || [self.nameTextField.text isEqualToString:NULL_PARAM_VALUE]) {
    return NO;
  }
  if (self.mobileTextField.text.length == 0 || [self.mobileTextField.text isEqualToString:NULL_PARAM_VALUE]) {
    return NO;
  }
  if (self.brandTextField.text.length == 0 || [self.brandTextField.text isEqualToString:NULL_PARAM_VALUE]) {
    return NO;
  }
  if (self.companyDescTextView.text.length == 0 || [self.companyDescTextView.text isEqualToString:LocaleStringForKey(NSOrderDescPromptTitle, nil)] || [self.companyDescTextView.text isEqualToString:NULL_PARAM_VALUE]) {
    return NO;
  }
  if (self.companyScaleTextView.text.length == 0 || [self.companyScaleTextView.text isEqualToString:LocaleStringForKey(NSOrderDescPromptTitle, nil)] || [self.companyScaleTextView.text isEqualToString:NULL_PARAM_VALUE]) {
    return NO;
  }
  if (self.welfareDescTextView.text.length == 0 || [self.welfareDescTextView.text isEqualToString:LocaleStringForKey(NSOrderDescPromptTitle, nil)] || [self.welfareDescTextView.text isEqualToString:NULL_PARAM_VALUE]) {
    return NO;
  }
  
  return YES;
}

#pragma mark - submit order
- (void)submitOrder:(id)sender {
  
  if (![self checkValue]) {
    ShowAlertWithOneButton(self,LocaleStringForKey(NSNoteTitle,nil), LocaleStringForKey(NSCheckInputMsg, nil), LocaleStringForKey(NSOKTitle, nil));
    return;
  }
  
  self.connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                               interactionContentType:SEND_COMMENT_TY] autorelease];
  
  [(ECAsyncConnectorFacade *)self.connFacade publishWelfare:self.nameTextField.text
                                                        tel:self.mobileTextField.text
                                                      email:self.emailTextField.text
                                                 weiXinCode:self.weixinTextField.text
                                                  brandName:self.brandTextField.text
                                          enterpriseService:self.companyDescTextView.text
                                                 storeScale:self.companyScaleTextView.text
                                           preferentialDesc:self.welfareDescTextView.text];
}

- (void)backLogicView
{
  [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:([[self.navigationController viewControllers] count]-2)] animated:YES];
  
  [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionSuccessMsg, nil)
                                msgType:SUCCESS_TY
                     belowNavigationBar:YES];
}

#pragma mark - ECConnectorDelegate

- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  switch (contentType) {
    case SEND_COMMENT_TY:
    {
      [UIUtils showAsyncLoadingView:LocaleStringForKey(NSSendingTitle, nil)
                    toBeBlockedView:NO];
      break;
    }
      
    default:
      break;
  }
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType {
  
  switch (contentType) {
      
    case SEND_COMMENT_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:SEND_COMMENT_TY
                                   MOC:nil
                     connectorDelegate:self
                                   url:url]) {
        
        [self backLogicView];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      [UIUtils closeAsyncLoadingView];
      break;
    }
      
    default:
      break;
  }
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  NSString *msg = nil;
  switch (contentType) {
    case SEND_COMMENT_TY:
    {
      msg = LocaleStringForKey(NSActionFaildMsg, nil);
      
      [UIUtils closeAsyncLoadingView];
      break;
    }
      
    default:
      break;
  }
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }
  
  [super connectFailed:error url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case SEND_COMMENT_TY:
      [UIUtils closeAsyncLoadingView];
      break;
      
    default:
      break;
  }
  [super connectCancelled:url contentType:contentType];
}

@end
