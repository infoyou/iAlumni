//
//  GroupChatViewController.m
//  iAlumni
//
//  Created by Adam on 13-10-14.
//
//

#import "GroupChatViewController.h"
#import "Club.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "Post.h"
#import "WXWDebugLogOutput.h"
#import "ClubDetailViewController.h"
#import "ECTextView.h"
#import "ECAsyncConnectorFacade.h"
#import "AlumniProfileViewController.h"
#import "ECPhotoPickerOverlayViewController.h"
#import "ECImageBrowseViewController.h"
#import "WXWNavigationController.h"
#import "WXWLabel.h"

#define MAX_MSG_WIDTH       140.0f
#define MIN_BUBBLE_HEIGHT   70.0f

#define SECTION_VIEW_HEIGHT 30.0f

#define SPIN_SIDE_LEN       20.0f

#define MAX_INPUT_VIEW_HEIGHT   80.0f

#define INPUT_AREA_INIT_HEIGHT  50.0f

@interface GroupChatViewController ()
@property (nonatomic, retain) Club *group;
@end

@implementation GroupChatViewController

#pragma mark - user actions
- (void)openGroupDetail:(id)sender {
  
  [self closeKeyboard];
  
  [AppManager instance].clubName = [NSString stringWithFormat:@"%@", self.group.clubName];
  [AppManager instance].clubId = [NSString stringWithFormat:@"%@", self.group.clubId];
  [AppManager instance].clubType = [NSString stringWithFormat:@"%@", self.group.clubType];
  [AppManager instance].hostSupTypeValue = self.group.hostSupTypeValue;
  [AppManager instance].hostTypeValue = self.group.hostTypeValue;
  
  [AppManager instance].isNeedReLoadClubDetail = YES;
  CGRect mFrame = CGRectMake(0, 0, LIST_WIDTH, self.view.bounds.size.height);
  ClubDetailViewController *groupDetailVC = [[[ClubDetailViewController alloc] initWithFrame:mFrame MOC:_MOC parentListVC:nil] autorelease];
  
  groupDetailVC.title = LocaleStringForKey(NSClubDetailTitle, nil);
  
  [self.navigationController pushViewController:groupDetailVC animated:YES];
}

- (void)send {
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:SEND_POST_TY] autorelease];
  
  [connFacade sendPost:self.content
                tagIds:NULL_PARAM_VALUE
             placeName:NULL_PARAM_VALUE
                 photo:self.selectedPhoto
              postType:DISCUSS_POST_TY
               groupId:STR_FORMAT(@"%@", self.group.clubId)];
}

#pragma mark - load data
- (void)loadListData:(LoadTriggerType)triggerType forNew:(BOOL)forNew {
  
  _currentType = CLUB_POST_LIST_TY;
  
  NSMutableString *requestParam = [NSMutableString stringWithFormat:@"<page_size>%@</page_size><sort_type>%d</sort_type><post_type>%d</post_type><host_type>%@</host_type><host_id>%@</host_id><list_type>%d</list_type>",
                                   ITEM_LOAD_COUNT,
                                   SORT_BY_ID_TY,
                                   DISCUSS_POST_TY,
                                   self.group.clubType,
                                   self.group.clubId,
                                   SPECIAL_GROUP_LIST_POST_TY];
  _loadNew = forNew;
  
  if (forNew) {
    [requestParam appendString:@"<page>0</page>"];
  } else {
    [requestParam appendFormat:@"<page>%d</page>", ++_currentStartIndex];
  }
  
  NSString *url = [CommonUtils geneUrl:requestParam itemType:_currentType];
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade fetchGets:url];
}

- (void)configureMOCFetchConditions {
  
  self.predicate = [NSPredicate predicateWithFormat:@"(clubId == %@)", self.group.clubId];
  
  self.entityName = @"Post";
  self.descriptors = [NSMutableArray array];
  
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"postId" ascending:YES] autorelease];
  [self.descriptors addObject:descriptor];
}

#pragma mark - life cycle methods

- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(Club *)group
{
  self = [super initWithMOC:MOC needTakePhoto:YES];
  if (self) {
    self.group = group;
  }
  return self;
}

- (void)dealloc {
  
  self.group = nil;
  
  [super dealloc];
}


- (void)viewDidLoad
{
  [super viewDidLoad];
	 
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSClubDetailTitle, nil)
                            target:self
                            action:@selector(openGroupDetail:)];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}


#pragma mark - ECConnectorDelegate methoes
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case CLUB_POST_LIST_TY:
    {
      if (!_loadNew) {
       
        [self addSpinViewInView:_headerView text:LocaleStringForKey(NSLoadingTitle, nil)];
      } else {
        
        [self addSpinViewInView:_footerView text:LocaleStringForKey(NSLoadingTitle, nil)];
      }
      
      break;
    }
      
    case SEND_POST_TY:
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
      
    case CLUB_POST_LIST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
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
      
    case SEND_POST_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:nil
                     connectorDelegate:self
                                   url:url]) {
        
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
  
  NSString *msg = nil;
  
  if ([self connectionMessageIsEmpty:error]) {
    self.connectionErrorMsg = msg;
  } else {
    
    switch (contentType) {
      case CLUB_POST_LIST_TY:
      {
        msg = LocaleStringForKey(NSLoadFeedFailedMsg, nil);
        break;
      }
        
      case SEND_POST_TY:
      {
        msg = LocaleStringForKey(NSSendFeedFailedMsg, nil);
        
        self.selectedPhoto = nil;
        break;
      }
        
      default:
        break;
    }
  }
  
  [self resetLoadingStatus];
  
  // should be called at end of method to clear connFacade instance
  [super connectFailed:error url:url contentType:contentType];
}

@end
