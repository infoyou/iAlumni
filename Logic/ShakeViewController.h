//
//  ShakeViewController.h
//  iAlumni
//
//  Created by Adam on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWRootViewController.h"
@class Shake;

@interface ShakeViewController : WXWRootViewController <UIGestureRecognizerDelegate, UIAccelerometerDelegate>
{
  Shake *_shake;
  UIImageView    *imageView;
  SystemSoundID   shakeSoundID;
  SystemSoundID   shakeEndID;
  
  UIImage        *shakeStartImg;
  UIImage        *shakeEndImg;
  
  long long _eventId;
  
  BOOL            _isShakeImg;
  BOOL            isRun;
  BOOL            isShakeAction;
  BOOL            _processing;
  
  BOOL histeresisExcited;
  UIAcceleration* lastAcceleration;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImage *shakeStartImg;
@property (nonatomic, retain) UIImage *shakeEndImg;

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

- (id)initWithMOC:(NSManagedObjectContext *)MOC eventId:(long long)eventId;

- (void)loadData;
- (void)initResource;

@end
