//
//  AlumniLinkCell.m
//  iAlumni
//
//  Created by Adam on 12-11-28.
//
//

#import "AlumniLinkCell.h"
#import "UIUtils.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "RelationshipLink.h"
#import "WXWLabel.h"
#import "AlumniLinkView.h"

#define AVATAR_RADIUS   30.0f
#define DIAMETER        AVATAR_RADIUS * 2

#define PHOTO_WIDTH     56.0f
#define PHOTO_HEIGHT    58.0f

#define CORNER_RADIUS   6.0f

@implementation AlumniLinkCell

#pragma mark - lifecycle methods
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
     linkListHolder:(id<ECClickableElementDelegate>)linkListHolder
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate
                MOC:(NSManagedObjectContext *)MOC {
  
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];
  if (self) {
    
    _contentBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - MARGIN * 4, 0)] autorelease];
    _contentBackgroundView.backgroundColor = TRANSPARENT_COLOR;
    _contentBackgroundView.layer.cornerRadius = CORNER_RADIUS;
    _contentBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _contentBackgroundView.layer.shadowOpacity = 0.9f;
    _contentBackgroundView.layer.shadowRadius = 1.0f;
    _contentBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
    _contentBackgroundView.layer.masksToBounds = NO;
    [self.contentView addSubview:_contentBackgroundView];
    
    _linkView = [[[AlumniLinkView alloc] initWithFrame:CGRectMake(0, 0, _contentBackgroundView.frame.size.width, 0)
                                                   MOC:MOC
                                imageDisplayerDelegate:imageDisplayerDelegate
                                        linkListHolder:linkListHolder
                                connectTriggerDelegate:connectTriggerDelegate] autorelease];
    _linkView.layer.masksToBounds = YES;
    _linkView.layer.cornerRadius = 6.0f;
    [_contentBackgroundView addSubview:_linkView];
    
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}


#pragma mark - draw cell
- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  
}

- (void)drawCellWithLink:(RelationshipLink *)link cellHeight:(CGFloat)cellHeight {
  
  _contentBackgroundView.frame = CGRectMake(MARGIN * 2, MARGIN * 2,
                                            self.frame.size.width - MARGIN * 4,
                                            cellHeight - MARGIN * 4);
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:_contentBackgroundView.bounds
                                                        cornerRadius:_contentBackgroundView.layer.cornerRadius];
  _contentBackgroundView.layer.shadowPath = shadowPath.CGPath;
  
  _linkView.frame = CGRectMake(0, 0,
                               _contentBackgroundView.frame.size.width,
                               _contentBackgroundView.frame.size.height);
  
  [_linkView drawWithLink:link height:_linkView.frame.size.height];
}


@end
