//
//  NearbyEntranceViewController.h
//  iAlumni
//
//  Created by Adam on 12-9-11.
//
//

#import "BaseListViewController.h"
#import "PlainTabView.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class Shake;
@class WinnerHeaderView;

@interface NearbyEntranceViewController : BaseListViewController <TapSwitchDelegate, ECClickableElementDelegate, ECClickableElementDelegate, UIActionSheetDelegate> {
  @private
  
  PlainTabView *_tabSwitchView;
  
  WinnerHeaderView *_winnerHeaderView;
  
  NSInteger _tapIndex;
  
  BOOL _userRefreshList;
  
  BOOL _currentLocationIsLatest;
  
  BOOL _winnerLoaded;
  
  UIButton *_contactUsButton;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
