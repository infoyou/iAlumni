//
//  UserProfileViewController.h
//  iAlumni
//
//  Created by Adam on 12-9-24.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "WXWImageDisplayerDelegate.h"
#import "ECItemUploaderDelegate.h"
#import "ECClickableElementDelegate.h"


@class UserProfileHeaderView;
@class PhotoFetcherView;

@interface UserProfileViewController : BaseListViewController <WXWImageDisplayerDelegate, UIActionSheetDelegate, ECItemUploaderDelegate, ECClickableElementDelegate> {
  @private
  
  CGFloat _viewHeight;
  
  UIView *_footerView;
  
  id _personalEntrance;
  SEL _refreshAction;
  
  UIButton *_signOutButton;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
         parentVC:(UIViewController *)parentVC;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(UIViewController *)parentVC
 personalEntrance:(id)personalEntrance
    refreshAction:(SEL)refreshAction;
@end
