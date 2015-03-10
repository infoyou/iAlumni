//
//  SearchClubViewController.m
//  iAlumni
//
//  Created by Adam on 12-8-20.
//
//

#import "SearchClubViewController.h"
#import "ClubListViewController.h"
#import "ECGradientButton.h"
#import "AppManager.h"
#import "CommonUtils.h"

#define SEARCH_BAR_H    44.f

@interface SearchClubViewController ()
@property (nonatomic, retain) UIView *searchBarBGView;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) ECGradientButton *closeSearchBarBut;
@property (nonatomic, retain) UIFilterView *filterView;
@end

@implementation SearchClubViewController

- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
  self = [super init];
  
  if (self) {
    _MOC = MOC;
  }
  
  return self;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  
  self.searchBar = nil;
  self.closeSearchBarBut = nil;
  self.searchBarBGView = nil;
  self.filterView = nil;
  
  [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
  if (self.searchBar != nil && ![NULL_PARAM_VALUE isEqualToString:self.searchBar.text]) {
    [self doCloseSearchBar:nil];
  }
}

- (void)addSearchBarView
{
    // Search Bar
    self.searchBarBGView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SEARCH_BAR_H)] autorelease];
    [self.searchBarBGView setBackgroundColor:COLOR(243, 238, 225)];
    
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SEARCH_BAR_H)] autorelease];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = LocaleStringForKey(NSSearchPromptTitle, nil);
    [(self.searchBar.subviews)[0]removeFromSuperview];
    [self.searchBar setBackgroundColor:TRANSPARENT_COLOR];
    
    [self.searchBarBGView addSubview:self.searchBar];
    
    self.closeSearchBarBut = [[[ECGradientButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-70.f, MARGIN, 60.f, 30.f)
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
    
    [self.view addSubview:self.searchBarBGView];
}

- (void)addFilterListView {

    // Table Cascade view
    self.filterView = [[[UIFilterView alloc] initWithFrame:CGRectMake(0, SEARCH_BAR_H, SCREEN_WIDTH, SCREEN_HEIGHT-(SEARCH_BAR_H*2+20.f)) tableFilterDelegate:self size:2] autorelease];
    [self.filterView setFilterData:[AppManager instance].supClubFilterList rightArray:[AppManager instance].clubFilterList];
    [self.view addSubview:self.filterView];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  
    [self addSearchBarView];
  
    [self addFilterListView];
  
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

#pragma mark - UISearchBarDelegate method
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)aSearchBar
{
  
  return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar
{
  [super initDisableView:CGRectMake(0.0f, 44.0f, 320.0f, 416.0f)];
  [self showDisableView];
  
  self.searchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH-80.f, SEARCH_BAR_H);
  
  self.closeSearchBarBut.hidden = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar {
  // Clear the search text
  // Deactivate the UISearchBar
  self.searchBar.text = NULL_PARAM_VALUE;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
  
  [self.searchBar resignFirstResponder];
  [AppManager instance].clubKeyWord = self.searchBar.text;
  
  [self goClubView:nil];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)aSearchBar
{
  [self.searchBar resignFirstResponder];
  return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
  
}

-(void)didSelectResult:(int)leftIndex rightStr:(int)rightIndex {
  
  self.searchBar.text = NULL_PARAM_VALUE;
  [AppManager instance].clubKeyWord = NULL_PARAM_VALUE;
  [self goClubView:nil];
}

#pragma mark - action
- (void)doCloseSearchBar:(id)sender {
  
  [self removeDisableView];
  
  self.searchBar.text = NULL_PARAM_VALUE;
  self.searchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, SEARCH_BAR_H);
  [self.searchBar resignFirstResponder];
  
  self.closeSearchBarBut.hidden = YES;
  
}

- (void)goClubView:(id)sender {
  
  //[CommonUtils doDelete:_MOC entityName:@"Club"];
  
  ClubListViewController *clubListVC = [[ClubListViewController alloc] initWithMOC:_MOC listType:CLUB_LIST_BY_NAME];
  
  clubListVC.title = LocaleStringForKey(NSClubTitle, nil);
  clubListVC.pageIndex = 0;
  
  [self.navigationController pushViewController:clubListVC animated:YES];
  RELEASE_OBJ(clubListVC);
  
}

@end
