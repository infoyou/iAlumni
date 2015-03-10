//
//  TagsOmissionView.m
//  iAlumni
//
//  Created by Adam on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TagsOmissionView.h"
#import "Tag.h"
#import "WXWLabel.h"
#import "CoreDataUtils.h"

#define ICON_SIDE_LENGTH 16.0f
#define POSTLIST_PHOTO_WIDTH			51.0f

@implementation TagsOmissionView

@synthesize nameLabel = _nameLabel;

- (id)initWithFrame:(CGRect)frame MOC:(NSManagedObjectContext *)MOC {
  self = [super initWithFrame:frame];
  if (self) {
    
    _MOC = MOC;
    
    _icon = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    _icon.backgroundColor = TRANSPARENT_COLOR;
    _icon.image = [UIImage imageNamed:@"tag.png"];
    [self addSubview:_icon];
    
    self.nameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:BASE_INFO_COLOR
                                         shadowColor:[UIColor whiteColor]] autorelease];
    self.nameLabel.backgroundColor = TRANSPARENT_COLOR;
    self.nameLabel.font = FONT(11);
    self.nameLabel.numberOfLines = 1;
    [self addSubview:self.nameLabel];
  }
  return self;
}

- (void)dealloc {
  
  self.nameLabel = nil;
  
  [super dealloc];
}

- (void)arrangeViews:(NSString *)names {
  
  _icon.frame = CGRectMake(0,
                           (self.frame.size.height - ICON_SIDE_LENGTH)/2.0f,
                           ICON_SIDE_LENGTH,
                           ICON_SIDE_LENGTH);
  
  self.nameLabel.text = names;
  CGSize size = [names sizeWithFont:self.nameLabel.font
                  constrainedToSize:CGSizeMake(self.frame.size.width - (_icon.frame.origin.x + MARGIN + MARGIN * 2), CGFLOAT_MAX)
                      lineBreakMode:NSLineBreakByTruncatingTail];
  self.nameLabel.frame = CGRectMake(_icon.frame.origin.x + ICON_SIDE_LENGTH + MARGIN,
                                    (self.frame.size.height - size.height)/2.0f,
                                    size.width, size.height);
}

@end
