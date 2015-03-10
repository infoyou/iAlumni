//
//  FilterListCell.m
//  iAlumni
//
//  Created by Adam on 13-8-1.
//
//

#import "FilterListCell.h"

@implementation FilterListCell

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
    [self drawSplitLine:line1Frame color:COLOR(40, 40, 41)];
    [self drawSplitLine:line2Frame color:COLOR(63, 63, 63)];
}

- (void)drawSplitLine:(CGRect)lineFrame color:(UIColor *)color
{
    
    UIView *splitLine = [[[UIView alloc] initWithFrame:lineFrame] autorelease];
    splitLine.backgroundColor = color;
    
    [self.contentView addSubview:splitLine];
}

@end
