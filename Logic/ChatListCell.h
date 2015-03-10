//
//  ChatListCell.h
//  iAlumni
//
//  Created by Adam on 12-6-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import "CMPopTipView.h"

@class Chat;
@class Alumni;

@interface ChatListCell : BaseUITableViewCell <CMPopTipViewDelegate>
{
    UIView *parentView;
    UILabel *bubbleLabel;
    UIView *popView;
    UILabel *dateLabel;
    UIImageView *bubbleImageView;
    
    UIButton *_popViewBut;
    
    id<ECClickableElementDelegate> _delegate;
}

@property (nonatomic, retain) UIView *parentView;

- (void)drawChat:(Chat*)chart;
- (id)initWithStyle:(UITableViewCellStyle)style alumni:(Alumni *)alumni reuseIdentifier:(NSString *)reuseIdentifier imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate;

@end
