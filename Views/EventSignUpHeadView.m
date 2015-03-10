//
//  EventSignUpHeadView.m
//  iAlumni
//
//  Created by Adam on 13-2-6.
//
//

#import "EventSignUpHeadView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Event.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "ECPlainButton.h"
#import "ECGradientButton.h"
#import "UIImageButton.h"
#import "AppManager.h"
#import "UIImage-Extensions.h"
#import "AppManager.h"

#define NAME_WIDTH      300.f

@interface EventSignUpHeadView()
@property (nonatomic, retain) Event *event;
@end

@implementation EventSignUpHeadView

- (id)initWithFrame:(CGRect)frame
              event:(Event *)event
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.event = event;
        
        [self initViewTop];
    }
    return self;
}

- (void)initViewTop {
    _nameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                        textColor:CELL_TITLE_COLOR
                                      shadowColor:[UIColor whiteColor]] autorelease];
    _nameLabel.font = BOLD_FONT(17);
    _nameLabel.numberOfLines = 0;
    _nameLabel.textAlignment = UITextAlignmentLeft;
    [self addSubview:_nameLabel];
    
    _nameLabel.text = self.event.title;
    CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font
                              constrainedToSize:CGSizeMake(NAME_WIDTH, CGFLOAT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping];
    _nameLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2,
                                  size.width, size.height);
    
    _timeLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                        textColor:COLOR(102, 99, 100)
                                      shadowColor:[UIColor clearColor]] autorelease];
    _timeLabel.font = FONT(15);
    [self addSubview:_timeLabel];
    
    _timeLabel.text = [NSString stringWithFormat:@"%@: %@ %@", LocaleStringForKey(NSDateTitle, nil), self.event.time, self.event.timeStr];
    size = [_timeLabel.text sizeWithFont:_timeLabel.font
                       constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4,
                                                    CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];
    _timeLabel.frame = CGRectMake(MARGIN * 2,
                                  _nameLabel.frame.origin.y + _nameLabel.frame.size.height + MARGIN*2,
                                  size.width, size.height);
}

- (void)dealloc {
    
    self.event = nil;
    [super dealloc];
}

@end
