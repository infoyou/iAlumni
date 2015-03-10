//
//  LanguageListViewController.m
//  iAlumni
//
//  Created by Adam on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LanguageListViewController.h"
#import "UIUtils.h"
#import "AppManager.h"

#define FONT_SIZE           16
#define LABEL_Y             10

static int selectIndex = 0;

@interface LanguageListViewController ()

@end

@implementation LanguageListViewController

- (id)initWithParentVC:(UIViewController *)parentVC
              entrance:(id)entrance
         refreshAction:(SEL)refreshAction {
  self = [super init];
  if (self) {
    
    _parentVC = parentVC;
    
    _entrance = entrance;
    _refreshAction = refreshAction;
    
    // Custom initialization
    if ([WXWCommonUtils currentLanguage] == EN_TY) {
      selectIndex = 0;
    }else {
      selectIndex = 1;
    }
  }
  return self;
}

- (void)dealloc
{
  isFirst = NO;
  [super dealloc];
}

- (void)initNavibar
{
  [self addLeftBarButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)
                           target:self
                           action:@selector(doBack:)];
	
  self.title = LocaleStringForKey(NSLanguageTitle,nil);
  
	// done
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSDoneTitle,nil)
                            target:self
                            action:@selector(doResetLanguage:)];
}

- (void)initTableView
{
  CGRect mTabFrame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
	_tableView = [[UITableView alloc] initWithFrame:mTabFrame
                                            style:UITableViewStyleGrouped];
	
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.dataSource = self;
	_tableView.delegate = self;
  _tableView.backgroundView = nil;
	
	[self.view addSubview:_tableView];
  [super initTableView];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self initNavibar];
  [self initTableView];
	// Do any additional setup after loading the view.
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

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  return NO;
}

#pragma mark - table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section) {
    case 0:
      return 2;
      break;
      
    default:
      return 0;
      break;
  }
}

-(void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell
{
  int row = [indexPath row];
  [cell setBackgroundColor:[UIColor whiteColor]];
  
  switch (row) {
    case 0:
    {
      // Label
      NSString *mText = @"English";
      CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE)];
      UILabel *mUILable = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN * 2, LABEL_Y, mDescSize.width, mDescSize.height)];
      mUILable.text = mText;
      mUILable.textColor = COLOR(82, 82, 82);
      [mUILable setBackgroundColor:TRANSPARENT_COLOR];
      mUILable.font = BOLD_FONT(13);
      mUILable.tag = row + 20;
      mUILable.highlightedTextColor = [UIColor whiteColor];
      [cell.contentView addSubview:mUILable];
      [mUILable release];
    }
      break;
      
    case 1:
    {
      // Label
      NSString *mText = @"中文";
      CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE)];
      CGRect labelFrame = CGRectMake(MARGIN * 2, LABEL_Y, mDescSize.width, mDescSize.height);
      UILabel *mUILable = [[UILabel alloc] initWithFrame:labelFrame];
      mUILable.text = mText;
      mUILable.textColor = COLOR(82, 82, 82);
      [mUILable setBackgroundColor:TRANSPARENT_COLOR];
      mUILable.font = BOLD_FONT(13);
      mUILable.tag = row + 20;
      mUILable.highlightedTextColor = [UIColor whiteColor];
      [cell.contentView addSubview:mUILable];
      [mUILable release];
    }
      break;
      
    default:
      break;
  }
  
  if (!isFirst && selectIndex == row) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    isFirst = YES;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
  for (UIView *subview in subviews) {
    [subview removeFromSuperview];
  }
  [subviews release];
  
  cell.selectionStyle = UITableViewCellSelectionStyleGray;
  
  // Configure the cell...
  [self configureCell:indexPath aCell:cell];
  return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  int newRow = [indexPath row];
  
  if(newRow != selectIndex){
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:selectIndex
                                                    inSection:0];
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath];
    oldCell.accessoryType = UITableViewCellAccessoryNone;
  }
  
  switch (newRow) {
    case 0:
    {
      //[AppManager setEN];
      [[WXWSystemInfoManager instance] setLanguageWithType:EN_TY];
    }
      break;
      
    case 1:
    {
      //[AppManager setCN];
      [[WXWSystemInfoManager instance] setLanguageWithType:ZH_HANS_TY];
    }
      break;
      
    default:
      break;
  }
  
  [super deselectCell];
}

#pragma mark - back
- (void)doBack:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)doResetLanguage:(id)sender{
  [self triggerReloadForLanguageSwitch];
}

#pragma mark - ECAppSettingDelegate method
- (void)triggerReloadForLanguageSwitch {
  if (ZH_HANS_TY == [WXWSystemInfoManager instance].currentLanguageCode) {
    [UIUtils showActivityView:self.view text:@"正在切换语言..."];
  } else {
    [UIUtils showActivityView:self.view text:@"Setting Language..."];
  }
  
  [WXWCommonUtils setLanguage:[WXWSystemInfoManager instance].currentLanguageDesc];

  [[AppManager instance] reloadForLanguageSwitch:self];
}

- (void)languageSwitchDone {
  
  // refresh tab bar item of homepage
  if (_parentVC && [_parentVC respondsToSelector:@selector(refreshTabItems)]) {
    [_parentVC performSelector:@selector(refreshTabItems)];
  }
  
  if (_entrance && _refreshAction) {
    [_entrance performSelector:_refreshAction];
  }
  
  [UIUtils closeActivityView];
  
  [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSLanguageSwitchDoneMsg, nil)
                         alternativeMsg:nil
                                msgType:SUCCESS_TY
                     belowNavigationBar:YES];
  
  [self dismissModalViewControllerAnimated:YES];
}

- (void)closeSpinView {
  [UIUtils closeActivityView];
}

@end
