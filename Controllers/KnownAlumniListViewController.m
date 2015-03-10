//
//  KnownAlumniListViewController.m
//  iAlumni
//
//  Created by Adam on 12-12-6.
//
//

#import "KnownAlumniListViewController.h"
#import "KnownAlumni.h"
#import "AlumniProfileViewController.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "UIUtils.h"

#define TAB_WIDTH   202.f
#define TAB_HEIGHT  32.0f

@interface KnownAlumniListViewController ()

@end

@implementation KnownAlumniListViewController

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType
              forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = LOAD_KNOWN_ALUMNUS_TY;
  
  NSInteger startIndex = 0;
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<page>%d</page><page_size>100</page_size>", startIndex];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"KnownAlumni";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *namePinyinDesc = [[[NSSortDescriptor alloc] initWithKey:@"firstNamePinyinChar"
                                                                  ascending:YES] autorelease];
  [self.descriptors addObject:namePinyinDesc];
  
  self.sectionNameKeyPath = @"firstNamePinyinChar";
  
  NSInteger isClassmate = 0;
  if (_tabType == SAME_CLASS_ALUMNUS_TY) {
    isClassmate = 1;
  }

  self.predicate = [NSPredicate predicateWithFormat:@"classmate == %d", isClassmate];
}

#pragma mark - lifecycle methods
- (void)dealloc {
  
  [super dealloc];
}

- (void)addTabSwitcher {
  _tabSwitchView = [[[PlainTabView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   TAB_WIDTH, TAB_HEIGHT)
                                           buttonTitles:@[LocaleStringForKey(NSNonclassmateTitle, nil), LocaleStringForKey(NSClassmateTitle, nil)]
                                      tapSwitchDelegate:self] autorelease];
  self.navigationItem.titleView = _tabSwitchView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self addTabSwitcher];
}

- (void)viewWillAppear:(BOOL)animated {
  
  if (!_autoLoaded) {
    [_tabSwitchView selectButtonWithIndex:OTHER_CLASS_ALUMNUS_TY];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - override methods
- (void)showProfile:(Alumni *)alumni {
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initHideLocationWithMOC:_MOC
                                                                                                  alumni:alumni
                                                                                                userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}


#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  _tabSwitchView.userInteractionEnabled = NO;
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  if ([XMLParser parserResponseXml:result
                              type:contentType
                               MOC:_MOC
                 connectorDelegate:self
                               url:url]) {
    _autoLoaded = YES;
    
    [self refreshTable];
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
    
  }
  
  _tabSwitchView.userInteractionEnabled = YES;
  
  _autoLoaded = YES;
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSFetchAlumnusFailedMsg, nil);
  }
  
  _tabSwitchView.userInteractionEnabled = YES;
  
  [super connectFailed:error
                   url:url
           contentType:contentType];
}

#pragma mark - clear list
- (void)clearList {
  
  self.fetchedRC = nil;
  [_tableView reloadData];
}

#pragma mark - TapSwitchDelegate methods
- (void)selectTapByIndex:(NSInteger)index {
  
  if (index == _tabType && _autoLoaded) {
    return;
  }

  _tabType = index;
  
  [self clearList];
  
  _tableView.alpha = 0.0f;
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  
}

@end
