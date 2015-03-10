//
//  ProfileSettingViewController.h
//  iAlumni
//
//  Created by Adam on 13-5-22.
//
//

#import "BaseListViewController.h"
#import "ECItemUploaderDelegate.h"
#import "ECPhotoPickerOverlayDelegate.h"
#import "ECClickableElementDelegate.h"


@class PhotoFetcherView;
@class UserProfileHeaderView;

@interface ProfileSettingViewController : BaseListViewController <ECPhotoPickerOverlayDelegate, ECItemUploaderDelegate, UIActionSheetDelegate, ECClickableElementDelegate> {
 
  @private
  UIImagePickerControllerSourceType _photoSourceType;

  PhotoFetcherView *_photoFetcherView;
  
  PhotoTakerType _photoTakerType;
  
  UserProfileHeaderView *_headerView;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
