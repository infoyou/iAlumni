//
//  EventSignUpHeadView.h
//  iAlumni
//
//  Created by Adam on 13-2-6.
//
//

#import <UIKit/UIKit.h>

@class WXWLabel;
@class Event;

@interface EventSignUpHeadView : UIView
{
    WXWLabel *_nameLabel;
    WXWLabel *_timeLabel;
}

- (id)initWithFrame:(CGRect)frame
              event:(Event *)event;

@end
