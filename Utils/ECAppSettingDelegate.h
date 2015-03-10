//
//  ECAppSettingDelegate.h
//  iAlumni
//
//  Created by Adam on 11-12-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ECAppSettingDelegate <NSObject>

@optional
- (void)triggerReloadForLanguageSwitch;
- (void)languageSwitchDone;
- (void)signOut;
- (void)closeSpinView;

@end
