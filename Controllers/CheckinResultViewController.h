//
//  CheckinResultViewController.h
//  iAlumni
//
//  Created by Adam on 12-8-28.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "EventCheckinDelegate.h"

@class CheckinResultHeaderView;
@class Event;

@interface CheckinResultViewController : BaseListViewController <EventCheckinDelegate> {
  @private
  CheckinResultHeaderView *_headerView;
  
  UIView *_footerView;
  
  NSString *_backendMsg;
  
  CheckinResultType _checkinResultType;
  
  Event *_eventDetail;
  
  CGFloat _checkinResultBoardHeight;
  
  UIViewController *_checkinEntrance;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
checkinResultType:(CheckinResultType)checkinResultType
      event:(Event *)event
         entrance:(UIViewController *)entrance
       backendMsg:(NSString *)backendMsg;

@end
