//
//  HomepageEntranceViewController.h
//  iAlumni
//
//  Created by Adam on 13-1-8.
//
//

#import "WXWRootViewController.h"
#import "BaseListViewController.h"
#import "ScrollAutoPlayerDelegate.h"

@class VideoWallContainerView;
@class NewsThumbnailView;
@class NearbyEntranceView;
@class SearchAlumniEntranceView;
@class TodoEntranceView;
@class AdvEntranceView;
@class WXWLabel;
@class SloganView;

@interface HomepageEntranceViewController : BaseListViewController <ScrollAutoPlayerDelegate, UIAlertViewDelegate> {
  @private
  
  BOOL _loaded;
  
  VideoWallContainerView *_videoWallContainer;
  
  NewsThumbnailView *_newsThumbnailView;
  
  NearbyEntranceView *_nearbyEntranceView;
  
  SearchAlumniEntranceView *_searchAlumniEntranceView;
  
  TodoEntranceView *_todoEntranceView;
  
  AdvEntranceView *_advEntranceView;
  
  WXWLabel *_sloganLabel;
  
  CGFloat _viewHeight;
  
  BOOL _needAdjustForiOS7;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
         parentVC:(UIViewController *)parentVC;

#pragma mark - open shared items
- (void)openSharedBrandWithId:(long long)brandId;
- (void)openSharedVideoWithId:(long long)videoId;

@end
