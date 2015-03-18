//
//  UserProfileViewController.m
//  iAlumni
//
//  Created by Adam on 12-9-24.
//
//

#import "UserProfileViewController.h"
#import "UserProfileHeaderView.h"
#import "UserListViewController.h"
#import "UIWebViewController.h"
#import "XMLParser.h"
#import "AlumniListViewController.h"
#import "WithTitleImageCell.h"
#import "NameCardSearchViewController.h"
#import "AttractiveAlumniListViewController.h"
#import "KnownAlumniListViewController.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "AppManager.h"
#import "UIUtils.h"
#import "LanguageListViewController.h"
#import "FeedbackViewController.h"
#import "WXWLabel.h"
#import "WechatIntroViewController.h"


#define SECTION_GAP       30.0f

#define FOOTER_HEIGHT     100.0f

enum {
  COOP_LANG_SEC,
    WECHAT_SEC,
};

enum {
  WECHAT_SEC_PUBLIC_CELL,
};

enum {
  COOP_LANG_SEC_LANG_CELL,
  COOP_LANG_SEC_COOP_CELL,
};

enum {
  LOGOFF_SEC_CELL,
};

enum {
  WECHAT_INSTALL_NOTE_TY,
  LOGOFF_TY,
};

#define WECHAT_SEC_COUNT          1

#define COOP_LANG_SEC_COUNT       2
#define INFO_SEC_COUNT            4
#define LOGOFF_SEC_COUNT          1
#define SECTION_COUNT             1

#define DEFAULT_HEIGHT  44.0f

@interface UserProfileViewController ()
@property (nonatomic, retain) id<ECItemUploaderDelegate> delegate;
@end

@implementation UserProfileViewController

#pragma mark - user action
- (void)refreshForLanguageSwitch {
  if (_personalEntrance && _refreshAction) {
    [_personalEntrance performSelector:_refreshAction];
  }
  
  self.navigationItem.title = LocaleStringForKey(NSSettingsTitle, nil);
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(UIViewController *)parentVC
 personalEntrance:(id)personalEntrance
    refreshAction:(SEL)refreshAction {
  
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                                          holder:nil
                                backToHomeAction:nil
                           needRefreshHeaderView:NO
                           needRefreshFooterView:NO
                                      tableStyle:UITableViewStyleGrouped
                                      needGoHome:NO];
  
  if (self) {
    self.parentVC = parentVC;
    
    _personalEntrance = personalEntrance;
    _refreshAction = refreshAction;
  }
  
  return self;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
         parentVC:(UIViewController *)parentVC {
    
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                                          holder:nil
                                backToHomeAction:nil
                           needRefreshHeaderView:NO
                           needRefreshFooterView:NO
                                      tableStyle:UITableViewStyleGrouped
                                      needGoHome:NO];
  if (self) {
    _viewHeight = viewHeight;
    
    self.parentVC = parentVC;
    
    _noNeedBackButton = YES;
    
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = CELL_COLOR;
  
  if (CURRENT_OS_VERSION >= IOS7) {
    _tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
  } else {
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  }
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [_tableView reloadData];
  
  self.lastSelectedIndexPath = nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  return NO;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case WECHAT_SEC:
      return WECHAT_SEC_COUNT;
      
    case COOP_LANG_SEC:
      return COOP_LANG_SEC_COUNT;
      
    default:
      return 0;
  }
}

- (UITableViewCell *)drawWechatSectionCell:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"wechatCell";
  
  return [self configureWithTitleImageCell:cellIdentifier
                                     title:LocaleStringForKey(NSFollowWechatPublicNoTitle, nil)
                                badgeCount:0
                                   content:nil
                                     image:[UIImage imageNamed:@"wechat.png"]
                                 indexPath:indexPath
                                 clickable:YES
                                dropShadow:YES
                              cornerRadius:GROUPED_CELL_CORNER_RADIUS];
  
}

- (UITableViewCell *)drawLanguageSectionCell:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"languageCell";
  
  return [self configureWithTitleImageCell:cellIdentifier
                                     title:LocaleStringForKey(NSCurrentSystemLanguageTitle, nil)
                                badgeCount:0
                                   content:nil
                                     image:[UIImage imageNamed:@"language.png"]
                                 indexPath:indexPath
                                 clickable:YES
                                dropShadow:YES
                              cornerRadius:GROUPED_CELL_CORNER_RADIUS];
  
}

- (UITableViewCell *)drawShareSectionCell:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"shareCell";
  
  return [self configureWithTitleImageCell:cellIdentifier
                                     title:LocaleStringForKey(NSShareSoftTitle, nil)
                                badgeCount:0
                                   content:nil
                                     image:[UIImage imageNamed:@"shareTo.png"]
                                 indexPath:indexPath
                                 clickable:YES
                                dropShadow:YES
                              cornerRadius:GROUPED_CELL_CORNER_RADIUS];
  
}


- (UITableViewCell *)drawNameCardSection:(NSIndexPath *)indexPath {
  
  static NSString *cellIdentifier = @"nameCardHeaderCell";
  
  return [self configureWithTitleImageCell:cellIdentifier
                                     title:LocaleStringForKey(NSFeedbackTitle, nil)
                                badgeCount:0
                                   content:nil
                                     image:[UIImage imageNamed:@"dm.png"]
                                 indexPath:indexPath
                                 clickable:YES
                                dropShadow:YES
                              cornerRadius:GROUPED_CELL_CORNER_RADIUS];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case WECHAT_SEC:
    {
      switch (indexPath.row) {
        case WECHAT_SEC_PUBLIC_CELL:
          return [self drawWechatSectionCell:indexPath];
          
        default:
          return nil;
      }
    }
      
    case COOP_LANG_SEC:
      switch (indexPath.row) {
        case COOP_LANG_SEC_LANG_CELL:
          return [self drawLanguageSectionCell:indexPath];
          
        case COOP_LANG_SEC_COOP_CELL:
          return [self drawNameCardSection:indexPath];
          
        default:
          return nil;
      }
      
    default:
      return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
    case WECHAT_SEC:
    {
      switch (indexPath.row) {
        case WECHAT_SEC_PUBLIC_CELL:
          return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSFollowWechatPublicNoTitle, nil)
                                                  content:nil
                                                indexPath:indexPath
                                                clickable:YES];
          
        default:
          return 0;
      }
      
    }
      
    case COOP_LANG_SEC:
    {
      switch (indexPath.row) {
          
        case COOP_LANG_SEC_COOP_CELL:
          return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSFeedbackTitle, nil)
                                                  content:nil
                                                indexPath:indexPath
                                                clickable:YES];
        case COOP_LANG_SEC_LANG_CELL:
          return [self calculateCommonCellHeightWithTitle:LocaleStringForKey(NSCurrentSystemLanguageTitle, nil)
                                                  content:nil
                                                indexPath:indexPath
                                                clickable:YES];
        default:
          return 0;
      }
    }
      
    default:
      return 0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  switch (section) {
    case COOP_LANG_SEC:
      return FOOTER_HEIGHT;
      
    default:
      return 0.0f;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  switch (section) {
    case COOP_LANG_SEC:
    {
      if (nil == _footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FOOTER_HEIGHT)];
        _footerView.backgroundColor = TRANSPARENT_COLOR;
        
        _signOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _signOutButton.backgroundColor = NAVIGATION_BAR_COLOR;
        _signOutButton.titleLabel.font = BOLD_FONT(15);
        [_signOutButton setTitle:LocaleStringForKey(NSLogoutTitle, nil) forState:UIControlStateNormal];
        [_signOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _signOutButton.frame = CGRectMake((self.view.frame.size.width - 300)/2.0f, MARGIN * 6, 300, 40);
        [_signOutButton addTarget:self
                          action:@selector(selectLogoff:)
                forControlEvents:UIControlEventTouchUpInside];
          
      if (IS_NEED_3RD_LOGIN != 1) {
            [_footerView addSubview:_signOutButton];
        }
        
        WXWLabel *versionLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                        textColor:BASE_INFO_COLOR
                                                      shadowColor:[UIColor whiteColor]] autorelease];
        versionLabel.font = BOLD_FONT(12);
        versionLabel.text = [NSString stringWithFormat:@"Version %@",VERSION];
        [_footerView addSubview:versionLabel];
        CGSize size = [versionLabel.text sizeWithFont:versionLabel.font
                             constrainedToSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        
        versionLabel.frame = CGRectMake((self.view.frame.size.width - size.width)/2.0f,
                                        _signOutButton.frame.origin.y + _signOutButton.frame.size.height + MARGIN * 4, size.width, size.height);
        
        WXWLabel *infoLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                     textColor:BASE_INFO_COLOR
                                                   shadowColor:[UIColor whiteColor]] autorelease];
        infoLabel.font = BOLD_FONT(12);
        infoLabel.text = [NSString stringWithFormat:@"Copyright © 2013 Weixun Inc. All rights reserved."];
        [_footerView addSubview:infoLabel];
        size = [infoLabel.text sizeWithFont:infoLabel.font
                                 constrainedToSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
        infoLabel.frame = CGRectMake((self.view.frame.size.width - size.width) / 2.0f,
                                     versionLabel.frame.origin.y + versionLabel.frame.size.height + MARGIN,
                                     size.width, size.height);

        
      }
      
      [_signOutButton setTitle:LocaleStringForKey(NSLogoutTitle, nil) forState:UIControlStateNormal];
      
      return _footerView;
      
    }
      
    default:
      return nil;
  }
}

- (void)switchLanguage {
  
  LanguageListViewController *mHomeVC = [[[LanguageListViewController alloc] initWithParentVC:self.parentVC
                                                                                     entrance:self
                                                                                refreshAction:@selector(refreshForLanguageSwitch)] autorelease];
  
  UINavigationController *mNC = [[[UINavigationController alloc] initWithRootViewController:mHomeVC] autorelease];
  mNC.navigationBar.tintColor = TITLESTYLE_COLOR;
  
  [self.navigationController presentModalViewController:mNC animated:YES];
  
}

- (void)selectFeedback:(NSIndexPath *)indexPath {
  FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] init:_MOC];
  
  [self.navigationController pushViewController:feedbackVC animated:YES];
  
  feedbackVC.title = LocaleStringForKey(NSFeedbackTitle,nil);
  RELEASE_OBJ(feedbackVC);
}

- (void)selectLogoff:(id)sender {
  if ([@"-1" isEqualToString:[AppManager instance].personId]) {
    [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:NO];
  } else {
    ShowAlertWithTwoButton(self, LocaleStringForKey(NSNoteTitle, nil), LocaleStringForKey(NSLogoutMsgTitle, nil), LocaleStringForKey(NSCancelTitle, nil), LocaleStringForKey(NSSureTitle, nil));
    
    _alertType = LOGOFF_TY;
  }
}

- (void)followOnWechat {
  /*
  if ([WXApi isWXAppInstalled]) {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WECHAT_PUBLIC_NO_URL]];
    
  } else {
    
    _alertType = WECHAT_INSTALL_NOTE_TY;
    
    ShowAlertWithTwoButton(self, nil, LocaleStringForKey(NSNoWeChatMsg, nil), LocaleStringForKey(NSDonotInstallTitle, nil),LocaleStringForKey(NSInstallTitle, nil));
  }
   */
  
  WechatIntroViewController *wechatIntroVC = [[[WechatIntroViewController alloc] init] autorelease];
  wechatIntroVC.title = LocaleStringForKey(NSFollowWechatPublicNoTitle, nil);
  [self.navigationController pushViewController:wechatIntroVC animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (indexPath.section) {
    case WECHAT_SEC:
      switch (indexPath.row) {
        case WECHAT_SEC_PUBLIC_CELL:
          [self followOnWechat];
          break;
                
        default:
          break;
      }
      break;
      
    case COOP_LANG_SEC:
      switch (indexPath.row) {
        case COOP_LANG_SEC_LANG_CELL:
          [self switchLanguage];
          break;
          
        case COOP_LANG_SEC_COOP_CELL:
          [self selectFeedback:indexPath];
          break;
          
        default:
          break;
      }
      break;
      
    default:
      break;
  }
}

#pragma mark - ECConnectorDelegate methods

- (void)connectStarted:(NSString *)url contentType:(NSInteger)contentType {
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
  [super connectCancelled:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  
  switch (contentType) {
    case SIGN_OUT_TY:
    {
      [XMLParser parserResponseXml:result
                              type:contentType
                               MOC:_MOC
                 connectorDelegate:self
                               url:url];
      
      [[AppManager instance] initParam];
      [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:NO];

      break;
    }
      
    default:
      break;
  }
  

  [super connectDone:result url:url contentType:contentType];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
  [[AppManager instance] initParam];
  [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:NO];
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - ECItemUploaderDelegate method
- (void)afterUploadFinishAction:(WebItemType)actionType {
  
}

#pragma mark - sign out
- (void)signOut {
  _currentType = SIGN_OUT_TY;
  
  NSString *url = [CommonUtils geneUrl:NULL_PARAM_VALUE itemType:_currentType];
  
  WXWAsyncConnectorFacade *connFacade = [self setupAsyncConnectorForUrl:url
                                                            contentType:_currentType];
  [connFacade asyncGet:url showAlertMsg:NO];
}

#pragma mark - alert delegate method
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  switch (_alertType) {
    case LOGOFF_TY:
      if (buttonIndex == 1) {
        [self signOut];
        
//         [[AppManager instance] initParam];
//        [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:NO];
      }
      break;
      
    case WECHAT_INSTALL_NOTE_TY:
    {
      
      switch (buttonIndex) {
        case 1:
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WECHAT_ITUNES_URL]];
          break;
        default:
          break;
      }
      break;
    }
    default:
      break;
  }
}


@end
