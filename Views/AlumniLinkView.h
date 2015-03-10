//
//  AlumniLinkView.h
//  iAlumni
//
//  Created by Adam on 12-11-29.
//
//

#import "WXWConnectorConsumerView.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"

@class WXWLabel;
@class RelationshipLink;
@class UIImageButton;
@class WXWGradientView;
@class ECStandardButton;

@interface AlumniLinkView : WXWConnectorConsumerView {
  @private
  
  NSManagedObjectContext *_MOC;
  
  id<ECClickableElementDelegate> _linkListHolder;
  
  UIImageView *_referenceAvatar;
  UIView *_avatarBackgroundView;
  WXWLabel *_referenceNameLabel;
  WXWLabel *_withMeEventLabel;
  WXWLabel *_withTargetEventLabel;
  
  //UIImageButton *_favoriteButton;
  //ECStandardButton *_favoriteButton;
  //WXWGradientView *_buttonBackgroundView;
  
  CGFloat _separatorY;
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
     linkListHolder:(id<ECClickableElementDelegate>)linkListHolder
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate;

- (void)drawWithLink:(RelationshipLink *)link height:(CGFloat)height;


@end
