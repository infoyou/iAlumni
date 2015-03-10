//
//  BaseFilterListViewController.m
//  iAlumni
//
//  Created by Adam on 13-7-29.
//
//

#import "BaseFilterListViewController.h"
#import "ECAsyncConnectorFacade.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "PlainTabView.h"
#import "AppManager.h"
#import "Search2FilterViewController.h"
#import "ILBarButtonItem.h"

@interface BaseFilterListViewController()
{
}

@property (nonatomic, retain) UINavigationController *filterNavVC;
@property (nonatomic, retain) Search2FilterViewController *search2FilterVC;
@property (nonatomic, retain) UIView *filterViewOverlay;
@property (nonatomic, retain) NSMutableArray *searchArray;
@property (nonatomic, retain) NSMutableArray *paramsArray;
@end

@implementation BaseFilterListViewController

#pragma mark - lifecycle methods

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
needRefreshHeaderView:(BOOL)needRefreshHeaderView
needRefreshFooterView:(BOOL)needRefreshFooterView
       needGoHome:(BOOL)needGoHome {
    
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:NO
        needRefreshFooterView:YES
                   needGoHome:NO];

    if (self) {
    }
    return self;
}

- (void)dealloc {
  
  self.filterNavVC = nil;
  self.search2FilterVC = nil;
  self.filterViewOverlay = nil;
  self.searchArray = nil;
  self.paramsArray = nil;
    
    [super dealloc];
}

- (void)setListData:(NSMutableArray *)searchArray paramArray:(NSMutableArray *)paramsArray {
    self.searchArray = searchArray;
    self.paramsArray = paramsArray;
}

- (void)addFilterButton {
    _searchBtn = [ILBarButtonItem barItemWithImage:[UIImage imageNamed:@"btnSearchWhite.png"]
                                     selectedImage:[UIImage imageNamed:@"btnSearchWhite.png"]
                                            target:self
                                            action:@selector(clickFilterMenu:)];
  
    self.navigationItem.rightBarButtonItem = _searchBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addFilterButton];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - click Filter Menu
-(void)clickFilterMenu:(id)sender {
    
    [AppManager instance].searchKeyWords = NULL_PARAM_VALUE;
    
    int x = 0;
    if (!isClickSearch) {
        x = self.view.frame.origin.x-220.f;
    }
    
    // right vc
    if (x != 0) {
        
        self.search2FilterVC = nil;
        self.search2FilterVC = [[[Search2FilterViewController alloc] initWithStyle:UITableViewStylePlain mainVC:self] autorelease];
        [self.search2FilterVC setListData:self.searchArray paramArray:self.paramsArray];
        self.filterNavVC = [[[UINavigationController alloc] initWithRootViewController:self.search2FilterVC] autorelease];
    }
    
    [self.filterNavVC.view setFrame:CGRectMake(100.f, 0.f, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.navigationController.view.frame = CGRectMake(x, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    [[self.navigationController.view superview] addSubview:self.filterNavVC.view];
    
    if (x != 0) {
        [UIView animateWithDuration:0.5 animations:^(void){
            self.navigationController.view.frame = CGRectMake(x, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            [self.filterNavVC.view setFrame:CGRectMake(100.f, 0.f, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [self initFilterView:CGRectMake(0.f, 0.f, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [self showFilterView];
        } completion:^(BOOL finished) {
            [[self.navigationController.view superview] addSubview:self.filterNavVC.view];
        }];
    } else {
        [self hideFilterView:nil];
    }
    
    isClickSearch = !isClickSearch;
}

- (void)clearData {
}

#pragma mark - handle vc
- (void)extendFilterVC
{
    [self.navigationController.view setFrame:CGRectMake(0-SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.filterNavVC.view setFrame:CGRectMake(0.f, 0.f, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self removeFilterView];
}

- (void)recoveryMainVC
{
    // main vc
    [self.navigationController.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    isClickSearch = !isClickSearch;
    
    [self hideFilterView:nil];
    [self clearData];
}

#pragma mark - Filter View option
- (void)initFilterView:(CGRect)frame {
    self.filterViewOverlay = [[[UIView alloc]
                               initWithFrame:frame] autorelease];
    self.filterViewOverlay.backgroundColor = [UIColor clearColor];
    self.filterViewOverlay.alpha = 0;
    [self addTapGestureRecognizer];
}

- (void)showFilterView {
    self.filterViewOverlay.alpha = 0;
    [self.view addSubview:self.filterViewOverlay];
    
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    self.filterViewOverlay.alpha = 0.6;
    self.filterViewOverlay.userInteractionEnabled = YES;
    [UIView commitAnimations];
}

- (void)removeFilterView {
    [self.filterViewOverlay removeFromSuperview];
}

- (void)addTapGestureRecognizer {
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideFilterView:)] autorelease];
    [self.filterViewOverlay addGestureRecognizer:tap];
}

- (void)hideFilterView:(id)sender {
    [UIView animateWithDuration:0.5 animations:^(void){
        if (self.filterNavVC) {
            [self.filterNavVC removeFromParentViewController];
            [self.filterNavVC.view removeFromSuperview];
        }
    } completion:^(BOOL finished) {
        self.navigationController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self removeFilterView];
    }];
}

@end