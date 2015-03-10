//
//  EventDetailViewController.h
//  iAlumni
//
//  Created by Adam on 13-1-25.
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
@class EventDetailHeadView;
@class AlumniEventDetailActionView;
@class UIImageButton;
@class WXWLabel;
@class BaseListViewController;

@interface EventDetailViewController : WXWRootViewController <UIActionSheetDelegate, EventActionDelegate, EKEventEditViewDelegate, MFMessageComposeViewControllerDelegate, WXApiDelegate, UPOMPDelegate, UIAlertViewDelegate> {
  
@private
  Event *_event;
  
  UIView *_sectionHeaderView;
  UIImageButton *_eventActionButton;
  
  long long _eventId;
  
  NSInteger _actionSheetOwnerType;
  
  EKEventStore *_eventStore;
  EKEvent *_dailyEvent;
  EKCalendar *_defaultCalendar;
  BOOL _needRefreshAfterBack;
  BOOL _autoLoaded;
  BOOL _needClearFakeClubInstance;
  
  BOOL _eventLoaded;
  AlumniEventDetailActionView *_bottomToolbar;
  
  UPOMP *_paymentView;
  
  BaseListViewController *_parentListVC;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC eventId:(long long)eventId parentListVC:(BaseListViewController *)parentListVC;

- (id)initWithMOC:(NSManagedObjectContext *)MOC event:(Event *)event parentListVC:(BaseListViewController *)parentListVC;

@end

