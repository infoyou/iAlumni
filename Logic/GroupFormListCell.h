//
//  GroupFormListCell.h
//  iAlumni
//
//  Created by Adam on 13-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import "CMPopTipView.h"

@class Post;

@interface GroupFormListCell : BaseUITableViewCell <CMPopTipViewDelegate>
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

- (void)drawPost:(Post*)post;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate;

@end
