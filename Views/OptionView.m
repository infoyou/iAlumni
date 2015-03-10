//
//  OptionView.m
//  iAlumni
//
//  Created by Adam on 12-9-10.
//
//

#import "OptionView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Option.h"
#import "CoreDataUtils.h"

#define SHADOW_BORDER_MARGIN  2.0f

#define ICON_SIDE_LENGTH      24.0f

@interface OptionView()
@property (nonatomic, retain) Option *option;
@end

@implementation OptionView

@synthesize option = _option;

- (id)initWithFrame:(CGRect)frame          
                MOC:(NSManagedObjectContext *)MOC
           delegate:(id<EventVoteDelegate>)delegate {
  self = [super initWithFrame:frame];
  if (self) {
    
    _delegate = delegate;
    
    _MOC = MOC;
    
    _contentLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                          textColor:[UIColor whiteColor]
                                        shadowColor:TRANSPARENT_COLOR] autorelease];
    _contentLabel.font = BOLD_FONT(13);
    _contentLabel.numberOfLines = 0;
    [self addSubview:_contentLabel];
    
  }
  return self;
}

- (void)dealloc {
  
  self.option = nil;
  
  [super dealloc];
}

- (void)addShadow {
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(SHADOW_BORDER_MARGIN, SHADOW_BORDER_MARGIN * 2,
                                                                         self.frame.size.width - SHADOW_BORDER_MARGIN * 2,
                                                                         self.frame.size.height - SHADOW_BORDER_MARGIN * 2)];
  self.layer.shadowPath = shadowPath.CGPath;
  self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  self.layer.shadowOpacity = 0.9f;
  self.layer.shadowRadius = 1.0f;
  self.layer.shadowOffset = CGSizeMake(0, 0);
  self.layer.masksToBounds = NO;
}

- (void)drawViewWithFrame:(CGRect)frame option:(Option *)option color:(UIColor*)color {
  
  self.option = option;
  
  self.backgroundColor = color;
  
  self.frame = frame;
  
  _contentLabel.text = option.content;
  CGSize size = [option.content sizeWithFont:_contentLabel.font
                           constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
  _contentLabel.frame = CGRectMake(MARGIN * 2,
                                   (self.frame.size.height - size.height)/2.0f,
                                   size.width, size.height);
  
  [self addShadow];
  
  if (nil == _selectedIcon) {
    _selectedIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected.png"]] autorelease];
    _selectedIcon.hidden = YES;
    _selectedIcon.backgroundColor = TRANSPARENT_COLOR;
    _selectedIcon.frame = CGRectMake(self.frame.size.width - MARGIN - ICON_SIDE_LENGTH,
                                     MARGIN, ICON_SIDE_LENGTH, ICON_SIDE_LENGTH);
    [self addSubview:_selectedIcon];
  }
  
  _selectedIcon.hidden = (option.selected.boolValue ? NO : YES);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  if (self.option.selected.boolValue) {
    _selectedIcon.hidden = NO;
  } else {
    _selectedIcon.hidden = YES;
  }
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(topicId == %@)", self.option.topicId];
  NSArray *options = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                             entityName:@"Option"
                                              predicate:predicate];
  
  for (Option *option in options) {
    if (option.optionId.longLongValue == self.option.optionId.longLongValue) {
      option.selected = [NSNumber numberWithBool:!option.selected.boolValue];
    } else {
      option.selected = @NO;
    }
  }
  
  SAVE_MOC(_MOC);
  
  if (_delegate) {
    [_delegate refreshVoteOptions];
  }
}

@end
