//
//  OrderViewController.m
//  iAlumni
//
//  Created by Adam on 13-8-7.
//
//

#import "OrderViewController.h"
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "UIImageButton.h"
#import "SubmitOrderViewController.h"

#define NAME_WIDTH                      270.0f
#define TITLE_ICON_WIDTH                26.0f
#define TITLE_ICON_HEIGHT               7.0f

#define DESC_CELL_HEIGHT                188.f

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
#define CELL_LABEL_X                    25.0f
#else
#define CELL_LABEL_X                    20.0f
#endif


#define TITLE_X                         28.0f
#define HEADER_VIEW_H                   274.f
#define GROUP_ICON_H                    176.f
#define GROUP_MEMBER_H                  63.7f

#define HEADER_LABEL_X                  34.f
#define ORDER_HEADVIEW_W                287.f
#define CELL_TOTAL_PRICE_H              62.f

#define NUMBER_FONT_SIZE                14.0f
#define FONT_SIZE                       14.0f
#define NUMBER_X                        220.f
#define LABEL_X                         20.0f
#define LABEL_Y                         16.0f
#define CONTENT_W                       195.f
#define LABEL_W                         80.f
#define DESC_TITLE_HEIGHT               25.0f
#define DESC_BUTTON_HEIGHT              25.0f
#define CONTENT_X                       85.0f
#define MEMBER_ACTIVITY_X               80.f

#define BTN_WIDTH                       120.0f
#define BTN_HEIGHT                      35.0f

#define LABEL_MAX                       100.0f
#define LABEL_CONTENT_INTERVAL          10.0f
#define NUMBER_X                        220.f
#define BUTTON_W                        90.f
#define PHOTO_WIDTH                     98.0f//110.0f
#define PHOTO_HEIGHT                    80.0f//90.0f

#define MEMBER2ACTIVITY_X               MARGIN*3
#define MEMBER2ACTIVITY_Y               30.0f

#define JOIN2MANAGE_Y                   60.0f

#define SECTION_COUNT                   3

#define FOOT_HEIGHT                     50.0f
#define GROUP_CELL_H                    46.f

#define CELL_IMG_W                      289.f

enum {
  SKU_ID = 0,
  SKU_NAME,
  SKU_PRICE,
  SKU_TYPE,
} SKU_DEFINE;

enum {
  baseCheckBox = 1000,
  checkBoxItem1 = 1001,
  checkBoxItem2 = 1002,
};

@interface OrderViewController() <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate>
{
  int tableHeight;
  
  int iDescHeight;
  int iChargeHeight;
  int iManageCount;
  
  int iChangeMarkHeight;
  int iPayHeight;
  
  int inputSize;
  CGFloat _animatedDistance;
  
  CGFloat groupTitleHeight;
  CGFloat totalHeight;
  
  int orderCount;
  CGFloat orderTotalAmount;
  CGFloat order1Amount;
  CGFloat order2Amount;
  int selOrderType;
  CGRect _frame;
    
    float CELL_MULTIPLE_H;
    float CELL_SINGLE_H;

}

@property (nonatomic, copy) NSString *payOrderId;
@property (nonatomic, copy) NSString *orderTitle;
@property (nonatomic, copy) NSString *skuMsg;

@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) NSArray *contractLabelArray;
@property (nonatomic, retain) NSMutableArray *contractValueArray;
@property (nonatomic, retain) NSMutableArray *skuArray;
@property (nonatomic, retain) NSMutableArray *skuIdArray;
@property (nonatomic, retain) NSMutableArray *salesPriceArray;

@property (nonatomic, retain) UITextField *mobileTextField;
@property (nonatomic, retain) UITextField *emailTextField;
@property (nonatomic, retain) UITextView *descTextField;

@property (nonatomic, copy) NSString *selSkuId;
@property (nonatomic, copy) NSString *salesPrice;

@property (nonatomic, copy) NSString *orderInfo;

@end

@implementation OrderViewController

#pragma mark - life cycle methods
- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext*)MOC
    paymentItemType:(PaymentItemType)paymentItemType
{
  self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needGoHome:NO];
  
  if (self) {
    _frame = frame;
    
    _paymentItemType = paymentItemType;
  }
  return self;
}

- (void)setPayOrderId:(NSString *)payOrderId orderTitle:(NSString *)orderTitle
               skuMsg:(NSString *)skuMsg
{
  self.payOrderId = payOrderId;
  self.orderTitle = orderTitle;
  self.skuMsg = skuMsg;
}

- (void)dealloc
{
  
  self.contractLabelArray = nil;
  self.contractValueArray = nil;
  
  self.skuArray = nil;
  self.salesPriceArray = nil;
  self.skuIdArray = nil;
  
  self.payOrderId = nil;
  self.orderTitle = nil;
  self.skuMsg = nil;
  
  self.selSkuId = nil;
  self.salesPrice = nil;
  
  self.headerView = nil;
  
  self.orderInfo = nil;
  
  [super dealloc];
}

- (void)didReceiveMemoryWarning{
  [super didReceiveMemoryWarning];
}

- (void)doBack:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - load detail
- (void)loadOrderDetail {
  
  orderCount = 1;
  totalHeight = 0;
  selOrderType = checkBoxItem1;
  orderTotalAmount = 0;
  
  // Cell Array
  self.contractLabelArray = [[[NSArray alloc] initWithObjects:
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSNameTitle, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSClassTitle, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSMobileTitle, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSEmailTitle, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSOrderDescTitle, nil)], nil] autorelease];
  
  NSString *userMobile = NULL_PARAM_VALUE;
  if ([AppManager instance].userMobile != nil) {
    userMobile = [AppManager instance].userMobile;
  }
  
  NSString *email = NULL_PARAM_VALUE;
  if ([AppManager instance].email != nil) {
    email = [AppManager instance].email;
  }
  
  self.contractValueArray = [NSMutableArray array];
  [self.contractValueArray insertObject:[AppManager instance].userName atIndex:0];
  [self.contractValueArray insertObject:[AppManager instance].classGroupId atIndex:1];
  [self.contractValueArray insertObject:userMobile atIndex:2];
  [self.contractValueArray insertObject:email atIndex:3];
  [self.contractValueArray insertObject:NULL_PARAM_VALUE atIndex:4];
  
  
  // group Name
  WXWLabel *orderTitle = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                textColor:COLOR(51, 51, 51)
                                              shadowColor:TRANSPARENT_COLOR] autorelease];
  orderTitle.font = BOLD_FONT(15);
  orderTitle.numberOfLines = 0;
  orderTitle.text = self.orderTitle;
  
  CGSize nameSize = [orderTitle.text sizeWithFont:orderTitle.font
                                constrainedToSize:CGSizeMake(NAME_WIDTH, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
  groupTitleHeight = nameSize.height;
  totalHeight += groupTitleHeight;
  
  NSArray *skuTempArray = [self.skuMsg componentsSeparatedByString:@"$"];
  int count = [skuTempArray count];
  
  self.skuArray = [NSMutableArray array];
  self.skuIdArray = [NSMutableArray array];
  self.salesPriceArray = [NSMutableArray array];
  
  for (int i=0; i<count; i++) {
    NSArray *skuDetailArray = [[skuTempArray objectAtIndex:i] componentsSeparatedByString:@"#"];
    
    [self.skuArray insertObject:skuDetailArray atIndex:i];
    [self.skuIdArray insertObject:[skuDetailArray objectAtIndex:SKU_ID] atIndex:i];
    [self.salesPriceArray insertObject:[skuDetailArray objectAtIndex:SKU_PRICE] atIndex:i];
    
      CGSize skuNameSize = [[skuDetailArray objectAtIndex:SKU_NAME] sizeWithFont:BOLD_FONT(FONT_SIZE)
                                                               constrainedToSize:CGSizeMake(168.f, CGFLOAT_MAX)
                                                                   lineBreakMode:NSLineBreakByWordWrapping];
    if ([[skuDetailArray objectAtIndex:SKU_TYPE] intValue] == 1) {
       
        CELL_MULTIPLE_H = 60.f + skuNameSize.height;
      totalHeight += CELL_MULTIPLE_H;
    } else {
        CELL_SINGLE_H = 20.f + skuNameSize.height;
      totalHeight += CELL_SINGLE_H;
    }
  }
  
  self.selSkuId = [self.skuIdArray objectAtIndex:(selOrderType - baseCheckBox-1)];
  self.salesPrice =  [self.salesPriceArray objectAtIndex:(selOrderType - baseCheckBox-1)];
  [AppManager instance].selSkuCount = @"1";
    
  //　总价
  totalHeight += CELL_TOTAL_PRICE_H;
}

- (void)initTableView {
  if (self.tableView == nil) {
    CGRect mTabFrame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
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

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.frame = _frame;
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  [self loadOrderDetail];
  [self initTableView];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIDeviceOrientationPortrait);
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  return NO;
}

#pragma mark - Table view delegate

- (void)drawIntroCell:(UITableViewCell *)cell {
  UIView *mCellView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, SCREEN_WIDTH-55, DESC_TITLE_HEIGHT+MARGIN*2+iDescHeight)];
  [mCellView setBackgroundColor:COLOR(222, 222, 222)];
  
  CGRect descTitleFrame = CGRectMake(CELL_LABEL_X, 0, SCREEN_WIDTH-20-4, DESC_TITLE_HEIGHT);
  UILabel *mLabel = [[UILabel alloc] initWithFrame:descTitleFrame];
  [mLabel setText:LocaleStringForKey(NSIntroductionTitle, nil)];
  [mLabel setFont:BOLD_FONT(FONT_SIZE+2)];
  [mLabel setTextColor:COLOR(196, 24, 32)];
  [mLabel setBackgroundColor:TRANSPARENT_COLOR];
  [mCellView addSubview:mLabel];
  [mLabel release];
  
  [mCellView setBackgroundColor:TRANSPARENT_COLOR];
  [cell.contentView addSubview:mCellView];
  [mCellView release];
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)drawManagementCell:(UITableViewCell *)cell {
  UIView *mCellView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, SCREEN_WIDTH-55, DESC_TITLE_HEIGHT+MARGIN*2+iDescHeight)];
  [mCellView setBackgroundColor:COLOR(222, 222, 222)];
  
  CGRect descTitleFrame = CGRectMake(CELL_LABEL_X, (DEFAULT_CELL_HEIGHT - DESC_TITLE_HEIGHT)/2.0f, SCREEN_WIDTH-20-4, DESC_TITLE_HEIGHT);
  UILabel *mLabel = [[UILabel alloc] initWithFrame:descTitleFrame];
  [mLabel setText:LocaleStringForKey(NSGroupManagementTitle, nil)];
  [mLabel setFont:BOLD_FONT(FONT_SIZE+2)];
  [mLabel setTextColor:COLOR(196, 24, 32)];
  [mLabel setBackgroundColor:TRANSPARENT_COLOR];
  [mCellView addSubview:mLabel];
  [mLabel release];
  
  [mCellView setBackgroundColor:TRANSPARENT_COLOR];
  [cell.contentView addSubview:mCellView];
  [mCellView release];
  
  cell.selectionStyle = UITableViewCellSelectionStyleBlue;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell
{
  int row = [indexPath row];
  [cell setBackgroundColor:[UIColor whiteColor]];
  
  [cell setBackgroundColor:TRANSPARENT_COLOR];
  UIImage *cellBGImage = [UIImage imageNamed:@"groupCellBG1.png"];
  int cellHeight = GROUP_CELL_H;
  if (row == 4)
  {
    cellBGImage = [UIImage imageNamed:@"groupCellBG2.png"];
    cellHeight = DESC_CELL_HEIGHT;
  }
  UIImageView *cellImageView = [[[UIImageView alloc] initWithImage:cellBGImage] autorelease];
  
  CGFloat imageX = 0;
  if (CURRENT_OS_VERSION >= IOS7) {
    imageX = MARGIN * 3;
  } else {
    imageX = 3.0f;
  }
  
  cellImageView.frame = CGRectMake(imageX, 0, CELL_IMG_W, cellHeight);
  
  [cell.contentView addSubview:cellImageView];
  
  // Label
  NSString *mText = self.contractLabelArray[row];
  UILabel *mUILable = [[UILabel alloc] init];
  mUILable.text = mText;
  mUILable.font = FONT(FONT_SIZE);
  CGSize mDescSize = [mUILable.text sizeWithFont:mUILable.font];
  mUILable.frame = CGRectMake(CELL_LABEL_X, LABEL_Y, LABEL_W, mDescSize.height);
  mUILable.textColor = COLOR(82, 82, 82);
  [mUILable setBackgroundColor:TRANSPARENT_COLOR];
  mUILable.tag = row + 40;
  [cell.contentView addSubview:mUILable];
  [mUILable release];
  
  // contact Msg
  NSString *contactMsg = self.contractValueArray[row];
  if (row < 2) {
    
    UILabel *mLable = [[UILabel alloc] init];
    mLable.text = contactMsg;
    mLable.font = FONT(FONT_SIZE);
    CGSize mNumberSize = [mLable.text sizeWithFont:mLable.font];
    mLable.textColor = COLOR(113, 113, 113);
    [mLable setBackgroundColor:TRANSPARENT_COLOR];
    mLable.frame = CGRectMake(CONTENT_X, LABEL_Y, 200, mNumberSize.height);
    mLable.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [cell.contentView addSubview:mLable];
    [mLable release];
  } else if(row == 2){
    
    self.mobileTextField = [[[UITextField alloc] initWithFrame:CGRectMake(CONTENT_X, LABEL_Y, CONTENT_W, 20)] autorelease];
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
    self.mobileTextField.layer.cornerRadius = 0.f;
    [self.mobileTextField.layer setMasksToBounds:YES];
    [cell.contentView addSubview:self.mobileTextField];
  } else if(row == 3){
    
    self.emailTextField = [[[UITextField alloc] initWithFrame:CGRectMake(CONTENT_X, LABEL_Y, CONTENT_W, 20)] autorelease];
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
    self.emailTextField.layer.cornerRadius = 0.f;
    [self.emailTextField.layer setMasksToBounds:YES];
    
    [cell.contentView addSubview:self.emailTextField];
  } else if(row == 4){
    
    CGRect textFrame = CGRectMake(CONTENT_X, LABEL_Y, CONTENT_W, cellHeight - 8*MARGIN);
    self.descTextField = [[[UITextView alloc] initWithFrame:textFrame] autorelease];
    self.descTextField.tag = row;
    self.descTextField.textColor = COLOR(113, 113, 113);
    self.descTextField.font = FONT(FONT_SIZE);
    self.descTextField.delegate = self;
    self.descTextField.text = LocaleStringForKey(NSOrderDescPromptTitle, nil);
    self.descTextField.returnKeyType = UIReturnKeyDefault;
    self.descTextField.keyboardType = UIKeyboardTypeDefault;
    // use the default type input method (entire keyboard)
    self.descTextField.scrollEnabled = YES;
    // this will cause automatic vertical resize when the table is resized
    //        self.descTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    // note: for UITextView, if you don't like autocompletion while typing use:
    self.descTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // board
    self.descTextField.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.descTextField.layer.borderColor = COLOR(212, 212, 212).CGColor;
    self.descTextField.layer.borderWidth = 1.0;
    self.descTextField.layer.cornerRadius = 0.f;
    [self.descTextField.layer setMasksToBounds:YES];
    self.descTextField.backgroundColor = COLOR(247, 247, 247);
    
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
    
    [self.descTextField setInputAccessoryView:topView];
    [cell.contentView addSubview:self.descTextField];
  }
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  [super deselectCell];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return totalHeight + 8*MARGIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  int row = [indexPath row];
  
  if (row == 4) {
    return DESC_CELL_HEIGHT;
  } else {
    return 44.f;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  switch (section) {
    case 0:
    {
      self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, totalHeight + 8*MARGIN)] autorelease];
      
      // group Name
      WXWLabel *orderTitle = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                    textColor:COLOR(86, 86, 86)
                                                  shadowColor:TRANSPARENT_COLOR] autorelease];
      orderTitle.font = BOLD_FONT(15);
      orderTitle.numberOfLines = 0;
      orderTitle.text = self.orderTitle;
      
      CGSize nameSize = [orderTitle.text sizeWithFont:orderTitle.font
                                    constrainedToSize:CGSizeMake(NAME_WIDTH, CGFLOAT_MAX)
                                        lineBreakMode:NSLineBreakByWordWrapping];
      
      orderTitle.frame = CGRectMake(15, 15,
                                    nameSize.width, nameSize.height);
      
      [self.headerView addSubview:orderTitle];
      
      UIImageView *clubDetailBG = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"submitOrderHead.png"]] autorelease];
      clubDetailBG.backgroundColor = TRANSPARENT_COLOR;
      clubDetailBG.frame = CGRectMake(15.f, orderTitle.frame.origin.y + nameSize.height + MARGIN, ORDER_HEADVIEW_W, totalHeight - groupTitleHeight);
      clubDetailBG.userInteractionEnabled = YES;
      
      // sku
      int count = [self.skuArray count];
        
      int top = 0;
      
      for (int i=0; i<count; i++) {
        
        NSArray *skuDetailArray = [self.skuArray objectAtIndex:i];
        if ([[skuDetailArray objectAtIndex:SKU_TYPE] intValue] == 1) {
          
          UIView *skuBGView = [[[UIView alloc] initWithFrame:CGRectMake(0, top, ORDER_HEADVIEW_W, CELL_MULTIPLE_H)] autorelease];
          skuBGView.backgroundColor = TRANSPARENT_COLOR;
          skuBGView.userInteractionEnabled = YES;
          
          // check box
          CGRect checkBoxFrame = CGRectMake(10, 13, 16, 15.5);
          NSString *checkBoxImg = @"payCheck.png";
          if (selOrderType == checkBoxItem1) {
            checkBoxImg = @"payCheckSel.png";
          }
          
            if (count == 1) {
                selOrderType = checkBoxItem1;
                checkBoxImg = @"payCheckSel.png";
            }
            
          UIImageView *checkBoxButton = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:checkBoxImg]] autorelease];
          checkBoxButton.backgroundColor = TRANSPARENT_COLOR;
          checkBoxButton.frame = checkBoxFrame;
          checkBoxButton.userInteractionEnabled = YES;
          [skuBGView addSubview:checkBoxButton];
          
          UIButton *checkBoxClickButton = [UIButton buttonWithType:UIButtonTypeCustom];
          checkBoxClickButton.tag = checkBoxItem1;
          checkBoxClickButton.frame = CGRectMake(10-15.f, 13-15.f, 16+30.f, 15.5+30.f);
          [checkBoxClickButton addTarget:self action:@selector(choseOrderType:) forControlEvents:UIControlEventTouchUpInside];
          [skuBGView addSubview:checkBoxClickButton];
          
          // label
          UILabel *skuNameLable = [[UILabel alloc] initWithFrame:CGRectZero];
          skuNameLable.text = [skuDetailArray objectAtIndex:SKU_NAME];
          skuNameLable.font = BOLD_FONT(FONT_SIZE);
          skuNameLable.numberOfLines = 0;
            
        CGSize skuNameSize = [skuNameLable.text sizeWithFont:skuNameLable.font
                              constrainedToSize:CGSizeMake(168.f, CGFLOAT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        skuNameLable.frame = CGRectMake(HEADER_LABEL_X, 13, skuNameSize.width, skuNameSize.height);
            
          skuNameLable.textColor = COLOR(86, 86, 86);
          [skuNameLable setBackgroundColor:TRANSPARENT_COLOR];
          [skuBGView addSubview:skuNameLable];
          [skuNameLable release];
          
          // Price
          UILabel *skuPriceLable = [[[UILabel alloc] init] autorelease];
          order1Amount = [[skuDetailArray objectAtIndex:SKU_PRICE] floatValue];
          skuPriceLable.text = [NSString stringWithFormat:@"￥%.2f", order1Amount];
          skuPriceLable.font = BOLD_FONT(NUMBER_FONT_SIZE);
          skuPriceLable.textColor = [UIColor blackColor];
          skuPriceLable.textAlignment = NSTextAlignmentRight;
          [skuPriceLable setBackgroundColor:TRANSPARENT_COLOR];
          skuPriceLable.frame = CGRectMake(182, 18, 85, 20.f);
          [skuBGView addSubview:skuPriceLable];
          
          int y = skuPriceLable.frame.origin.y + skuNameSize.height + 10;
            
          // 数量
          UILabel *countLable = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
          countLable.text = LocaleStringForKey(NSOrderCountTitle, nil);
          countLable.font = BOLD_FONT(FONT_SIZE);
          CGSize countSize = [countLable.text sizeWithFont:countLable.font];
          countLable.frame = CGRectMake(34, y, countSize.width, countSize.height);
          countLable.textColor = COLOR(86, 86, 86);
          [countLable setBackgroundColor:TRANSPARENT_COLOR];
          [skuBGView addSubview:countLable];
          
          // submit Reduce Img
          CGRect submitReduceFrame = CGRectMake(180.f, y - 4.f, 25, 25);
          UIImageView *submitReduceImg = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"submitReduce.png"]] autorelease];
          [submitReduceImg setHighlightedImage:[UIImage imageNamed:@"submitReduceSel.png"]];
          submitReduceImg.backgroundColor = TRANSPARENT_COLOR;
          submitReduceImg.frame = submitReduceFrame;
          submitReduceImg.userInteractionEnabled = YES;
          [skuBGView addSubview:submitReduceImg];
          
          // submit Reduce Click Button
          UIButton *submitReduceClickButton = [UIButton buttonWithType:UIButtonTypeCustom];
          submitReduceClickButton.frame = CGRectMake(180.f-10, y - 4.f-10, 25+20, 25+20);
          [submitReduceClickButton addTarget:self action:@selector(submitReduce:) forControlEvents:UIControlEventTouchUpInside];
          [skuBGView addSubview:submitReduceClickButton];
          
          // order count
          UITextField *skuTextField = [[[UITextField alloc] initWithFrame:CGRectMake(208, y - 4.f, 33.f, 25)] autorelease];
          skuTextField.tag = 10001;
          skuTextField.textAlignment = NSTextAlignmentCenter;
          skuTextField.backgroundColor = COLOR(247, 247, 247);
          skuTextField.adjustsFontSizeToFitWidth = YES;
          skuTextField.textColor = [UIColor blackColor];
          skuTextField.keyboardType = UIKeyboardTypePhonePad;
          skuTextField.borderStyle = UITextBorderStyleLine;
          skuTextField.returnKeyType = UIReturnKeyDone;
          skuTextField.font = BOLD_FONT(14);
          skuTextField.autocorrectionType = UITextAutocorrectionTypeNo;
          skuTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
          skuTextField.clearsOnBeginEditing = NO;
          skuTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
          skuTextField.delegate = self;
          [skuTextField setEnabled:NO];
          skuTextField.text = [NSString stringWithFormat:@"%d", orderCount];
          
          // board
          skuTextField.layer.backgroundColor = [[UIColor clearColor] CGColor];
          skuTextField.layer.borderColor = COLOR(212, 212, 212).CGColor;
          skuTextField.layer.borderWidth = 1.0;
          skuTextField.layer.cornerRadius = 5.f;
          [skuTextField.layer setMasksToBounds:YES];
          [skuBGView addSubview:skuTextField];
          
          // submit Add Img
          CGRect submitAddFrame = CGRectMake(244.f, y - 4.f, 25, 25);
          UIImageView *submitAddImg = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"submitAdd.png"]] autorelease];
          [submitAddImg setHighlightedImage:[UIImage imageNamed:@"submitAddSel.png"]];
          submitAddImg.backgroundColor = TRANSPARENT_COLOR;
          submitAddImg.frame = submitAddFrame;
          submitAddImg.userInteractionEnabled = YES;
          [skuBGView addSubview:submitAddImg];
          
          // submit add click
          UIButton *submitAddClickButton = [UIButton buttonWithType:UIButtonTypeCustom];
          submitAddClickButton.frame = CGRectMake(244.f-10.f, y - 4.f-10.f, 25+20, 25+20);
          [submitAddClickButton addTarget:self action:@selector(submitAdd:) forControlEvents:UIControlEventTouchUpInside];
          [skuBGView addSubview:submitAddClickButton];
          
          // line
          [self drawSplitLine:CGRectMake(1, CELL_MULTIPLE_H-1, ORDER_HEADVIEW_W-2, 0.5) color:COLOR(239, 239, 239) inView:skuBGView];
          
          [clubDetailBG addSubview:skuBGView];
          top += CELL_MULTIPLE_H;
          
        } else {
          UIView *skuBGView = [[[UIView alloc] initWithFrame:CGRectMake(0, top, ORDER_HEADVIEW_W, CELL_SINGLE_H)] autorelease];
          skuBGView.backgroundColor = TRANSPARENT_COLOR;
          
          // check box
          CGRect checkBoxFrame = CGRectMake(10, 16, 16, 15.5);
          NSString *checkBoxImg = @"payCheck.png";
          if (selOrderType == checkBoxItem2) {
            checkBoxImg = @"payCheckSel.png";
          }
          
            if (count == 1) {
                selOrderType = checkBoxItem2;
                checkBoxImg = @"payCheckSel.png";
            }
            
          UIImageView *checkBoxButton = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:checkBoxImg]] autorelease];
          checkBoxButton.backgroundColor = TRANSPARENT_COLOR;
          checkBoxButton.frame = checkBoxFrame;
          checkBoxButton.userInteractionEnabled = YES;
          [skuBGView addSubview:checkBoxButton];
          
          UIButton *checkBoxClickButton = [UIButton buttonWithType:UIButtonTypeCustom];
          checkBoxClickButton.tag = checkBoxItem2;
          checkBoxClickButton.frame = CGRectMake(10-15.f, 16-15.f, 16+30.f, 15.5+30.f);
          [checkBoxClickButton addTarget:self action:@selector(choseOrderType:) forControlEvents:UIControlEventTouchUpInside];
          [skuBGView addSubview:checkBoxClickButton];
          
          // label
          UILabel *skuNameLable = [[UILabel alloc] initWithFrame:CGRectZero];
          skuNameLable.text = [skuDetailArray objectAtIndex:SKU_NAME];
          skuNameLable.font = BOLD_FONT(FONT_SIZE);
          skuNameLable.numberOfLines = 0;
            
          CGSize skuNameSize = [skuNameLable.text sizeWithFont:skuNameLable.font
                                               constrainedToSize:CGSizeMake(168.f, CGFLOAT_MAX)
                                                   lineBreakMode:NSLineBreakByWordWrapping];
          skuNameLable.frame = CGRectMake(HEADER_LABEL_X, 13, skuNameSize.width, skuNameSize.height);
            
          skuNameLable.textColor = COLOR(86, 86, 86);
          [skuNameLable setBackgroundColor:TRANSPARENT_COLOR];
          [skuBGView addSubview:skuNameLable];
          [skuNameLable release];
          
          // Price
          UILabel *skuPriceLable = [[[UILabel alloc] init] autorelease];
          order2Amount = [[skuDetailArray objectAtIndex:SKU_PRICE] floatValue];
          skuPriceLable.text = [NSString stringWithFormat:@"￥%.2f", order2Amount];
          
          skuPriceLable.font = BOLD_FONT(NUMBER_FONT_SIZE);
          skuPriceLable.textColor = [UIColor blackColor];
          skuPriceLable.textAlignment = NSTextAlignmentRight;
          [skuPriceLable setBackgroundColor:TRANSPARENT_COLOR];
          skuPriceLable.frame = CGRectMake(182, 18, 85, 20.f);
          [skuBGView addSubview:skuPriceLable];
          
          // line
          [self drawSplitLine:CGRectMake(1, CELL_SINGLE_H-1, ORDER_HEADVIEW_W-2, 0.5) color:COLOR(239, 239, 239) inView:skuBGView];
          
          [clubDetailBG addSubview:skuBGView];
          top += CELL_SINGLE_H;
        }
      }
      
      // 总价
      UIView *skuBGView = [[[UIView alloc] initWithFrame:CGRectMake(0, top, ORDER_HEADVIEW_W, CELL_TOTAL_PRICE_H)] autorelease];
      skuBGView.backgroundColor = TRANSPARENT_COLOR;
      
      UILabel *totalPriceLable = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
      totalPriceLable.text = LocaleStringForKey(NSTotalPriceTitle, nil);
      totalPriceLable.font = BOLD_FONT(FONT_SIZE+3);
      CGSize totalPriceSize = [totalPriceLable.text sizeWithFont:totalPriceLable.font];
      totalPriceLable.frame = CGRectMake(HEADER_LABEL_X, 16, totalPriceSize.width, totalPriceSize.height);
      totalPriceLable.textColor = COLOR(29, 29, 29);
      [totalPriceLable setBackgroundColor:TRANSPARENT_COLOR];
      [skuBGView addSubview:totalPriceLable];
      
      // Price
      UILabel *skuPriceLable = [[[UILabel alloc] init] autorelease];
      CGFloat totalAmount = 0.0f;
      if (selOrderType == checkBoxItem1) {
        totalAmount = orderCount * order1Amount;
      } else {
        totalAmount = order2Amount;
      }
      orderTotalAmount = totalAmount;
      
      skuPriceLable.text = [NSString stringWithFormat:@"￥%.2f", totalAmount];
      skuPriceLable.font = BOLD_FONT(NUMBER_FONT_SIZE+2);
      skuPriceLable.textColor = COLOR(172, 15, 18);
      skuPriceLable.textAlignment = NSTextAlignmentRight;
      [skuPriceLable setBackgroundColor:TRANSPARENT_COLOR];
      skuPriceLable.frame = CGRectMake(182, 18, 85, 20.f);
      [skuBGView addSubview:skuPriceLable];
      
      [clubDetailBG addSubview:skuBGView];
      
      [self.headerView addSubview:clubDetailBG];
      
      return self.headerView;
    }
      break;
  }
  
  return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
  UIView *mUIView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, FOOT_HEIGHT)] autorelease];
  [mUIView setBackgroundColor:TRANSPARENT_COLOR];
  
  CGRect submitOrderFrame = CGRectMake(15, 15, 285, 48);
  
  // submit order
  UIImageButton *submitOrderButton = [[[UIImageButton alloc]
                                       initImageButtonWithFrame:submitOrderFrame
                                       target:self
                                       action:@selector(submitOrder:)
                                       title:LocaleStringForKey(NSSubmitOrderTitle, nil)
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
  return FOOT_HEIGHT + 20;
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

- (void)doSubmitOrder {
  CGRect mFrame = CGRectMake(0, 0, LIST_WIDTH, self.view.bounds.size.height);
  
  SubmitOrderViewController *orderVC = [[[SubmitOrderViewController alloc] initWithFrame:mFrame
                                                                                     MOC:_MOC
                                                                         paymentItemType:_paymentItemType] autorelease];
  
  orderVC.title = LocaleStringForKey(NSConfimOrderTitle, nil);
  
    NSString *descVal = NULL_PARAM_VALUE;
    
    if (![LocaleStringForKey(NSOrderDescPromptTitle, nil) isEqualToString:self.descTextField.text]) {
        descVal = self.descTextField.text;
    }
  [orderVC setPayOrderId:self.payOrderId
              orderTitle:self.orderTitle
                selSkuId:self.selSkuId
        orderTotalAmount:(CGFloat)orderTotalAmount
                  mobile:self.mobileTextField.text
                   email:self.emailTextField.text
                    desc:descVal];
  
  [self.navigationController pushViewController:orderVC animated:YES];
}

- (void)submitOrderForWelfare {
  _currentType = SET_ORDER_INFO_TY;
  
    NSString *descVal = NULL_PARAM_VALUE;
    
    if (![LocaleStringForKey(NSOrderDescPromptTitle, nil) isEqualToString:self.descTextField.text]) {
        descVal = self.descTextField.text;
    }
    
  NSString *param = STR_FORMAT(@"<skuId>%@</skuId><qty>%d</qty><storeId></storeId><salesPrice>%@</salesPrice><totalAmount>%f</totalAmount><mobile>%@</mobile><email>%@</email><remark>%@</remark>", self.selSkuId, orderCount,self.salesPrice, orderTotalAmount, self.mobileTextField.text, self.emailTextField.text, descVal);
  
  NSString *url = [CommonUtils geneUrl:param itemType:SET_ORDER_INFO_TY];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:SET_ORDER_INFO_TY];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)submitOrder:(id)sender {
  
  switch (_paymentItemType) {
    case WELFARE_PAYMENT_TY:
      [self submitOrderForWelfare];
      break;
      
    case GROUP_PAYMENT_TY:
    case EVENT_PAYMENT_TY:
      [self doSubmitOrder];
      break;
      
    default:
      break;
  }
  
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
  
  [self.mobileTextField resignFirstResponder];
  [self.emailTextField resignFirstResponder];
  [self.descTextField resignFirstResponder];
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
  [self.descTextField resignFirstResponder];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
  return YES;
}

- (void)submitReduce:(id)sender {
  orderCount --;
  
  if (orderCount < 1) {
    orderCount = 1;
  }
  
  [AppManager instance].selSkuCount = [NSString stringWithFormat:@"%d", orderCount];
  [self.tableView reloadData];
}

- (void)submitAdd:(id)sender {
  orderCount ++;
  
  [AppManager instance].selSkuCount = [NSString stringWithFormat:@"%d", orderCount];
  [self.tableView reloadData];
}

- (void)choseOrderType:(id)sender {
  
    if ([self.skuArray count] == 1) {
        return;
    }
    
  int type = [sender tag];
  selOrderType = type;
  
  self.selSkuId = [self.skuIdArray objectAtIndex:(selOrderType - baseCheckBox-1)];
  self.salesPrice = [self.salesPriceArray objectAtIndex:(selOrderType - baseCheckBox-1)];
  
  [self.tableView reloadData];
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

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  switch (contentType) {
    case SET_ORDER_INFO_TY:
    {
      self.orderInfo = [XMLParser parserOrderIdWithData:result
                                      connectorDelegate:self
                                                    url:url
                                                   type:contentType];
      if (self.orderInfo != nil) {
        NSArray *infoList = [self.orderInfo componentsSeparatedByString:@"#"];
        if (infoList.count == 2) {
          self.payOrderId = infoList[1];
          
          [self doSubmitOrder];
        }
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFailedToGetOrderMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      break;
    }
      
    default:
      break;
  }
  
  [super connectDone:result
                 url:url
         contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFailedToGetOrderMsg, nil)
                                msgType:ERROR_TY
                     belowNavigationBar:YES];
  
  [super connectFailed:error url:url contentType:contentType];
}

@end
