//
//  SplashViewController.m
//  iAlumni
//
//  Created by Adam on 13-2-2.
//
//

#import "SplashViewController.h"
#import "WXWLabel.h"
#import "CommonUtils.h"

#define TIMER_INTERVAL  2.0f

#define BOTTOM_BAR_HEIGHT   55.0f

@interface SplashViewController ()
@property (nonatomic, retain) NSTimer *scrollTimer;
@property (nonatomic, retain) NSArray *notes;
@property (nonatomic, retain) WXWLabel *titleLabel;
@end

@implementation SplashViewController

#pragma mark - lifecycle methods

- (id)init {
  self = [super initWithMOC:nil
                     holder:nil
           backToHomeAction:nil
                 needGoHome:NO];
  if (self) {
    self.notes = [NSArray arrayWithObjects:LocaleStringForKey(NSMottoTitle, nil), LocaleStringForKey(NSHomepageSolganTitle, nil), nil];
  }
  return self;
}

- (void)dealloc {
  
  if (self.scrollTimer != nil) {
    [self.scrollTimer invalidate];
    self.scrollTimer = nil;
  }
  
  self.titleLabel = nil;
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationController.navigationBarHidden = YES;

  UIImage *image = [UIImage imageNamed:@"Default-568h.png"];
  
  UIImageView *startUpImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0.0f,
                                                                                 self.view.frame.size.width,
                                                                                 self.view.frame.size.height)] autorelease];
  startUpImageView.backgroundColor = [UIColor clearColor];
  startUpImageView.image = image;
  
  [self.view addSubview:startUpImageView];
  
  self.titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(0, startUpImageView.frame.size.height,
                                                                self.view.frame.size.width, 0)
                                           textColor:NAVIGATION_BAR_COLOR
                                         shadowColor:TRANSPARENT_COLOR
                                                font:BOLD_FONT(18)] autorelease];
  self.titleLabel.textAlignment = UITextAlignmentCenter;
  
  [startUpImageView addSubview:self.titleLabel];
  
  
  [self triggerAutoScroll];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - scroll display notes

- (void)updateTitle:(NSString *)title {
  [UIView animateWithDuration:0.3f
                   animations:^{
                     
                     CGFloat y = self.view.frame.size.height - BOTTOM_BAR_HEIGHT - self.titleLabel.frame.size.height - MARGIN;
                     self.titleLabel.frame = CGRectMake(0, y, self.titleLabel.frame.size.width,
                                                        self.titleLabel.frame.size.height);
                     
                     self.titleLabel.alpha = 0.0f;
                   }
                   completion:^(BOOL finished) {
                     
                     self.titleLabel.frame = CGRectMake(0, self.view.frame.size.height,
                                                        self.titleLabel.frame.size.width,
                                                        self.titleLabel.frame.size.height);

                     
                     [UIView animateWithDuration:0.3f
                                      animations:^{
                                        self.titleLabel.text = title;
                                        CGSize size = [CommonUtils sizeForText:title font:self.titleLabel.font];
                                        CGFloat y = (BOTTOM_BAR_HEIGHT - size.height)/2.0f + (self.view.frame.size.height - BOTTOM_BAR_HEIGHT);
                                        self.titleLabel.frame = CGRectMake(0, y,
                                                                           self.titleLabel.frame.size.width,
                                                                           size.height);
                                        self.titleLabel.alpha = 1.0f;
                                      }];
                   }];
}

- (void)autoScollShow {
  
  if (_currentIndex >= self.notes.count) {
    _currentIndex = 0;
  }
  
  if (self.notes.count > 0) {
    NSString *title = (NSString *)[self.notes objectAtIndex:_currentIndex];
    if (title.length > 0) {
      [self updateTitle:title];
    }
  }
  
  _currentIndex++;
}

- (void)triggerAutoScroll {
  
  if (self.notes.count == 0) {
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

@end
