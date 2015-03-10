//
//  AlumniExampleCell.m
//  iAlumni
//
//  Created by Adam on 13-1-16.
//
//

#import "AlumniExampleCell.h"
#import "AlumniExampleWallView.h"

#define EXAMPLE_AREA_35INCH_HEIGHT   150.0f
#define EXAMPLE_AREA_40INCH_HEIGHT   238.0f


@implementation AlumniExampleCell

#pragma mark - lifecycle methods

- (void)addExampleAreaView {
  CGFloat height = EXAMPLE_AREA_35INCH_HEIGHT;
  
  CGRect frame = CGRectMake(MARGIN * 2, MARGIN * 2, self.frame.size.width - MARGIN * 4,
                            height);
  
  _wallView = [[[AlumniExampleWallView alloc] initWithFrame:frame
                                     imageDisplayerDelegate:_imageDisplayerDelegate
                                     connectTriggerDelegate:_connectionTriggerHolderDelegate
                                                        MOC:_MOC
                                                   entrance:_entrance
                                                     action:_action] autorelease];

  [self.contentView addSubview:_wallView];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate
                MOC:(NSManagedObjectContext *)MOC
           entrance:(id)entrance
             action:(SEL)action {
  
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
connectionTriggerHolderDelegate:connectionTriggerHolderDelegate
                          MOC:MOC];
  if (self) {
    
    _entrance = entrance;
    
    _action = action;
    
    [self addExampleAreaView];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - timer controller
- (void)play {
  [_wallView play];
}

- (void)stopPlay {
  [_wallView stopPlay];
}


@end
