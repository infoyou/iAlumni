//
//  HomepageContainerController.h
//  iAlumni
//
//  Created by Adam on 13-1-8.
//
//

#import <UIKit/UIKit.h>
#import "WXWRootViewController.h"
#import "TabBarView.h"

@interface HomeContainerController : WXWRootViewController <TabDelegate, UIAlertViewDelegate, MFMessageComposeViewControllerDelegate> {
    
  @private

  CGFloat _tabbarOriginalY;
  
  SharedItemType _sharedItemType;

  AppOpenTriggerType _openTriggerType;
  //BOOL _autoSelectEventTab;
  
  int _sharedEventType;

}


- (id)initWithMOC:(NSManagedObjectContext *)MOC;

#pragma mark - refresh tab items
- (void)refreshTabItems;
- (void)adjustTabbarForNavigationBarVisible;
- (void)adjustTabbarForNavigationBarInvisible;

#pragma mark - open shared event
- (void)openSharedEventById:(long long)eventId;
- (void)setAutoSelectEventTabFlagWithId:(long long)eventId eventType:(int)eventType;
- (void)setAutoSelectBrandId:(long long)brandId;
- (void)setAutoSelectVideoId:(long long)videoId;
- (void)setAutoSelectWelfareId:(NSString *)welfareId;

- (void)hideTabBar;
- (void)showTabBar;

- (void)displayNavigationBarForiOS7;

- (void)selectNotifyEventByHtml5;

@end
