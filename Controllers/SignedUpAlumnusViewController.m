//
//  SignedUpAlumnusViewController.m
//  iAlumni
//
//  Created by Adam on 12-9-8.
//
//

#import "SignedUpAlumnusViewController.h"
#import "AppManager.h"
#import "WXWImageCache.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "CoreDataUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "Member.h"
#import "PeopleWithChatCell.h"
#import "EventSignedUpAlumni.h"
#import "CoreDataUtils.h"
#import "ChatListViewController.h"
#import "Liker.h"
#import "AlumniFounder.h"
#import "XMLParser.h"
#import "Event.h"
#import "AlumniProfileViewController.h"
#import "DMChatViewController.h"

#define PEOPLE_CELL_HEIGHT    90.0f
#define NAME_LIMITED_WIDTH    144.0f

#define PHOTO_WIDTH           56.0f

@interface SignedUpAlumnusViewController ()
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Alumni *alumni;
@end

@implementation SignedUpAlumnusViewController

@synthesize event = _eventDetail;
@synthesize alumni = _alumni;

#pragma mark - load alumnus
- (void)configureMOCFetchConditions {
  self.entityName = @"EventSignedUpAlumni";
  
  self.descriptors = [NSMutableArray array];
  
  self.predicate = [NSPredicate predicateWithFormat:@"(eventId == %@)", self.event.eventId];
  NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"orderId"
                                                                  ascending:YES] autorelease];
  [self.descriptors addObject:sortDescriptor];
}

- (void)loadListData:(LoadTriggerType)triggerType
             forNew:(BOOL)forNew {

  [super loadListData:triggerType forNew:forNew];
  
  NSInteger startIndex = 0;
  if (!forNew) {
    startIndex = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<event_id>%@</event_id><page>%d</page><page_size>%@</page_size><is_get_checkin>1</is_get_checkin>",
                     self.event.eventId, startIndex, ITEM_LOAD_COUNT];
  
  NSString *url = [CommonUtils geneUrl:param itemType:SIGNUP_USER_TY];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self interactionContentType:SIGNUP_USER_TY] autorelease];
  (self.connDic)[url] = connFacade;
  
  [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
      event:(Event *)event {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:YES
      needRefreshFooterView:YES
                 needGoHome:NO];
  if (self) {
    self.event = event;
    
  }
  return self;
}

- (void)dealloc {
  
  self.event = nil;
  
  self.alumni = nil;
  
  [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = CELL_COLOR;
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
            blockCurrentView:NO];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case SIGNUP_USER_TY:
      if ([XMLParser parserEventStuff:result
                             itemType:SIGNUP_USER_TY
                          event:self.event
                                  MOC:_MOC
                    connectorDelegate:self
                                  url:url]) {
        
        [self refreshTable];
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumniFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      break;
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  NSString *msg = nil;
  
  switch (contentType) {
    case SIGNUP_USER_TY:
      msg = LocaleStringForKey(NSFetchAlumniFailedMsg, nil);
      break;
      
    default:
      break;
  }

  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  }

  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  return self.fetchedRC.fetchedObjects.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return [self drawFooterCell];
  }
  
  static NSString *kCellIdentifier = @"kUserCell";
  PeopleWithChatCell *cell = (PeopleWithChatCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[PeopleWithChatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:kCellIdentifier
                             imageDisplayerDelegate:self
                             imageClickableDelegate:self
                                                MOC:_MOC] autorelease];
  }
  
  EventSignedUpAlumni *alumni = (EventSignedUpAlumni *)[_fetchedRC objectAtIndexPath:indexPath];
  
  [cell drawCell:alumni];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == _fetchedRC.fetchedObjects.count) {
    return PEOPLE_CELL_HEIGHT;
  } else {
    EventSignedUpAlumni *alumni = (EventSignedUpAlumni *)[_fetchedRC objectAtIndexPath:indexPath];
    
    CGSize constraint = CGSizeMake(NAME_LIMITED_WIDTH, 20);
    CGSize size = [alumni.name sizeWithFont:Arial_FONT(14)
                          constrainedToSize:constraint
                              lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGFloat height = MARGIN + size.height + MARGIN;
    
    size = [alumni.companyName sizeWithFont:FONT(13)
                          constrainedToSize:CGSizeMake(280 - MARGIN -
                                                       (MARGIN + PHOTO_WIDTH + PHOTO_MARGIN * 2 +
                                                        MARGIN * 2),
                                                       CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
    
    height += size.height + MARGIN;
    
    if (height < PEOPLE_CELL_HEIGHT) {
      height = PEOPLE_CELL_HEIGHT;
    }
    
    return height;
  }
}

- (void)showProfile:(NSString *)personId userType:(NSString *)userType {
  
  Alumni *alumni = (Alumni *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                    entityName:@"Alumni"
                                                     predicate:[NSPredicate predicateWithFormat:@"(personId == %@)", personId]];
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                      alumni:alumni
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)beginChat {
  
  DMChatViewController *chatVC = [[[DMChatViewController alloc] initWithMOC:_MOC
                                                                     alumni:self.alumni] autorelease];
  [self.navigationController pushViewController:chatVC animated:YES];

  /*
  [CommonUtils doDelete:_MOC entityName:@"Chat"];
  ChatListViewController *chartVC = [[ChatListViewController alloc] initWithMOC:_MOC
                                                                         alumni:self.alumni];
  [self.navigationController pushViewController:chartVC animated:YES];
  RELEASE_OBJ(chartVC);
   */
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ([self currentCellIsFooter:indexPath]) {
    return;
  }
  
  EventSignedUpAlumni *alumni = (EventSignedUpAlumni *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  [self showProfile:alumni.personId userType:[NSString stringWithFormat:@"%@", alumni.userType]];
  
  [_tableView deselectRowAtIndexPath:indexPath animated:YES];
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
