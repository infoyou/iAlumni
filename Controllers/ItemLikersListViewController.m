//
//  ItemLikersListViewController
//  ExpatCircle
//
//  Created by Adam on 11-12-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ItemLikersListViewController.h"
#import "AppManager.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "CoreDataUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "Member.h"
#import "PeopleWithChatCell.h"
#import "Alumni.h"
#import "CoreDataUtils.h"
#import "ChatListViewController.h"
#import "Liker.h"
#import "AlumniFounder.h"
#import "XMLParser.h"
#import "AlumniProfileViewController.h"
#import "DMChatViewController.h"

#define PEOPLE_CELL_HEIGHT    90.0f

@interface ItemLikersListViewController()
@property (nonatomic, copy) NSString *hashedLikedItemId;
@property (nonatomic, retain) Alumni *alumni;
@end

@implementation ItemLikersListViewController

@synthesize hashedLikedItemId = _hashedLikedItemId;
@synthesize alumni = _alumni;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
needRefreshHeaderView:(BOOL)needRefreshHeaderView
needRefreshFooterView:(BOOL)needRefreshFooterView
hashedLikedItemId:(NSString *)hashedLikedItemId {
  
  self = [super initWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:needRefreshHeaderView
      needRefreshFooterView:needRefreshFooterView
                 needGoHome:NO];
  if (self) {
    self.hashedLikedItemId = hashedLikedItemId;
    
    _loadContentType = ITEM_LIKE_TY;
    
    _noNeedDisplayEmptyMsg = YES;
  }
  return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           itemId:(long long)itemId
  loadContentType:(WebItemType)loadContentType {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 needGoHome:NO];
  
  if (self) {
    _itemId = itemId;
    
    _loadContentType = loadContentType;
    
    _noNeedDisplayEmptyMsg = YES;
  }
  return self;
}

- (void)dealloc {
  
  self.hashedLikedItemId = nil;
  
  self.alumni = nil;
  
  [[WXWImageManager instance].imageCache clearAllCachedImages];
  
  [super dealloc];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
  
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
}

- (void)createFakeAlumniInstance {
  for (Liker *member in self.fetchedRC.fetchedObjects) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(personId == %@)", member.memberId];
    
    Alumni *alumni = (Alumni *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC entityName:@"Alumni" predicate:predicate];
    if (nil == alumni) {
      alumni = (Alumni *)[NSEntityDescription insertNewObjectForEntityForName:@"Alumni"
                                                       inManagedObjectContext:_MOC];
      alumni.personId = [NSString stringWithFormat:@"%@", member.memberId];
      alumni.classGroupName = member.groupClassName;
      alumni.name = member.name;
      alumni.companyName = member.companyName;
      alumni.imageUrl = member.photoUrl;
      alumni.userType = [NSString stringWithFormat:@"%@", member.userType];
      alumni.containerType = @(FETCH_SHAKE_USER_TY);
    }
  }
  SAVE_MOC(_MOC);
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded) {
    
    switch (_loadContentType) {
      case ITEM_LIKE_TY:
      {
        [self refreshTable];
        
        [self createFakeAlumniInstance];
        break;
      }
        
      case LOAD_BRAND_ALUMNUS_TY:
        [self loadAlumniFounders];
        break;
        
      default:
        break;
    }
        
    _autoLoaded = YES;
  }
}

#pragma mark - load data
- (void)configureMOCFetchConditions {
  
  self.descriptors = [NSMutableArray array];
  
  switch (_loadContentType) {
    case ITEM_LIKE_TY:
    {
      self.predicate = [NSPredicate predicateWithFormat:@"(ANY likedItemIds.itemId == %@)", self.hashedLikedItemId];
      self.entityName = @"Liker";
      
      NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"memberId" ascending:NO] autorelease];
      [self.descriptors addObject:sortDescriptor];
      break;
    }
      
    case LOAD_BRAND_ALUMNUS_TY:
    {
      self.predicate = [NSPredicate predicateWithFormat:@"(brandId == %lld)", _itemId];
      self.entityName = @"AlumniFounder";
      NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"personId" ascending:NO] autorelease];
      [self.descriptors addObject:sortDescriptor];

      break;
    }
      
    default:
      break;
  }
    

}

- (void)loadAlumniFounders {
  NSString *param = [NSString stringWithFormat:@"<channel_id>%lld</channel_id>", _itemId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:LOAD_BRAND_ALUMNUS_TY];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self interactionContentType:LOAD_BRAND_ALUMNUS_TY] autorelease];
  (self.connDic)[url] = connFacade;
  
  [connFacade asyncGet:url showAlertMsg:YES];
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
    case LOAD_BRAND_ALUMNUS_TY:
      if ([XMLParser parserResponseXml:result
                                  type:LOAD_BRAND_ALUMNUS_TY
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url
                          parentItemId:_itemId]) {
        
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
    case LOAD_BRAND_ALUMNUS_TY:
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
  return self.fetchedRC.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *kCellIdentifier = @"kUserCell";
  PeopleWithChatCell *cell = (PeopleWithChatCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[PeopleWithChatCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:kCellIdentifier
                             imageDisplayerDelegate:self
                             imageClickableDelegate:self
                                                MOC:_MOC] autorelease];
  }
  
  NSPredicate *predicate = nil;
  switch (_loadContentType) {
    case ITEM_LIKE_TY:
    {
      Liker *member = (Liker *)[self.fetchedRC objectAtIndexPath:indexPath];
      
      predicate = [NSPredicate predicateWithFormat:@"(personId == %@)", member.memberId];
      break;
    }
    case LOAD_BRAND_ALUMNUS_TY:
    {
      AlumniFounder *founder = (AlumniFounder *)[self.fetchedRC objectAtIndexPath:indexPath];
      
      predicate = [NSPredicate predicateWithFormat:@"(personId == %@)", founder.personId];
      break;
    }
      
    default:
      break;
  }
  
  Alumni *alumni = (Alumni *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                    entityName:@"Alumni"
                                                     predicate:predicate];
  
  [cell drawCell:alumni];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return PEOPLE_CELL_HEIGHT;
}

- (void)showProfile:(NSString *)personId userType:(NSString *)userType {
  
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                    personId:personId
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
  
  Liker *member = (Liker *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  [self showProfile:member.personId userType:[NSString stringWithFormat:@"%@", member.userType]];

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
