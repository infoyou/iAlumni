//
//  VoteDetailViewController.m
//  iAlumni
//
//  Created by Adam on 12-9-10.
//
//

#import "VoteDetailViewController.h"
#import "EventTopic.h"
#import "Option.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "TopicOptionCell.h"
#import "TopicContentView.h"
#import "ECColorfulButton.h"
#import "AppManager.h"
#import "UIUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "XMLParser.h"
#import "UIImageButton.h"

#define OPTION_VIEW_WIDTH           145.0f

#define ONE_OPTIONS_COUNT           2

#define SELECTION_ICON_SIDE_LENGTH  24.0f

#define SUBMIT_BUTTON_WIDTH         200.0f
#define SUBMIT_BUTTON_HEIGHT        36.0f

#define MIN_HEIGHT                  130.0f

@interface VoteDetailViewController ()
@property (nonatomic, retain) EventTopic *eventTopic;
@property (nonatomic, retain) Option *selectedOption;
@end

@implementation VoteDetailViewController

@synthesize eventTopic = _eventTopic;
@synthesize selectedOption = _selectedOption;

#pragma mark - user action
- (void)submit:(id)sender {
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(selected == 1)"];
  Option *selectedOption = (Option *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                            entityName:@"Option"
                                                             predicate:predicate];
  if (selectedOption) {
    
    self.selectedOption = selectedOption;
    
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSSelectOptionConfirmMsg, nil)
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil];
    
    [as addButtonWithTitle:LocaleStringForKey(NSYesTitle, nil)];
    [as addButtonWithTitle:LocaleStringForKey(NSNoTitle, nil)];
    as.cancelButtonIndex = [as numberOfButtons] - 1;
    [as showInView:self.navigationController.view];
    
    RELEASE_OBJ(as);
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSSelectOneOptionMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
}

- (void)doSubmit {
  
  NSString *param = [NSString stringWithFormat:@"<person_id>%@</person_id><pool_id>%@</pool_id><item_id>%@</item_id>", [AppManager instance].personId, self.eventTopic.topicId, self.selectedOption.optionId];
  
  NSString *url = [CommonUtils geneUrl:param itemType:SUBMIT_OPTION_TY];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self interactionContentType:SUBMIT_OPTION_TY] autorelease];
  (self.connDic)[url] = connFacade;
  
  [connFacade asyncGet:url showAlertMsg:YES];
  
  self.selectedOption = nil;
  
}

#pragma mark - load data

- (void)configureMOCFetchConditions {
  self.entityName = @"Option";
  self.predicate = [NSPredicate predicateWithFormat:@"(topicId == %@)", self.eventTopic.topicId];
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"orderId"
                                                                  ascending:YES] autorelease];
  [self.descriptors addObject:sortDescriptor];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC eventTopic:(EventTopic *)eventTopic {
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 needGoHome:NO];
  
  if (self) {
    self.eventTopic = eventTopic;
    _noNeedDisplayEmptyMsg = YES;
  }
  return self;
}

- (void)dealloc {
  
  self.eventTopic = nil;
  
  self.selectedOption = nil;
  
  DELETE_OBJS_FROM_MOC(_MOC, @"Option", nil);
  
  [super dealloc];
}

- (void)initTableViewHeaderView {
  CGSize size = [self.eventTopic.content sizeWithFont:BOLD_FONT(15)
                                    constrainedToSize:CGSizeMake(self.view.frame.size.width - (MARGIN * 4 + MARGIN * 2), CGFLOAT_MAX)
                                        lineBreakMode:NSLineBreakByWordWrapping];
  TopicContentView *headerView = [[[TopicContentView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, size.height + MARGIN * 4 + MARGIN * 2)
                                                                  content:self.eventTopic.content] autorelease];
  _tableView.tableHeaderView = headerView;
  
  _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y,
                                _tableView.frame.size.width, _tableView.frame.size.height - TOOLBAR_HEIGHT);
  
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)initBottomToolbar {
  
  CGFloat y = self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - TOOLBAR_HEIGHT;
  
  _bottomToolbar = [[[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, TOOLBAR_HEIGHT)] autorelease];
  _bottomToolbar.backgroundColor = [UIColor colorWithWhite:0.1f alpha:0.7f];
  [self.view addSubview:_bottomToolbar];
  
  UIImageButton *submitButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake((self.view.frame.size.width - SUBMIT_BUTTON_WIDTH)/2.0f, (TOOLBAR_HEIGHT - SUBMIT_BUTTON_HEIGHT)/2.0f, SUBMIT_BUTTON_WIDTH, SUBMIT_BUTTON_HEIGHT)
                                                                          target:self
                                                                          action:@selector(submit:)
                                                                           title:LocaleStringForKey(NSSubmitButTitle, nil)
                                                                           image:nil
                                                                     backImgName:@"orangeButton.png"
                                                                  selBackImgName:nil
                                                                       titleFont:BOLD_FONT(20)
                                                                      titleColor:[UIColor whiteColor]
                                                                titleShadowColor:TRANSPARENT_COLOR
                                                                     roundedType:NO_ROUNDED
                                                                 imageEdgeInsert:ZERO_EDGE
                                                                 titleEdgeInsert:ZERO_EDGE] autorelease];
  [_bottomToolbar addSubview:submitButton];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  [self initTableViewHeaderView];
  
  [self initBottomToolbar];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded) {
    [self refreshTable];
    
    _autoLoaded = YES;
  }
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
            blockCurrentView:YES];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case SUBMIT_OPTION_TY:
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSSubmitDoneMsg, nil)
                                      msgType:SUCCESS_TY
                           belowNavigationBar:YES];
        
        self.eventTopic.voted = @YES;
        SAVE_MOC(_MOC);
        
        [self.navigationController popViewControllerAnimated:YES];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSSubmitFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      break;
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  NSString *msg = nil;
  
  switch (contentType) {
    case SUBMIT_OPTION_TY:
      msg = LocaleStringForKey(NSSubmitFailedMsg, nil);
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
  
  NSInteger count = ceil((double)_fetchedRC.fetchedObjects.count/ONE_OPTIONS_COUNT);
  return count;
}

- (CGFloat)cellHeight:(Option *)leftOption rightOption:(Option *)rightOption {
  CGSize leftSize = CGSizeMake(0, 0);
  if (leftOption) {
    leftSize = [leftOption.content sizeWithFont:BOLD_FONT(13)
                              constrainedToSize:CGSizeMake(OPTION_VIEW_WIDTH - MARGIN * 4, CGFLOAT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping];
  }
  
  CGSize rightSize = CGSizeMake(0, 0);
  if (rightOption) {
    rightSize = [rightOption.content sizeWithFont:BOLD_FONT(13)
                                constrainedToSize:CGSizeMake(OPTION_VIEW_WIDTH - MARGIN * 4, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
  }
  
  CGFloat height = (rightSize.height < leftSize.height ? leftSize.height : rightSize.height);
  height += MARGIN * 4 + (MARGIN + SELECTION_ICON_SIDE_LENGTH + MARGIN) * 2;
  
  if (height < MIN_HEIGHT) {
    return MIN_HEIGHT;
  } else {
    return height;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *kCellIdentifier = @"OptionCell";
  TopicOptionCell *cell = (TopicOptionCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[TopicOptionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:kCellIdentifier
                                               MOC:_MOC
                                          delegate:self] autorelease];
  }
  
  Option *leftOption = nil;
  Option *rightOption = nil;
  if (indexPath.row * 2 < self.fetchedRC.fetchedObjects.count) {
    leftOption = (Option *)(self.fetchedRC.fetchedObjects)[indexPath.row * 2];
  }
  
  if ((indexPath.row * 2 + 1) < self.fetchedRC.fetchedObjects.count) {
    rightOption = (Option *)(self.fetchedRC.fetchedObjects)[(indexPath.row * 2 + 1)];
  }
  
  [cell drawCellWithLeftOption:leftOption
                   rightOption:rightOption
                     cellIndex:indexPath.row
                        height:[self cellHeight:leftOption
                                    rightOption:rightOption]];
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  Option *leftOption = nil;
  Option *rightOption = nil;
  if (indexPath.row * 2 < self.fetchedRC.fetchedObjects.count) {
    leftOption = (Option *)(self.fetchedRC.fetchedObjects)[indexPath.row * 2];
  }
  
  if ((indexPath.row * 2 + 1) < self.fetchedRC.fetchedObjects.count) {
    rightOption = (Option *)(self.fetchedRC.fetchedObjects)[(indexPath.row * 2 + 1)];
  }
  
  return [self cellHeight:leftOption rightOption:rightOption];
}

#pragma mark - EventVoteDelegate methods
- (void)refreshVoteOptions {
  [_tableView reloadData];
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  switch (buttonIndex) {
    case CALL_ACTION_SHEET_IDX:
    {
      // TODO add submit action
      [self doSubmit];
      break;
    }
    case CANCEL_ACTION_SHEET_IDX:
      return;
      
    default:
      break;
  }
  
}

@end
