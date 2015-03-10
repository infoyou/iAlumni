//
//  UserIconViewController.h
//  iAlumni
//
//  Created by Adam on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWRootViewController.h"
@class AlumniDetail;

@interface UserIconViewController : WXWRootViewController <UIGestureRecognizerDelegate>
{
    UIView *canvasView;
    AlumniDetail *_user;
    
    NSString *_userImageUrl;
    NSString *_userType;
}

- (id)initWithUser:(AlumniDetail *)user;
- (id)initWithMsg:(NSString *)imageUrl userType:(NSString *)userType;

@end
