//
//  EventActionDelegate.h
//  iAlumni
//
//  Created by Adam on 12-9-8.
//
//

#import <Foundation/Foundation.h>

@protocol EventActionDelegate <NSObject>

@optional
- (void)goSponsor;
- (void)goLocation;
- (void)goContracts;
- (void)goSignUpList;
- (void)goCheckInList;
- (void)addCalendar;
- (void)doSignUp;

- (void)voteAction;
- (void)awardAction;
- (void)discussAction;
- (void)moreAction;

- (void)showBigPhoto:(NSString *)url;

- (void)showBigPhotoWithUrl:(NSString *)url imageFrame:(CGRect)imageFrame;

- (void)signUp;
- (void)checkin;
- (void)vote;

@end
