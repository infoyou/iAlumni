//
//  MessageCell.m
//  iAlumni
//
//  Created by Adam on 12-2-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MessageCell.h"
#import "MessageButton.h"
#import "CommonUtils.h"
#import "TextConstants.h"
#import "WXWLabel.h"
#import "Messages.h"

#define BTN_WIDTH   60.0f
#define BTN_HEIGHT  30.0f

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.contentView.backgroundColor = CELL_COLOR;
        
        _messageLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                              textColor:BASE_INFO_COLOR
                                            shadowColor:[UIColor whiteColor]] autorelease];
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = BOLD_FONT(13);
        [self addSubview:_messageLabel];
        
//        _awardButton = [[[MessageButton alloc] initWithFrame:CGRectZero
//                                                      target:nil
//                                                      action:nil
//                                                   colorType:RED_BTN_COLOR_TY
//                                                       title:nil
//                                                       image:nil
//                                                  titleColor:ORANGE_BTN_TITLE_COLOR
//                                            titleShadowColor:ORANGE_BTN_TITLE_SHADOW_COLOR
//                                                   titleFont:BOLD_FONT(12)
//                                                 roundedType:HAS_ROUNDED
//                                             imageEdgeInsert:ZERO_EDGE 
//                                             titleEdgeInsert:ZERO_EDGE] autorelease];
//        [self addSubview:_awardButton];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)drawCell:(Messages *)message target:(id)target action:(SEL)action {
    
    _messageLabel.text = message.content;
    CGSize size;
    
    if (_awardButton == nil) {
        size = [_messageLabel.text sizeWithFont:_messageLabel.font 
                              constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 6, CGFLOAT_MAX) 
                                  lineBreakMode:NSLineBreakByWordWrapping];
        _messageLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2, size.width, size.height);
        
        return;
    }else {
        size = [_messageLabel.text sizeWithFont:_messageLabel.font 
                                     constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 6 - BTN_WIDTH, CGFLOAT_MAX) 
                                         lineBreakMode:NSLineBreakByWordWrapping];
        _messageLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2, size.width, size.height);
    }
    
    CGFloat height = 44.0f;
    if (size.height > height) {
        height = size.height;
    }
    
    height += MARGIN * 2 + MARGIN * 2;
    
    _awardButton.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - BTN_WIDTH, (height - BTN_HEIGHT)/2.0f, BTN_WIDTH, BTN_HEIGHT);
    _awardButton.message = message;
    
    [_awardButton addTarget:target
                     action:action 
           forControlEvents:UIControlEventTouchUpInside];
    
    switch (message.type.intValue) {
        case AWARD_SYS_MSG_TY:
            [_awardButton setTitle:LocaleStringForKey(NSAwardTitle, nil) 
                          forState:UIControlStateNormal];
            break;
            
        case UPDATE_AVAILABLE_SYS_MSG_TY:
            [_awardButton setTitle:LocaleStringForKey(NSUpdateTitle, nil) 
                          forState:UIControlStateNormal];
            break;
            
        default:
            [_awardButton setTitle:LocaleStringForKey(NSDetailsTitle, nil) 
                          forState:UIControlStateNormal];
            break;
    }
}

@end
