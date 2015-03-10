//
//  GroupEventMainViewController.h
//  iAlumni
//
//  Created by Adam on 13-8-13.
//
//

#import "WXWRootViewController.h"
#import "EventListViewController.h"
#import "FilterScrollViewController.h"
#import "PanMoveProtocol.h"


@interface GroupEventMainViewController : WXWRootViewController <PanMoveProtocol, UIGestureRecognizerDelegate, HorizontalScrollArrangeDelegate> {
  @private
  
  EventListViewController *_eventListVC;
  
  FilterScrollViewController *_filterVC;
  
  WXWRootViewController *_parentVC;
  
  BOOL _currentIsEvent;
  
  BOOL _showingFilter;
  
  BOOL _showPanel;
  
  UIPanGestureRecognizer *_panRecognizer;
  
  UITapGestureRecognizer *_tapGesture;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(WXWRootViewController *)parentVC;

#pragma mark - user actions
- (void)openSharedEventById:(long long)eventId;
@end
