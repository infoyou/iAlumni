//
//  MessageListViewController.m
//  iAlumni
//
//  Created by Adam on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MessageListViewController.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "MessageCell.h"
#import "CoreDataUtils.h"
#import "Messages.h"
#import "MessageButton.h"
#import "AppManager.h"
#import "XMLParser.h"
#import "WXWLabel.h"

#define LABEL_TAG     1000

@interface MessageListViewController()
@property (nonatomic, retain) NSArray *messageTypes;
@property (nonatomic, retain) UPOMP *cpView;
@property (nonatomic, retain) Messages *currentPayItem;
@end

@implementation MessageListViewController
@synthesize cpView;

- (void)clearPaymentDoneItems {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(paymentDone == YES)"];
  DELETE_OBJS_FROM_MOC(_MOC, @"Messages", predicate);
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction
     messageTypes:(NSArray *)messageTypes {
  
  self = [super initWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 tableStyle:UITableViewStyleGrouped
                 needGoHome:NO];
  
  if (self) {
    self.messageTypes = messageTypes;
    
    _noNeedDisplayEmptyMsg = YES;
    
    [self clearPaymentDoneItems];
  }
  
  return self;
}

- (void)setAllMessageBeQuickViewed {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(quickViewed == 0)"];
  NSArray *messages = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                                 entityName:@"Messages"
                                                  predicate:predicate];
  for (Messages *message in messages) {
    message.quickViewed = @YES;
    message.reviewed = @YES;
  }
  SAVE_MOC(_MOC);
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;

  if (CURRENT_OS_VERSION >= IOS7) {
    _tableView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT + SYS_STATUS_BAR_HEIGHT, self.view.frame.size.width, _tableView.frame.size.height - NAVIGATION_BAR_HEIGHT - SYS_STATUS_BAR_HEIGHT);
  }
  
  [self refreshTable];
  
  // set the flag, then the audio notification will not be executed again next time if user click it
  [AppManager instance].unreadMessageReceived = NO;
  
  [self setAllMessageBeQuickViewed];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)dealloc {
  
  self.messageTypes = nil;
  
  self.currentPayItem = nil;
  
  [super dealloc];
}

#pragma mark - user action

- (void)openWapForDetail:(Messages *)message {
  
  if (YES) {
    return;
  }
  
  NSString *url = [NSString stringWithFormat:@"%@user_id=%@&session=%@&plat=i&version=%@&lang=%@",
                   message.url,
                   [AppManager instance].userId,
                   [AppManager instance].sessionId,
                   VERSION,
                   [WXWSystemInfoManager instance].currentLanguageDesc];
  
  [CommonUtils openWebView:self.navigationController
                     title:nil
                       url:url
           needCloseButton:YES
            needNavigation:NO
      blockViewWhenLoading:YES
            needHomeButton:NO];
  
}

- (void)showAwardStatus:(id)sender {
  MessageButton *button = (MessageButton *)sender;
  [self openWapForDetail:button.message];
}

- (void)updateApp:(id)sender {
  
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_URL]];
  
  //  MessageButton *button = (MessageButton *)sender;
  //  button.message.reviewed = [NSNumber numberWithBool:YES];
  //  SAVE_MOC(_MOC);
}

- (void)reviewDetails:(id)sender {
  
  MessageButton *button = (MessageButton *)sender;
  [self openWapForDetail:button.message];
}

#pragma mark - open message url
- (void)openMessage:(Messages *)message {
  if (message.url && message.url.length > 0) {
    [CommonUtils openWebView:self.navigationController
                       title:nil
                         url:message.url
             needCloseButton:YES
              needNavigation:NO
              needHomeButton:NO];
    
  }
}

#pragma mark - override methods
- (void)configureMOCFetchConditions {
  self.entityName = @"Messages";
  
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO] autorelease];
  [self.descriptors addObject:descriptor];
  
  if (self.messageTypes.count > 0) {
    self.predicate = [NSPredicate predicateWithFormat:@"type == %@", self.messageTypes[0]];
    
    if (self.messageTypes.count > 1) {
      NSMutableArray *predicates = [NSMutableArray arrayWithObject:self.predicate];
      for (int i = 1; i < self.messageTypes.count; i++) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", self.messageTypes[i]];
        [predicates addObject:predicate];
      }
      
      self.predicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    }
  }
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.fetchedRC.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  Messages *message = (Messages *)[_fetchedRC objectAtIndexPath:indexPath];
  
  static NSString *cellIdentifier = @"messageCell";
  
  UITableViewCell *cell = [self configureCommonGroupedCell:cellIdentifier
                                                     title:nil
                                                badgeCount:0
                                                   content:message.content
                                                 indexPath:indexPath
                                                 clickable:YES
                                                dropShadow:YES
                                              cornerRadius:GROUPED_CELL_CORNER_RADIUS];
  
  WXWLabel *label = (WXWLabel *)[cell.contentView viewWithTag:LABEL_TAG];
  if (message.paymentDone.boolValue) {
    
    if (nil == label) {
      label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                     textColor:NAVIGATION_BAR_COLOR
                                   shadowColor:TEXT_SHADOW_COLOR] autorelease];
      label.text = LocaleStringForKey(NSPaymentDoneMsg, nil);
      label.font = BOLD_FONT(11);
      [cell.contentView addSubview:label];
    }
    
    label.hidden = NO;
    
    CGFloat height = [self calculateCommonCellHeightWithTitle:nil
                                                      content:message.content
                                                    indexPath:indexPath
                                                    clickable:YES];
    
    CGSize size = [label.text sizeWithFont:label.font];
    label.frame = CGRectMake(270 - size.width,
                             (height - size.height)/2.0f - 2.0f, size.width, size.height);
  } else {
    if (label) {
      label.hidden = YES;
    }
  }

  return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Messages *message = (Messages *)[_fetchedRC objectAtIndexPath:indexPath];
  
  return [self calculateCommonCellHeightWithTitle:nil
                                          content:message.content
                                        indexPath:indexPath
                                        clickable:YES];
  
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  Messages *message = (Messages *)[_fetchedRC objectAtIndexPath:indexPath];
  
  if (message.type.intValue != SYSTEM_MSG_TY) {
    
    self.currentPayItem = message;
    
    if (message.paymentDone.boolValue) {
      return;
    } else {

      [self triggerOnlinePayment:message.messageId];
    }
  
  } else {
    self.currentPayItem = nil;
    
    [self openMessage:message];
  }
}
*/

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
  [UIUtils showActivityView:self.view
                       text:LocaleStringForKey(NSLoadingTitle, nil)];
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result
                url:(NSString *)url
        contentType:(NSInteger)contentType
{
  [UIUtils closeActivityView];
  switch (contentType) {
    case PAY_DATA_TY:
    {
      [self goPay:result];
      break;
    }
      
    default:
      break;
  }
  [super connectDone:result url:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType
{
  [UIUtils closeActivityView];
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case PAY_DATA_TY:
    {
      [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaymentErrorMsg, nil)
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      break;
    }
      
    default:
      break;
  }
  
  [UIUtils closeActivityView];
  
  [super connectFailed:error
                   url:url
           contentType:contentType];
}

#pragma mark - pay
- (void)triggerOnlinePayment:(NSString *)orderId {
  
  if (nil == orderId || 0 == orderId.length) {
    return;
  }
    
    _currentType = PAY_DATA_TY;
    
  NSString *param = [NSString stringWithFormat:@"<order_id>%@</order_id>", orderId];
  NSString *url = [CommonUtils geneUrl:param itemType:_currentType];
  
  ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                  interactionContentType:_currentType] autorelease];
  [connFacade fetchGets:url];
}

- (void)goPay:(NSData *)result {
  cpView = [[UPOMP alloc] init];
  cpView.viewDelegate = self;
  [((iAlumniAppDelegate*)APP_DELEGATE).window addSubview:cpView.view];
  
  [cpView setXmlData:result];
  
  NSLog(@"message: %@", [[[NSString alloc] initWithData:result
                                               encoding:NSUTF8StringEncoding] autorelease]);
}

#pragma mark - handle payment result
- (void)refreshListForPaymentDone {
  self.currentPayItem.paymentDone = @(YES);
  
  SAVE_MOC(_MOC);
  
  [_tableView reloadData];
  
  switch (self.currentPayItem.type.intValue) {
    case EVENT_PAYMENT_MSG_TY:
      [AppManager instance].eventPaymentItemCount -= 1;
      break;
      
    case GROUP_PAYMENT_MSG_TY:
      [AppManager instance].groupPaymentItemCount -= 1;
      break;
      
    default:
      break;
  }
}

- (BOOL)checkPaymentRecallResult:(NSString *)result {
  if (nil == result || 0 == result.length) {
    return NO;
  }
  
  NSArray *list = [result componentsSeparatedByString:PAYMENT_RESPCODE_START_SEPARATOR];
  if (list.count == 2) {
    NSString *partResult = list[1];
    if (0 == partResult.length) {
      return NO;
    }
    
    NSArray *resultList = [partResult componentsSeparatedByString:PAYMENT_RESPCODE_END_SEPARATOR];
    if (resultList.count == 2) {
      NSString *codeStr = resultList[0];
      if (0 == codeStr.length) {
        return NO;
      }
      
      NSInteger code = codeStr.intValue;
      
      if (code != 0) {
        return NO;
      } else {
        
        return YES;
      }
    }
  }
  
  return NO;
}

#pragma mark - UPOMPDelegate method
-(void)viewClose:(NSData*)data {
  
  //获得返回数据并释放内存
  //以下为自定义相关操作
  
  cpView.viewDelegate = nil;
  RELEASE_OBJ(cpView);
  
  NSString *resultStr = [[[NSString alloc] initWithData:data
                                               encoding:NSUTF8StringEncoding] autorelease];
  NSLog(@"resultStr = %@", resultStr);
  
  if ([self checkPaymentRecallResult:resultStr]) {
    
    // refresh payment successful flag
    [self refreshListForPaymentDone];
    
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaymentDoneMsg, nil)
                                  msgType:SUCCESS_TY
                       belowNavigationBar:YES];
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSPaymentErrorMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
  
}

@end
