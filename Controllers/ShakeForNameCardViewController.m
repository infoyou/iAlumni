//
//  ShakeForNameCardViewController.m
//  iAlumni
//
//  Created by Adam on 12-12-6.
//
//

#import "ShakeForNameCardViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "NameCardCandidatesViewController.h"


#define ICON_SIDE_LENGTH   80.0f
#define ICON_Y             100.0f

@interface ShakeForNameCardViewController ()

@end

@implementation ShakeForNameCardViewController

#pragma mark - animate shake icon
- (void)arrangeViews {
  _leftIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shakeNameCardLeft.png"]] autorelease];
  _leftIcon.backgroundColor = TRANSPARENT_COLOR;
  _leftIcon.frame = CGRectMake(self.view.frame.size.width/2.0f - MARGIN * 2 - ICON_SIDE_LENGTH,
                              ICON_Y, ICON_SIDE_LENGTH, ICON_SIDE_LENGTH);
  [self.view addSubview:_leftIcon];

  _rightIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shakeNameCardRight.png"]] autorelease];
  _rightIcon.backgroundColor = TRANSPARENT_COLOR;
  _rightIcon.frame = CGRectMake(self.view.frame.size.width/2.0f + MARGIN * 2,
                               ICON_Y, ICON_SIDE_LENGTH, ICON_SIDE_LENGTH);
  [self.view addSubview:_rightIcon];

  WXWLabel *titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                              textColor:COLOR(162, 162, 162)
                                            shadowColor:TRANSPARENT_COLOR] autorelease];
  titleLabel.font = BOLD_FONT(19);
  titleLabel.backgroundColor = TRANSPARENT_COLOR;
  titleLabel.numberOfLines = 0;
  titleLabel.textAlignment = UITextAlignmentCenter;
  titleLabel.text = LocaleStringForKey(NSShakeNameCardInfoMsg, nil);
  
  CGSize size = [titleLabel.text sizeWithFont:titleLabel.font
                            constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 6, CGFLOAT_MAX)
                                lineBreakMode:NSLineBreakByWordWrapping];
  titleLabel.frame = CGRectMake((self.view.frame.size.width - size.width)/2.0f,
                                _rightIcon.frame.origin.y + _rightIcon.frame.size.height + MARGIN * 2,
                                size.width, size.height);
  [self.view addSubview:titleLabel];
}

#pragma mark - lifecycle methods
- (void)dealloc {
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.hidesBackButton = YES;

  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shakeBg.png"]];
  
  [self arrangeViews];
  
}

- (void)arrangeAnimation {
  _leftIcon.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(0));
  [UIView animateWithDuration:0.5f
                        delay:0.0f
                      options:(UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction)
                   animations:^{
                     
                     _leftIcon.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-30));
                     
                   } completion:^(BOOL finished){
                   }];
  
  _rightIcon.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(0));
  [UIView animateWithDuration:0.5f
                        delay:0.0f
                      options:(UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction)
                   animations:^{
                     
                     _rightIcon.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(30));
                     
                   } completion:^(BOOL finished){
                   }];
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self arrangeAnimation];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (BOOL)canBecomeFirstResponder {
  return YES;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - ECLocationFetcherDelegate methods

- (void)locationManagerDidReceiveLocation:(WXWLocationManager *)manager
                                 location:(CLLocation *)location {
  
  [super locationManagerDidReceiveLocation:manager
                                  location:location];
  
  _processing = NO;
  
  NameCardCandidatesViewController *nameCardListVC = [[[NameCardCandidatesViewController alloc] initWithMOC:_MOC] autorelease];
  nameCardListVC.title = LocaleStringForKey(NSExchangeNameCardTitle, nil);
  [self.navigationController pushViewController:nameCardListVC animated:YES];
}
@end
