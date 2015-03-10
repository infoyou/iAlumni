//
//  ScrollAutoPlayerDelegate.h
//  iAlumni
//
//  Created by Adam on 13-1-25.
//
//

#import <Foundation/Foundation.h>

@protocol ScrollAutoPlayerDelegate <NSObject>

@required
- (void)play;
- (void)stopPlay;

@end
