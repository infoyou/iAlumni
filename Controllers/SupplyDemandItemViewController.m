//
//  SupplyDemandItemViewController.m
//  iAlumni
//
//  Created by Adam on 13-6-4.
//
//

#import "SupplyDemandItemViewController.h"
#import "Post.h"
#import "AuthorCell.h"
#import "AlumniProfileViewController.h"
#import "SupplyDemandItemCell.h"
#import "TagSearchResultViewController.h"
#import "ECImageBrowseViewController.h"
#import "WXWNavigationController.h"
#import "SupplyDemandItemToolbar.h"
#import "CommonUtils.h"
#import "XMLParser.h"
#import "UIUtils.h"
#import "EncryptUtil.h"
#import "AppManager.h"
#import "Alumni.h"
#import "WXWCoreDataUtils.h"
#import "ChatListViewController.h"
#import "UIWebViewController.h"
#import "Tag.h"
#import "DMChatViewController.h"

enum {
  AUTHOR_CELL,
  CONTENT_CELL,
};

#define CELL_COUNT    2

#define AUTHOR_CELL_HEIGHT      71.0f

#define FLAG_SIDE_LEN   42.0f

#define TAG_LIST_HEIGHT 40.0f

@interface SupplyDemandItemViewController ()
@property (nonatomic, retain) Post *item;
@property (nonatomic, retain) UIImage *postImage;
@end

@implementation SupplyDemandItemViewController

#pragma mark - user actions
- (void)favoriteItem:(id)sender {
  
  if (_target && _triggerRefreshAction) {
    [_target performSelector:_triggerRefreshAction];
  }

   if ([self.item.favorited intValue] != 1) {
   _currentType = POST_FAVORITE_ACTION_TY;
   }else {
   _currentType = POST_UNFAVORITE_ACTION_TY;
   }
   
   NSString *param = [NSString stringWithFormat:@"<post_id>%@</post_id>", self.item.postId];
   NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
   
   WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                             contentType:_currentType];
   [connFacade fetchGets:url];
}

- (void)openChatListForAlumni:(Alumni *)alumni {
  
  DMChatViewController *chatVC = [[[DMChatViewController alloc] initWithMOC:_MOC
                                                                     alumni:alumni] autorelease];
  [self.navigationController pushViewController:chatVC animated:YES];

  /*
  DELETE_OBJS_FROM_MOC(_MOC, @"Chat", nil);
  
  ChatListViewController *chartVC = [[[ChatListViewController alloc] initWithMOC:_MOC alumni:alumni] autorelease];
  [self.navigationController pushViewController:chartVC animated:YES];
   */
}

- (void)sendDM:(id)sender {
  
  if ([[AppManager instance].personId isEqualToString:self.item.authorId]) {
    return;
  }
  
  _currentType = ALUMNI_QUERY_DETAIL_TY;
  
  NSString *url = [NSString stringWithFormat:@"%@%@&personId=%@&username=%@&sessionId=%@&userType=%d&active_personId=%@", [AppManager instance].hostUrl, ALUMNI_DETAIL_URL, self.item.authorId, [AppManager instance].userId, [AppManager instance].sessionId, ALUMNI_USER_TY, [AppManager instance].personId];

  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade fetchGets:url];
}

- (void)shareItem:(id)sender {
  if ([WXApi isWXAppInstalled]) {
    ((iAlumniAppDelegate*)APP_DELEGATE).wxApiDelegate = self;
    
    NSString *url = [NSString stringWithFormat:CONFIGURABLE_DOWNLOAD_URL,
                     [AppManager instance].hostUrl,
                     [WXWSystemInfoManager instance].currentLanguageDesc,
                     [AppManager instance].releaseChannelType];
    [CommonUtils sharePostByWeChat:self.item
                             scene:WXSceneSession
                               url:url
                             image:self.postImage];
  } else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:LocaleStringForKey(NSNoWeChatMsg, nil)
                                                   delegate:self
                                          cancelButtonTitle:LocaleStringForKey(NSDonotInstallTitle, nil)
                                          otherButtonTitles:LocaleStringForKey(NSInstallTitle, nil), nil];
    [alert show];
    [alert release];
  }

}

- (void)deleteItem:(id)sender {
  UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSDeleteFeedWarningMsg, nil)
                                                  delegate:self
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
  [as addButtonWithTitle:LocaleStringForKey(NSDeleteActionTitle, nil)];
  as.destructiveButtonIndex = [as numberOfButtons] - 1;
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.view];
  RELEASE_OBJ(as);
}

#pragma mark - lifecycle methods

- (id)initMOC:(NSManagedObjectContext *)MOC
         item:(Post *)item
       target:(id)target
triggerRrefreshAction:(SEL)triggerRrefreshAction
{
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 needGoHome:NO];
  
  if (self) {
    self.item = item;
    
    _noNeedDisplayEmptyMsg = YES;
    
    _target = target;
    _triggerRefreshAction = triggerRrefreshAction;
  }
  return self;
}

- (void)dealloc {
  
  self.item = nil;
  self.postImage = nil;
  
  [super dealloc];
}

- (void)addToolbar {
  
  BOOL itemSentByMe = [AppManager instance].personId.intValue == self.item.authorId.intValue ? YES : NO;
  
  CGFloat y = self.view.frame.size.height - TOOLBAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
  if (CURRENT_OS_VERSION >= IOS7) {
    y -= SYS_STATUS_BAR_HEIGHT;
  }
  
  _toolbar = [[[SupplyDemandItemToolbar alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, TOOLBAR_HEIGHT)
                                                        item:self.item
                                                selfSentItem:itemSentByMe
                                                      target:self
                                                   favAction:@selector(favoriteItem:)
                                                    dmAction:@selector(sendDM:)
                                                 shareAction:@selector(shareItem:)
                                                deleteAction:@selector(deleteItem:)] autorelease];
  [self.view addSubview:_toolbar];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self addToolbar];
  
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  CGRect frame = _tableView.frame;
  frame.size = CGSizeMake(frame.size.width, frame.size.height - TOOLBAR_HEIGHT);
  _tableView.frame = frame;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (!_autoLoaded) {
    [_tableView reloadData];
    
    _autoLoaded = YES;
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  
  return CELL_COUNT;
}


- (UITableViewCell *)drawAuthorCell {
  static NSString *kCellIdentifier = @"authorCell";
  
  AuthorCell *cell = (AuthorCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[AuthorCell alloc] initWithStyle:UITableViewCellStyleDefault
                              reuseIdentifier:kCellIdentifier] autorelease];
  }
  
  [cell drawCellWithImageUrl:self.item.authorPicUrl
                  authorName:self.item.authorName];
  
  return cell;
}

- (UITableViewCell *)drawContentCell {

  static NSString *kCellIdentifier = @"contentCell";
  SupplyDemandItemCell *cell = (SupplyDemandItemCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
  if (nil == cell) {
    cell = [[[SupplyDemandItemCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:kCellIdentifier
                                   coreTextViewDelegate:self
                                   tagSelectionDelegate:self
                                 imageDisplayerDelegate:self
                                 imageClickableDelegate:self
                                                    MOC:_MOC] autorelease];
  }
  
  [cell drawCellWithItem:self.item];
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.row) {
    case AUTHOR_CELL:
      
      return [self drawAuthorCell];
      
    case CONTENT_CELL:
      
      return [self drawContentCell];
      
    default:
      return nil;
  }
}

- (void)selectAuthorCell {
  AlumniProfileViewController *profileVC = [[[AlumniProfileViewController alloc] initWithMOC:_MOC
                                                                                    personId:self.item.authorId
                                                                                    userType:ALUMNI_USER_TY] autorelease];
  profileVC.title = LocaleStringForKey(NSAlumniDetailTitle, nil);
  [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (indexPath.row) {
    case AUTHOR_CELL:
      [self selectAuthorCell];
      break;
      
    default:
      break;
  }
}

- (CGFloat)contentHeight {
  
  CGFloat textLimitedWidth = self.view.frame.size.width - (MARGIN * 2 + FLAG_SIDE_LEN + MARGIN * 2 + MARGIN * 2);
  
  CGFloat height = MARGIN * 2;
  height += [JSCoreTextView measureFrameHeightForText:self.item.content
                                             fontName:SYS_FONT_NAME
                                             fontSize:15.0f
                                   constrainedToWidth:textLimitedWidth
                                           paddingTop:0
                                          paddingLeft:0];
  
  height += MARGIN * 2;
  
  height += TAG_LIST_HEIGHT;
  
  height += MARGIN * 2;
  
  if (self.item.imageAttached) {
    height += textLimitedWidth;
    
    height += MARGIN * 2;
  }
  
  height += 20.0f;
  
  height += MARGIN * 2;
  
  return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case AUTHOR_CELL:      
      return AUTHOR_CELL_HEIGHT;
      
    case CONTENT_CELL:
      return [self contentHeight];
      
    default:
      return 0;
  }
  
}

#pragma mark - TagSelectionDelegate methods
- (void)selectTagWithName:(Tag *)tag {
  TagSearchResultViewController *tagSearchResultVC = [[[TagSearchResultViewController alloc] initWithMOC:_MOC tagId:tag.tagId] autorelease];
  tagSearchResultVC.title = STR_FORMAT(LocaleStringForKey(NSSearchTagTitle, nil), tag.tagName);
  [self.navigationController pushViewController:tagSearchResultVC animated:YES];

}

#pragma mark - ECClickableElementDelegate methods
- (void)openImageUrl:(NSString *)imageUrl {
  if (imageUrl && [imageUrl length] > 0) {
    ECImageBrowseViewController *imgBrowseVC = [[[ECImageBrowseViewController alloc] initWithImageUrl:imageUrl] autorelease];
    WXWNavigationController *imgBrowseNav = [[[WXWNavigationController alloc] initWithRootViewController:imgBrowseVC] autorelease];
    imgBrowseVC.title = LocaleStringForKey(NSBigPicTitle, nil);
    [self.navigationController presentModalViewController:imgBrowseNav animated:YES];    
  }

}

#pragma mark - ECConnectorDelegate methoes
- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  if (contentType != POST_FAVORITE_ACTION_TY &&
      contentType != POST_UNFAVORITE_ACTION_TY) {
    
    [self showAsyncLoadingView:LocaleStringForKey(NSLoadingTitle, nil)
              blockCurrentView:YES];

  }
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
      
    case POST_FAVORITE_ACTION_TY:
    case POST_UNFAVORITE_ACTION_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        
        self.item.favorited = @(!self.item.favorited.boolValue);
        
        [_toolbar updateFavButtonWithStatus:self.item.favorited.boolValue];
        
      } else {
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSActionFaildMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      break;
    }
      
    case ALUMNI_QUERY_DETAIL_TY:
    {
      NSData *decryptedData = [EncryptUtil TripleDESforNSData:result encryptOrDecrypt:kCCDecrypt];
      if ([XMLParser parserResponseXml:decryptedData
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(personId == %@)", self.item.authorId];
        Alumni *alumni = (Alumni *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                             entityName:@"Alumni"
                                                              predicate:predicate];
        [self openChatListForAlumni:alumni];
      }
      break;
    }
      
    case DELETE_FEED_TY:
    {
      [UIUtils closeActivityView];
      if ([XMLParser parserResponseXml:result
                                  type:DELETE_FEED_TY
                                   MOC:nil
                     connectorDelegate:self
                                   url:url]) {
        
        NSString *name = @"Post";

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(postId == %@)", self.item.postId];
        DELETE_OBJS_FROM_MOC(_MOC, name, predicate);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FEED_DELETED_NOTIFY
                                                            object:nil
                                                          userInfo:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSDeleteFeedDoneMsg, nil)
                                      msgType:SUCCESS_TY
                           belowNavigationBar:YES];
      } else {
        [UIUtils showNotificationOnTopWithMsg:(self.errorMsgDic)[url]
                               alternativeMsg:LocaleStringForKey(NSDeleteFeedFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
      
      break;
    }
      
    default:
      break;
  }
  
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url contentType:(NSInteger)contentType {
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
      
    case LOAD_SUPPLY_DEMAND_ITEM_TY:
    {
      
      if ([self connectionMessageIsEmpty:error]) {
        self.connectionErrorMsg = LocaleStringForKey(NSLoadFeedFailedMsg, nil);
      }
      
    }
      break;
      
    default:
      break;
  }
  
  [super connectFailed:error url:url contentType:contentType];
}


#pragma mark - WXApiDelegate methods
-(void) onResp:(BaseResp*)resp
{
  if([resp isKindOfClass:[SendMessageToWXResp class]]) {
    switch (resp.errCode) {
      case WECHAT_OK_CODE:
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatDoneMsg, nil)
                                      msgType:SUCCESS_TY
                           belowNavigationBar:YES];
        break;
        
      case WECHAT_BACK_CODE:
        break;
        
      default:
        [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSAppShareByWeChatFailedMsg, nil)
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
        break;
    }
  }
  
  ((iAlumniAppDelegate*)APP_DELEGATE).wxApiDelegate = nil;
}

#pragma mark - WXWImageDisplayerDelegate methods
- (void)saveDisplayedImage:(UIImage *)image {
  self.postImage = image;
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex {

  if (as.cancelButtonIndex == buttonIndex) {
    return;
  } else if (as.destructiveButtonIndex == buttonIndex) {
    
    _currentType = DELETE_FEED_TY;
    
    
    NSString *param = [NSString stringWithFormat:@"<post_id>%@</post_id>", LLINT_TO_STRING(self.item.postId.longLongValue)];
    
    NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
    
    WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                              contentType:_currentType];
    [connFacade asyncGet:url
            showAlertMsg:YES];
  }
}

#pragma mark - JSCoreTextViewDelegate methods
- (void)textView:(JSCoreTextView *)textView linkTapped:(AHMarkedHyperlink *)link {
  
  UIWebViewController *webVC = [[UIWebViewController alloc] initWithNeedAdjustForiOS7:YES];
  UINavigationController *webViewNav = [[UINavigationController alloc] initWithRootViewController:webVC];
  webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
  webVC.strUrl = link.URL.absoluteString;
  webVC.strTitle = NULL_PARAM_VALUE;
  
  [self.parentViewController presentModalViewController:webViewNav
                                               animated:YES];
  RELEASE_OBJ(webVC);
  RELEASE_OBJ(webViewNav);

}

@end
