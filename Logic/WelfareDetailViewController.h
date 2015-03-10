//
//  WelfareDetailViewController.h
//  iAlumni
//
//  Created by Adam on 13-8-14.
//
//

#import "BaseListViewController.h"

@class Welfare;
@class WelfareImageWallCell;

@interface WelfareDetailViewController : BaseListViewController <UIActionSheetDelegate, WXWImageFetcherDelegate> {
  @private
  Welfare *_welfare;

  BOOL _imageWallLoaded;
  
  WelfareImageWallCell *_imageWallcell;
  
  id _welfareListVC;
  SEL _setReloadFlagAction;
  
  BOOL _hasStores;

  NSInteger _asOwnerType;
  
  CGRect _originalTableFrame;
  CGRect _originalViewFrame;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
          welfare:(Welfare *)welfare
    welfareListVC:(id)welfareListVC
setReloadFlagAction:(SEL)setReloadFlagAction;

@end
