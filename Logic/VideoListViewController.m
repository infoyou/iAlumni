//
//  VideoListViewController.m
//  iAlumni
//
//  Created by Adam on 13-1-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VideoListViewController.h"
#import "Video.h"
#import "VideoViewController.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "VideoListCell.h"
#import "VideoToolView.h"
#import "MKHorizMenu.h"

#define FONT_SIZE       12.0f
#define TITLE_W         200.f
#define TITLE_Y         10.0f
#define DATE_H          20.f
#define MARK_IMG_H      16.f
#define THUMB_SIDE_LENGTH 80.0f

enum {
    horizVideoTypeTag = 1001,
    horizVideoSortTag = 1002,
};

enum {
    OPEN_VIDEO_IDX,
    SHARE_WECHAT_IDX,
};

@interface VideoListViewController() <ECFilterListDelegate, ECClickableElementDelegate, UIActionSheetDelegate, WXApiDelegate, UIAlertViewDelegate, UISearchBarDelegate,MKHorizMenuDataSource, MKHorizMenuDelegate>

@property (nonatomic, retain) Video *selectedVideo;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UIView *searchMaskView;

@property (nonatomic, retain) MKHorizMenu *horizVideoType;
@property (nonatomic, retain) MKHorizMenu *horizVideoSort;
@end

@implementation VideoListViewController
@synthesize requestParam;
@synthesize horizVideoType;
@synthesize horizVideoSort;

#pragma mark - arrange search bar
- (void)addSearchMaskView {
    if (self.searchMaskView == nil) {
        self.searchMaskView = [[[UIView alloc] initWithFrame:CGRectMake(0, TOOL_TITLE_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TOOL_TITLE_HEIGHT)] autorelease];
    }
    
    [self.view addSubview:self.searchMaskView];
    
    self.searchMaskView.backgroundColor = [UIColor colorWithWhite:0.6f alpha:0.9f];
}

- (void)displaySearchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self.searchBar becomeFirstResponder];
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.searchBar.frame = CGRectMake(0, 0, self.searchBar.frame.size.width, TOOL_TITLE_HEIGHT);
                         
                         [self addSearchMaskView];
                         
                         self.searchBar.alpha = 1.0f;
                     }];
}

#pragma mark - user actions
- (void)search:(id)sender {
    
    if (_inSearching) {
        return;
    }
    
    _inSearching = YES;
    
    if (self.searchBar == nil) {
        self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)] autorelease];
        self.searchBar.delegate = self;
        self.searchBar.tintColor = NAVIGATION_BAR_COLOR;
        self.searchBar.placeholder = LocaleStringForKey(NSVideoPlaceholderTitle, nil);
        [self.view addSubview:self.searchBar];
        
        self.searchBar.text = NULL_PARAM_VALUE;
    }
    
    [self displaySearchBar];
}

#pragma mark - life cycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC selectedVideoId:(NSInteger)selectedVideoId
{
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:NO
        needRefreshFooterView:YES
                   tableStyle:UITableViewStyleGrouped
                   needGoHome:NO];
    
    if (self) {
        // Custom initialization
        
        _selectedVideoId = selectedVideoId;
        
        _currentStartIndex = 0;
        [super clearPickerSelIndex2Init:2];
        
    }
    return self;
}

- (void)dealloc
{
    self.requestParam = nil;
    self.selectedVideo = nil;
    self.thumbnail = nil;
    self.searchBar = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew
{
    [super loadListData:triggerType forNew:forNew];
    
    _currentType = VIDEO_TY;
    NSInteger index = 0;
    if (!forNew) {
        index = ++_currentStartIndex;
    }
    
    self.requestParam = [NSString stringWithFormat:@"<page_size>30</page_size><page>%d</page><video_type>%@</video_type><order_value>%@</order_value><keywords>%@</keywords>", index, _TableCellSaveValArray[0], _TableCellSaveValArray[1], self.searchBar.text];
    
    NSString *url = [CommonUtils geneUrl:self.requestParam itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade fetchGets:url];
    
    self.searchBar.text = NULL_PARAM_VALUE;
}

#pragma mark - core data
- (void)configureMOCFetchConditions {
    
    self.predicate = [NSPredicate predicateWithFormat:@"(videoId > 0)"];
    self.entityName = @"Video";
    self.descriptors = [NSMutableArray array];
    
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES] autorelease];
    [self.descriptors addObject:dateDesc];
}

#pragma mark - View lifecycle

- (void)changeNaviHeight
{
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.size = self.view.frame.size;
    frame.size.height = NAVIGATION_BAR_HEIGHT;
    self.navigationController.navigationBar.frame = frame;
}

- (void)viewWillAppear:(BOOL)animated {
    
	[super deselectCell];
    [self changeNaviHeight];
    
	if (!_autoLoaded) {
        if (![AppManager instance].isLoadVedioFilterOk) {
            [self getVideoFliter];
        } else {
//            [videoToolView setType:([AppManager instance].videoTypeList)[0][1]
//                              sort:([AppManager instance].videoSortList)[0][1]];
//            [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
            
            [self loadHorizData];
        }
	}
}

- (void)changeTableStyle
{
    
    CGFloat y = 0;
    CGFloat height = _tableView.frame.size.height;
    if (CURRENT_OS_VERSION < IOS7) {
        y = TOOL_TITLE_HEIGHT;
        height -= TOOL_TITLE_HEIGHT;
    }
    
    y += TOOL_TITLE_HEIGHT;
    
    _tableView.frame = CGRectMake(0, y, _tableView.frame.size.width, height);
    
    _tableView.separatorColor = COLOR(205, 205, 205);
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}

- (void)addToolView
{
    videoToolView = [[VideoToolView alloc] initForVideo:CGRectMake(0, 0, self.view.frame.size.width, TOOL_TITLE_HEIGHT)
                                               topColor:COLOR(236, 232, 226)
                                            bottomColor:COLOR(223, 220, 212)
                                               delegate:self
                                       userListDelegate:self];
    [self.view addSubview:videoToolView];
    
}

- (void)initToolData
{
    _TableCellShowValArray = [[NSMutableArray alloc] init];
    _TableCellSaveValArray = [[NSMutableArray alloc] init];
    
    for (NSUInteger i=0; i<2; i++) {
        [_TableCellShowValArray insertObject:[NSString stringWithFormat:@"%d", iOriginalSelIndexVal] atIndex:i];
        [_TableCellSaveValArray insertObject:NULL_PARAM_VALUE atIndex:i];
    }
}

- (void)addSearchButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:IMAGE_WITH_NAME(@"btnSearchWhite.png") forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 34, 30);
    btn.showsTouchWhenHighlighted = YES;
    [btn addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:btn] autorelease];
    
    self.navigationItem.rightBarButtonItem = item;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //  [self addToolView];
    
    [self changeTableStyle];
    
    [self initToolData];
    
    [self addSearchButton];
    
    [self addHorizVideoTypeView];
    
    [self addHorizVideoSortView];
}

- (void)addHorizVideoTypeView
{
    self.horizVideoType = [[MKHorizMenu alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TOOL_TITLE_HEIGHT)];
    self.horizVideoType.tag = horizVideoTypeTag;
    self.horizVideoType.delegate = self;
    self.horizVideoType.dataSource = self;
    self.horizVideoType.itemSelectedDelegate = self;
    [self.view addSubview:self.horizVideoType];
}

- (void)addHorizVideoSortView
{
    self.horizVideoSort = [[MKHorizMenu alloc] initWithFrame:CGRectMake(0, TOOL_TITLE_HEIGHT, self.view.frame.size.width, TOOL_TITLE_HEIGHT)];
    self.horizVideoSort.tag = horizVideoSortTag;
    self.horizVideoSort.delegate = self;
    self.horizVideoSort.dataSource = self;
    self.horizVideoSort.itemSelectedDelegate = self;
    [self.view addSubview:self.horizVideoSort];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRC sections][section];
	return [sectionInfo numberOfObjects] + 1;
}

- (void)updateTable:(NSArray *)indexPaths {
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:indexPaths
                      withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Foot Cell
    if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
        return [self drawFooterCell];
    }
    
    // Event Cell
    static NSString *CellIdentifier = @"VideoCell";
    VideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[VideoListCell alloc] initWithStyle:UITableViewCellStyleValue1
                                     reuseIdentifier:CellIdentifier
                              imageDisplayerDelegate:self
                                                 MOC:_MOC] autorelease];
    }
    
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    [subviews release];
    
    Video *video = [self.fetchedRC objectAtIndexPath:indexPath];
    
    [cell drawVideo:video];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return;
    }
    
    self.selectedVideo = [self.fetchedRC objectAtIndexPath:indexPath];
    
    [UIUtils closeActivityView];
    
    UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil] autorelease];
    [as addButtonWithTitle:LocaleStringForKey(NSOpenVideoTitle, nil)];
    [as addButtonWithTitle:LocaleStringForKey(NSShareToWechatTitle, nil)];
    [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
    as.cancelButtonIndex = as.numberOfButtons - 1;
    
    [as showInView:self.view];
    
    /*
     VideoViewController *videoVC = [[VideoViewController alloc] initWithURL:video.videoUrl];
     [self.navigationController pushViewController:videoVC animated:YES];
     RELEASE_OBJ(videoVC);
     */
    [super deselectCell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _fetchedRC.fetchedObjects.count) {
        return TOOL_TITLE_HEIGHT;
    } else {
        
        Video *video = [_fetchedRC objectAtIndexPath:indexPath];
        if (!video) {
            return VIDEO_LIST_CELL_HEIGHT;
        } else {
            
            CGSize constrainedSize = CGSizeMake(TITLE_W, CGFLOAT_MAX);
            CGSize titleSize = [video.videoName sizeWithFont:BOLD_FONT(13)
                                           constrainedToSize:constrainedSize
                                               lineBreakMode:NSLineBreakByWordWrapping];
            
            float cellHeight = titleSize.height + TITLE_Y*2 + DATE_H + MARK_IMG_H;
            if (cellHeight < VIDEO_LIST_CELL_HEIGHT) {
                return VIDEO_LIST_CELL_HEIGHT;
            } else {
                return cellHeight;
            }
        }
    }
}

#pragma mark - auto scroll to current selected video in homepage
- (void)autoScrollToSelectedVideoIfNeeded {
    if (!_autoScrolled) {
        
        if (_selectedVideoId > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoId == %d", _selectedVideoId];
            Video *selectedVideo = (Video *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                                      entityName:@"Video"
                                                                       predicate:predicate];
            if (selectedVideo && self.fetchedRC.fetchedObjects.count > 0) {
                NSIndexPath *targetIndexPath = [self.fetchedRC indexPathForObject:selectedVideo];
                if (targetIndexPath) {
                    [_tableView scrollToRowAtIndexPath:targetIndexPath
                                      atScrollPosition:UITableViewScrollPositionTop
                                              animated:NO];
                }
            }
        }
        
        _autoScrolled = YES;
    }
}

#pragma mark - reset refresh header/footer view status
- (void)resetHeaderRefreshViewStatus {
	_reloading = NO;
	[UIUtils dataSourceDidFinishLoadingNewData:_tableView
                                    headerView:_headerRefreshView];
}

- (void)resetFooterRefreshViewStatus {
	_reloading = NO;
	
	[UIUtils dataSourceDidFinishLoadingOldData:_tableView
                                    footerView:_footerRefreshView];
}

- (void)resetHeaderOrFooterViewStatus {
    
    if (_loadForNewItem) {
        [self resetHeaderRefreshViewStatus];
    } else {
        [self resetFooterRefreshViewStatus];
    }
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
    [UIUtils showActivityView:_tableView text:LocaleStringForKey(NSLoadingTitle, nil)];
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
    switch (contentType) {
        case VIDEO_FILTER_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                
                //        [videoToolView setType:([AppManager instance].videoTypeList)[0][1]
                //                          sort:([AppManager instance].videoSortList)[0][1]];
                
                [self loadHorizData];
                
            } else {
                [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
            }
            break;
        }
            
        case VIDEO_TY:
        {
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                [self resetUIElementsForConnectDoneOrFailed];
            } else {
                [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
            }
            break;
        }
            
        case VIDEO_CLICK_TY:
        {
            
            break;
        }
            
        default:
            break;
            
    }
    
    [self refreshTable];
    
    if (contentType == VIDEO_TY) {
        //[self autoScrollToSelectedVideoIfNeeded];
    }
    
    _autoLoaded = YES;
    [UIUtils closeActivityView];
    [super connectDone:result url:url contentType:contentType];
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

#pragma mark - scrolling override
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([UIUtils shouldLoadOlderItems:scrollView
                      tableViewHeight:_tableView.contentSize.height + TOOL_TITLE_HEIGHT
                           footerView:_footerRefreshView
                            reloading:_reloading]) {
        
        _reloading = YES;
        
        _shouldTriggerLoadLatestItems = YES;
        
        [self loadListData:TRIGGERED_BY_SCROLL forNew:NO];
    }
}

#pragma mark - Video
- (void)showVideoTypeList {
    [self setDropDownValueArray:0];
}

- (void)showVideoSortList {
    [self setDropDownValueArray:1];
}

#pragma mark - UIPickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    pickSel0Index = row;
    isPickSelChange = YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_PickData count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _PickData[row];
}

- (void)setDropDownValueArray:(int)type
{
    [NSFetchedResultsController deleteCacheWithName:nil];
    iFliterIndex = type;
    self.descriptors = [NSMutableArray array];
    
    self.DropDownValArray = [[[NSMutableArray alloc] init] autorelease];
    switch (type) {
            
        case 0:
        {
            self.DropDownValArray = [AppManager instance].videoTypeList;
        }
            break;
            
        case 1:
        {
            self.DropDownValArray = [AppManager instance].videoSortList;
        }
            break;
    }
    
    [super setPopView];
}

-(void)onPopCancle:(id)sender {
    [super onPopCancle];
    
    [_TableCellShowValArray removeObjectAtIndex:iFliterIndex];
    [_TableCellShowValArray insertObject:[NSString stringWithFormat:@"%d",iOriginalSelIndexVal] atIndex:iFliterIndex];
    
    [_TableCellSaveValArray removeObjectAtIndex:iFliterIndex];
    [_TableCellSaveValArray insertObject:NULL_PARAM_VALUE atIndex:iFliterIndex];
    
    [_tableView reloadData];
}

-(void)onPopOk:(id)sender {
    
    [super onPopSelectedOk];
    int iPickSelectIndex = [super pickerList0Index];
    
    [self setTableCellVal:iFliterIndex aShowVal:(self.DropDownValArray)[iPickSelectIndex][RECORD_NAME_IDX]
                 aSaveVal:(self.DropDownValArray)[iPickSelectIndex][RECORD_ID_IDX] isFresh:YES];
    
    [self doSelect];
}

-(void)setTableCellVal:(int)index
              aShowVal:(NSString*)aShowVal
              aSaveVal:(NSString*)aSaveVal
               isFresh:(BOOL)isFresh {
    
    [_TableCellShowValArray removeObjectAtIndex:index];
    [_TableCellShowValArray insertObject:aShowVal atIndex:index];
    
    [_TableCellSaveValArray removeObjectAtIndex:index];
    [_TableCellSaveValArray insertObject:aSaveVal atIndex:index];
    
    [videoToolView setType:_TableCellShowValArray[0]
                      sort:_TableCellShowValArray[1]];
    
}

- (void)doSelect
{
    
    DELETE_OBJS_FROM_MOC(_MOC, @"Video", nil);
    _currentStartIndex = 0;
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)getVideoFliter
{
    _currentType = VIDEO_FILTER_TY;
    
    NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade fetchGets:url];
}

- (void)updateVideoClick:(NSString *)videoId
{
    _currentType = VIDEO_CLICK_TY;
    
    NSString *param = [NSString stringWithFormat:@"<video_id>%@</video_id>", videoId];
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade fetchGets:url];
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
    return NO;
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case OPEN_VIDEO_IDX:
        {
            [self updateVideoClick:[self.selectedVideo.videoId stringValue]];
            VideoViewController *videoVC = [[VideoViewController alloc] initWithURL:self.selectedVideo.videoUrl];
            [self.navigationController pushViewController:videoVC animated:YES];
            RELEASE_OBJ(videoVC);
            
            break;
        }
            
        case SHARE_WECHAT_IDX:
        {
            if ([WXApi isWXAppInstalled]) {
                ((iAlumniAppDelegate*)APP_DELEGATE).wxApiDelegate = self;
                
                if (self.selectedVideo.imageUrl.length > 0) {
                    self.thumbnail = [CommonUtils cutMiddlePartImage:[[WXWImageManager instance].imageCache getImage:self.selectedVideo.imageUrl]
                                                               width:THUMB_SIDE_LENGTH
                                                              height:THUMB_SIDE_LENGTH];
                }
                
                [CommonUtils shareVideo:self.selectedVideo scene:WXSceneSession image:self.thumbnail];
                
            } else {
                
                ShowAlertWithTwoButton(self, nil,
                                       LocaleStringForKey(NSNoWeChatMsg, nil),
                                       LocaleStringForKey(NSDonotInstallTitle, nil),
                                       LocaleStringForKey(NSInstallTitle, nil));
            }
            
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - WXApiDelegate methods
- (void)onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        switch (resp.errCode) {
            case WECHAT_OK_CODE:
                [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatDoneMsg, nil)
                                              msgType:SUCCESS_TY
                                   belowNavigationBar:YES];
                break;
                
            case WECHAT_BACK_CODE:
                break;
                
            default:
                [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatFailedMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                break;
        }
    }
    
    ((iAlumniAppDelegate*)APP_DELEGATE).wxApiDelegate = nil;
}

#pragma mark - alert delegate method
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WECHAT_ITUNES_URL]];
            break;
        default:
            break;
    }
}

#pragma mark - UISearchBarDelegate methods

- (void)hideSearchBar {
    
    _inSearching = NO;
    
    [self.searchBar resignFirstResponder];
    
    self.searchBar.alpha = 0.0f;
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.searchMaskView.backgroundColor = [UIColor colorWithWhite:0.6f alpha:0.0f];
                         self.searchBar.frame = CGRectMake(0, 0, self.searchBar.frame.size.width, 0);
                     }
                     completion:^(BOOL finished){
                         [self.searchMaskView removeFromSuperview];
                     }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    DELETE_OBJS_FROM_MOC(_MOC, @"Video", nil);
    [self refreshTable];
    
    _currentStartIndex = 0;
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    
    [self hideSearchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    self.searchBar.text = NULL_PARAM_VALUE;
    
    [self hideSearchBar];
}

#pragma mark - HorizMenu Data Source
- (UIImage*)selectedItemImageForMenu:(MKHorizMenu*) tabMenu
{
//    return [[UIImage imageNamed:@"ButtonSelected.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    return [[CommonUtils createImageWithColor:[UIColor blackColor]] stretchableImageWithLeftCapWidth:16 topCapHeight:0];
}

- (UIColor *)backgroundColorForMenu:(MKHorizMenu *)tabView
{
//    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"MenuBar.png"]];
    return [UIColor grayColor];
}

- (int)numberOfItemsForMenu:(MKHorizMenu *)tabView
{
    if (tabView.tag == horizVideoTypeTag) {
        return [[AppManager instance].videoTypeList count];
    } else {
        return [[AppManager instance].videoSortList count];
    }
}

- (NSString *)horizMenu:(MKHorizMenu *)horizMenu titleForItemAtIndex:(NSUInteger)index
{
    if (horizMenu.tag == horizVideoTypeTag) {
        return [[[AppManager instance].videoTypeList objectAtIndex:index] objectAtIndex:1];
    } else {
        return [[[AppManager instance].videoSortList objectAtIndex:index] objectAtIndex:1];
    }
}

#pragma mark - HorizMenu Delegate
-(void)horizMenu:(MKHorizMenu *)horizMenu itemSelectedAtIndex:(NSUInteger)index
{
    if (horizMenu.tag == horizVideoTypeTag) {
        [_TableCellSaveValArray removeObjectAtIndex:0];
        [_TableCellSaveValArray insertObject:[[[AppManager instance].videoTypeList objectAtIndex:index] objectAtIndex:0] atIndex:0];
    } else {
        [_TableCellSaveValArray removeObjectAtIndex:1];
        [_TableCellSaveValArray insertObject:[[[AppManager instance].videoSortList objectAtIndex:index] objectAtIndex:0] atIndex:1];
    }
    
    [self doSelect];
}

- (void)loadHorizData
{
    [self.horizVideoType reloadData];
    [self.horizVideoSort reloadData];
    
    [self.horizVideoType setSelectedIndex:0 animated:YES];
    [self.horizVideoSort setSelectedIndex:0 animated:YES];
    
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

@end