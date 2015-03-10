//
//  CurrentItemTextView.m
//  iAlumni
//
//  Created by Adam on 11-11-9.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CurrentItemTextView.h"

@implementation CurrentItemTextView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = TRANSPARENT_COLOR;
    
    _contentLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN, MARGIN,
                                                                self.bounds.size.width - MARGIN * 2,
                                                                self.bounds.size.height - MARGIN * 2)
                                          textColor:[UIColor whiteColor]
                                        shadowColor:TRANSPARENT_COLOR] autorelease];
    _contentLabel.backgroundColor = TRANSPARENT_COLOR;
    _contentLabel.font = BOLD_FONT(14);
    _contentLabel.numberOfLines = 6;
    _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_contentLabel];
  }
  return self;
}

- (void)updateContent:(NSString *)content {
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     _contentLabel.frame = CGRectMake(_contentLabel.frame.origin.x,
                                                      _contentLabel.frame.origin.y - 30,
                                                      _contentLabel.frame.size.width,
                                                      _contentLabel.frame.size.height);
                     _contentLabel.alpha = 0.0f;
                   }
                   completion:^(BOOL finished){
                     
                     _contentLabel.frame = CGRectMake(_contentLabel.frame.origin.x,
                                                      self.frame.size.height,
                                                      _contentLabel.frame.size.width,
                                                      _contentLabel.frame.size.height);
                     
                     [UIView animateWithDuration:0.2f
                                      animations:^{
                                        _contentLabel.text = content;
                                        
                                        _contentLabel.frame = CGRectMake(_contentLabel.frame.origin.x,
                                                                         MARGIN,
                                                                         _contentLabel.frame.size.width,
                                                                         _contentLabel.frame.size.height);
                                        _contentLabel.alpha = 1.0f;
                                      }];
                   }];
}


@end
