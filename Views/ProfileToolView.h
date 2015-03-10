//
//  ProfileToolView.h
//  iAlumni
//
//  Created by Adam on 12-11-15.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class UIImageButton;

@interface ProfileToolView : UIView {
  @private
  
  id<ECClickableElementDelegate> _profileDelegate;
  
  UIButton *_favoriteButton;
  
  AlumniRelationshipType _relationshipType;
}

- (id)initWithFrame:(CGRect)frame
    profileDelegate:(id<ECClickableElementDelegate>)profileDelegate;

#pragma mark - update favorite status
- (void)updateFavoriteStatusWithType:(AlumniRelationshipType)relationType;

- (void)startSpinView;
- (void)stopSpingForSuccess:(BOOL)success;

@end
