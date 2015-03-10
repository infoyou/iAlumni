//
//  ShakeEntranceViewController.m
//  iAlumni
//
//  Created by Adam on 12-12-1.
//
//

#import "ShakeEntranceViewController.h"
#import "AppManager.h"
#import "CommonUtils.h"
#import "UIUtils.h"

static BOOL checkShakeing(UIAcceleration* last, UIAcceleration* current, double threshold) {
  double
  deltaX = fabs(last.x - current.x),
  deltaY = fabs(last.y - current.y),
  deltaZ = fabs(last.z - current.z);
  
  /*
  return
  (deltaX > threshold && deltaY > threshold) ||
  (deltaX > threshold && deltaZ > threshold) ||
  (deltaY > threshold && deltaZ > threshold);
   */
  return
  (deltaX > threshold) ||
  (deltaY > threshold) ||
  (deltaZ > threshold);
}

@interface ShakeEntranceViewController ()
@property (nonatomic, retain) UIAcceleration* lastAcceleration;
@end

@implementation ShakeEntranceViewController

#pragma mark - begin locating
- (void)triggerProcessing
{
  
  if (![IPHONE_SIMULATOR isEqualToString:[CommonUtils deviceModel]]) {
    [AppManager instance].latitude = 0.0;
    [AppManager instance].longitude = 0.0;
    
    [UIUtils showActivityView:self.view
                         text:LocaleStringForKey(NSLocatingMsg, nil)];
    
    [self getCurrentLocationInfoIfNecessary];
  } else {
    [AppManager instance].latitude = [SIMULATION_LATITUDE doubleValue];
    [AppManager instance].longitude = [SIMULATION_LONGITUDE doubleValue];
  }
}

#pragma mark - prepare Condition

- (void)prepareSoundResource {
  
  // Sound
  NSString *shakePath = [[NSBundle mainBundle] pathForResource:@"shake"
                                                        ofType:@"wav"];
  AudioServicesCreateSystemSoundID((CFURLRef)[NSURL
                                              fileURLWithPath:shakePath], &_shakeSoundID);
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
{
  self = [super initWithMOC:MOC
                     holder:nil
           backToHomeAction:nil
                 needGoHome:NO];
  if (self) {
    
  }
  return self;
}

- (void)dealloc {
  
  self.lastAcceleration = nil;
  
  [UIAccelerometer sharedAccelerometer].delegate = nil;
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self prepareSoundResource];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.lastAcceleration = nil;
}

- (void)viewDidAppear:(BOOL)animated {
  
  [UIAccelerometer sharedAccelerometer].delegate = self;
  
  [super viewDidAppear:animated];
  
  [self becomeFirstResponder];  
}

- (void)viewWillDisappear:(BOOL)animated {
  
  [self resignFirstResponder];
  
  [super viewWillDisappear:animated];
  
  _shaking = NO;
  
  [UIAccelerometer sharedAccelerometer].delegate = nil;
}

- (void)setShakeDelegate {
  _shaking = YES;
  [UIAccelerometer sharedAccelerometer].delegate = self;
  
  [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
  return YES;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - UIAccelerometerDelegate methods

- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration {
  
  if (self.lastAcceleration) {
    
    if (!_processing) {
      if (checkShakeing(self.lastAcceleration, acceleration, 0.8)) {
        // SHAKE DETECTED. DO HERE WHAT YOU WANT.
        AudioServicesPlaySystemSound(_shakeSoundID);
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        _processing = YES;

        [self triggerProcessing];
      }
    }
  }
  
  self.lastAcceleration = acceleration;
}
 

#pragma mark - ECLocationFetcherDelegate methods

- (void)locationManagerDidReceiveLocation:(WXWLocationManager *)manager
                                 location:(CLLocation *)location {
  
  [super locationManagerDidReceiveLocation:manager
                                  location:location];
  
  [UIUtils closeAsyncLoadingView];
}

- (void)locationManagerDidFail:(WXWLocationManager *)manager {
  [super locationManagerDidFail:manager];
  
  _processing = NO;
  
  [UIUtils closeAsyncLoadingView];
}

- (void)locationManagerCancelled:(WXWLocationManager *)manager {
  [super locationManagerCancelled:manager];

  _processing = NO;
  
  [UIUtils closeActivityView];
}


@end
