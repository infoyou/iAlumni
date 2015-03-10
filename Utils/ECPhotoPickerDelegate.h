//
//  ECPhotoPickerDelegate.h
//  iAlumni
//
//  Created by Adam on 11-11-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ECPhotoPickerDelegate <NSObject>

@required
- (void)selectPhoto:(UIImage *)selectedImage;

@end
