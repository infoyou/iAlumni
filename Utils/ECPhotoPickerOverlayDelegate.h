//
//  ECPhotoPickerOverlayDelegate.h
//  iAlumni
//
//  Created by Adam on 12-1-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ECPhotoPickerOverlayDelegate <NSObject>

@required
- (void)didTakePhoto:(UIImage *)photo;
- (void)didFinishWithCamera;

@optional
- (void)adjustUIAfterUserBrowseAlbumInImagePicker;

@end
