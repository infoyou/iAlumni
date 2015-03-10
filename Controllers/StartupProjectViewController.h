//
//  StartupProjectViewController.h
//  iAlumni
//
//  Created by Adam on 13-3-3.
//
//

#import "BaseListViewController.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "EventActionDelegate.h"
#import "GlobalConstants.h"
#import "WXApi.h"
#import "UPOMP.h"

@class Event;
@class StartupProjectHeaderView;
@class StartupProjectToolbar;
@class UIImageButton;
@class WXWLabel;

@interface StartupProjectViewController : BaseListViewController <UIActionSheetDelegate, EventActionDelegate, EKEventEditViewDelegate, MFMessageComposeViewControllerDelegate, WXApiDelegate, UPOMPDelegate, UIAlertViewDelegate> {
  
@private
  Event *_event;
  
  UIView *_sectionHeaderView;
  UIImageButton *_eventActionButton;
  
  CGFloat _actionButtonOriginalY;
  
  WXWLabel *_descTitleLabel;
  
  long long _eventId;
  
  NSInteger _actionSheetOwnerType;
  
  EKEventStore *_eventStore;
  EKEvent *_dailyEvent;
  EKCalendar *_defaultCalendar;
  BOOL _needRefreshAfterBack;
  
  BOOL _needClearFakeClubInstance;
  
  StartupProjectHeaderView *_headView;
  
  BOOL _eventLoaded;
  StartupProjectToolbar *_bottomToolbar;
  
  UPOMP *_paymentView;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC eventId:(long long)eventId;

- (id)initWithMOC:(NSManagedObjectContext *)MOC event:(Event *)event;

@end

