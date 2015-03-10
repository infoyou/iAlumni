//
//  GroupMemberPhotoListViewController.m
//  iAlumni
//
//  Created by Adam on 13-7-29.
//
//

#import "GroupMemberPhotoListViewController.h"
#import "Alumni.h"
#import "ClubDetail.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "PlainTabView.h"
#import "PhotoWallView.h"
#import "AppManager.h"
#import "AlumniProfileViewController.h"
#import "PhotoElement.h"
#import "ILBarButtonItem.h"
#import "Search2FilterViewController.h"

#define HEADER_HEIGHT           0 //40.0f
#define CELL_IMAGE_COUNT        3
#define kImagePositionx         @"positionx"
#define kImagePositiony         @"positiony"

enum {
  FIRST_IDX,
  SECOND_IDX,
};

@interface GroupMemberPhotoListViewController() <TapSwitchDelegate, PhotoWallDelegate, UIActionSheetDelegate, HGPhotoDelegate>
{
  
  int currentDataSize;
  int tapIndex;
  
  BOOL isClickSearch;
  
  BOOL _needDistinguishCharge;
  
  NSInteger _selectedIdex;
}

@property (nonatomic, copy) NSString *payState;
@property (nonatomic, retain) ClubDetail *group;
@property (nonatomic, retain) PhotoWallView *photoWall;
@property (nonatomic, retain) PlainTabView *tabSwitchView;
@property (nonatomic, retain) NSMutableArray *arrayPositions;

@end

@implementation GroupMemberPhotoListViewController

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType
              forNew:(BOOL)forNew {
  
  [super loadListData:triggerType forNew:forNew];
  
  _currentType = CLUB_MANAGE_USER_TY;
  
  NSInteger index = 0;
  if (!forNew) {
    index = ++_currentStartIndex;
  }
  
  if ([AppManager instance].searchKeyWords && [AppManager instance].searchKeyWords.length > 0) {
    self.payState = NULL_PARAM_VALUE;
  }
  
  NSString *param = [NSString stringWithFormat:@"<host_id>%@</host_id><host_type></host_type><host_type_value>%@</host_type_value><host_sub_type_value>%@</host_sub_type_value><host_name>%@</host_name><page>%d</page><page_size>20</page_size><is_approve>%@</is_approve><member_name>%@</member_name>", self.group.sponsorId, self.group.hostSupTypeValue, self.group.hostTypeValue, self.group.name, index, self.payState, [AppManager instance].searchKeyWords];
  
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
  
  switch (_selectedIdex) {
    case FIRST_IDX:
      self.predicate = [NSPredicate predicateWithFormat:@"(groupId == %@) AND (isApprove == 1)", self.group.sponsorId];
      break;
      
    case SECOND_IDX:
      self.predicate = [NSPredicate predicateWithFormat:@"(groupId == %@) AND (isApprove == 0)", self.group.sponsorId];
      break;
      
    default:
      self.predicate = [NSPredicate predicateWithFormat:@"(groupId == %@)", self.group.sponsorId];
      break;
  }
}

#pragma mark - lifecycle methods

- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(ClubDetail *)group {
  
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:YES
                 needGoHome:NO];
  
  if (self) {
    self.group = group;
    self.payState = NULL_PARAM_VALUE;
    _selectedIdex = -1;
    [self clearData];
  }
  return self;
}

- (void)dealloc {
  
  [self clearData];
  self.payState = nil;
  self.group = nil;
  self.photoWall = nil;
  self.tabSwitchView = nil;
  self.arrayPositions = nil;
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [super addFilterButton];
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  [self initFilterMenuData];
  
  self.photoWall = [[[PhotoWallView alloc] initWithFrame:CGRectZero] autorelease];
  self.photoWall.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
  
  if (!_autoLoaded) {
    [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
    //        [self.tabSwitchView selectButtonWithIndex:FIRST_IDX];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (self.fetchedRC.fetchedObjects) {
    currentDataSize = self.fetchedRC.fetchedObjects.count;
    
    if (currentDataSize % 3 == 0) {
      return currentDataSize/3;
    } else {
      return currentDataSize/3 + 1;
    }
  } else {
    return 0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return PHOTO_ONE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"GroupMemberPhotoListCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  NSArray *subviews = [[NSArray alloc] initWithArray:cell.subviews];
  for (UIView *subview in subviews) {
    [subview removeFromSuperview];
  }
  [subviews release];
  
  if (indexPath) {
    [self addPhotoWallView:cell index:[indexPath row]];
  }
  
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  return cell;
}

- (void)addPhotoWallView:(UITableViewCell *)cell index:(int)index
{
  
  if (self.arrayPositions == nil) {
    self.arrayPositions = [NSMutableArray array];
    
    NSDictionary *positionDict = nil;
    for (int i=0; i<CELL_IMAGE_COUNT; i++) {
      switch (i%CELL_IMAGE_COUNT) {
        case 0:
          positionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"10", kImagePositionx, @"0", kImagePositiony, nil];
          break;
          
        case 1:
          positionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"116.6", kImagePositionx, @"0", kImagePositiony, nil];
          break;
          
        case 2:
          positionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"223.4", kImagePositionx, @"0", kImagePositiony, nil];
          break;
          
        default:
          break;
      }
      
      [self.arrayPositions insertObject:positionDict atIndex:i];
    }
  }
  
  NSArray *alumniArray = self.fetchedRC.fetchedObjects;
  int alumniCount = [alumniArray count];
  for (int i=0; i<CELL_IMAGE_COUNT; i++) {
    if (i > alumniCount - 1) {
      return;
    }
    
    int alumniIndex = index*CELL_IMAGE_COUNT + i;
    if (alumniIndex > currentDataSize-1) {
      return;
    }
    
    Alumni *alumni = (Alumni *)[alumniArray objectAtIndex:(alumniIndex)];
    NSDictionary *dictionaryTemp = [self.arrayPositions objectAtIndex:i];
    CGFloat originx = [[dictionaryTemp objectForKey:kImagePositionx] floatValue];
    CGFloat originy = [[dictionaryTemp objectForKey:kImagePositiony] floatValue];
    
    PhotoElement *photoTemp = [[[PhotoElement alloc] initWithOrigin:CGPointMake(originx, originy)] autorelease];
    photoTemp.delegate = self;
    [photoTemp setPhotoImageUrl:alumni.imageUrl];
    [photoTemp setUserNameValue:alumni.name];
    [photoTemp setCompanyValue:alumni.companyName];
    photoTemp.tag = [alumni.personId intValue];
    [cell addSubview:photoTemp];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType {
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType {
  
  if ([XMLParser parseMemberForGroupId:self.group.sponsorId.longLongValue
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
  currentDataSize = 0;
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - scroll action
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [super scrollViewDidScroll:scrollView];
}

#pragma mark - ECClickableElementDelegate method
- (void)openProfile:(NSString*)personId userType:(NSString*)userType
{
  
  //    if ([[AppManager instance].personId isEqualToString:personId]) {
  //        return;
  //    }
  
  Alumni *alumni = (Alumni *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                       entityName:@"Alumni"
                                                        predicate:[NSPredicate predicateWithFormat:@"personId == %@", personId]];
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC alumni:alumni userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - PhotoWallDelegate method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex != actionSheet.cancelButtonIndex) {
    [self.photoWall deletePhotoByIndex:tapIndex];
  }
}

- (void)photoWallPhotoTaped:(NSUInteger)index
{
  tapIndex = index;
  NSArray *alumniArray = self.fetchedRC.fetchedObjects;
  Alumni *clickAlumni = [alumniArray objectAtIndex:index];
  [self openProfile:clickAlumni.personId userType:@"1"];
  
  /*
   UIActionSheet *actionSheetTemp = [[UIActionSheet alloc] initWithTitle:nil
   delegate:self
   cancelButtonTitle:@"取消"
   destructiveButtonTitle:@"删除组员"
   otherButtonTitles:nil, nil];
   [actionSheetTemp showInView:self.view];
   [actionSheetTemp release];
   */
}

- (void)photoWallMovePhotoFromIndex:(NSInteger)index toIndex:(NSInteger)newIndex
{
  
}

- (void)photoWallAddAction
{
}

- (void)photoWallAddFinish
{
  
}

- (void)photoWallDeleteFinish
{
  
}

#pragma mark - refresh Photo Wall
- (void)refreshPhotoWall {
  
  if (currentDataSize == 0) {
    return;
  }
  
  NSMutableArray *photoArray = [NSMutableArray array];
  NSMutableArray *nameArray = [NSMutableArray array];
  NSMutableArray *companyArray = [NSMutableArray array];
  
  NSArray *alumniArray = self.fetchedRC.fetchedObjects;
  
  for (int i=0; i<currentDataSize; i++) {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
    
    NSLog(@"===== line = %d =====indexPath = %@===== ", i, indexPath);
    
    Alumni *alumni = (Alumni *)[alumniArray objectAtIndex:i];
    
    if(alumni.imageUrl && alumni.imageUrl.length > 0){
      NSLog(@"imageUrl = %@", alumni.imageUrl);
      [photoArray insertObject:alumni.imageUrl atIndex:i];
    } else {
      NSLog(@"imageUrl = EMPTY");
      [photoArray insertObject:NULL_PARAM_VALUE atIndex:i];
    }
    
    if (alumni.name && alumni.name.length > 0) {
      NSLog(@"name = %@", alumni.name);
      [nameArray insertObject:alumni.name atIndex:i];
    } else {
      NSLog(@"name = EMPTY");
      [nameArray insertObject:NULL_PARAM_VALUE atIndex:i];
    }
    
    if (alumni.companyName && alumni.companyName.length > 0) {
      NSLog(@"companyName = %@", alumni.companyName);
      [companyArray insertObject:alumni.companyName atIndex:i];
    } else {
      NSLog(@"companyName = EMPTY");
      //            [NSString stringWithFormat:@"=#=%d", i]
      [companyArray insertObject:NULL_PARAM_VALUE atIndex:i];
    }
  }
  
  [self.photoWall setPhotos:photoArray names:nameArray companys:companyArray];
  
  [_tableView reloadData];
}

- (void)photoTaped:(PhotoElement*)photo {
  [self openProfile:[NSString stringWithFormat:@"%d", photo.tag] userType:@"1"];
}

#pragma mark - handle vc
- (void)clearData {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(groupId == %@)", self.group.sponsorId];
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Alumni", predicate);
}

- (void)recoveryMainVC
{
  [super recoveryMainVC];
  
  switch ([AppManager instance].filterSupIndex) {
    case 0:
    {
      self.payState = NULL_PARAM_VALUE;
      _selectedIdex = -1;
    }
      break;
      
    case 1:
    {
      self.payState = @"1";
      _selectedIdex = FIRST_IDX;
    }
      break;
      
    case 2:
    {
      self.payState = @"0";
      _selectedIdex = SECOND_IDX;
    }
      break;
      
    default:
      break;
  }
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

#pragma mark - init Filter Menu data
-(void)initFilterMenuData {
  
  NSMutableArray *searchArray = nil;
  NSMutableArray *paramsArray = nil;
  
  searchArray = [NSMutableArray array];
  [searchArray insertObject:LocaleStringForKey(NSCheckAllTitle, nil)atIndex:0];
  [searchArray insertObject:LocaleStringForKey(NSHavePaidTitle, nil)atIndex:1];
  [searchArray insertObject:LocaleStringForKey(NSNotPaidTitle, nil)atIndex:2];
  
  paramsArray = nil;
  
  [super setListData:searchArray paramArray:paramsArray];
  
}

@end