//
//  Search2FilterViewController.m
//  iAlumni
//
//  Created by Adam on 13-7-31.
//
//

#import "Search2FilterViewController.h"
#import "FilterListViewController.h"
#import "WXWNavigationController.h"
#import "ECGradientButton.h"
#import "AppManager.h"
#import "FilterListCell.h"
#import "GroupMemberPhotoListViewController.h"

#define     HEADER_HEIGHT       44.f
#define     SEARCH_BAR_H        44.f
#define     SHORT_W             220.f
#define     CELL_HEIGHT         44.f

@interface Search2FilterViewController () <UISearchBarDelegate>
@property (nonatomic, retain) NSArray *listArray;
@property (nonatomic, retain) NSMutableArray *paramArray;
@property (nonatomic, retain) UIView *searchBarBGView;
@property (nonatomic, retain) UIView *disableViewOverlay;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) ECGradientButton *closeSearchBarBut;
@property (nonatomic, retain) UIViewController *mainVC;
@end

@implementation Search2FilterViewController

- (id)initWithStyle:(UITableViewStyle)style mainVC:(UIViewController *)mainVC
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.mainVC = mainVC;
    }
    return self;
}

- (void)setListData:(NSArray *)listArray paramArray:(NSMutableArray *)paramArray {
    
    self.listArray = listArray;
    self.paramArray = paramArray;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:COLOR(51, 51, 51)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    [self addSearchBarView];
//    self.tableView.frame = CGRectMake(0, HEADER_HEIGHT, self.tableView.frame.size.width, self.tableView.frame.size.height - HEADER_HEIGHT);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)addSearchBarView {
    // Search Bar
    self.searchBarBGView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SHORT_W, SEARCH_BAR_H)] autorelease];
    [self.searchBarBGView setBackgroundColor:COLOR(51, 51, 51)];
    
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SHORT_W, SEARCH_BAR_H)] autorelease];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = LocaleStringForKey(NSSearchPromptTitle, nil);
    [(self.searchBar.subviews)[0]removeFromSuperview];
    [self.searchBar setBackgroundColor:TRANSPARENT_COLOR];
    
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
    
//    self.tableView.tableHeaderView = self.searchBarBGView;
    return self.searchBarBGView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.listArray count] > 0) {
        return [self.listArray count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self addSearchBarView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Search2FilterViewController";
    FilterListCell *cell = (FilterListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[[FilterListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell...
    int row = [indexPath row];
    cell.textLabel.text = [self.listArray objectAtIndex:row];
    cell.textLabel.textColor = COLOR(249, 249, 249);
    cell.textLabel.font = FONT(17);
    
    [cell drawCell];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    [AppManager instance].filterSupIndex = [indexPath row];
    [(GroupMemberPhotoListViewController*)self.mainVC recoveryMainVC];
}

#pragma mark - UISearchBarDelegate method
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)aSearchBar
{
    [(GroupMemberPhotoListViewController*)self.mainVC extendFilterVC];
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)aSearchBar
{
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.searchBarBGView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.searchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    [self initDisableView:CGRectMake(0.0f, 44.0f, 320.0f, 416.0f)];
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
    
    [(GroupMemberPhotoListViewController*)self.mainVC extendFilterVC];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    
    [self.searchBar resignFirstResponder];
    [AppManager instance].searchKeyWords = self.searchBar.text;
    [(GroupMemberPhotoListViewController*)self.mainVC recoveryMainVC];
    
    [self removeDisableView];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)aSearchBar
{
    [self.searchBar resignFirstResponder];
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar
{
    
}

#pragma mark - action
- (void)doCloseSearchBar:(id)sender {
    
    [self removeDisableView];
    
    self.searchBar.text = NULL_PARAM_VALUE;
    self.searchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, SEARCH_BAR_H);
    [self.searchBar resignFirstResponder];
    
    self.closeSearchBarBut.hidden = YES;
    
    [(GroupMemberPhotoListViewController*)self.mainVC recoveryMainVC];
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
