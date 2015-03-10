//
//  NewSystemMessageView.m
//  iAlumni
//
//  Created by Adam on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NewSystemMessageView.h"
#import <QuartzCore/QuartzCore.h>
#import "GlobalConstants.h"
#import "ShakeMessageIcon.h"
#import "MessageListViewController.h"
#import "CommonUtils.h"
#import "WXWNavigationController.h"
#import "TextConstants.h"
#import "WXWLabel.h"
#import "AppManager.h"

#define ICON_ZH_X         0.0f
#define ICON_EN_X         20.0f
#define ICON_Y            2.0f
#define ICON_WIDTH        31.0f
#define ICON_HEIGHT       24.0f

#define TITLE_ZH_X        30.0f
#define TITLE_EN_X        52.0f
#define TITLE_Y           4.0f
#define TITLE_ZH_WIDTH    80.0f
#define TITLE_EN_WIDTH    80.0f
#define TITLE_HEIGHT      20.0f

#define BOARDVIEW_ZH_X    120.0f
#define BOARDVIEW_EN_X    79.0f

@interface NewSystemMessageView()
@property (nonatomic, retain) ShakeMessageIcon *messageIcon;
@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UIView *boardView;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@end

@implementation NewSystemMessageView

@synthesize messageIcon = _messageIcon;
@synthesize title = _title;
@synthesize boardView = _boardView;
@synthesize audioPlayer = _audioPlayer;

#pragma mark - lifecycle methods
- (id)initWithParentNavVC:(UINavigationController *)parentNavVC 
                      MOC:(NSManagedObjectContext *)MOC 
                    frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.boardView];
        
        _parentNavVC = parentNavVC;
        
        _MOC = MOC;
        
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        [gradientLayer setBounds:self.bounds];
        [gradientLayer setPosition:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
        
        [gradientLayer setColors:@[(id)COLOR(52, 57, 60).CGColor,(id)COLOR(36, 40, 42).CGColor]];
        [self.layer insertSublayer:gradientLayer atIndex:0];
        RELEASE_OBJ(gradientLayer);
    }
    return self;
}

- (void)dealloc {
    self.messageIcon = nil;
    self.title = nil;
    self.boardView = nil;
    self.audioPlayer = nil;
    [super dealloc];
}

#pragma mark - properties

- (AVAudioPlayer *)audioPlayer {
    if (nil == _audioPlayer) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"newMessageRing" ofType:@"mp3"];
        NSURL *fileUrl = [NSURL fileURLWithPath:path isDirectory:NO];
        
        NSError *error;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:&error];
        _audioPlayer.delegate = self;
    }
    return _audioPlayer;
}

- (void)arrangeBoardViewFrame {
    CGFloat x = 0;
    switch ([WXWCommonUtils currentLanguage]) {
        case EN_TY:
            x = BOARDVIEW_EN_X;
            break;
            
        case ZH_HANS_TY:
            x = BOARDVIEW_ZH_X;
            break;
        default:
            break;
    }
    
    _boardView.frame = CGRectMake(x, 5, 110, 30);
}

- (UIView *)boardView {
    if (nil == _boardView) {
        _boardView = [[UIView alloc] init];
        _boardView.backgroundColor = TRANSPARENT_COLOR;
        [_boardView addSubview:self.messageIcon];
        [_boardView addSubview:self.title];
    }
    
    [self arrangeBoardViewFrame];
    return _boardView;
}

- (void)arrangeIconFrame {
    CGFloat x = 0;
    switch ([WXWCommonUtils currentLanguage]) {
        case EN_TY:
            x = ICON_EN_X;
            break;
            
        case ZH_HANS_TY:
            x = ICON_ZH_X;
            break;
        default:
            break;
    }
    
    _messageIcon.frame = CGRectMake(x, ICON_Y, ICON_WIDTH, ICON_HEIGHT);
}

- (UIImageView *)messageIcon {
    if (nil == _messageIcon) {
        _messageIcon = [[ShakeMessageIcon alloc] init];
        
        _messageIcon.backgroundColor = TRANSPARENT_COLOR;
    }
    
    [self arrangeIconFrame];
    
    return _messageIcon;
}

- (void)arrangeTitleFrame {
    
    CGFloat x = 0;
    
    switch ([WXWCommonUtils currentLanguage]) {
        case EN_TY:
            x = TITLE_EN_X;        
            break;
            
        case ZH_HANS_TY:
            x = TITLE_ZH_X;
            break;
        default:
            break;
    }
    
    CGSize size = [_title.text sizeWithFont:_title.font
                          constrainedToSize:CGSizeMake(200, TITLE_HEIGHT) 
                              lineBreakMode:NSLineBreakByWordWrapping];
    _title.frame = CGRectMake(x, TITLE_Y, size.width, TITLE_HEIGHT);
    
}

- (UILabel *)title {
    if (nil == _title) {
        
        
        _title = [[WXWLabel alloc] initWithFrame:CGRectZero 
                                      textColor:COLOR(97, 98, 100) 
                                    shadowColor:[UIColor lightGrayColor]];
        _title.text = LocaleStringForKey(NSMessageTitle, nil);
        _title.font = FONT(14);
        _title.backgroundColor = TRANSPARENT_COLOR;
        
        [self arrangeTitleFrame];
    }
    return _title;
}

#pragma mark - touch event
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    MessageListViewController *listVC = [[MessageListViewController alloc] initWithMOC:_MOC 
                                                                                holder:nil 
                                                                      backToHomeAction:nil
                                                                          messageTypes:nil];
    WXWNavigationController *nav = [[WXWNavigationController alloc] initWithRootViewController:listVC];
    listVC.title = LocaleStringForKey(NSMessageTitle, nil);
    [_parentNavVC presentModalViewController:nav animated:YES];
    RELEASE_OBJ(listVC);
    RELEASE_OBJ(nav);  
}

#pragma mark - AVAudioPlayerDelegate methods
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    //self.audioPlayer = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    //self.audioPlayer = nil;
}

#pragma mark - update icon
- (void)shakeIcon {
    [self.messageIcon shake];
}

- (void)notifyUser {
    //[self.audioPlayer play];
    
    [self performSelector:@selector(shakeIcon) withObject:nil afterDelay:1.0f];
}

- (void)updateIcon:(NSInteger)count newUnreadMessageReceived:(BOOL)newUnreadMessageReceived {
    if (count == 0) {
        self.messageIcon.image = [UIImage imageNamed:@"message.png"];
    } else if (count < 10){
        self.messageIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"message_%d.png", count]];
    } else {
        self.messageIcon.image = [UIImage imageNamed:@"message_more.png"];
    }
    if (newUnreadMessageReceived) {
        [self performSelector:@selector(notifyUser) withObject:nil afterDelay:0.1f];
    }
}

#pragma mark - set title
- (void)adjustTitleForLanguageSwitch {
    [self arrangeBoardViewFrame];
    [self arrangeIconFrame];
    
    _title.text = LocaleStringForKey(NSMessageTitle, nil);
    [self arrangeTitleFrame];
}

@end

