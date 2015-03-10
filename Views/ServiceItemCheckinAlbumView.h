//
//  ServiceItemCheckinAlbumView.h
//  iAlumni
//
//  Created by Adam on 12-8-17.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"
#import "WXWImageDisplayerDelegate.h"
#import "WXWImageFetcherDelegate.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;

@interface ServiceItemCheckinAlbumView  : UIView <WXWImageFetcherDelegate> {
  UIActivityIndicatorView *_spinView;
  BOOL _clickable;
  
  NSInteger _displayedPeopleCount;
  
  UIImageView *_rightArrow;
  
  BOOL photoLoaded;
  
@private
  
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  NSMutableDictionary *_photoDic;
  
  WXWLabel *_noCheckinNotifyLabel;
  
  NSMutableArray *_imageViewList;
  
  NSArray *_currentCheckinAlumnus;
  
  WXWLabel *_checkinCountLabel;
}

@property (nonatomic, readonly, getter = isPhotoLoaded) BOOL photoLoaded;
@property (nonatomic, retain) UIActivityIndicatorView *spinView;
@property (nonatomic, assign) BOOL clickable;

- (void)hideRightArrow;
- (void)startSpinView;
- (void)stopSpinView;

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

- (void)drawAlbum:(NSManagedObjectContext *)MOC
hashedCheckedinItemId:(NSString *)hashedCheckedinItemId;

@end
