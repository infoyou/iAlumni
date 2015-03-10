//
//  WelfareMainFallViewController.h
//  iAlumni
//
//  Created by Adam on 13-9-4.
//
//

#import "WXWRootViewController.h"
#import "PanMoveProtocol.h"
#import "FilterScrollViewController.h"

@class AlumniWelfareViewController;


@interface WelfareMainFallViewController : WXWRootViewController <PanMoveProtocol, UIGestureRecognizerDelegate, HorizontalScrollArrangeDelegate> {
  
  @private
  
  AlumniWelfareViewController *_welfareListVC;
  
  FilterScrollViewController *_filterVC;
  
  UIViewController *_parentVC;
  
  BOOL _showingFilter;
  
  BOOL _showPanel;
  
  BOOL _forFavorited;
  
  UIPanGestureRecognizer *_panRecognizer;
  
  UITapGestureRecognizer *_tapGesture;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(UIViewController *)parentVC;

- (id)initFavoritedWelfareWithMOC:(NSManagedObjectContext *)MOC parentVC:(UIViewController *)pVC;

@end
