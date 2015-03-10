//
//  BizEntranceViewController.h
//  iAlumni
//
//  Created by Adam on 13-1-25.
//
//

#import "WXWRootViewController.h"
#import "PlainTabView.h"
#import "BaseListViewController.h"

@class BizGroupIndicatorBar;
@class PlainTabView;

@interface BizEntranceViewController : BaseListViewController <UIScrollViewDelegate, TapSwitchDelegate> {
  @private
  CGFloat _viewHeight;
  
  PlainTabView *_tabSwitchView;
  
  NSInteger _groupCategory;
    
  BizGroupIndicatorBar *_selectionIndicator;
  
  NSInteger _popularGroupCellCount;
    
  BOOL _needRefresh;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
         parentVC:(UIViewController *)parentVC;

@end
