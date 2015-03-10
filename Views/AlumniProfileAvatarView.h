//
//  AlumniProfileAvatarView.h
//  iAlumni
//
//  Created by Adam on 12-11-13.
//
//

#import "WXWConnectorConsumerView.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;
@class AlumniProfileTopBackgroundView;
@class Alumni;
@class ProfileToolView;
@class LinkEntranceView;
@class AlumniLocationStatusView;
@class WithMeConnectionView;

@interface AlumniProfileAvatarView : WXWConnectorConsumerView <UIGestureRecognizerDelegate> {
@private
  
  UIButton *_avatarImageViewButton;
  
  AlumniLocationStatusView *_alumniStatusView;
  
  WXWLabel *_nameLabel;
  
  WXWLabel *_classLabel;
  
  WXWLabel *_bioLabel;
  
  ProfileToolView *_toolView;
  
  id _profileHolder;
  SEL _saveAvatarAction;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  LinkEntranceView *_linkEntranceView;
  //WithMeConnectionView *_withMeConnectionView;
  
  CGFloat _bottomLineY;
  
  BOOL _hideLocation;
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
           personId:(NSString *)personId
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
      profileHolder:(id)profileHolder
   saveAvatarAction:(SEL)saveAvatarAction
       hideLocation:(BOOL)hideLoation;

#pragma mark - draw view methods
- (void)arrangeToolViews;
- (void)arrangeProfileBio;
- (void)updateBadges;

#pragma mark - update favorite status
- (void)updateFavoriteStatusWithType:(AlumniRelationshipType)relationType;
- (void)startSpinView;
- (void)stopSpingForSuccess:(BOOL)success;

#pragma mark - set alumni entity for refresh
- (void)refreshAfterAlumniLoaded:(Alumni *)alumni;

@end
