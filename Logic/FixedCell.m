//
//  DiYuCell2.m
//  IYLM
//
//  Created by JianYe on 13-1-11.
//  Copyright (c) 2013年 Jian-Ye. All rights reserved.
//

#import "FixedCell.h"

@implementation FixedCell
@synthesize titleLabel;
- (void)dealloc
{
    self.titleLabel = nil;
    [super dealloc];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawCell {
    
    CGRect line1Frame = CGRectMake(0, self.contentView.frame.size.height - 0.5, SCREEN_WIDTH, 0.5);
    CGRect line2Frame = CGRectMake(0, self.contentView.frame.size.height - 1, SCREEN_WIDTH, 0.5);
    [self drawSplitLine:line1Frame color:COLOR(23, 24, 25)];
    [self drawSplitLine:line2Frame color:COLOR(48, 48, 48)];
}

- (void)drawSplitLine:(CGRect)lineFrame color:(UIColor *)color
{
    
    UIView *splitLine = [[[UIView alloc] initWithFrame:lineFrame] autorelease];
    splitLine.backgroundColor = color;
    
    [self.contentView addSubview:splitLine];
}

@end
