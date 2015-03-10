//
//  MyInfoViewController.h
//  iAlumni
//
//  Created by Adam on 13-10-23.
//
//

#import "BaseListViewController.h"
#import "ECItemUploaderDelegate.h"
#import "ECPhotoPickerOverlayDelegate.h"
#import "ECClickableElementDelegate.h"
#import "WXApi.h"

@interface MyInfoViewController : BaseListViewController {
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(UIViewController *)parentVC;

- (void)openDMForPush;

@end
