
#import "FilterScrollViewController.h"
#import "ECGradientButton.h"
#import "ExtensibilityCell.h"
#import "FixedCell.h"
#import "AppManager.h"
#import "EventListViewController.h"

#define     HEADER_HEIGHT       44.f
#define     SEARCH_BAR_H        44.f
#define     SHORT_W             260.f
#define     CELL_HEIGHT         44.f

#define SEARCH_BAR_RIGHT_PAD    80.0f

@interface FilterScrollViewController() <UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate>
{
  
}

@property (nonatomic, retain) UIView *searchBarBGView;
@property (nonatomic, retain) UIView *disableViewOverlay;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) ECGradientButton *closeSearchBarBut;
@property (nonatomic, retain) UIViewController *mainVC;

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, retain) NSIndexPath *selectIndex;
@property (nonatomic, retain) NSArray *listArray;
@property (nonatomic, retain) NSMutableArray *paramArray;
@end

@implementation FilterScrollViewController

- (void)dealloc
{
  self.expansionTableView = nil;
  self.isOpen = NO;
  self.selectIndex = nil;
  self.mainVC = nil;
  self.paramArray = nil;
  self.listArray = nil;
  self.searchBarBGView = nil;
  self.disableViewOverlay = nil;
  self.searchBar = nil;
  self.closeSearchBarBut = nil;
  self.delegate = nil;
  
  [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nil];
  if (self) {
    
  }
  return self;
}

- (void)viewDidAppear:(BOOL)animated
{
  self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.expansionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  self.expansionTableView.sectionFooterHeight = 0;
  self.expansionTableView.sectionHeaderHeight = 0;
  
  self.isOpen = NO;
}


- (void)setListData:(NSArray *)listArray
         paramArray:(NSMutableArray *)paramArray
           parentVC:(UIViewController *)parentVC
           forGroup:(BOOL)forGroup {

  _forGroup = forGroup;
  
  self.listArray = listArray;
  self.paramArray = paramArray;
  self.mainVC = parentVC;
  
  self.isOpen = NO;
  self.selectIndex = nil;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    return HEADER_HEIGHT;
  }
  
  return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  if (section == 0) {
    return [self addSearchBarView];
  }
  return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  if ([self.listArray count] > 0) {
    return [self.listArray count];
  }
  
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (self.isOpen) {
    if (self.selectIndex.section == section) {
      return [[self.paramArray objectAtIndex:section] count] + 1;
    }
  }
  
  return 1;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 40;
}

- (NSString *)findSelectedItemNameWithIndexPath:(NSIndexPath *)indexPath {
  
  NSArray *list = self.paramArray[indexPath.section];
  for (NSArray *contentList in list) {
    if (contentList.count >= RECORD_SELECTION_IDX) {
      if (((NSNumber *)contentList[RECORD_SELECTION_IDX]).intValue == SELECTED_TY) {
        return contentList[RECORD_NAME_IDX];
      }
    }
  }
  return NULL_PARAM_VALUE;
}

- (UITableViewCell *)drawExtendableCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
  if (self.isOpen&&self.selectIndex.section == indexPath.section&&indexPath.row!=0) {
    static NSString *CellIdentifier = @"FixedCell";
    FixedCell *cell = (FixedCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
      cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
      
      [cell.contentView setBackgroundColor:COLOR(29, 29, 29)];
      
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSArray *list = [self.paramArray objectAtIndex:self.selectIndex.section];
    NSArray *contentList = [list objectAtIndex:indexPath.row-1];
    cell.titleLabel.text = [contentList objectAtIndex:RECORD_NAME_IDX];
    
    if (((NSNumber *)self.paramArray[indexPath.section][indexPath.row - 1][RECORD_SELECTION_IDX]).intValue == SELECTED_TY) {
      cell.titleLabel.textColor = COLOR(255, 102, 102);
      cell.dotIcon.hidden = YES;//NO; hide dot icon currently
    } else {
      cell.titleLabel.textColor = COLOR(136, 136, 136);
      cell.dotIcon.hidden = YES;
    }
        
    return cell;
  } else {
    static NSString *CellIdentifier = @"ExtensibilityCell";
    ExtensibilityCell *cell = (ExtensibilityCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
      cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
      
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
      
      cell.titleLabel.textColor = COLOR(246, 246, 246);
      [cell.contentView setBackgroundColor:COLOR(51, 51, 51)];
      
      cell.selectedLabel.textColor = COLOR(255, 102, 102);
      cell.selectedLabel.textAlignment = UITextAlignmentRight;
      
      cell.dotIcon.hidden = YES;
      cell.arrowImageView.hidden = NO;
    }
    
    NSString *name = [self.listArray objectAtIndex:indexPath.section];
    cell.titleLabel.text = name;
    cell.selectedLabel.text = [self findSelectedItemNameWithIndexPath:indexPath];
    CGSize size = [CommonUtils sizeForText:cell.selectedLabel.text font:cell.selectedLabel.font];
    cell.selectedLabel.frame = CGRectMake(cell.arrowImageView.frame.origin.x - MARGIN - 80, (40 - size.height)/2.0f, 80, size.height);
    
    [cell changeArrowWithUp:([self.selectIndex isEqual:indexPath] ? YES:NO)];
    
    return cell;
  }
}

- (UITableViewCell *)drawInextensibleCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"ExtensibilityCell";
  ExtensibilityCell *cell = (ExtensibilityCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    [cell.contentView setBackgroundColor:COLOR(51, 51, 51)];

    cell.arrowImageView.hidden = YES;
  }
  
  NSString *name = [self.listArray objectAtIndex:indexPath.section];
  cell.titleLabel.text = name;

  if (((NSNumber *)[AppManager instance].welfareTypeList[indexPath.section][RECORD_SELECTION_IDX]).integerValue == SELECTED_TY) {
    cell.dotIcon.hidden = YES;//NO; hide dot icon currently
    cell.titleLabel.textColor = COLOR(255, 102, 102);
  } else {
    cell.dotIcon.hidden = YES;
    cell.titleLabel.textColor = COLOR(246, 246, 246);
  }

  return cell;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section < self.paramArray.count) {
    return [self drawExtendableCellWithTableView:tableView indexPath:indexPath];
  } else {
    return [self drawInextensibleCellWithTableView:tableView indexPath:indexPath];
  }
}

#pragma mark - Table view delegate

- (void)recoveryMainView {
  [self.navigationController removeFromParentViewController];
  [self.navigationController.view removeFromSuperview];
  
  if ([self.mainVC respondsToSelector:@selector(recoveryMainVC)]) {
    [self.mainVC performSelector:@selector(recoveryMainVC)];
  }
}

- (void)resetGroupTypeOption {
  
  switch ([AppManager instance].filterSupIndex) {
    case 1:
    {
      // user select alumni branch, then set club type to "All"
      NSArray *list = self.paramArray[2];
      for (NSInteger i = 0; i < list.count; i++) {
        if (i == 0) {
          self.paramArray[2][i][RECORD_SELECTION_IDX] = @(SELECTED_TY);
        } else {
          self.paramArray[2][i][RECORD_SELECTION_IDX] = @(UNSELECTED_TY);
        }
      }
      break;
    }
      
    case 2:
    {
      // user select club, the nset alumni branch type to "All"
      NSArray *list = self.paramArray[1];
      for (NSInteger i = 0; i < list.count; i++) {
        if (i == 0) {
          self.paramArray[1][i][RECORD_SELECTION_IDX] = @(SELECTED_TY);
        } else {
          self.paramArray[1][i][RECORD_SELECTION_IDX] = @(UNSELECTED_TY);
        }
      }
      break;
    }
      
    default:
      break;
  }
  
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  if (indexPath.section < self.paramArray.count) {
    
    // 用户点击了可伸缩的1级cell或2级cell
    if (self.paramArray.count > 0) {
      
      // table is extendable
      if (indexPath.row == 0) {
        if ([indexPath isEqual:self.selectIndex]) {
          self.isOpen = NO;
          [self didSelectCellRowFirstDo:NO nextDo:NO];
          self.selectIndex = nil;
          
        } else {
          if (!self.selectIndex) {
            self.selectIndex = indexPath;
            [self didSelectCellRowFirstDo:YES nextDo:NO];
          } else {
            [self didSelectCellRowFirstDo:NO nextDo:YES];
          }
        }
      } else {
        int filterIndex = indexPath.row-1;
        [AppManager instance].filterSupIndex = [indexPath section];
        [AppManager instance].filterIndex = filterIndex;
        
        NSArray *filterList = self.paramArray[indexPath.section];
        for (NSInteger i = 0; i < filterList.count; i++) {
          if (i == filterIndex) {
            self.paramArray[indexPath.section][i][RECORD_SELECTION_IDX] = @(SELECTED_TY);
          } else {
            self.paramArray[indexPath.section][i][RECORD_SELECTION_IDX] = @(UNSELECTED_TY);
          }
        }
        
        if (_forGroup) {
          [self resetGroupTypeOption];
        }
        
        [self recoveryMainView];
      }
    } else {
      
      // not extendable cell
      [AppManager instance].filterSupIndex = indexPath.section;
      
      for (NSInteger i = 0; i < [AppManager instance].welfareTypeList.count; i++) {
        if (i == indexPath.section) {
          [AppManager instance].welfareTypeList[i][RECORD_SELECTION_IDX] = @(SELECTED_TY);
        } else {
          [AppManager instance].welfareTypeList[i][RECORD_SELECTION_IDX] = @(UNSELECTED_TY);
        }
      }
      
      [self recoveryMainView];
    }
    
  } else {
    
    // 用户点击了不可伸缩的1级cell
    [AppManager instance].filterSupIndex = indexPath.section;
    [self recoveryMainView];
  }
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
  self.isOpen = firstDoInsert;
  
  ExtensibilityCell *cell = (ExtensibilityCell *)[self.expansionTableView cellForRowAtIndexPath:self.selectIndex];
  [cell changeArrowWithUp:firstDoInsert];
  
  [self.expansionTableView beginUpdates];
  
  int section = self.selectIndex.section;
  int contentCount = [[self.paramArray objectAtIndex:section] count];
  
	NSMutableArray *rowToInsert = [[NSMutableArray alloc] init];
	for (NSUInteger i = 1; i < contentCount + 1; i++) {
		NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
		[rowToInsert addObject:indexPathToInsert];
	}
	
	if (firstDoInsert)
  {   [self.expansionTableView insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
  }
	else
  {
    [self.expansionTableView deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
  }
  
	[rowToInsert release];
	
	[self.expansionTableView endUpdates];
  if (nextDoInsert) {
    self.isOpen = YES;
    self.selectIndex = [self.expansionTableView indexPathForSelectedRow];
    [self didSelectCellRowFirstDo:YES nextDo:NO];
  }
  if (self.isOpen) [self.expansionTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (UIView *)addSearchBarView {
  // Search Bar
  self.searchBarBGView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SHORT_W, SEARCH_BAR_H)] autorelease];
  [self.searchBarBGView setBackgroundColor:COLOR(51, 51, 51)];
  
  self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SHORT_W, SEARCH_BAR_H)] autorelease];
  self.searchBar.delegate = self;
  self.searchBar.placeholder = LocaleStringForKey(NSSearchPromptTitle, nil);
  
  if ([CommonUtils currentOSVersion] < IOS7) {
    [(self.searchBar.subviews)[0]removeFromSuperview];
    [self.searchBar setBackgroundColor:TRANSPARENT_COLOR];
  } 
  
  [self.searchBarBGView addSubview:self.searchBar];
  
  self.closeSearchBarBut = [[[ECGradientButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-70.f, MARGIN+3.f, 60.f, 30.f)
                                                             target:self
                                                             action:@selector(doCloseSearchBar:)
                                                          colorType:TINY_GRAY_BTN_COLOR_TY
                                                              title:LocaleStringForKey(NSCancelTitle, nil)
                                                              image:nil
                                                         titleColor:COLOR(117, 117, 117)
                                                   titleShadowColor:GRAY_BTN_TITLE_SHADOW_COLOR
                                                          titleFont:BOLD_FONT(13)
                                                        roundedType:HAS_ROUNDED
                                                    imageEdgeInsert:ZERO_EDGE
                                                    titleEdgeInsert:ZERO_EDGE] autorelease];
  [self.searchBarBGView addSubview:self.closeSearchBarBut];
  self.closeSearchBarBut.hidden = YES;
  
  return self.searchBarBGView;
}

#pragma mark - UISearchBarDelegate method
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)aSearchBar
{  
  if (self.delegate) {
    [self.delegate arrangeViewsForKeywordsSearch];
  }
  
  return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar
{

  [self initDisableView:CGRectMake(0.0f, 44.0f, 320.0f, 416.0f)];
  [self showDisableView];
  
  self.searchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH-80.f, SEARCH_BAR_H);
  
  self.closeSearchBarBut.hidden = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
  
  [self.searchBar resignFirstResponder];
  [AppManager instance].searchKeyWords = self.searchBar.text;

  if ([self.mainVC respondsToSelector:@selector(recoveryMainVC)]) {
    [self.mainVC performSelector:@selector(recoveryMainVC)];
  }

  [self removeDisableView];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)aSearchBar
{
  [self.searchBar resignFirstResponder];
  return YES;
}

#pragma mark - action
- (void)doCloseSearchBar:(id)sender {
  
  [self removeDisableView];
  
  self.searchBar.text = NULL_PARAM_VALUE;

  [self.searchBar resignFirstResponder];
  
  self.searchBar.frame = CGRectMake(0, 0, SHORT_W, SEARCH_BAR_H);
  
  self.closeSearchBarBut.hidden = YES;
  
  if (self.delegate) {
    [self.delegate arrangeViewsForCancelKeywordsSearch];
  }
}

#pragma mark - DisableView option
- (void)initDisableView:(CGRect)frame {
  
  self.disableViewOverlay = [[[UIView alloc]
                              initWithFrame:frame] autorelease];
  self.disableViewOverlay.backgroundColor=[UIColor blackColor];
  self.disableViewOverlay.alpha = 0;
}

- (void)showDisableView {
  
  self.disableViewOverlay.alpha = 0;
  [self.view addSubview:self.disableViewOverlay];
  
  [UIView beginAnimations:@"FadeIn" context:nil];
  [UIView setAnimationDuration:0.5];
  self.disableViewOverlay.alpha = 0.6;
  [UIView commitAnimations];
}

- (void)removeDisableView {
  
  [self.disableViewOverlay removeFromSuperview];
}

@end
