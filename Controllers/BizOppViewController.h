//
//  BizOppViewController.h
//  iAlumni
//
//  Created by Adam on 13-8-13.
//
//

#import "BaseListViewController.h"

@class BizOppWallView;
@class RectCellAreaView;

@interface BizOppViewController : BaseListViewController {
  @private
  
  BizOppWallView *_bizOppWallView;
  
  CGFloat _viewHeight;
  
  RectCellAreaView *_favoriteItemArea;
  RectCellAreaView *_favoriteWelfareArea;
  
  BOOL _needAdjustForiOS7;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
       viewHeight:(CGFloat)viewHeight
parentViewController:(UIViewController *)parentViewController;

- (void)openWelfare;
- (void)openSupplyDemand;

@end
