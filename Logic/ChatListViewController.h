//
//  ChatListViewController.h
//  iAlumni
//
//  Created by Adam on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "ChatFaceViewController.h"
#import "Chat.h"
#import "UIInputToolbar.h"
#import "ECClickableElementDelegate.h"

@class Alumni;

@interface ChatListViewController : BaseListViewController <UIInputToolbarDelegate, 
UIPopoverControllerDelegate, UIGestureRecognizerDelegate, ECClickableElementDelegate> {
    
    UIInputToolbar *inputToolbar;
    Alumni        *_alumni;
    Chat               *_chart;
    
    BOOL                keyboardWasShown;
    
    NSString    *startChatId;
    NSString    *endChatId;
    
	NSString                   *_phraseString;
    NSMutableString            *_messageString;
    ChatFaceViewController     *_faceViewController;
    
    UIView *promptView;
    UILabel *promptLabel;
    
@private
    BOOL keyboardIsVisible;
}

@property (nonatomic, retain) UIInputToolbar *inputToolbar;
@property (nonatomic, copy) NSString    *startChatId;
@property (nonatomic, copy) NSString    *endChatId;
@property (nonatomic, retain) NSString               *phraseString;
@property (nonatomic, retain) NSMutableString        *messageString;
@property (nonatomic, retain) ChatFaceViewController     *faceViewController;
@property (nonatomic, retain) UIView *promptView;
@property (nonatomic, retain) UILabel *promptLabel;

- (id)initWithMOC:(NSManagedObjectContext *)MOC alumni:(Alumni *)alumni;
- (void)hideKeyboard;
- (void)openProfile:(NSString*)userId userType:(NSString*)userType;

@end
