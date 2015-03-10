//
//  SloganView.m
//  iAlumni
//
//  Created by Adam on 13-11-13.
//
//

#import "SloganView.h"
#import "WXWLabel.h"
#import "CommonUtils.h"
#import "Slogan.h"

#define TIMER_INTERVAL  5.0f

@interface SloganView ()
@property (nonatomic, retain) NSArray *slogans;
@property (nonatomic, retain) NSTimer *scrollTimer;
@end

@implementation SloganView

- (id)initWithFrame:(CGRect)frame MOC:(NSManagedObjectContext *)MOC
{
  self = [super initWithFrame:frame];
  if (self) {
    
    _MOC = MOC;
    
    _sloganLabel = [[[WXWLabel alloc] initWithFrame:self.bounds
                                          textColor:DARK_TEXT_COLOR
                                        shadowColor:TRANSPARENT_COLOR
                                               font:BOLD_FONT(20)] autorelease];
    _sloganLabel.textAlignment = UITextAlignmentCenter;
    _sloganLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    [self addSubview:_sloganLabel];
    
  }
  return self;
}

- (void)dealloc {
  
  self.slogans = nil;
  
  if (self.scrollTimer != nil) {
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
  }
  
  [super dealloc];
}

#pragma mark - arrange auto scroll
- (void)triggerAutoScroll {
  
  self.slogans = [WXWCoreDataUtils fetchObjectsFromMOC:_MOC
                                            entityName:@"Slogan"
                                             predicate:nil];
  
  if (self.slogans.count == 0) {
    return;
  }
  
  _currentIndex = 0;
  
  self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                      target:self
                                                    selector:@selector(autoScollShow)
                                                    userInfo:nil
                                                     repeats:YES];
  [self.scrollTimer fire];
  
}

- (void)autoScollShow {
  
  if (_currentIndex >= self.slogans.count) {
    _currentIndex = 0;
  }
  
  if (self.slogans.count > 0) {
    Slogan *slogan = (Slogan *)[self.slogans objectAtIndex:_currentIndex];
    if (slogan.content.length > 0) {
      [self updateTitle:slogan.content];
    }
  }
  
  _currentIndex++;
}

- (void)updateTitle:(NSString *)title {
  [UIView animateWithDuration:0.3f
                   animations:^{
                     
                     CGFloat y = 0 - _sloganLabel.frame.size.height;
                     _sloganLabel.frame = CGRectMake(0, y, _sloganLabel.frame.size.width,
                                                     _sloganLabel.frame.size.height);
                     
                     _sloganLabel.alpha = 0.0f;
                   }
                   completion:^(BOOL finished) {
                     
                     _sloganLabel.frame = CGRectMake(0, self.frame.size.height,
                                                     _sloganLabel.frame.size.width,
                                                     _sloganLabel.frame.size.height);
                     
                     [UIView animateWithDuration:0.3f
                                      animations:^{
                                        _sloganLabel.text = title;
                                        CGSize size = [CommonUtils sizeForText:title font:_sloganLabel.font];
                                        
                                        _sloganLabel.frame = CGRectMake(0, (self.frame.size.height - size.height)/2.0f,
                                                                        _sloganLabel.frame.size.width,
                                                                        size.height);
                                        _sloganLabel.alpha = 1.0f;
                                      }];
                   }];
}


@end
