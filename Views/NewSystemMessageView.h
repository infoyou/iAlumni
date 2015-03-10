//
//  NewSystemMessageView.h
//  iAlumni
//
//  Created by Adam on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h> 
#import <CoreData/CoreData.h>

@class ShakeMessageIcon;
@class WXWLabel;

@interface NewSystemMessageView : UIView <AVAudioPlayerDelegate> {
  @private
  ShakeMessageIcon *_messageIcon;
  WXWLabel *_title;
  UIView *_boardView;
  AVAudioPlayer *_audioPlayer;
  UINavigationController *_parentNavVC;
  NSManagedObjectContext *_MOC;
}

- (id)initWithParentNavVC:(UINavigationController *)parentNavVC 
                      MOC:(NSManagedObjectContext *)MOC
                    frame:(CGRect)frame;

#pragma mark - set title
- (void)adjustTitleForLanguageSwitch;

#pragma mark - update icon
- (void)updateIcon:(NSInteger)count newUnreadMessageReceived:(BOOL)newUnreadMessageReceived;

@end

