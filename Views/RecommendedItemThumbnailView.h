//
//  RecommendedItemThumbnailView.h
//  ExpatCircle
//
//  Created by Adam on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECTitleThumbnailView.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class RecommendedItem;

@interface RecommendedItemThumbnailView : ECTitleThumbnailView {
  @private
  
  RecommendedItem *_recommendedItem;
}

- (id)initWithFrame:(CGRect)frame
        recommended:(RecommendedItem *)recommended;

@end
