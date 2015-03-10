//
//  IndustryListViewController.m
//  iAlumni
//
//  Created by Adam on 12-11-25.
//
//

#import "IndustryListViewController.h"
#import "Industry.h"
#import "CoreDataUtils.h"
#import "AppManager.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "ConfigurableTextCell.h"
#import "XMLParser.h"
#import "UIUtils.h"

#define IMAGE_TAG 100
#define ICON_SIDE_LENGTH  24.0f

@interface IndustryListViewController ()
@property (nonatomic, copy) NSString *currentSelectedIndustryId;
@end

@implementation IndustryListViewController

#pragma mark - load industries
- (void)loadIndustries {

  NSString *url = ALUMNI_INDUSTRY_REQ_URL;
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                           contentType:INDUSTRY_TY];
  
  [connFacade fetchGets:url];
}

- (void)configureMOCFetchConditions {
  self.entityName = @"Industry";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *sortDesc = [[[NSSortDescriptor alloc] initWithKey:@"industryId" ascending:YES] autorelease];
  [self.descriptors addObject:sortDesc];
  
}

- (BOOL)industriesLoaded {
  return [WXWCoreDataUtils objectInMOC:_MOC
                         entityName:@"Industry"
                          predicate:[NSPredicate predicateWithFormat:@"(industryId <> %@)", INDUSTRY_ALL_ID]];
}


#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
currentSelectedIndustryId:(NSString *)currentSelectedIndustryId
     searchHolder:(id)searchHolder
     selectAction:(SEL)selectAction {
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 needGoHome:NO];
  if (self) {
    self.currentSelectedIndustryId = currentSelectedIndustryId;
    
    _searchHolder = searchHolder;
    _selectAction = selectAction;
  }
  return self;
}

- (void)dealloc {
  
  self.currentSelectedIndustryId = nil;
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if ([self industriesLoaded]) {
    [self refreshTable];
  } else {
    [self loadIndustries];
  }
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.fetchedRC.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  static NSString *kCellIdentifier = @"industryCell";

  Industry *industry = (Industry *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  ConfigurableTextCell *cell =  [self configurePlainCell:kCellIdentifier
                                                   title:industry.cnName
                                              badgeCount:0
                                                 content:nil
                                               indexPath:indexPath
                                               clickable:YES
                                          selectionStyle:UITableViewCellSelectionStyleBlue];
  
  if (nil == [cell.contentView viewWithTag:IMAGE_TAG]) {
    UIImageView *icon = [[[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - MARGIN * 2 - ICON_SIDE_LENGTH, (DEFAULT_CELL_HEIGHT - ICON_SIDE_LENGTH)/2.0f, ICON_SIDE_LENGTH, ICON_SIDE_LENGTH)] autorelease];
    icon.tag = IMAGE_TAG;
    icon.backgroundColor = TRANSPARENT_COLOR;
    [cell.contentView addSubview:icon];
  }
  
  UIImageView *selectionIcon = (UIImageView *)[cell.contentView viewWithTag:IMAGE_TAG];
  
  if ([industry.industryId isEqualToString:_currentSelectedIndustryId]) {
    selectionIcon.image = [UIImage imageNamed:@"radioButton.png"];
  } else {
    selectionIcon.image = [UIImage imageNamed:@"unselected.png"];
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Industry *industry = (Industry *)[self.fetchedRC objectAtIndexPath:indexPath];
  
  if (_searchHolder && _selectAction) {
    [_searchHolder performSelector:_selectAction withObject:industry];
  }
  
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
  [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil) blockCurrentView:YES];
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  switch (contentType) {
    case INDUSTRY_TY:
    {
      if([XMLParser parserResponseXml:result
                                 type:contentType
                                  MOC:_MOC
                    connectorDelegate:self
                                  url:url]) {
        [AppManager instance].isLoadIndustryDataOK = YES;
        
        [self refreshTable];
      
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFetchIndustryFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
    }
      break;
      
    default:
      break;
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
  [super connectFailed:error url:url contentType:contentType];
}

@end
