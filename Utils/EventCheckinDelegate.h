//
//  EventCheckinDelegate.h
//  iAlumni
//
//  Created by Adam on 12-8-28.
//
//

#import <Foundation/Foundation.h>

@protocol EventCheckinDelegate <NSObject>

@optional
- (void)setCheckinResultType:(CheckinResultType)type;
//- (void)setCheckinNumber:(long long)number;

- (void)quickCheck;

@end
