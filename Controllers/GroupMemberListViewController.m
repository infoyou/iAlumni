//
//  GroupMemberListViewController.m
//  iAlumni
//
//  Created by Adam on 12-12-6.
//
//

#import "GroupMemberListViewController.h"
#import "Alumni.h"
#import "Club.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "AppManager.h"

#define HEADER_HEIGHT   40.0f

#define TAB_WIDTH   202.f
#define TAB_HEIGHT  32.0f

enum {
  FIRST_IDX,
  SECOND_IDX,
};

@interface GroupMemberListViewController ()
@property (nonatomic, retain) Club *group;
@end

@implementation GroupMemberListViewController

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType
              forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = CLUB_MANAGE_USER_TY;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<host_id>%@</host_id><host_type></host_type><host_type_value>%@</host_type_value><host_sub_type_value>%@</host_sub_type_value><host_name>%@</host_name><page>%d</page><page_size>100</page_size>", self.group.clubId, self.group.hostSupTypeValue, self.group.hostTypeValue, self.group.clubName, index];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"Alumni";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *namePinyinDesc = [[[NSSortDescriptor alloc] initWithKey:@"firstNamePinyinChar"
                                                                  ascending:YES] autorelease];
  [self.descriptors addObject:namePinyinDesc];
  
  self.sectionNameKeyPath = @"firstNamePinyinChar";

  if (self.group.needPay.boolValue) {
    switch (_selectedIdex) {
      case FIRST_IDX:
        self.predicate = [NSPredicate predicateWithFormat:@"(groupId == %@) AND (isApprove == 1)", self.group.clubId];
        break;
        
      case SECOND_IDX:
        self.predicate = [NSPredicate predicateWithFormat:@"(groupId == %@) AND (isApprove == 0)", self.group.clubId];
        break;
        
      default:
        break;
    }
  } else {
    self.predicate = [NSPredicate predicateWithFormat:@"(groupId == %@)", self.group.clubId];
  }
  
}


#pragma mark - lifecycle methods

- (void)clearData {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(groupId == %@)", self.group.clubId];
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Alumni", predicate);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(Club *)group {
  self = [super initWithMOC:MOC];
  if (self) {
    self.group = group;
    
    [self clearData];
  }
  return self;
}

- (void)dealloc {
  
  [self clearData];
  
  self.group = nil;
  
  [super dealloc];
}

- (void)addTabIfNeeded {
  
  if (!self.group.needPay.boolValue) {
    return;
  }
  
  NSArray *tabNames = nil;
  
  tabNames = @[LocaleStringForKey(NSHavePaidTitle, nil), LocaleStringForKey(NSNotPaidTitle, nil)];

  
  _tabSwitchView = [[[PlainTabView alloc] initWithFrame:CGRectMake(0, 0, TAB_WIDTH, TAB_HEIGHT)
                                           buttonTitles:tabNames
                                      tapSwitchDelegate:self] autorelease];
  
  self.navigationItem.titleView = _tabSwitchView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self addTabIfNeeded];
  
  if ([[AppManager instance].hostSupTypeValue isEqualToString:SELF_CLASS_TYPE]) {
    self.title = LocaleStringForKey(NSClassMemberTitle, nil);
  } else {
    self.title = LocaleStringForKey(NSGroupMemberTitle, nil);
  }
}

- (void)viewWillAppear:(BOOL)animated {
  
  if (!_autoLoaded) {
    if (self.group.needPay.boolValue) {
      [_tabSwitchView selectButtonWithIndex:FIRST_IDX];
    } else {
      [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    }
    
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methods

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType {
  
  if ([XMLParser parseMemberForGroupId:self.group.clubId.longLongValue
                               xmlData:result
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
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSFetchAlumnusFailedMsg, nil);
  }
  
  [super connectFailed:error
                   url:url
           contentType:contentType];
}

#pragma mark - TapSwitchDelegate methods

- (void)selectTapByIndex:(NSInteger)index {

  _selectedIdex = index;
  
  [self removeEmptyMessageIfNeeded];
  
  self.fetchedRC = nil;
  [_tableView reloadData];
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}


@end
