//
//  WelfareBrandViewController.m
//  iAlumni
//
//  Created by Adam on 13-8-21.
//
//

#import "WelfareBrandViewController.h"
#import "Welfare.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "Brand.h"
#import "BrandInfoCell.h"
#import "CompanyManagerCell.h"
#import "AlumniProfileViewController.h"
#import "ChatListViewController.h"
#import "DMChatViewController.h"

#define CELL_INNER_MARGIN     8.0f

#define FIRST_ALUMNI_CELL_HEIGHT    105.0f
#define ALUMNI_CELL_HEIGHT          70.0f
#define AVATAR_SIDE_LEN             50

enum {
  INFO_SEC,
  ALUMNI_SEC
};

enum {
  BRAND_INFO_CELL,
};

@interface WelfareBrandViewController ()
@property (nonatomic, retain) Brand *brand;
@property (nonatomic, retain) NSArray *alumniList;
@end

@implementation WelfareBrandViewController

#pragma mark - user action
- (void)triggerChat:(Alumni *)alumni {
  
  DMChatViewController *chatVC = [[[DMChatViewController alloc] initWithMOC:_MOC
                                                                     alumni:alumni] autorelease];
  [self.navigationController pushViewController:chatVC animated:YES];

  /*
  [CommonUtils doDelete:_MOC entityName:@"Chat"];
  ChatListViewController *chartVC = [[ChatListViewController alloc] initWithMOC:_MOC alumni:alumni];
  chartVC.title = LocaleStringForKey(NSChatWithTitle, nil);
  [self.navigationController pushViewController:chartVC animated:YES];
  RELEASE_OBJ(chartVC);
*/
}

#pragma mark - load data
- (void)loadBrandDetail {
  _currentType = LOAD_WELFARE_BRAND_DETAIL_TY;
  
  NSString *param = STR_FORMAT(@"<brandId>%@</brandId>", _welfare.brandId);
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:YES];
}

#pragma mark - life cycle methods
- (id)initWithWelfare:(Welfare *)welfare MOC:(NSManagedObjectContext *)MOC
{
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                                          holder:nil
                                backToHomeAction:nil
                           needRefreshHeaderView:NO
                           needRefreshFooterView:NO
                                      tableStyle:UITableViewStyleGrouped
                                      needGoHome:NO];
  if (self) {
    _welfare = welfare;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateInfoCell:)
                                                 name:TEXT_CONTENT_LOADED_NOTIFY
                                               object:nil];
    
  }
  return self;
}

- (void)dealloc {
  
  self.brand = nil;
  
  self.alumniList = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:TEXT_CONTENT_LOADED_NOTIFY
                                                object:nil];
  
  [super dealloc];
}

- (void)setTableViewProperties {
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  _tableView.alpha = 0.0f;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  [self setTableViewProperties];
}

- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  
  if (!_autoLoaded) {
    [self loadBrandDetail];
  }
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

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  switch (contentType) {
    case LOAD_WELFARE_BRAND_DETAIL_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        self.brand = (Brand *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                        entityName:@"Brand"
                                                         predicate:[NSPredicate predicateWithFormat:@"(brandId == %@)", _welfare.brandId]];
        
        self.alumniList = self.brand.brandAlumnus.allObjects;
        _hasAlumni = self.alumniList.count > 0 ? YES : NO;
        
        _autoLoaded = YES;
        [_tableView reloadData];
        
        _tableView.alpha = 1.0f;
      }
      break;
    }
    default:
      break;
  }
  
  [super connectDone:result
                 url:url
         contentType:contentType];
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

#pragma mark - UITableViewDelegate, UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  
  if (_hasAlumni) {
    return 2;
  } else {
    return 1;
  }
  
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case INFO_SEC:
      return 1;
      
    case ALUMNI_SEC:
      return self.alumniList.count;
      
    default:
      return 0;
  }
}

- (BrandInfoCell *)drawBrandInfoCellAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *kCellIdentifier = @"brandInfoCell";
  BrandInfoCell *cell = (BrandInfoCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (cell == nil) {
    cell = [[[BrandInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                 reuseIdentifier:kCellIdentifier] autorelease];
    
    cell.cornerRadius = 2.0f;
  }
  
  [cell parserCellPositionAtIndexPath:indexPath elementTotalCount:1];
  
  [cell drawCellWithBrand:self.brand height:[self brandInfoCellHeight] - WELFARE_CELL_MARGIN * 2];
  
  return cell;
}


- (UITableViewCell *)drawAlumniCellAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *kCellIndentifier = @"alumniCell";
  CompanyManagerCell *cell = (CompanyManagerCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIndentifier];
  if (cell == nil) {
    cell = [[[CompanyManagerCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kCellIndentifier
                                          brandInfoVC:self
                                           chatAction:@selector(triggerChat:)] autorelease];
    
    cell.cornerRadius = 2.0f;
  }
  
  [cell parserCellPositionAtIndexPath:indexPath elementTotalCount:self.alumniList.count];
  
  if (indexPath.row < self.alumniList.count) {
    Alumni *alumni = self.alumniList[indexPath.row];
    
    NSString *title = nil;
    if (indexPath.row == 0) {
      title = LocaleStringForKey(NSAlumniInCompanyTitle, nil);
    }
    [cell drawCellWithAlumni:alumni title:title];
  }

  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case INFO_SEC:
      return [self drawBrandInfoCellAtIndexPath:indexPath];
      
    case ALUMNI_SEC:
      
      return [self drawAlumniCellAtIndexPath:indexPath];
      
    default:
      return nil;
  }
}

- (CGFloat)brandInfoCellHeight {
  
  CGFloat height = CELL_INNER_MARGIN;//WELFARE_CELL_MARGIN + CELL_INNER_MARGIN;
  
  CGSize size = [LocaleStringForKey(NSIntroTitle, nil) sizeWithFont:BOLD_FONT(25)];
  height += size.height + CELL_INNER_MARGIN;
  
  CGFloat textLimitedWidth = self.view.frame.size.width - WELFARE_CELL_MARGIN * 2 - CELL_INNER_MARGIN * 2;
  size = [self.brand.name sizeWithFont:BOLD_FONT(20) constrainedToSize:CGSizeMake(textLimitedWidth, CGFLOAT_MAX)];
  
  height += size.height + CELL_INNER_MARGIN * 2;
  
  //  size = [self.brand.bio sizeWithFont:BOLD_FONT(13)
  //                constrainedToSize:CGSizeMake(textLimitedWidth, CGFLOAT_MAX)];
  //  height += size.height + CELL_INNER_MARGIN * 3;
  
  height += _textContentHeight + CELL_INNER_MARGIN * 3;
  
  size = [LocaleStringForKey(NSConsultTitle, nil) sizeWithFont:BOLD_FONT(15)];
  
  //height += size.height + CELL_INNER_MARGIN + WELFARE_CELL_MARGIN;
  height += size.height;
  
  return height;
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case INFO_SEC:
      return [self brandInfoCellHeight];
      
    case ALUMNI_SEC:
    {
      if (indexPath.row == 0) {
        return FIRST_ALUMNI_CELL_HEIGHT;
      }
      
      return ALUMNI_CELL_HEIGHT;
    }
      
    default:
      return 0;
  }
}

- (void)callSupport {
  if ([NULL_PARAM_VALUE isEqualToString:self.brand.tel]) {
    return;
  }
  
  UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSCallActionSheetTitle, nil)
                                                  delegate:self
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
  
  [as addButtonWithTitle:LocaleStringForKey(NSCallTitle, nil)];
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.navigationController.view];
  
  RELEASE_OBJ(as);
  
}

- (void)selectAlumniAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row < self.alumniList.count) {
    
    Alumni *alumni = self.alumniList[indexPath.row];
    
    AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                      personId:alumni.userId
                                                                                      userType:ALUMNI_USER_TY] autorelease];
    profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
    [self.navigationController pushViewController:profileVC animated:YES];
  }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (indexPath.section) {
    case INFO_SEC:
    {
      [self callSupport];
      break;
    }
      
    case ALUMNI_SEC:
    {
      [self selectAlumniAtIndexPath:indexPath];
      break;
    }
    default:
      break;
  }
}

- (void)updateInfoCell:(NSNotification *)notification {
  
  NSDictionary *heightDic = [notification userInfo];
  NSNumber *heightInfo = (NSNumber *)heightDic[TEXT_CONTENT_HEIGHT_KEY];
  
  _textContentHeight = heightInfo.floatValue;
  
  _textContentLoaded = YES;
  
  /*
   [_tableView beginUpdates];
   [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
   withRowAnimation:UITableViewRowAnimationNone];
   [_tableView endUpdates];
   */
  [_tableView reloadData];
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case CALL_ACTION_SHEET_IDX:
    {
      if (self.brand.tel.length > 0) {
        NSString *phoneNumber = [self.brand.tel stringByReplacingOccurrencesOfString:@" " withString:NULL_PARAM_VALUE];
        phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:NULL_PARAM_VALUE];
        NSString *phoneStr = [[NSString alloc] initWithFormat:@"tel:%@", phoneNumber];
        NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
        [[UIApplication sharedApplication] openURL:phoneURL];
        [phoneURL release];
        [phoneStr release];
      }
      break;
    }
    default:
      break;
  }
}

@end
