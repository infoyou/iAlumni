//
//  AlumniEventDetailActionView.h
//  iAlumni
//
//  Created by Adam on 13-1-26.
//
//

#import <UIKit/UIKit.h>
#import "EventActionDelegate.h"

@class WXWLabel;
@class Event;

@interface AlumniEventDetailActionView : UIView {
    
    @private
    id<EventActionDelegate> _delegate;
}

- (id)initWithFrame:(CGRect)frame
        event:(Event *)event
           delegate:(id<EventActionDelegate>)delegate;

@end
