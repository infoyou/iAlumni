//
//  SupplyDemandComposerViewController.h
//  iAlumni
//
//  Created by Adam on 13-5-30.
//
//

#import "WXWRootViewController.h"
#import "ECEditorDelegate.h"
#import "ECPhotoPickerDelegate.h"
#import "ECPhotoPickerOverlayDelegate.h"
#import "ECItemUploaderDelegate.h"
#import "SupplyDemandTextEditorView.h"

@class SupplyDemandComposerHeaderView;
@class SupplyDemandTextEditorView;
@class PhotoFetcherView;
@class TagSelectionView;
@class WXWLabel;

@interface SupplyDemandComposerViewController : WXWRootViewController <UIActionSheetDelegate, ECPhotoPickerDelegate, UIImagePickerControllerDelegate, ECEditorDelegate, ECPhotoPickerOverlayDelegate, SupplyDemandTextEditorProtocal> {
  
  @private
  
  SupplyDemandComposerHeaderView *_textComposer;
  
  SupplyDemandTextEditorView *_textEditorView;
  
  PhotoFetcherView *_photoFetcherView;
  
  UIButton *_selectPhotoButton;
  
  //TagSelectionView *_tagSelectionView;
  
  BOOL _needMoveDownUI;
  BOOL _needMoveDown20px;
  
  BOOL _tagLoaded;
  BOOL _tagLoading;
  BOOL _tryToOpenTagList;
  
  // take photo
  ActionSheetOwnerType _actionSheetOwnerType;
  UIImagePickerControllerSourceType _photoSourceType;

}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
   uploadDelegate:(id<ECItemUploaderDelegate>)uploadDelegate;


@end
