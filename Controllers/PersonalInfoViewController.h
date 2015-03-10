//
//  PersonalInfoViewController.h
//  iAlumni
//
//  Created by Adam on 13-9-24.
//
//

#import "WXWRootViewController.h"

@class WXWNumberBadge;

@interface PersonalInfoViewController : WXWRootViewController {
  
  @private
  CGFloat _viewHeight;
  
  UIView *_dmEntranceView;
  UIView *_knownAlumnusEntranceView;
  UIView *_profileEntranceView;
  UIView *_wantKnowAlumnusEntranceView;
  UIView *_appSettingEntranceView;
  
  WXWNumberBadge *_dmNewNumberBadge;
  
  BOOL _needRefreshNewDMNumberBadge;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
parentViewController:(UIViewController *)parentViewController;

- (void)openDMForPush;

@end
