//
//  ECInnerShadowTextView.h
//  iAlumni
//
//  Created by Adam on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECTextView.h"
#import "GlobalConstants.h"

@interface ECInnerShadowTextView : ECTextView {
  @private
  UIImageView *_addCommentImageView;
  
}

- (void)hideAddCommentIcon;

- (void)showAddCommentIcon;

@end
