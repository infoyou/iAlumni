//
//  EventVoteDelegate.h
//  iAlumni
//
//  Created by Adam on 12-9-10.
//
//

#import <Foundation/Foundation.h>

@protocol EventVoteDelegate <NSObject>

@optional
- (void)refreshVoteOptions;

@end
