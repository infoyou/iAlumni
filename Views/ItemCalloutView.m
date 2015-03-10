//
//  ItemCalloutView.m
//  ExpatCircle
//
//  Created by Adam on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ItemCalloutView.h"
#import <QuartzCore/QuartzCore.h>
#import "Store.h"
#import "WXWLabel.h"

#define ICON_WIDTH  16.0f
#define ICON_HEIGHT 16.0f

#define COUPON_ICON_SIDE_LENGTH 32.0f

@interface ItemCalloutView()
@property (nonatomic, retain) Store *store;
@end

@implementation ItemCalloutView


- (id)initWithFrame:(CGRect)frame
               store:(Store *)store
         sequenceNO:(NSInteger)sequeneNO 
             target:(id)target 
   showDetailAction:(SEL)showDetailAction {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.store = store;
    _target = target;
    _showDetailAction = showDetailAction;
      
    self.backgroundColor = TRANSPARENT_COLOR;
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    [shadowPath moveToPoint:CGPointMake(2, 2)];
    [shadowPath addLineToPoint:CGPointMake(self.frame.size.width + 2, 2)];
    [shadowPath addLineToPoint:CGPointMake(self.frame.size.width + 2, self.frame.size.height + 2)];
    [shadowPath addLineToPoint:CGPointMake(2, self.frame.size.height + 2)];
    [shadowPath addLineToPoint:CGPointMake(2, 2)];
    self.layer.shadowPath = shadowPath.CGPath;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.9f;
    self.userInteractionEnabled = YES;
    
    _button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    _button.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _button.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
    _button.layer.borderWidth = 1.0f;
    _button.layer.borderColor = [UIColor lightGrayColor].CGColor;   
    _button.layer.cornerRadius = 6.0f;
    _button.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 200, 0.0f, 0.0f);
    _button.userInteractionEnabled = YES;
    _button.enabled = YES;
    [self addSubview:_button];
    
    _nameLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2, self.frame.size.width - MARGIN * 4, 20)
                                       textColor:[UIColor blackColor] 
                                     shadowColor:[UIColor whiteColor]] autorelease];
    _nameLabel.font = BOLD_FONT(16);
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _nameLabel.text = [NSString stringWithFormat:@"%d. %@", sequeneNO, store.storeName];
    [_button addSubview:_nameLabel];
    
    /*
    _likeIndicator = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 7, ICON_WIDTH, ICON_HEIGHT)] autorelease];
    _likeIndicator.backgroundColor = TRANSPARENT_COLOR;
    NSString *likeImageName = item.liked.boolValue ? @"like.png" : @"unlike.png";
    _likeIndicator.image = [UIImage imageNamed:likeImageName];
    [_button addSubview:_likeIndicator];
    
    
    _likeCountLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                            textColor:[UIColor blackColor] 
                                          shadowColor:[UIColor whiteColor]] autorelease];
    _likeCountLabel.font = BOLD_FONT(12);
    _likeCountLabel.text = [NSString stringWithFormat:@"%@", item.likeCount];
    CGSize size = [_likeCountLabel.text sizeWithFont:_likeCountLabel.font
                                   constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    _likeCountLabel.frame = CGRectMake(_likeIndicator.frame.origin.x + ICON_WIDTH + MARGIN, _likeIndicator.frame.origin.y, size.width, size.height);
    [_button addSubview:_likeCountLabel];
    
    _commentIndicator = [[[UIImageView alloc] initWithFrame:CGRectMake(_likeCountLabel.frame.origin.x + MARGIN * 2 + _likeCountLabel.frame.size.width, _likeIndicator.frame.origin.y, ICON_WIDTH, ICON_HEIGHT)] autorelease];
    _commentIndicator.backgroundColor = TRANSPARENT_COLOR;
    _commentIndicator.image = [UIImage imageNamed:@"commentGray.png"];
    [_button addSubview:_commentIndicator];
    
    _commentCountLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                               textColor:[UIColor blackColor]
                                             shadowColor:[UIColor whiteColor]] autorelease];
    _commentCountLabel.font = BOLD_FONT(12);
    _commentCountLabel.text = [NSString stringWithFormat:@"%@", item.commentCount];
    size = [_commentCountLabel.text sizeWithFont:_commentCountLabel.font
                               constrainedToSize:CGSizeMake(200, CGFLOAT_MAX) 
                                   lineBreakMode:NSLineBreakByWordWrapping];
    _commentCountLabel.frame = CGRectMake(_commentIndicator.frame.origin.x + MARGIN + ICON_WIDTH, _commentIndicator.frame.origin.y, size.width, size.height);
    [_button addSubview:_commentCountLabel];
    
    _categoryNameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                               textColor:[UIColor blackColor]
                                             shadowColor:[UIColor whiteColor]] autorelease];
    _categoryNameLabel.font = BOLD_FONT(12);
    _categoryNameLabel.text = item.categoryName;
    size = [_categoryNameLabel.text sizeWithFont:_categoryNameLabel.font
                               constrainedToSize:CGSizeMake(200, CGFLOAT_MAX) 
                                   lineBreakMode:NSLineBreakByWordWrapping];
    _categoryNameLabel.frame = CGRectMake(MARGIN * 2, self.frame.size.height - MARGIN - size.height, size.width, size.height);
    [_button addSubview:_categoryNameLabel];
    
    if (item.hasCoupon.boolValue) {
      _couponIndicator = [[[UIImageView alloc] initWithFrame:CGRectMake(170.0f, 25.0f, COUPON_ICON_SIDE_LENGTH, COUPON_ICON_SIDE_LENGTH)] autorelease];
      _couponIndicator.backgroundColor = TRANSPARENT_COLOR;
      _couponIndicator.image = [UIImage imageNamed:@"hasCoupon.png"];
      [_button addSubview:_couponIndicator];
    }
     */
  }
  return self;
}

#pragma mark - touch event handlers 
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  
  if ([self pointInside:point withEvent:event]) {
    
    if (_target && _showDetailAction) {
      // if use click the callout view, then go to detail view controller
      [_target performSelector:_showDetailAction withObject:self.store];
    }
    
    return self;
  } else {
    return [super hitTest:point withEvent:event];
  }
}

- (void)dealloc {
  
  self.store = nil;
  
  [super dealloc];
}


@end
