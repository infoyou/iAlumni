//
//  LikePeopleAlbumView.h
//  iAlumni
//
//  Created by Adam on 11-12-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "WXWImageDisplayerDelegate.h"
#import "WXWImageFetcherDelegate.h"
#import "ECClickableElementDelegate.h"


@interface LikePeopleAlbumView : UIView <WXWImageFetcherDelegate> {
  
  NSInteger _displayedPeopleCount;
  
  UIView *_topShadow;
  
  UIImageView *_rightArrow;
  
  BOOL photoLoaded;
  
@private
  
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  NSMutableDictionary *_photoDic;
  
}

@property (nonatomic, readonly, getter = isPhotoLoaded) BOOL photoLoaded;

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

- (void)drawAlbum:(NSManagedObjectContext *)MOC;
@end
