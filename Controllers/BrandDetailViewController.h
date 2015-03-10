//
//  BrandDetailViewController.h
//  iAlumni
//
//  Created by Adam on 12-8-20.
//
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "ECItemUploaderDelegate.h"
#import "WXApi.h"

@class Brand;
@class BrandBaseInfoView;

@interface BrandDetailViewController : BaseListViewController <ECClickableElementDelegate, ECItemUploaderDelegate, WXApiDelegate> {
  @private
  Brand *_brand;
  
  long long _brandId;
  
  BrandBaseInfoView *_baseInfoView;
  
  // location
  BOOL _currentLocationIsLatest;
  
  UIView *_branchTitleView;
  
  NSIndexPath *_commentIndexPath;
  BOOL _needUpdateCommentCount;
  
  BOOL _presentTipsProcessing;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
            brand:(Brand *)brand
locationRefreshed:(BOOL)locationRefreshed;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
          brandId:(long long)brandId
locationRefreshed:(BOOL)locationRefreshed;


@end
