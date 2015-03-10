//
//  WelfareItemWallView.h
//  iAlumni
//
//  Created by Adam on 13-8-18.
//
//

#import "WXWConnectorConsumerView.h"
#import "UIPageControl+CustomizeDot.h"
#import "HintEnlargedButton.h"

@class WXWLabel;

@interface WelfareItemWallView : WXWConnectorConsumerView <UIScrollViewDelegate> {
@private
  
  UIScrollView *_wallView;
  
  UIPageControl *_pageControl;
  
  id _welfareDetailVC;
  
  SEL _favoriteAction;
  
  SEL _shareAction;
  
  SEL _saveImageAction;
  
  NSInteger _currentPageIndex;
  
  BOOL _stopScrolling;
  
  UIView *_bottonBackgroundView;
  
  UIButton *_favoriteButton;
  WXWLabel *_favoriteLabel;
//  HintEnlargedButton *_shareButton;
  UIButton *_shareButton;
  UIView *_shareBackgroundView;
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
    welfareDetailVC:(id)welfareDetailVC
     favoriteAction:(SEL)favoriteAction
        shareAction:(SEL)shareAction
    saveImageAction:(SEL)saveImageAction;

- (void)updateImageList:(NSArray *)imageList favoritedStatus:(BOOL)favoritedStatus;

- (void)updateFavoritedStatus:(BOOL)status;

- (void)play;

- (void)stopPlay;

@end
