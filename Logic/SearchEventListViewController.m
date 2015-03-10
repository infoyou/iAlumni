//
//  SearchEventListViewController.m
//  iAlumni
//
//  Created by Adam on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SearchEventListViewController.h"
#import "EventListCell.h"
#import "Event.h"
#import "EventDetailViewController.h"
#import "NaviButton.h"
#import "EventCity.h"
#import "PlainTabView.h"
#import "EventToolView.h"
#import "ClubListCell.h"
#import "GroupListViewController.h"
#import "Club.h"
#import "GroupDiscussionViewController.h"
#import "ClubDetailViewController.h"
#import "ECGradientButton.h"

#define defaultFont               18

#define HEADER_HEIGHT             38.0f
#define SEARCH_BAR_H              44.f
#define BUTTON_WIDTH              65.0
#define BUTTON_SEGMENT_WIDTH      51.0
#define CAP_WIDTH                 5.0

@interface SearchEventListViewController()
{
    int eventPageIndex;
}

@property (nonatomic, retain) UIView *searchBarBGView;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) ECGradientButton *closeSearchBarBut;

@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *hostTypeValue;
@property (nonatomic, copy) NSString *hostSubTypeValue;
@property (nonatomic, copy) NSMutableArray *clubFilters;
@property (nonatomic, copy) NSString *keyWords;
@end

@implementation SearchEventListViewController

- (void)clearEvents {
    DELETE_OBJS_FROM_MOC(_MOC, @"Event", nil);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(UIViewController *)parentVC
         tabIndex:(int)tabIndex
{
    
    self = [super initWithMOC:MOC
                       holder:nil
             backToHomeAction:nil
        needRefreshHeaderView:NO
        needRefreshFooterView:YES
                   tableStyle:UITableViewStylePlain
                   needGoHome:NO];
    
    self.parentVC = parentVC;
    _currentStartIndex = 0;
    
    [self clearEvents];
    
    return self;
}

- (void)dealloc {
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    [self clearFliter];
        
    self.cityId = nil;
    self.hostTypeValue = nil;
    self.hostSubTypeValue = nil;
    [super dealloc];
}

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
    
    [super loadListData:triggerType forNew:forNew];
    
    NSMutableString *requestParam = nil;
    
    _currentType = EVENTLIST_TY;
    
    NSInteger index = 0;
    if (!forNew) {
        index = ++ eventPageIndex;
    }
    
    requestParam = [NSMutableString stringWithFormat:@"<host_type_value>%@</host_type_value><host_sub_type_value>%@</host_sub_type_value><screen_type>%@</screen_type><city_id>%@</city_id><sort_type>%@</sort_type><page_size>20</page_size><page>%d</page><longitude>%f</longitude><latitude>%f</latitude><keywords>%@</keywords>", NULL_PARAM_VALUE, NULL_PARAM_VALUE, @"0", @"0", @"1", index, [AppManager instance].longitude, [AppManager instance].latitude, self.keyWords];
    
    NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade fetchGets:url];
}

- (void)clearFliter {
    // Clear Fliter
    [[AppManager instance].supClubFilterList removeAllObjects];
    [AppManager instance].supClubFilterList = nil;
    [[AppManager instance].clubFilterList removeAllObjects];
    [AppManager instance].clubFilterList = nil;
    [AppManager instance].clubFliterLoaded = NO;
}

#pragma mark - core data

- (void)configureMOCFetchConditions {
    
    self.entityName = @"Event";
    self.descriptors = [NSMutableArray array];
    self.predicate = nil;
    
    NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"showOrder" ascending:YES] autorelease];
    [self.descriptors addObject:dateDesc];
    
}

#pragma mark - View lifecycle

- (void)addSearchBarView {
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

- (void)setTableViewProperties {
    
    _tableView.frame = CGRectMake(0, HEADER_HEIGHT,
                                  _tableView.frame.size.width,
                                  _tableView.frame.size.height - HEADER_HEIGHT);
    
    _tableView.separatorStyle = NO;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
}

- (void)hideView {
    _originalTableViewFrame = _tableView.frame;
    _tableView.alpha = 0.0f;
    self.searchBarBGView.alpha = 1.0f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = CELL_COLOR;
    [self addSearchBarView];
    _tableView.frame = CGRectMake(0, _tableView.frame.origin.y + HEADER_HEIGHT, _tableView.frame.size.width, _tableView.frame.size.height - HEADER_HEIGHT);
    [self setTableViewProperties];
    
    [self hideView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super deselectCell];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super deselectCell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    return self.fetchedRC.fetchedObjects.count + 1;
}

- (void)updateTable:(NSArray *)indexPaths {
    [_tableView beginUpdates];
    
    [_tableView reloadRowsAtIndexPaths:indexPaths
                      withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

- (EventListCell *)drawEventCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    
    // Event Cell
    NSString *kEventCellIdentifier = @"SearchEventCell";
    EventListCell *cell = (EventListCell *)[tableView dequeueReusableCellWithIdentifier:kEventCellIdentifier];
    if (nil == cell) {
        cell = [[[EventListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEventCellIdentifier] autorelease];
    }
    
    Event *event = [self.fetchedRC objectAtIndexPath:indexPath];
    [cell drawEvent:event];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
        return [self drawFooterCell];
    } else {
        return [self drawEventCell:tableView indexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
        return;
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    [AppManager instance].isClub2Event = NO;
    
    Event *event = [self.fetchedRC objectAtIndexPath:indexPath];
    [AppManager instance].eventId = [event.eventId stringValue];
    EventDetailViewController *detailVC = [[[EventDetailViewController alloc] initWithMOC:_MOC
                                                                                    event:event
                                                                             parentListVC:nil] autorelease];
    detailVC.title = LocaleStringForKey(NSEventDetailTitle, nil);

//    if (self.parentVC) {
//        [self.parentVC.navigationController pushViewController:detailVC animated:YES];
//    } else {
        [self.navigationController pushViewController:detailVC animated:YES];
//    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return EVENT_LIST_CELL_HEIGHT;
}

#pragma mark - load Event list from web
- (void)stopAutoRefreshUserList {
    [timer invalidate];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
    
    [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
    
    switch (contentType) {
            
        case EVENTLIST_TY:
        {
            
            if ([XMLParser parserResponseXml:result
                                        type:contentType
                                         MOC:_MOC
                           connectorDelegate:self
                                         url:url]) {
                
                _tableView.frame = _originalTableViewFrame;
                _tableView.alpha = 1.0f;
                self.searchBarBGView.alpha = 1.0f;
                
                [self refreshTable];
                
                [self closeAsyncLoadingView];
                
            } else {
                [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
                [self closeAsyncLoadingView];
            }
            
            break;
        }
            
        case EVENT_CITY_LIST_TY:
        {
          BOOL ret = [XMLParser parserResponseXml:result
                                             type:contentType
                                              MOC:_MOC
                                connectorDelegate:self
                                              url:url];
            
            if (ret) {
                [super setPopView];
            } else {
                [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                              msgType:ERROR_TY
                                   belowNavigationBar:YES];
                
            }
            
            [self closeAsyncLoadingView];
            break;
        }
            
        default:
            break;
    }
    
    [self resetUIElementsForConnectDoneOrFailed];
    
    [super connectDone:result
                   url:url
           contentType:contentType
 closeAsyncLoadingView:NO];
    
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
    
    [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
    
    [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - clear list
- (void)clearList {
    
    if (!_keepEventsInMOC) {
        [self clearEvents];
    }
    _keepEventsInMOC = NO;
    
    self.fetchedRC = nil;
    [_tableView reloadData];
    
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
    self.keyWords = self.searchBar.text;
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    
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
}

@end