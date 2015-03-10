//
//  DirectionMPMoviePlayer.m
//  iAlumni
//
//  Created by Adam on 13-1-1.
//
//

#import "DirectionMPMoviePlayer.h"

@implementation DirectionMPMoviePlayer

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIDeviceOrientationIsLandscape(interfaceOrientation);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0

- (BOOL)shouldAutorotate
{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

#endif

- (void)dealloc
{
    
    [super dealloc];
}

@end

