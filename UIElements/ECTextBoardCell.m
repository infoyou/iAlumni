//
//  ECTextBoardCell.m
//  ExpatCircle
//
//  Created by Adam on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECTextBoardCell.h"
#import "WXWLabel.h"

@interface ECTextBoardCell()
@property (nonatomic, retain) NSMutableArray *labelsContainer;
@end

@implementation ECTextBoardCell

@synthesize labelsContainer = _labelsContainer;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
  }
  return self;
}

- (void)dealloc {
  
  self.labelsContainer = nil;
  
  [super dealloc];
}

- (WXWLabel *)initLabel:(CGRect)frame
             textColor:(UIColor *)textColor 
           shadowColor:(UIColor *)shadowColor {
  
  WXWLabel *label = [[WXWLabel alloc] initWithFrame:frame
                                        textColor:textColor
                                      shadowColor:shadowColor];
  
  if (nil == self.labelsContainer) {
    self.labelsContainer = [NSMutableArray array];
  }
  [self.labelsContainer addObject:label];
  return label;
}

#pragma mark - remove shadow of labels when selected or highlighted

- (void)applyLabelsShadow:(BOOL)needShadow {
  for (WXWLabel *label in self.labelsContainer) {
    if (label.noShadow) {
      label.shadowColor = nil;
    } else {
      label.shadowColor = needShadow ? [UIColor whiteColor] : nil;
    }
  }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  [super setHighlighted:highlighted animated:animated];
  
  [self applyLabelsShadow:!highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  
  [self applyLabelsShadow:!selected];
}

@end
