//
//  CheckinListViewController.m
//  iAlumni
//
//  Created by Adam on 12-8-18.
//
//

#import "CheckinListViewController.h"
#import "ServiceItem.h"
#import "XMLParser.h"
#import "CheckinUserCell.h"
#import "CheckedinMember.h"
#import "ChatListViewController.h"
#import "AlumniProfileViewController.h"
#import "ECAsyncConnectorFacade.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "UIUtils.h"
#import "DMChatViewController.h"

#define CELL_HEIGHT    75.0f

#define PHOTO_WIDTH       56.0f
#define CHAT_WIDTH        25.0f


@interface CheckinListViewController ()
@property (nonatomic, retain) ServiceItem *item;
@property (nonatomic, copy) NSString *hashedServiceItemId;
@property (nonatomic, retain) Alumni *alumni;
@end

@implementation CheckinListViewController

@synthesize item = _item;
@synthesize hashedServiceItemId = _hashedServiceItemId;
@synthesize alumni = _alumni;

#pragma mark - user action
- (void)checkin:(id)sender {
  ECAsyncConnectorFacade *checkinActionConnFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                               interactionContentType:ITEM_CHECKIN_TY] autorelease];
  
  NSString *param = [NSString stringWithFormat:@"<service_id>%@</service_id><longitude>%f</longitude><latitude>%f</latitude>",
                     self.item.itemId,
                     [AppManager instance].longitude,
                     [AppManager instance].latitude];
  
  NSString *url = [CommonUtils geneUrl:param itemType:ITEM_CHECKIN_TY];
  
  (self.connDic)[url] = checkinActionConnFacade;
  
  [checkinActionConnFacade checkin:url];
}

#pragma mark - load check in list

- (void)loadListData:(LoadTriggerType)triggerType
                      forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  NSInteger startIndex = 0;
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<service_id>%@</service_id><start_index>%d</start_index><count>%@</count>", self.item.itemId, startIndex, ITEM_LOAD_COUNT];
  
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_CHECKEDIN_ALUMNUS_TY];
  
  ECAsyncConnectorFacade *loadChecedinAlumnusConnFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                                     interactionContentType:LOAD_CHECKEDIN_ALUMNUS_TY] autorelease];
  (self.connDic)[url] = loadChecedinAlumnusConnFacade;
  
  [loadChecedinAlumnusConnFacade fetchCheckedinAlumnus:url];
}

#pragma mark - lifecycle methods

- (id)initWithMOC:(NSManagedObjectContext *)MOC
             item:(ServiceItem *)item
     hashedServiceItemId:(NSString *)hashedServiceItemId {
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:YES
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    self.item = item;
    self.hashedServiceItemId = hashedServiceItemId;
  }
  
  return self;
}

- (void)dealloc {
  
  self.item = nil;
  
  self.hashedServiceItemId = nil;
  
  self.alumni = nil;
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = CELL_COLOR;
  
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSCheckInTitle, nil)
                            target:self
                            action:@selector(checkin:)];
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
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

#pragma mark - predicate
- (void)configureMOCFetchConditions {
  self.entityName = @"CheckedinMember";
  
  self.descriptors = [NSMutableArray array];
  
  NSSortDescriptor *desc = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
  [self.descriptors addObject:desc];
  
  
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case ITEM_CHECKIN_TY:
    {
      CheckinResultType ret = [XMLParser parserCheckin:result
                                     connectorDelegate:self
                                                   url:url];
      switch (ret) {
        case CHECKIN_OK_TY:
        {
          [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCheckinDoneMsg, nil)
                                        msgType:SUCCESS_TY
                             belowNavigationBar:YES];
          
          [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
          
          break;
        }
          
        case CHECKIN_FAILED_TY:
        {
          [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                                 alternativeMsg:LocaleStringForKey(NSCheckinFailedMsg, nil)
                                        msgType:ERROR_TY
                             belowNavigationBar:YES];
          break;
        }
          
        case CHECKIN_FARAWAY_TY:
        {
          [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                                 alternativeMsg:LocaleStringForKey(NSCheckinFarAwayMsg, nil)
                                        msgType:ERROR_TY
                             belowNavigationBar:YES];
          break;
        }
          
        default:
          break;
      }

      break;
    }
      
    case LOAD_CHECKEDIN_ALUMNUS_TY:
    {
      if ([XMLParser parserCheckedinAlumnus:result
                               hashedItemId:self.hashedServiceItemId
                                        MOC:_MOC
                          connectorDelegate:self
                                        url:url]) {
        
        [self refreshTable];
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchCheckinUserFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }

      break;
    }
    default:
      break;
  }
  
  //[self resetUIElementsForConnectDoneOrFailed];
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = LocaleStringForKey(NSFetchCheckinUserFailedMsg, nil);
  }

  [super connectFailed:error url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  return _fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return [self drawFooterCell];
  }

  CheckedinMember *member = (CheckedinMember *)(_fetchedRC.fetchedObjects)[indexPath.row];
  
  static NSString *kCellIdentifier = @"cellIdentifier";
  
  CheckinUserCell *cell = (CheckinUserCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[CheckinUserCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:kCellIdentifier
                            imageDisplayerDelegate:self
                            imageClickableDelegate:self
                                               MOC:_MOC] autorelease];
  }
  
  [cell drawCellWithAlumni:member];
  
  return cell;
}

- (void)showProfile:(NSString *)personId userType:(NSString *)userType {
  Alumni *alumni = (Alumni *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                    entityName:@"Alumni"
                                                     predicate:[NSPredicate predicateWithFormat:@"personId == %@", personId]];
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC alumni:alumni userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return 0;
  }
  
  CheckedinMember *member = (CheckedinMember *)(_fetchedRC.fetchedObjects)[indexPath.row];
  
  CGFloat limitedWidth = self.view.frame.size.width - (MARGIN + PHOTO_WIDTH + PHOTO_MARGIN * 2 + MARGIN + CHAT_WIDTH) - MARGIN * 2;
  CGSize size = [member.name sizeWithFont:BOLD_FONT(15)
                        constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat height = MARGIN + size.height;
  
  size = [member.groupClassName sizeWithFont:BOLD_FONT(12)
                           constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
  
  height += MARGIN + size.height;
  
  size = [member.companyName sizeWithFont:BOLD_FONT(12)
                        constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByWordWrapping];
  height += MARGIN + size.height;
  
  size = [member.elapsedTime sizeWithFont:FONT(11)
                        constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByWordWrapping];
  height += MARGIN + size.height;
  
  if (height < CELL_HEIGHT) {
    height = CELL_HEIGHT;
  }
  
  return height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return;
  }
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];

  CheckedinMember *member = (CheckedinMember *)(_fetchedRC.fetchedObjects)[indexPath.row];
  
  [self showProfile:member.personId userType:[NSString stringWithFormat:@"%@", member.userType]];
}

#pragma mark - ECClickableElementDelegate method
- (void)doChat:(Alumni*)aAlumni {
  
  self.alumni = aAlumni;
  
  UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSActionSheetTitle, nil)
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:LocaleStringForKey(NSChatActionSheetTitle, nil)
                                          otherButtonTitles:nil] autorelease];
  
  [as addButtonWithTitle:LocaleStringForKey(NSProfileActionSheetTitle, nil)];
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.navigationController.view];
}

#pragma mark - Action Sheet
- (void)beginChat {
  
  DMChatViewController *chatVC = [[[DMChatViewController alloc] initWithMOC:_MOC
                                                                     alumni:self.alumni] autorelease];
  [self.navigationController pushViewController:chatVC animated:YES];
  
  /*
  [CommonUtils doDelete:_MOC entityName:@"Chat"];
  ChatListViewController *chartVC = [[[ChatListViewController alloc] initWithMOC:_MOC
                                                                         alumni:self.alumni] autorelease];
  [self.navigationController pushViewController:chartVC animated:YES];
   */
}

- (void)actionSheet:(UIActionSheet*)aSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case CHAT_SHEET_IDX:
		{
      [self beginChat];
      return;
		}
      
		case DETAIL_SHEET_IDX:
      [self showProfile:self.alumni.personId userType:self.alumni.userType];
			return;
			
    case CANCEL_SHEET_IDX:
      return;
      
		default:
			break;
	}
}

@end
