//
//  SubmitOrderViewController.m
//  iAlumni
//
//  Created by Adam on 13-8-8.
//
//

#import "SubmitOrderViewController.h"
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "UIImageButton.h"
#import "UPOMP.h"
#import "PaymentWebViewController.h"
#import "WXWNavigationController.h"

#define NAME_WIDTH                      270.0f

#define CELL_IMG_W                      289.f

#define CELL_ICON_X                     13.f
#define CELL_ICON_Y                     2.f
#define CELL_TITLE_Y                    11.f
#define CELL_DESC_Y                     28.f
#define DESC_CELL_HEIGHT                106.f


#define TITLE_X                         28.0f
#define HEADER_VIEW_H                   274.f
#define GROUP_ICON_H                    176.f
#define GROUP_MEMBER_H                  63.7f

#define HEADER_LABEL_X                  34.f
#define ORDER_HEADVIEW_W                287.f
#define CELL_MULTIPLE_H                 75.f
#define CELL_SINGLE_H                   44.f
#define CELL_TOTAL_PRICE_H              62.f

#define NUMBER_FONT_SIZE                16.0f
#define FONT_SIZE                       14.0f
#define NUMBER_X                        220.f
#define LABEL_X                         20.0f
#define LABEL_Y                         16.0f
#define CONTENT_W                       190.f
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

#define FOOT_HEIGHT                     50.0f
#define GROUP_CELL_H                    46.f

@interface SubmitOrderViewController() <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate, UPOMPDelegate>
{
  
  int iDescHeight;
  int selectIndex;
  CGRect _frame;
}

@property (nonatomic, copy) NSString *payOrderId;
@property (nonatomic, copy) NSString *orderTitle;

@property (nonatomic, retain) UPOMP *cpView;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) NSArray *headerLabelArray;
@property (nonatomic, retain) NSArray *contractLabelArray;
@property (nonatomic, retain) NSMutableArray *contractValueArray;
@property (nonatomic, retain) NSMutableArray *cellHeightArray;

@property (nonatomic, copy) NSString *selSkuId;
@property (nonatomic, copy) NSString *orderTotalAmount;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *desc;
@end

@implementation SubmitOrderViewController

#pragma mark - navigation back to item detail
- (void)backToItemDetail {  
  
  UINavigationController *nav = self.navigationController;
  
  [[self retain] autorelease];
  
  [nav popViewControllerAnimated:NO];
  [nav popViewControllerAnimated:YES];
}

#pragma mark - life cycle methods
- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext*)MOC           
    paymentItemType:(PaymentItemType)paymentItemType
{
  self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needGoHome:NO];
  
  if (self) {
    _frame = frame;
    
    _paymentItemType = paymentItemType;
    
    if (CURRENT_OS_VERSION >= IOS7) {
      _imageX = MARGIN * 3;
      _labelX = 25.0f;
    } else {
      _imageX = 3.0f;
      _labelX = 20.0f;
    }
  
  }
  return self;
}

- (void)dealloc
{
  self.headerLabelArray = nil;
  self.contractLabelArray = nil;
  self.contractValueArray = nil;
  
  self.selSkuId = nil;
  self.orderTitle = nil;
  self.orderTotalAmount = nil;
  self.mobile = nil;
  self.email = nil;
  self.desc = nil;
  
  self.payOrderId = nil;
  
  self.cpView = nil;
  self.headerView = nil;
  
  [super dealloc];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)setPayOrderId:(NSString *)payOrderId
           orderTitle:(NSString *)orderTitle
             selSkuId:(NSString *)selSkuId
     orderTotalAmount:(CGFloat)orderTotalAmount
               mobile:(NSString*)mobile
                email:(NSString*)email
                 desc:(NSString*)desc
{
  self.payOrderId = payOrderId;
  self.orderTitle = orderTitle;
  self.selSkuId = selSkuId;
  
  self.orderTotalAmount = [NSString stringWithFormat:@"%.2f", orderTotalAmount];
  self.mobile = mobile;
  self.email = email;
  self.desc = desc;
}

#pragma mark - load detail
- (void)loadOrderDetail {
  
  // Cell Array
  self.headerLabelArray = [[[NSArray alloc] initWithObjects:LocaleStringForKey(NSOrderDetailTitle, nil), LocaleStringForKey(NSPayActionSheetTitle, nil), nil] autorelease];
  
  // Cell Array
  self.contractLabelArray = [[[NSArray alloc] initWithObjects:
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSOrderItemTitle, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSOrderIdTitle, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSOrderAmountTitle, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSNameTitle, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSClassTitle, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSMobileTitle, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSEmailTitle, nil)],
                              [NSString stringWithFormat:@"%@ :", LocaleStringForKey(NSOrderDescTitle, nil)], nil] autorelease];
  
  if (self.payOrderId == nil) {
    self.payOrderId = NULL_PARAM_VALUE;
  }
  
  self.contractValueArray = [NSMutableArray array];
  [self.contractValueArray insertObject:self.orderTitle atIndex:0];
  [self.contractValueArray insertObject:self.payOrderId atIndex:1];
  [self.contractValueArray insertObject:self.orderTotalAmount atIndex:2];
  [self.contractValueArray insertObject:[AppManager instance].userName atIndex:3];
  [self.contractValueArray insertObject:[AppManager instance].classGroupId atIndex:4];
  [self.contractValueArray insertObject:self.mobile atIndex:5];
  [self.contractValueArray insertObject:self.email atIndex:6];
  [self.contractValueArray insertObject:self.desc atIndex:7];
  
    
    self.cellHeightArray = [NSMutableArray array];
    for (int i=0; i<8; i++) {
        CGSize fontSize = [[self.contractValueArray objectAtIndex:i] sizeWithFont:FONT(FONT_SIZE)
                                    constrainedToSize:CGSizeMake(CONTENT_W, CGFLOAT_MAX)];
        
        float cellHeight = fontSize.height;
        
        if (i != 7 && cellHeight < 44.f) {
            cellHeight = 44.f;
        } else if (i == 7 && cellHeight < DESC_CELL_HEIGHT) {
            cellHeight = DESC_CELL_HEIGHT;
        }
        
        [self.cellHeightArray insertObject:@(cellHeight) atIndex:i];
    }
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
  
  CGRect descTitleFrame = CGRectMake(_labelX, 0, SCREEN_WIDTH-20-4, DESC_TITLE_HEIGHT);
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
  
  CGRect descTitleFrame = CGRectMake(_labelX, (DEFAULT_CELL_HEIGHT - DESC_TITLE_HEIGHT)/2.0f, SCREEN_WIDTH-20-4, DESC_TITLE_HEIGHT);
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  int section = [indexPath section];
  int row = [indexPath row];
  
  if (section == 1) {
    selectIndex = row;
  }
  [self.tableView reloadData];
  
  [super deselectCell];
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section) {
    case 0:
      return 8;
      break;
      
    case 1:
      return 2;
      break;
      
    default:
      break;
  }
  
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
  int section = [indexPath section];
  
  switch (section) {
    case 0:
    {
      int row = [indexPath row];
      float cellHeight = [[self.cellHeightArray objectAtIndex:row] floatValue];

      return cellHeight;
    }
      break;
      
    case 1:
    {
      return 52.f;
    }
      break;
      
    default:
      break;
  }
  
  return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)] autorelease];
  
  // group Name
  WXWLabel *headerTitle = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                 textColor:COLOR(86, 86, 86)
                                               shadowColor:TRANSPARENT_COLOR] autorelease];
  headerTitle.font = BOLD_FONT(15);
  headerTitle.numberOfLines = 0;
  headerTitle.text = [self.headerLabelArray objectAtIndex:section];
  
  CGSize nameSize = [headerTitle.text sizeWithFont:headerTitle.font
                                 constrainedToSize:CGSizeMake(NAME_WIDTH, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
  
  headerTitle.frame = CGRectMake(15, 10,
                                 nameSize.width, nameSize.height);
  
  [self.headerView addSubview:headerTitle];
  
  return self.headerView;
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
                                         title:LocaleStringForKey(NSConfimPayTitle, nil)
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
  switch (section) {
    case 1:
      return FOOT_HEIGHT + 20;
      break;
      
    default:
      return 0;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"SubmitOrderCell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  NSArray *subviews = [[[NSArray alloc] initWithArray:cell.contentView.subviews] autorelease];
  for (UIView *subview in subviews) {
    [subview removeFromSuperview];
  }
  
  // Configure the cell...
  [self configureCell:indexPath aCell:cell];
  
  return cell;
}

- (void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell
{
  int section = [indexPath section];
  int row = [indexPath row];
  
  switch (section) {
    case 0:
    {
      [cell setBackgroundColor:TRANSPARENT_COLOR];
      UIImage *cellBGImage = [UIImage imageNamed:@"groupCellBG1.png"];
      if (row == 7)
      {
        cellBGImage = [UIImage imageNamed:@"groupCellBG2.png"];
      }
        
      UIImageView *cellImageView = [[[UIImageView alloc] initWithImage:cellBGImage] autorelease];
    
      cellImageView.frame = CGRectMake(_imageX, 0, CELL_IMG_W, [self.cellHeightArray[row] floatValue]);
      
      [cell.contentView addSubview:cellImageView];
      
      // Label
      NSString *mText = self.contractLabelArray[row];
      CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE)];
      WXWLabel *mUILable = [[WXWLabel alloc] initWithFrame:CGRectMake(_labelX, LABEL_Y, LABEL_W, mDescSize.height) textColor:COLOR(102, 102, 102) shadowColor:TRANSPARENT_COLOR];
      mUILable.text = mText;
      mUILable.font = FONT(FONT_SIZE);
      mUILable.tag = row + 40;
      [cell.contentView addSubview:mUILable];
      [mUILable release];
      
      // contact Msg
      NSString *contactMsg = self.contractValueArray[row];
                            
      WXWLabel *mLable = [[WXWLabel alloc] initWithFrame:CGRectZero textColor:COLOR(113, 113, 113) shadowColor:TRANSPARENT_COLOR];
      mLable.text = contactMsg;
      mLable.font = FONT(FONT_SIZE);

      CGRect mLabelFrame = CGRectMake(CONTENT_X, LABEL_Y-14, CONTENT_W, [self.cellHeightArray[row] floatValue]);
      
      mLable.frame = mLabelFrame;
      mLable.numberOfLines = 0;
      [cell.contentView addSubview:mLable];
      [mLable release];
    }
      break;
      
    case 1:
    {
      [cell setBackgroundColor:TRANSPARENT_COLOR];
      UIImage *cellBGImage = [UIImage imageNamed:@"orderCellBG1.png"];
      if (row == 1)
      {
        cellBGImage = [UIImage imageNamed:@"orderCellBG2.png"];
      }
      int cellHeight = 52.f;
      
      switch (row) {
        case 0:
        {
          
          UIImageView *cellImageView = [[[UIImageView alloc] initWithImage:cellBGImage] autorelease];
          cellImageView.frame = CGRectMake(_imageX, 0, CELL_IMG_W, cellHeight);
          
          [cell.contentView addSubview:cellImageView];
          
          UIImage *cellIcon = [UIImage imageNamed:@"alipayIcon.png"];
          UIImageView *cellIconView = [[[UIImageView alloc] initWithImage:cellIcon] autorelease];
          cellIconView.frame = CGRectMake(CELL_ICON_X, CELL_ICON_Y, 55.5, 49);
          [cell.contentView addSubview:cellIconView];
          
          // Label
          UILabel *mUILable = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
          mUILable.font = BOLD_FONT(FONT_SIZE);
          mUILable.text = LocaleStringForKey(NSAlipayTitle, nil);;
          CGSize mDescSize = [mUILable.text sizeWithFont:mUILable.font];
          mUILable.frame = CGRectMake(79, CELL_TITLE_Y, 143, mDescSize.height);
          mUILable.textColor = COLOR(86, 86, 86);
          [mUILable setBackgroundColor:TRANSPARENT_COLOR];
          [cell.contentView addSubview:mUILable];
          
          // contact Msg
          UILabel *mLable = [[[UILabel alloc] init] autorelease];
          [mLable setBackgroundColor:TRANSPARENT_COLOR];
          mLable.font = FONT(FONT_SIZE-4);
          mLable.text = LocaleStringForKey(NSAlipayDescTitle, nil);;
          CGSize mNumberSize = [mLable.text sizeWithFont:mLable.font];
          mLable.textColor = COLOR(149, 149, 149);
          mLable.frame = CGRectMake(79, CELL_DESC_Y, 143, mNumberSize.height);
          mLable.lineBreakMode = NSLineBreakByTruncatingTail;
          [cell.contentView addSubview:mLable];
          
          // check box
          UIImage *checkBoxIcon = [UIImage imageNamed:@"checkBoxIcon.png"];
          if (selectIndex == row) {
            checkBoxIcon = [UIImage imageNamed:@"checkBoxIconSel.png"];
          }
          UIImageView *checkBoxIconView = [[[UIImageView alloc] initWithImage:checkBoxIcon] autorelease];
          checkBoxIconView.frame = CGRectMake(230, 11, 32, 33.5);
          [cell.contentView addSubview:checkBoxIconView];
        }
          break;
          
        case 1:
        {
          
          UIImageView *cellImageView = [[[UIImageView alloc] initWithImage:cellBGImage] autorelease];
          cellImageView.frame = CGRectMake(_imageX, 0, CELL_IMG_W, cellHeight);
          
          [cell.contentView addSubview:cellImageView];
          
          UIImage *cellIcon = [UIImage imageNamed:@"unipayIcon.png"];
          UIImageView *cellIconView = [[[UIImageView alloc] initWithImage:cellIcon] autorelease];
          cellIconView.frame = CGRectMake(CELL_ICON_X, CELL_ICON_Y, 55.5, 49);
          [cell.contentView addSubview:cellIconView];
          
          // Label
          UILabel *mUILable = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
          mUILable.text = LocaleStringForKey(NSUnionpayTitle, nil);
          mUILable.font = BOLD_FONT(FONT_SIZE);
          CGSize mDescSize = [mUILable.text sizeWithFont:mUILable.font];
          mUILable.frame = CGRectMake(79, CELL_TITLE_Y, 143, mDescSize.height);
          mUILable.textColor = COLOR(86, 86, 86);
          [mUILable setBackgroundColor:TRANSPARENT_COLOR];
          [cell.contentView addSubview:mUILable];
          
          // contact Msg
          UILabel *mLable = [[UILabel alloc] init];
          mLable.text = LocaleStringForKey(NSUnionpayDescTitle, nil);
          mLable.font = FONT(FONT_SIZE-4);
          CGSize mNumberSize = [mLable.text sizeWithFont:mLable.font];
          mLable.textColor = COLOR(149, 149, 149);
          [mLable setBackgroundColor:TRANSPARENT_COLOR];
          mLable.frame = CGRectMake(79, CELL_DESC_Y, 143, mNumberSize.height);
          mLable.lineBreakMode = NSLineBreakByTruncatingTail;
          [cell.contentView addSubview:mLable];
          [mLable release];
          
          // check box
          UIImage *checkBoxIcon = [UIImage imageNamed:@"checkBoxIcon.png"];
          if (selectIndex == row) {
            checkBoxIcon = [UIImage imageNamed:@"checkBoxIconSel.png"];
          }
          UIImageView *checkBoxIconView = [[[UIImageView alloc] initWithImage:checkBoxIcon] autorelease];
          checkBoxIconView.frame = CGRectMake(230, 11, 32, 33.5);
          [cell.contentView addSubview:checkBoxIconView];
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

- (void)submitOrder:(id)sender {
  
  switch (selectIndex) {
    case 0:
    {
      [self doAliPay];
    }
      break;
      
    case 1:
    {
      [self doUnionPay];
    }
      break;
      
    default:
      break;
  }
}

- (void)backLogicView
{
  [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:([[self.navigationController viewControllers] count]-3)] animated:YES];
  
  [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaymentDoneMsg, nil)
                                msgType:SUCCESS_TY
                     belowNavigationBar:YES];
}

- (void)drawSplitLine:(CGRect)lineFrame color:(UIColor *)color inView:(UIView*)inView {
  
  UIView *splitLine = [[[UIView alloc] initWithFrame:lineFrame] autorelease];
  splitLine.backgroundColor = color;
  
  [inView addSubview:splitLine];
}

#pragma mark - pay
- (void)doAliPay {
  
  NSString *url = NULL_PARAM_VALUE;
  switch (_paymentItemType) {
    case GROUP_PAYMENT_TY:
      url = [NSString stringWithFormat:@"%@/event?action=order_alipay&order_id=%@&sku_id=%@&count=%@&t=%@", [AppManager instance].hostUrl, self.payOrderId, self.selSkuId, [AppManager instance].selSkuCount, PAY_GROUP_FEES];
      break;
      
    case EVENT_PAYMENT_TY:
      //url = [NSString stringWithFormat:@"%@/event?action=order_by_online_payment&order_id=%@&sku_id=%@&count=%@&t=%@", [AppManager instance].hostUrl, self.payOrderId, self.selSkuId, [AppManager instance].selSkuCount, [AppManager instance].payBusinessType];
      url = [NSString stringWithFormat:@"%@/event?action=order_alipay&order_id=%@&sku_id=%@&count=%@&t=%@", [AppManager instance].hostUrl, self.payOrderId, self.selSkuId, [AppManager instance].selSkuCount, PAY_EVENT_FEES];
      break;
      
    case WELFARE_PAYMENT_TY:
      url = STR_FORMAT(@"%@/event?action=order_alipay&order_id=%@&sku_id=%@&count=%@&t=%@", [AppManager instance].hostUrl, self.payOrderId, self.selSkuId, [AppManager instance].selSkuCount,PAY_WELFARE_FEES);
    default:
      break;
  }
  [self gotoUrl:url aTitle:NULL_PARAM_VALUE];
}

- (void)doUnionPay {
  
  if (_paymentItemType == WELFARE_PAYMENT_TY) {
    _currentType = WELFARE_APP_PAYMENT_TY;
  } else {
    _currentType = PAY_DATA_TY;
  }
  
  _currentType = WELFARE_APP_PAYMENT_TY;
  
  NSString *param = [NSString stringWithFormat:@"<order_id>%@</order_id><sku_id>%@</sku_id><item_count>%@</item_count>", self.payOrderId, self.selSkuId, [AppManager instance].selSkuCount];
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:_currentType] autorelease];
  [connFacade fetchGets:url];
}

- (void)goPay:(NSData *)result {
  self.cpView = [[[UPOMP alloc] init] autorelease];
  self.cpView.viewDelegate = self;
  [((iAlumniAppDelegate*)APP_DELEGATE).window addSubview:self.cpView.view];
  
  [self.cpView setXmlData:result];
  
  NSLog(@"message: %@", [[[NSString alloc] initWithData:result
                                               encoding:NSUTF8StringEncoding] autorelease]);
}

- (BOOL)checkPaymentRecallResult:(NSString *)result {
  if (nil == result || 0 == result.length) {
    return NO;
  }
  
  NSArray *list = [result componentsSeparatedByString:PAYMENT_RESPCODE_START_SEPARATOR];
  if (list.count == 2) {
    NSString *partResult = list[1];
    if (0 == partResult.length) {
      return NO;
    }
    
    NSArray *resultList = [partResult componentsSeparatedByString:PAYMENT_RESPCODE_END_SEPARATOR];
    if (resultList.count == 2) {
      NSString *codeStr = resultList[0];
      if (0 == codeStr.length) {
        return NO;
      }
      
      NSInteger code = codeStr.intValue;
      
      if (code != 0) {
        return NO;
      } else {
        return YES;
      }
    }
  }
  
  return NO;
}

#pragma mark - UPOMPDelegate method
-(void)viewClose:(NSData*)data {
  
  //获得返回数据并释放内存
  self.cpView.viewDelegate = nil;
  self.cpView = nil;
  
  NSString *resultStr = [[[NSString alloc] initWithData:data
                                               encoding:NSUTF8StringEncoding] autorelease];
  NSLog(@"resultStr = %@", resultStr);
  
  //以下为自定义相关操作
  if ([self checkPaymentRecallResult:resultStr]) {
    
    // refresh payment successful flag
    [self backLogicView];
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaymentErrorMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
  
}

#pragma mark - UIWebViewDelegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
  [UIUtils showActivityView:self.view text:LocaleStringForKey(NSLoadingTitle, nil)];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
  NSString *url = [[request URL] absoluteString];
  
  if (url && [url length] > 0) {
    if ([url rangeOfString:ALIPAY_MARK].length > 0) {
      _sessionExpired = YES;
    }
  }
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
  if (_sessionExpired) {
    [self backLogicView];
  }
  [UIUtils closeActivityView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
  [UIUtils closeActivityView];
}

- (void)gotoUrl:(NSString*)url aTitle:(NSString*)title
{
  
  PaymentWebViewController *paymentWebVC = [[[PaymentWebViewController alloc] initWithUrl:url
                                                                                 parentVC:self] autorelease];
  WXWNavigationController *nav = [[[WXWNavigationController alloc] initWithRootViewController:paymentWebVC] autorelease];
  paymentWebVC.title = title;
  
  [self.parentViewController presentModalViewController:nav
                                               animated:YES];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
  
  [UIUtils showActivityView:self.tableView text:LocaleStringForKey(NSLoadingTitle, nil)];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  [UIUtils closeActivityView];
  
  switch (contentType) {
      
    case PAY_DATA_TY:
    case WELFARE_APP_PAYMENT_TY:
    {
      [self goPay:result];
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
  
  [super connectFailed:error url:url contentType:contentType];
}

@end
