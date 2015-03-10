//
//  SupplyDemandListViewController.m
//  iAlumni
//
//  Created by Adam on 13-5-22.
//
//

#import "SupplyDemandListViewController.h"
#import "UIImageButton.h"
#import "SupplyDemandCell.h"
#import "Post.h"
#import "SupplyDemandComposerViewController.h"
#import "WXWNavigationController.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "AppManager.h"
#import "UIUtils.h"
#import "TagSearchResultViewController.h"
#import "PopupView.h"
#import "SupplyDemandItemViewController.h"
#import "WXWLabel.h"
#import "Tag.h"
#import "NaviButton.h"
#import "UIWebViewController.h"

#define SEARCHBAR_HEIGHT  40.0f

#define SUBMIT_BUTTON_WIDTH         200.0f
#define SUBMIT_BUTTON_HEIGHT        36.0f

#define CELL_HEIGHT   88.0f

#define BOTTOM_TOOL_HEIGHT          0 //32.0f

enum {
    ALL_SD_TY,
    S_TY = SUPPLY_POST_TY,
    D_TY = DEMAND_POST_TY,
    LIKED_SD_TY,
    MY_SD_TY,
};

@interface SupplyDemandListViewController ()
@property (nonatomic, retain) UIView *searchbackgroundView;
@property (nonatomic, copy) NSString *keywords;
@end

@implementation SupplyDemandListViewController

#pragma mark - user action
- (void)cancelSearch:(UITapGestureRecognizer *)gesture {
    [self disableSearchStatus];
    
    if (_clearButtonClicked) {
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
        
        _clearButtonClicked = NO;
    }
}

- (void)selectFilter:(NSNumber *)filterType {
    _filterType = filterType.intValue;
    
    [self resetKeywordSearchElements];
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)selectedFeedBeDeleted {
    _selectedFeedBeDeleted = YES;
}

- (void)setRefreshFlag {
    _needRefresh = YES;
}

#pragma mark - load data
- (void)loadTags {
    _currentType = SUPPLY_DEMAND_TAG_TY;
    
    NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:SUPPLY_DEMAND_TAG_TY];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:SUPPLY_DEMAND_TAG_TY];
    [connFacade asyncGet:url showAlertMsg:YES];
    
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
    
    [super loadListData:triggerType
                 forNew:forNew];
    
    _currentType = LOAD_SUPPLY_DEMAND_ITEM_TY;
    
    NSInteger index = 0;
    if (!forNew) {
        index = ++_currentStartIndex;
    }
    
    NSString *param = [NSString stringWithFormat:@"<page_size>%@</page_size><sort_type>%d</sort_type><post_type>%d</post_type><supply_demand>%d</supply_demand><page>%d</page><keyword>%@</keyword><latitude></latitude><longitude></longitude>",
                       ITEM_LOAD_COUNT,
                       SORT_BY_ID_TY,
                       SUPPLY_DEMAND_COMBINE_TY,
                       _filterType,
                       index,
                       self.keywords];
    
    NSMutableString *requestParam = [NSMutableString stringWithString:param];
    
    if (_filterType == LIKED_SD_TY) {
        [requestParam appendString:@"<is_favorite>1</is_favorite>"];
    }
    
    NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade fetchNews:url];
    
    self.keywords = NULL_PARAM_VALUE;
    
    _needRefresh = NO;
}

- (void)configureMOCFetchConditions {
    self.entityName = @"Post";
    self.descriptors = [NSMutableArray array];
    NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO] autorelease];
    [self.descriptors addObject:descriptor];
    
    switch (_filterType) {
        case S_TY:
        case D_TY:
            self.predicate = [NSPredicate predicateWithFormat:@"(postType == %d)", _filterType];
            break;
            
        case LIKED_SD_TY:
            self.predicate = [NSPredicate predicateWithFormat:@"(favorited == 1)"];
            break;
            
        default:
            self.predicate = nil;
            break;
    }
    
}

#pragma mark - search tag
- (void)searchWithTag:(Tag *)tag {
    
    TagSearchResultViewController *tagSearchResultVC = [[[TagSearchResultViewController alloc] initWithMOC:_MOC tagId:tag.tagId] autorelease];
    tagSearchResultVC.title = STR_FORMAT(LocaleStringForKey(NSSearchTagTitle, nil), tag.tagName);
    [self.navigationController pushViewController:tagSearchResultVC animated:YES];
    
    _needRefresh = YES;
}

#pragma mark - user action

- (void)resetKeywordSearchElements {
    _searchBar.text = nil;
    self.keywords = NULL_PARAM_VALUE;
}

- (void)openFilterOptions:(id)sender {
    
    [self disableSearchStatus];
    
    PopupView *popupView = [[[PopupView alloc] initWithDelegate:self
                                                selectionAction:@selector(selectFilter:)] autorelease];
    
    NSDictionary *dic = @{@(ALL_SD_TY):LocaleStringForKey(NSAllTitle, nil),
                          @(S_TY):LocaleStringForKey(NSSupplyLongTitle, nil),
                          @(D_TY):LocaleStringForKey(NSDemandLongTitle, nil),
                          @(LIKED_SD_TY):LocaleStringForKey(NSFollowedTitle, nil),
                          @(MY_SD_TY):LocaleStringForKey(NSMySupplyDemandTitle, nil)};
    [popupView presentFromFrame:CGRectMake(SCREEN_WIDTH - 50, 20, 50, 44)
                      optionDic:dic
           currentSelectedIndex:_filterType];
}

- (void)doSendSupplyDemand
{
    SupplyDemandComposerViewController *composerVC = [[[SupplyDemandComposerViewController alloc] initWithMOC:_MOC uploadDelegate:self] autorelease];
    composerVC.title = LocaleStringForKey(NSPublishSupplyDemandTitle, nil);
    WXWNavigationController *nav = [[[WXWNavigationController alloc] initWithRootViewController:composerVC] autorelease];
    
    nav.title = LocaleStringForKey(NSPublishSupplyDemandTitle, nil);
    
    //    [self.navigationController presentModalViewController:nav animated:YES];
    [self.parentVC presentModalViewController:nav animated:YES];
    //    [self.parentVC.navigationController pushViewController:nav animated:YES];
    //    [self.parentVC pushViewController:nav animated:YES];
    
    _returnFromComposer = YES;
}

- (void)sendSupplyDemand:(UITapGestureRecognizer *)tapGesture {

    [self doSendSupplyDemand];
}

#pragma mark - lifecycle methods

- (void)initBottomToolbar {
    
    CGFloat y = self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - BOTTOM_TOOL_HEIGHT;
    if (_needAdjustForiOS7) {
        y = self.view.frame.size.height - BOTTOM_TOOL_HEIGHT - NAVIGATION_BAR_HEIGHT - SYS_STATUS_BAR_HEIGHT;
    }
    
    y -= HOMEPAGE_TAB_HEIGHT;
    _bottomToolbar = [[[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, BOTTOM_TOOL_HEIGHT)] autorelease];
    _bottomToolbar.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.7f];
    [self.view addSubview:_bottomToolbar];
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(sendSupplyDemand:)] autorelease];
    [_bottomToolbar addGestureRecognizer:tapGesture];
    
    UIView *topLine = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, _bottomToolbar.frame.size.width, 2.0f)] autorelease];
    topLine.backgroundColor = ORANGE_COLOR;
    [_bottomToolbar addSubview:topLine];
    
    UIImageView *icon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sendSupplyDemand.png"]] autorelease];
    [_bottomToolbar addSubview:icon];
    WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                             textColor:[UIColor whiteColor]
                                           shadowColor:TRANSPARENT_COLOR
                                                  font:BOLD_FONT(15)] autorelease];
    [_bottomToolbar addSubview:label];
    
    label.text = LocaleStringForKey(NSPublishSupplyDemandTitle, nil);
    CGSize size = [label.text sizeWithFont:label.font];
    
    CGFloat width = icon.frame.size.width + MARGIN + size.width;
    
    icon.frame = CGRectMake((_bottomToolbar.frame.size.width - width)/2.0f, (_bottomToolbar.frame.size.height - icon.frame.size.height)/2.0f, icon.frame.size.width, icon.frame.size.height);
    label.frame = CGRectMake(icon.frame.origin.x + icon.frame.size.width + MARGIN, (_bottomToolbar.frame.size.height - size.height)/2.0f, size.width, size.height);
    
    _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y,
                                  _tableView.frame.size.width, _tableView.frame.size.height - BOTTOM_TOOL_HEIGHT);
}


- (void)initSearchBar {
    _searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0,
                                                                self.view.frame.size.width,
                                                                SEARCHBAR_HEIGHT)] autorelease];
    _searchBar.delegate = self;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _searchBar.placeholder = LocaleStringForKey(NSSupplyDemandSearchPlaceholderTitle, nil);
    [_searchBar sizeToFit];
    _searchBar.tintColor = [UIColor lightGrayColor];
    
    _tableView.tableHeaderView = _searchBar;
    
    for (UIView *view in _searchBar.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            _searchTextField = (UITextField *)view;
            
            _searchTextField.delegate = self;
        }
    }
}

- (void)clearSupplyDemandItems {
    DELETE_OBJS_FROM_MOC(_MOC, @"Post", ([NSPredicate predicateWithFormat:@"(postType == %d) OR (postType == %d)", S_TY, D_TY]));
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
needAdjustForiOS7:(BOOL)needAdjustForiOS7 parentVC:(UIViewController *)parentVC
{
    
    self = [self initWithMOC:MOC needAdjustForiOS7:needAdjustForiOS7];
    
    if (self) {
        
        self.parentVC = parentVC;
    }
    
    return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
needAdjustForiOS7:(BOOL)needAdjustForiOS7
{
    self = [super initNoNeedLoadBackendDataWithMOC:MOC
                                            holder:nil
                                  backToHomeAction:nil
                             needRefreshHeaderView:NO
                             needRefreshFooterView:YES
                                        tableStyle:UITableViewStylePlain
                                        needGoHome:NO];
    if (self) {
        
        _filterType = ALL_SD_TY;
        
        _needAdjustForiOS7 = needAdjustForiOS7;
        
        DELETE_OBJS_FROM_MOC(_MOC, @"Post", nil);
        
        self.keywords = NULL_PARAM_VALUE;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectedFeedBeDeleted)
                                                     name:FEED_DELETED_NOTIFY
                                                   object:nil];
        
    }
    return self;
}

- (id)initFavoritedItemsWithMOC:(NSManagedObjectContext *)MOC
              needAdjustForiOS7:(BOOL)needAdjustForiOS7{
    self = [self initWithMOC:MOC needAdjustForiOS7:needAdjustForiOS7];
    if (self) {
        
        _filterType = LIKED_SD_TY;
        
        _forFavorited = YES;
    }
    
    return self;
}

- (void)dealloc {
    
    _searchBar.delegate = nil;
    
    self.searchbackgroundView = nil;
    
    self.keywords = nil;
    
    _searchTextField.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FEED_DELETED_NOTIFY
                                                  object:nil];
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_forFavorited) {
        [self addRightBarButtonWithTitle:LocaleStringForKey(NSFilterTitle, nil)
                                  target:self
                                  action:@selector(openFilterOptions:)];
    }
    
    [self initSearchBar];
    
//    [self initBottomToolbar];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![WXWCoreDataUtils objectInMOC:_MOC entityName:@"Tag" predicate:nil]) {
        [self loadTags];
    } else if (!_autoLoaded) {
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    }
    
    if (_needRefresh) {
        self.fetchedRC = nil;
        DELETE_OBJS_FROM_MOC(_MOC, @"Post", nil);
        [self refreshTable];
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    }
    
    if (!_selectedFeedBeDeleted) {
        [self updateLastSelectedCell];
    } else {
        [self deleteLastSelectedCell];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - arrange search bar
- (void)disableSearchStatus {
    
    if (self.searchbackgroundView.alpha > 0.0f && _searchBar.isFirstResponder) {
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self.searchbackgroundView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished){
                             [self.searchbackgroundView removeFromSuperview];
                         }];
        
        [_searchBar resignFirstResponder];
        
        [_searchBar setShowsCancelButton:NO animated:YES];
        
    }
}

#pragma mark - keyword search
- (void)searchWithKeywords {
    
    [self clearSupplyDemandItems];
    
    [self refreshTable];
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    if (_clearButtonClicked) {
        
        // user click the clear button, the clear the search bar text and reload
        // list for all supply and demand items
        
        _clearButtonClicked = NO;
        [_searchBar resignFirstResponder];
        
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
        return;
    }
    
    self.searchbackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, SEARCHBAR_HEIGHT + 4, self.view.frame.size.width, self.view.frame.size.height - SEARCHBAR_HEIGHT)] autorelease];
    self.searchbackgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(cancelSearch:)] autorelease];
    [self.searchbackgroundView addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self.searchbackgroundView];
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.searchbackgroundView.alpha = 0.8f;
                     }];
    
    [_searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.keywords = searchText;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self disableSearchStatus];
    
    [self searchWithKeywords];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self disableSearchStatus];
    
    self.keywords = NULL_PARAM_VALUE;
    
    if (_clearButtonClicked) {
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
        
        _clearButtonClicked = NO;
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    return self.fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)drawItemCellWithIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"itemCell";
    
    SupplyDemandCell *cell = (SupplyDemandCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (nil == cell) {
        cell = [[[SupplyDemandCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:kCellIdentifier
                                         searchDelegate:self
                                           searchAction:@selector(searchWithTag:)
                                                    MOC:_MOC] autorelease];
    }
    
    Post *item = self.fetchedRC.fetchedObjects[indexPath.row];
    if (item) {
        [cell drawCellWithItem:item];
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self currentCellIsFooter:indexPath]) {
        return [self drawFooterCell];
    } else {
        return [self drawItemCellWithIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self currentCellIsFooter:indexPath]) {
        return;
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    Post *item = self.fetchedRC.fetchedObjects[indexPath.row];
    SupplyDemandItemViewController *supplyDemandItemVC = [[[SupplyDemandItemViewController alloc] initMOC:_MOC
                                                                                                     item:item
                                                                                                   target:self
                                                                                    triggerRrefreshAction:@selector(setRefreshFlag)] autorelease];
    
    supplyDemandItemVC.title = LocaleStringForKey(NSSponsorTitle, nil);
    
//    [self.navigationController pushViewController:supplyDemandItemVC animated:YES];
    
    [self.parentVC.navigationController pushViewController:supplyDemandItemVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return CELL_HEIGHT;
}

#pragma mark - ECConnectorDelegate methoes
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
    
    BOOL blockCurrentView = NO;
    if (_userFirstUseThisList) {
        blockCurrentView = YES;
    } else {
        blockCurrentView = NO;
    }
    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
              blockCurrentView:blockCurrentView];
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
    
    BOOL closeAsyncLoadingView = YES;
    
    switch (contentType) {
        case SUPPLY_DEMAND_TAG_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                
                _autoLoaded = YES;
                
                closeAsyncLoadingView = NO;
                
                [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
            }
            
            break;
        }
            
        case POST_FAVORITE_ACTION_TY:
        case POST_UNFAVORITE_ACTION_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                
                NSLog(@"done");
            } else {
                NSLog(@"failed");
            }
            
            break;
        }
            
        case LOAD_SUPPLY_DEMAND_ITEM_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                
                [self refreshTable];
                
                _autoLoaded = YES;
                
                if (_autoLoadAfterSent) {
                    _autoLoadAfterSent = NO;
                }
                
            } else {
                [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                                       alternativeMsg:LocaleStringForKey(NSLoadSupplyDemandFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
            }
            
            [self resetUIElementsForConnectDoneOrFailed];
            
            if (_userFirstUseThisList) {
                _userFirstUseThisList = NO;
            }
            
            break;
        }
            
        default:
            break;
    }
    
    [super connectDone:result url:url contentType:contentType closeAsyncLoadingView:closeAsyncLoadingView];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
    [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
    
    switch (contentType) {
        case SUPPLY_DEMAND_TAG_TY:
        case LOAD_SUPPLY_DEMAND_ITEM_TY:
        {
            if (_autoLoadAfterSent) {
                _autoLoadAfterSent = NO;
            }
            
            if ([self connectionMessageIsEmpty:error]) {
                self.connectionErrorMsg = LocaleStringForKey(NSLoadFeedFailedMsg, nil);
            }
            
            if (_userFirstUseThisList) {
                _userFirstUseThisList = NO;
            }
        }
            break;
            
        default:
            break;
    }
    
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - ECItemUploaderDelegate methods
- (void)afterUploadFinishAction:(WebItemType)actionType {
    
    _autoLoadAfterSent = YES;
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - UITextFieldDelegate methods
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    _clearButtonClicked = YES;
    
    return YES;
}

#pragma mark - scrolling override
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([UIUtils shouldLoadOlderItems:scrollView
                      tableViewHeight:_tableView.contentSize.height + SEARCHBAR_HEIGHT
                           footerView:_footerRefreshView
                            reloading:_reloading]) {
        
        _reloading = YES;
        
        _shouldTriggerLoadLatestItems = YES;
        
        [self loadListData:TRIGGERED_BY_SCROLL forNew:NO];
    }
}


@end
