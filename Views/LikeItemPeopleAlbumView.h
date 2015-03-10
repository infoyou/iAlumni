//
//  LikeItemPeopleAlbumView.h
//  ExpatCircle
//
//  Created by Adam on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "WXWImageDisplayerDelegate.h"
#import "WXWImageFetcherDelegate.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;

@interface LikeItemPeopleAlbumView : UIView <WXWImageFetcherDelegate> {
  @private
  
  UIImageView *_rightArrow;
  
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  NSMutableDictionary *_photoDic;

  NSInteger _displayedPeopleCount;
  
  NSInteger _totalLikesCount;
  WXWLabel *_likesCountLabel;
  
  UIImageView *_likeIcon;
  
  BOOL _likedByMe;
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

- (void)drawLikesAlbum:(NSInteger)totalLikesCount 
             likedByMe:(BOOL)likedByMe
                   MOC:(NSManagedObjectContext *)MOC 
     hashedLikedItemId:(NSString *)hashedLikedItemId;

@end
