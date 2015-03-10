//
//  EventDetailHeadView.h
//  iAlumni
//
//  Created by Adam on 13-1-25.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"
#import "EventActionDelegate.h"

@class WXWLabel;
@class Event;
@class UIImageButton;

@interface EventDetailHeadView : UIView <UIGestureRecognizerDelegate, WXWImageFetcherDelegate>{
    
@private

    UIButton *_postImgButton;
    WXWLabel *_nameLabel;
    WXWLabel *_timeLabel;
    id<EventActionDelegate> _delegate;
    UIView *_activityView;
  
  UIImageButton *_eventSignBut;
  
  UIImageButton *_eventCheckinBut;
  
  id _imageHolder;
  
  SEL _saveImageAction;
}

@property (nonatomic, retain) Event *event;

- (id)initWithFrame:(CGRect)frame
              event:(Event *)event
           delegate:(id<EventActionDelegate>)delegate
        imageHolder:(id)imageHolder
    saveImageAction:(SEL)saveImageAction;

@end

