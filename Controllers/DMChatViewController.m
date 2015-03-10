//
//  DMChatViewController.m
//  iAlumni
//
//  Created by Adam on 13-10-23.
//
//

#import "DMChatViewController.h"
#import "Alumni.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "Post.h"
#import "AppManager.h"

@interface DMChatViewController ()
@property (nonatomic, retain) Alumni *alumni;
@property (nonatomic, retain) NSString    *startChatId;
@property (nonatomic, retain) NSString    *endChatId;

@end

@implementation DMChatViewController

#pragma mark - action

- (void)loadLatestChat:(NSNotification *)notification {
  [self refreshData:nil];
}

- (void)refreshData:(id)sender {
  
  _needAutoScrollToBottom = YES;
  
  [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
}

- (void)send {
  
  _currentType = CHAT_SUBMIT_TY;
  
  NSString *param = [NSString stringWithFormat:@"<target_user_id>%@</target_user_id><target_user_type>%@</target_user_type><message>%@</message>", self.alumni.personId, self.alumni.userType, self.content];
  
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url contentType:_currentType];
  [connFacade fetchGets:url];
}

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  NSString *requestParam = [NSString stringWithFormat:@"<target_user_id>%@</target_user_id><target_user_type>%@</target_user_type><id>%@</id><page_turning>%d</page_turning><page_size>6</page_size>", self.alumni.personId, self.alumni.userType, forNew == YES ? self.endChatId : self.startChatId, forNew == YES ? 2 : 1];
  
  _currentType = CHART_LIST_TY;
  
  NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade fetchGets:url];
}

- (void)configureMOCFetchConditions {
  
  self.predicate = [NSPredicate predicateWithFormat:@"authorId.lenght > 0"];
  
  self.entityName = @"Post";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];
}


#pragma mark - life cycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC alumni:(Alumni *)alumni
{
  self = [super initWithMOC:MOC needTakePhoto:NO];
  if (self) {
    self.alumni = alumni;
    
    self.startChatId = NULL_PARAM_VALUE;
    self.endChatId = NULL_PARAM_VALUE;
    
    [AppManager instance].notShowDMAlert = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadLatestChat:)
                                                 name:DM_PUSH_RECEIVED_NOTIFY
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  
  [AppManager instance].notShowDMAlert = NO;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:DM_PUSH_RECEIVED_NOTIFY
                                                object:nil];
  
  self.alumni = nil;
  self.endChatId = nil;
  self.startChatId = nil;
  
  [super dealloc];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSRefreshTitle, nil)
                            target:self
                            action:@selector(refreshData:)];
  
  self.title = LocaleStringForKey(NSChatWithTitle, nil);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECConnectorDelegate methoes
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case CHART_LIST_TY:
    {
      if (!_loadNew) {
        
        [self addSpinViewInView:_headerView text:LocaleStringForKey(NSLoadingTitle, nil)];
      } else {
        
        [self addSpinViewInView:_footerView text:LocaleStringForKey(NSLoadingTitle, nil)];
      }
      
      break;
    }
      
    case CHAT_SUBMIT_TY:
    {
      [self addSpinViewInView:_footerView text:LocaleStringForKey(NSSendingTitle, nil)];
      break;
    }
    default:
      break;
  }
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
      
    case CHART_LIST_TY:
    {
      if ([XMLParser parserDMMessageWithxmlData:result
                                            MOC:_MOC
                              connectorDelegate:self
                                            url:url
                                         alumni:self.alumni]) {
        
        [self refreshTable];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSLoadFeedFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      [self resetLoadingStatus];
      break;
    }
      
    case CHAT_SUBMIT_TY:
    {
      if (RESP_OK == [XMLParser handleCommonResult:result showFlag:NO]) {
        
        _needAutoScrollToBottom = YES;
        
        [self loadListData:TRIGGERED_BY_AUTOLOAD forNew:YES];
        
      } else {
        [WXWUIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSSendFeedFailedMsg, nil)
                                         msgType:ERROR_TY
                              belowNavigationBar:YES];
        
        [self resetLoadingStatus];
      }
      
      if (self.selectedPhoto == nil) {
        [_inputView resetTextContent];
        [self resetInputViewFrame];
      } else {
        self.selectedPhoto = nil;
      }
      
      break;
    }
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  if ([self connectionMessageIsEmpty:error]) {
    
    NSString *msg = nil;
    switch (contentType) {
      case CHART_LIST_TY:
      {
        msg = LocaleStringForKey(NSLoadFeedFailedMsg, nil);
        break;
      }
        
      case CHAT_SUBMIT_TY:
      {
        msg = LocaleStringForKey(NSSendFeedFailedMsg, nil);
        
        self.selectedPhoto = nil;
        break;
      }
        
      default:
        break;
    }
    
    self.connectionErrorMsg = msg;
  }
  
  [self resetLoadingStatus];
  
  // should be called at end of method to clear connFacade instance
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  Post *chatInfo = (Post *)[self.fetchedRC objectAtIndexPath:indexPath];
  if (indexPath.row == 0) {
    self.startChatId = STR_FORMAT(@"%@", chatInfo.postId);
  }
  
  if (indexPath.row == self.fetchedRC.fetchedObjects.count - 1) {
    self.endChatId = STR_FORMAT(@"%@", chatInfo.postId);
  }
  
  return [super tableView:tableView cellForRowAtIndexPath:indexPath];
  
}

@end
