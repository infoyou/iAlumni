//
//  AppSettingViewController.m
//  iAlumni
//
//  Created by Adam on 12-9-29.
//
//

#import "AppSettingViewController.h"
#import "VerticalLayoutItemInfoCell.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "FeedbackViewController.h"
#import "LanguageListViewController.h"
#import "WXWLabel.h"
#import "ConfigurableTextCell.h"
#import "AppManager.h"

enum {
  LANG_SEC,
  COOP_SEC,
  LOGOFF_SEC,
};

enum {
  LANG_SEC_CELL,
};

enum {
  COOP_SEC_CELL,
};

enum {
  LOGOFF_SEC_CELL,
};

enum {
  LOGOFF_TY,
};

#define SECTION_COUNT       3

#define LANG_SEC_COUNT      1
#define COOP_SEC_COUNT      1
#define LOGOFF_SEC_COUNT    1

#define DEFAULT_CELL_HEIGHT 44.0f

#define FOOTER_HEIGHT       230.0f

#define BUFFER_SIZE         1024 * 100

@interface AppSettingViewController ()

@end

@implementation AppSettingViewController

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction {
  
  self = [super initWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 tableStyle:UITableViewStyleGrouped
                 needGoHome:NO];
  
  if (self) {
    
  }
  
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

  [self checkListWhetherEmpty];
}

- (void)viewDidUnload {
  [super viewDidUnload];
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
    case LANG_SEC:
      return LANG_SEC_COUNT;
      
    case COOP_SEC:
      return COOP_SEC_COUNT;
      
    case LOGOFF_SEC:
      return LOGOFF_SEC_COUNT;
      
    default:
      return 0;
  }
}

- (UITableViewCell *)drawLangSectionCell:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case LANG_SEC_CELL:
    {
      static NSString *kCellIdentifier = @"langCell";
      /*
      ConfigurableTextCell *cell = (ConfigurableTextCell *)[_tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
      if (nil == cell) {
        cell = [[[ConfigurableTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier] autorelease];
        cell.dropsShadow = YES;
        cell.cornerRadius = 4.0f;
      }
      
      [cell prepareForTableView:_tableView indexPath:indexPath];
      
      [cell drawCommonCellWithTitle:LocaleStringForKey(NSCurrentSystemLanguageTitle, nil)
                     subTitle:nil
                      content:nil
         contentLineBreakMode:NSLineBreakByWordWrapping
     contentConstrainedHeight:DEFAULT_CELL_HEIGHT
                    clickable:YES];
      
      return cell;
      */
      
      return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSCurrentSystemLanguageTitle,nil)
                                     subTitle:nil
                                      content:nil
                               cellIdentifier:kCellIdentifier
                                       height:DEFAULT_CELL_HEIGHT
                                    clickable:YES];
    }
      
    default:
      return nil;
  }
}

- (UITableViewCell *)drawCoopSectionCell:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case COOP_SEC_CELL:
    {
      static NSString *kCellIdentifier = @"coopCell";
      return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSFeedbackTitle,nil)
                                     subTitle:nil
                                      content:nil
                               cellIdentifier:kCellIdentifier
                                       height:DEFAULT_CELL_HEIGHT
                                    clickable:YES];
    }
      
    default:
      return nil;
  }
}

- (UITableViewCell *)drawLogoffSectionCell:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case LOGOFF_SEC_CELL:
    {
      static NSString *kCellIdentifier = @"logoffCell";
      return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSLogoutTitle,nil)
                                     subTitle:nil
                                      content:nil
                               cellIdentifier:kCellIdentifier
                                       height:DEFAULT_CELL_HEIGHT
                                    clickable:YES];
    }
      
    default:
      return nil;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  switch (indexPath.section) {
    case LANG_SEC:
      return [self drawLangSectionCell:indexPath];
      
    case COOP_SEC:
      return [self drawCoopSectionCell:indexPath];
      
    case LOGOFF_SEC:
      return [self drawLogoffSectionCell:indexPath];
      
    default:
      return nil;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  switch (indexPath.section) {
    case LANG_SEC:
    {
      LanguageListViewController *mHomeVC = [[LanguageListViewController alloc] init];
      
      UINavigationController *mNC = [[UINavigationController alloc] initWithRootViewController:mHomeVC];
      mNC.navigationBar.tintColor = TITLESTYLE_COLOR;
      [self presentModalViewController:mNC animated:YES];
      RELEASE_OBJ(mHomeVC);
      RELEASE_OBJ(mNC);
      
      break;
    }
      
    case COOP_SEC:
    {
      FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] init:_MOC];
      [self.navigationController pushViewController:feedbackVC animated:YES];
      feedbackVC.title = LocaleStringForKey(NSFeedbackTitle,nil);
      RELEASE_OBJ(feedbackVC);
      break;
    }
      
    case LOGOFF_SEC:
    {
      if ([@"-1" isEqualToString:[AppManager instance].personId]) {
        [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:NO];
      } else {
        ShowAlertWithTwoButton(self, LocaleStringForKey(NSNoteTitle, nil), LocaleStringForKey(NSLogoutMsgTitle, nil), LocaleStringForKey(NSCancelTitle, nil), LocaleStringForKey(NSSureTitle, nil));
        
        _alertOwnerType = LOGOFF_TY;
      }
      
      break;
    }
      
    default:
      break;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  switch (section) {
    case LOGOFF_SEC:
    {
      return FOOTER_HEIGHT;
    }
      
    default:
      return 0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  /*
  switch (indexPath.section) {
    case LANG_SEC:
      return DEFAULT_CELL_HEIGHT + [ConfigurableTextCell tableView:tableView
                                          neededHeightForIndexPath:indexPath];
      break;
      
    default:
      return DEFAULT_CELL_HEIGHT;
  }
   */
  return DEFAULT_CELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  switch (section) {
    case LOGOFF_SEC:
    {
      if (nil == _footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FOOTER_HEIGHT)];
        _footerView.backgroundColor = CELL_COLOR;
                
        WXWLabel *infoLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                   textColor:BASE_INFO_COLOR
                                                 shadowColor:[UIColor whiteColor]] autorelease];
        infoLabel.font = BOLD_FONT(12);
        infoLabel.text = [NSString stringWithFormat:@"Copyright © 2013 Weixun Inc. All rights reserved."];
        [_footerView addSubview:infoLabel];
        CGSize size = [infoLabel.text sizeWithFont:infoLabel.font
                          constrainedToSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
        infoLabel.frame = CGRectMake((self.view.frame.size.width - size.width) / 2.0f,
                                     FOOTER_HEIGHT - size.height - MARGIN,
                                     size.width, size.height);
        
        WXWLabel *versionLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                      textColor:BASE_INFO_COLOR
                                                    shadowColor:[UIColor whiteColor]] autorelease];
        versionLabel.font = BOLD_FONT(12);
        versionLabel.text = [NSString stringWithFormat:@"Version %@",VERSION];
        [_footerView addSubview:versionLabel];
        size = [versionLabel.text sizeWithFont:versionLabel.font
                                    constrainedToSize:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)
                                        lineBreakMode:NSLineBreakByWordWrapping];
        
        versionLabel.frame = CGRectMake((self.view.frame.size.width - size.width)/2.0f,
                                        infoLabel.frame.origin.y - MARGIN - size.height, size.width, size.height);

      }
      return _footerView;
      
    }
      
    default:
      return nil;
  }
}

#pragma mark - alert delegate method
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  switch (_alertOwnerType) {
    case LOGOFF_TY:
      if (buttonIndex == 1) {
          
          [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"loginEd"];
          [[NSUserDefaults standardUserDefaults] synchronize];
          
        [((iAlumniAppDelegate*)APP_DELEGATE) openLoginNeedDisplayError:NO];
      }
      break;
            
    default:
      break;
  }
  
}

@end
