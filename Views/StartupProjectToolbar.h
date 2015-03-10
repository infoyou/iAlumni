//
//  StartupProjectToolbar.h
//  iAlumni
//
//  Created by Adam on 13-3-3.
//
//

#import <UIKit/UIKit.h>
#import "EventActionDelegate.h"
#import "WXWGradientView.h"

@class WXWLabel;
@class Event;

@interface StartupProjectToolbar : WXWGradientView {
  
@private
  id<EventActionDelegate> _delegate;
}

- (id)initWithFrame:(CGRect)frame
              event:(Event *)event
           delegate:(id<EventActionDelegate>)delegate;


@end
