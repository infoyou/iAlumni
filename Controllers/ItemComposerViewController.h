//
//  ItemComposerViewController.h
//  iAlumni
//
//  Created by Adam on 12-12-8.
//
//

#import "WXWRootViewController.h"
#import "GlobalConstants.h"
#import "ECPhotoPickerDelegate.h"
#import "ECEditorDelegate.h"
#import "ECItemUploaderDelegate.h"
#import "ECPhotoPickerOverlayDelegate.h"


@class TextComposerView;
@class PhotoFetcherView;
@class Club;

@interface ItemComposerViewController : WXWRootViewController <UIActionSheetDelegate, ECPhotoPickerDelegate, UIImagePickerControllerDelegate, ECEditorDelegate, ECPhotoPickerOverlayDelegate> {
  @private
  
  BOOL _needMoveDownUI;
  
  TextComposerView *_textComposer;
  
  WebItemType _contentType;

  PhotoFetcherView *_photoFetcherView;
  
  // take photo
  ActionSheetOwnerType _actionSheetOwnerType;
  UIImagePickerControllerSourceType _photoSourceType;
  
  BOOL _needMoveDown20px;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
            group:(Club *)group
      contentType:(NSInteger)contentType
 uploaderDelegate:(id<ECItemUploaderDelegate>)uploaderDelegate;

@end
