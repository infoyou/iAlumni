//
//  ECPhotoPickerController.h
//  iAlumni
//
//  Created by Adam on 11-11-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WXWRootViewController.h"
#import "ECPhotoPickerDelegate.h"
#import "GlobalConstants.h"

@interface ECPhotoPickerController : WXWRootViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
  
@private
  UIImagePickerController *_imagePicker;
  id<ECPhotoPickerDelegate> _delegate;
  UIImage *_originalImage;
  UIImage *_handledImage;
  UIImageView *_imageView;
  UIView *_selectionIndicator;
  CGRect _originalImageIndicatorFrame;
  CGRect _bWImageIndicatorFrame;
  BOOL _bwImageSelected;

}

@property (nonatomic, retain) id<ECPhotoPickerDelegate> delegate;
@property (nonatomic, retain) UIImagePickerController *imagePicker;

- (id)initWithSourceType:(UIImagePickerControllerSourceType)sourceType;

@end
