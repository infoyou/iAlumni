//
//  AlumniRelationshipListViewController.m
//  iAlumni
//
//  Created by Adam on 12-11-28.
//
//

#import "AlumniRelationshipListViewController.h"
#import "AlumniLinkCell.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "RelationshipLink.h"
#import "CoreDataUtils.h"
#import "ECColorfulButton.h"
#import "XMLParser.h"
#import "AlumniProfileViewController.h"
#import "UIUtils.h"

#define AVATAR_DIAMETER        60.0f

#define PHOTO_WIDTH     56.0f
#define PHOTO_HEIGHT    58.0f

#define FAVORITE_BUTTON_BACKGROUND_HEIGHT           44.0f
#define CONTENT_FAVORITE_BUTTON_SEPARATOR_WIDTH     1.0f

@interface AlumniRelationshipListViewController ()
@end

@implementation AlumniRelationshipListViewController

#pragma mark - load data

- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = LOAD_ALL_KNOWN_ALUMNUS_TY;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  NSString *param = [NSString stringWithFormat:@"<page_size>%@</page_size><page>%d</page>", ITEM_LOAD_COUNT, index];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"RelationshipLink";

  self.descriptors = [NSMutableArray array];
  
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"linkId" ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];

}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC {
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  if (self) {
    DELETE_OBJS_FROM_MOC(_MOC, @"RelationshipLink", nil);
    
    RelationshipLink *link = (RelationshipLink *)[NSEntityDescription insertNewObjectForEntityForName:@"RelationshipLink"
                                                                               inManagedObjectContext:_MOC];
    link.linkId = @(1ll);
    link.referenceAvatarUrl = @"http://alumniapp.ceibs.edu:8080/ceibs_test/FileUploadServlet/upfiles/qronghao.e08sh2_middle_1354168718695.jpg?x=1";
    link.referenceType = @(1);
    link.referenceId = @(246109ll);
    link.referenceName = @"杨宁 Teddy";
    link.withMeEvent = @"与我一起参加了2012年10月13日的移动互联网协会成立大会";
    link.withTargetEvent = @"与张某一起参加了2012年9月17日的乐活活动";
    link.favorited = @(NO);
    
    link = (RelationshipLink *)[NSEntityDescription insertNewObjectForEntityForName:@"RelationshipLink"
                                                                               inManagedObjectContext:_MOC];
    link.linkId = @(2ll);
    link.referenceAvatarUrl = @"http://alumniapp.ceibs.edu:8080/ceibs_test/FileUploadServlet/upfiles/qronghao.e08sh2_middle_1354168718695.jpg?x=1";
    link.referenceType = @(1);
    link.referenceId = @(277558ll);
    link.referenceName = @"施金贵 SHI Jingui";
    link.withMeEvent = @"与我一起参加了2012年10月13日的移动互联网协会成立大会";
    link.withTargetEvent = @"与张某一起参加了2012年5月10日的足球俱乐部活动";
    link.favorited = @(YES);

    SAVE_MOC(_MOC);
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)setTableViewProperties {
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setTableViewProperties];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded) {
    
    //[self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    
    [self refreshTable];
  }
  _autoLoaded = YES;
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.fetchedRC.fetchedObjects.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (self.fetchedRC.fetchedObjects.count == indexPath.row) {
    return DEFAULT_CELL_HEIGHT;
  }
  
  RelationshipLink *link = (RelationshipLink *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  CGSize size = [link.referenceName sizeWithFont:BOLD_FONT(14)
                               constrainedToSize:CGSizeMake(PHOTO_WIDTH, CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
  
  CGFloat avatarSideHeight = PHOTO_MARGIN + PHOTO_HEIGHT + MARGIN + size.height + PHOTO_MARGIN;
  
  CGFloat textWidth = self.view.frame.size.width - (MARGIN * 4 + PHOTO_WIDTH + PHOTO_MARGIN * 2 + MARGIN * 2) - MARGIN * 4;
  
  size = [link.withMeEvent sizeWithFont:BOLD_FONT(13)
                      constrainedToSize:CGSizeMake(textWidth, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat withMeEventHeight = size.height;
  
  size = [link.withTargetEvent sizeWithFont:BOLD_FONT(13)
                          constrainedToSize:CGSizeMake(textWidth, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat withTargetEventHeight = size.height;
  
  CGFloat linkEventSideHeight = 0;
  if (withMeEventHeight < withTargetEventHeight) {
    linkEventSideHeight = withTargetEventHeight * 2 + MARGIN * 2;
  } else {
    linkEventSideHeight = withMeEventHeight * 2 + MARGIN * 2;
  }
  
  CGFloat cellHeight = 0;
  if (avatarSideHeight < linkEventSideHeight) {
    cellHeight = linkEventSideHeight + MARGIN * 4;
  } else {
    cellHeight = avatarSideHeight + MARGIN * 4;
  }
  
  //cellHeight += FAVORITE_BUTTON_BACKGROUND_HEIGHT + CONTENT_FAVORITE_BUTTON_SEPARATOR_WIDTH;
  
  cellHeight += MARGIN * 2 * 2;
  
  return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
    return [self drawFooterCell];
  }
  
  RelationshipLink *link = (RelationshipLink *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  static NSString *kCellIdentifier = @"linkCell";
  AlumniLinkCell *cell = (AlumniLinkCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[AlumniLinkCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:kCellIdentifier
                           imageDisplayerDelegate:self
                                   linkListHolder:self
                           connectTriggerDelegate:self
                                              MOC:_MOC] autorelease];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  [cell drawCellWithLink:link cellHeight:[self tableView:tableView heightForRowAtIndexPath:indexPath]];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == self.fetchedRC.fetchedObjects.count) {
    return;
  }
  
  RelationshipLink *link = (RelationshipLink *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  AlumniProfileViewController *alumniProfileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                          personId:[NSString stringWithFormat:@"%@", link.referenceId]
                                                                                          userType:ALUMNI_USER_TY] autorelease];
  alumniProfileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:alumniProfileVC animated:YES];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  if ([XMLParser parserResponseXml:result
                              type:contentType
                               MOC:_MOC
                 connectorDelegate:self
                               url:url]) {
   
    [self refreshTable];
    _autoLoaded = YES;
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchAlumnusFailedMsg, nil)
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
    self.connectionErrorMsg = LocaleStringForKey(NSFetchAlumnusFailedMsg, nil);
  }
  
  [super connectFailed:error url:url contentType:contentType];
}

@end
