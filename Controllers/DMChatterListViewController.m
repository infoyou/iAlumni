//
//  DMChatterListViewController.m
//  iAlumni
//
//  Created by Adam on 13-10-25.
//
//

#import "DMChatterListViewController.h"
#import "CommonUtils.h"
#import "UserListCell.h"
#import "DMChatViewController.h"
#import "AlumniProfileViewController.h"

@interface DMChatterListViewController ()

@end

@implementation DMChatterListViewController

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = CHAT_USER_LIST_TY;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  NSString *param = [NSString stringWithFormat:@"<page>%d</page><page_size>%@</page_size>", index, ITEM_LOAD_COUNT];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade fetchGets:url];
}

- (void)configureMOCFetchConditions {
  
  self.entityName = @"Alumni";
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"orderId" ascending:YES] autorelease];
  
  [self.descriptors addObject:dateDesc];
  
  self.predicate = [NSPredicate predicateWithFormat:@"personId <> %@", [AppManager instance].personId];
}

#pragma mark - life cycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  if (self) {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"personId <> %@", [AppManager instance].personId];
    DELETE_OBJS_FROM_MOC(_MOC, @"Alumni", predicate);
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType{
  
  switch (contentType) {
      
    case CHAT_USER_LIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [self refreshTable];
        
        _autoLoaded = YES;
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      break;
    }
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}


- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                msgType:ERROR_TY
                     belowNavigationBar:YES];
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  
  return self.fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return [self drawFooterCell];
  }
  
	static NSString *kCellIdentifier = @"AlumniCell";
  
	UserListCell *cell = [[[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:kCellIdentifier
                                     imageDisplayerDelegate:self
                                     imageClickableDelegate:self
                                                        MOC:_MOC] autorelease];
  
  cell.accessoryType = UITableViewCellAccessoryNone;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  Alumni *aAlumni = (Alumni *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  [cell drawCell:aAlumni userListType:CHAT_USER_LIST_TY];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return USER_LIST_CELL_HEIGHT;
}

- (void)adjustNewMessageNumberForAlumni:(Alumni *)alumni {
  NSInteger allNewMsgNumber = [AppManager instance].msgNumber.intValue;
  allNewMsgNumber -= alumni.notReadMsgCount.intValue;
  if (allNewMsgNumber < 0) {
    allNewMsgNumber = 0;
  }
  
  [CommonUtils updateNewDMNumber:allNewMsgNumber];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == [[self.fetchedRC fetchedObjects] count]) {
    return;
  }
  
  Alumni *alumni = [self.fetchedRC objectAtIndexPath:indexPath];
  
  [self goChatView:alumni];
  
  [self adjustNewMessageNumberForAlumni:alumni];
}

#pragma mark - ECClickableElementDelegate methods

- (void)openProfile:(NSString*)userId userType:(NSString*)userType
{
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                    personId:userId
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)goChatView:(Alumni*)aAlumni {
  
  DMChatViewController *chatVC = [[[DMChatViewController alloc] initWithMOC:_MOC
                                                                     alumni:aAlumni] autorelease];
  [self.navigationController pushViewController:chatVC animated:YES];
}

@end
