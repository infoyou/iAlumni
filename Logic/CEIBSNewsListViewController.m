//
//  CEIBSNewsListViewController.m
//  iAlumni
//
//  Created by Adam on 12-10-25.
//
//

#import "CEIBSNewsListViewController.h"
#import "News.h"
#import "ListSectionView.h"
#import "HotNewsCell.h"
#import "UIWebViewController.h"
#import "WXWNavigationController.h"
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "UIUtils.h"

#define SECTION_VIEW_HEIGHT     16.0f

@interface CEIBSNewsListViewController ()
@property (nonatomic, retain) UIView *emptyMessageView;
@end

@implementation CEIBSNewsListViewController

#pragma mark - set predicate
- (void)configureMOCFetchConditions {
  
  self.entityName = @"News";
  self.sectionNameKeyPath = @"elapsedDayCount";
  
  self.descriptors = [NSMutableArray array];
  
  NSSortDescriptor *elapsedDayDesc = [[[NSSortDescriptor alloc] initWithKey:@"elapsedDayCount" ascending:YES] autorelease];
  [self.descriptors addObject:elapsedDayDesc];
  
  NSSortDescriptor *timestampDesc = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
  [self.descriptors addObject:timestampDesc];
  
  self.predicate = [NSPredicate predicateWithFormat:@"type == %d", FOR_HOMEPAGE_NEWS_TY];
}

#pragma mark - load news
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = LOAD_NEWS_REPORT_TY;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  /*
  NSString *param = [NSString stringWithFormat:@"<page_size>%@</page_size><page>%d</page>", ITEM_LOAD_COUNT, index];  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  [connFacade fetchGets:url];
   */
  NSString *param = [NSString stringWithFormat:@"<page>%d</page><page_size>%@</page_size><news_type>%d</news_type>", index, ITEM_LOAD_COUNT, FOR_HOMEPAGE_NEWS_TY];
  
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_NEWS_REPORT_TY];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:LOAD_NEWS_REPORT_TY];
  [connFacade asyncGet:url showAlertMsg:YES];

}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
needAdjustForiOS7:(BOOL)needAdjustForiOS7 {
  
  self = [super initWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:YES
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    //DELETE_OBJS_FROM_MOC(_MOC, @"News", nil);
    
    _needAdjustForiOS7 = needAdjustForiOS7;
  }
  
  return self;
}

- (void)dealloc {
  
  //DELETE_OBJS_FROM_MOC(_MOC, @"News", nil);
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
    
  if (!_autoLoaded) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [_fetchedRC.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRC sections][section];
  if (section == [self.fetchedRC.sections count] - 1) {
    return [sectionInfo numberOfObjects] + 1;
  } else {
    return [sectionInfo numberOfObjects];
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.section == [self.fetchedRC.sections count] - 1) {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedRC sections][indexPath.section];
    
    if (indexPath.row == [sectionInfo numberOfObjects]) {
      return [self drawFooterCell];
    }
  }
  
  News *news = [self.fetchedRC objectAtIndexPath:indexPath];
  
  static NSString *cellIdentifier = @"newsCell";
  
  HotNewsCell *cell = (HotNewsCell *)[_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (nil == cell) {
    cell = [[[HotNewsCell alloc] initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:cellIdentifier
                        imageDisplayerDelegate:self
                                           MOC:_MOC] autorelease];
  }
  
  [cell drawNews:news];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return NEWS_CEL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)table
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
  return [_fetchedRC sectionForSectionIndexTitle:title atIndex:index];
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
  
  id <NSFetchedResultsSectionInfo> sectionInfo = [_fetchedRC sections][section];
  
  NSArray *newsList = [sectionInfo objects];
  NSString *name = nil;
  if (newsList.count > 0) {
    News *news = (News *)newsList.lastObject;
    name = news.dateSeparator;
  }
  
  return [[[ListSectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, SECTION_VIEW_HEIGHT)
                                           title:name] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return SECTION_VIEW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == [_fetchedRC.sections count] - 1) {
    id<NSFetchedResultsSectionInfo> sectionInfo = [_fetchedRC sections][indexPath.section];
    if (indexPath.row == [sectionInfo numberOfObjects]) {
      return;
    }
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  News *news = [_fetchedRC objectAtIndexPath:indexPath];
  
  UIWebViewController *webVC = [[[UIWebViewController alloc] initWithNeedAdjustForiOS7:YES] autorelease];
  WXWNavigationController *webViewNav = [[[WXWNavigationController alloc] initWithRootViewController:webVC] autorelease];
  webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
  webVC.strUrl = news.url;
  
  [self.parentViewController presentModalViewController:webViewNav
                                               animated:YES];
    
  _lastSelectedIndexPath = indexPath;
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
            blockCurrentView:NO];
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  if ([XMLParser parserResponseXml:result
                              type:contentType
                               MOC:self.MOC
                 connectorDelegate:self
                               url:url]) {
    [self refreshTable];
    
    if (!_autoLoaded) {
      _autoLoaded = YES;
    }
  
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchNewsFailedMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSFetchNewsFailedMsg, nil);
  }

  [super connectFailed:error url:url contentType:contentType];
}

@end
