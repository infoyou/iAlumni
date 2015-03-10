//
//  AlumniWelfareViewController.h
//  iAlumni
//
//  Created by Adam on 13-8-13.
//
//

#import "BaseListViewController.h"
#import "BaseFilterListViewController.h"
#import "PanMoveProtocol.h"

@class WaterflowViewCell;
@class WaterflowView;
@class ILBarButtonItem;

@interface AlumniWelfareViewController : BaseListViewController {
  @private
  
  UIView *_bottomToolbar;
  
  BOOL _filterDataLoaded;
  
  BOOL _needReload;
  
  UIButton *_searchBtn;
  
  BOOL _scrolling;
  
  BOOL _showingFilter;
  
  BOOL _forFavorited;
  
  BOOL _canOpenProvider;
  
  BOOL _loadingData;
  
  CGFloat _bottomToolDisplayedY;
  
  CGFloat _bottomToolHiddenY;  
}

@property (nonatomic, assign) id<PanMoveProtocol> delegate;

- (id)initWithMOC:(NSManagedObjectContext *)MOC parentVC:(UIViewController *)pVC;

- (id)initFavoritedWelfareWithMOC:(NSManagedObjectContext *)MOC parentVC:(UIViewController *)pVC;

- (UIView *)quiltView:(WaterflowView *)quiltView cellAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - handle vc
- (void)setViewMoveWayType:(ScrollMoveWayType)tag;
- (void)setShowingFilter:(BOOL)flag;
- (void)extendFilterVC;
- (void)recoveryMainVC;
- (void)disableTableScroll;
- (void)enableTableScroll;
- (BOOL)tableScrolling;

#pragma mark - gesture controllers
- (void)enableTapGotoDetail;
- (void)disableTapGotoDetail;

@end
