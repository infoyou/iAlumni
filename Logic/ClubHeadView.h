//
//  ClubHeadView.h
//  iAlumni
//
//  Created by Adam on 12-8-16.
//
//

#import "WXWRootViewController.h"
#import "ClubManagementDelegate.h"

@class ClubSimple;
@class UIImageButton;

@interface ClubHeadView : UIView <UIAlertViewDelegate> {
  id<ClubManagementDelegate> _delegate;
  
  CGRect  _frame;
  UIView  *_headerView;
  UIView  *topView;
  NSManagedObjectContext *_MOC;
  
  WebItemType _currentType;
  
  BOOL    joinStatus;
  
  ClubSimple *_clubSimple;
  
  UIImageButton *_memberBut;
  
  UIImageButton *_joinAndQuitBut;
  
  UIBarButtonItem *_payBarButton;
  
  UIView *_member2ActivityView;
  
  UIToolbar *_postToolbar;
  
  BOOL _autoLoaded;
}

@property (nonatomic, assign) BOOL joinStatus;

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext*)MOC
   clubHeadDelegate:(id<ClubManagementDelegate>)clubHeadDelegate;

- (void)loadData;

- (void)updateStatusAfterPaymentDone;

@end
