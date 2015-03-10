//
//  FavoriteAlumniResultView.h
//  iAlumni
//
//  Created by Adam on 12-11-21.
//
//

#import <UIKit/UIKit.h>
#import "WXWConnectorConsumerView.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"
#import "UIImageButton.h"
#import "WXWImageDisplayerDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"

@class Alumni;

@interface FavoriteAlumniResultView : WXWConnectorConsumerView {
  @private
  
  NSManagedObjectContext *_MOC;
  
  UIView *_topView;
  
  UIImageButton *_wantToKnowButton;
  UIImageButton *_knownButton;
  UIImageButton *_deleteButton;
  
  BOOL _userCancel;
  
  AlumniRelationshipType _relationshipType;
  
  CGFloat _checkButtonBottomY;
  
  id<ECClickableElementDelegate> _holder;
  SEL _closeAction;
  SEL _favoriteAction;
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
             holder:(id<ECClickableElementDelegate>)holder
        closeAction:(SEL)closeAction
     favoriteAction:(SEL)favoriteAction
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate
             alumni:(Alumni *)alumni;

@end
