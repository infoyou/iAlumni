//
//  UserProfileHeaderView.m
//  iAlumni
//
//  Created by Adam on 12-9-24.
//
//

#import "UserProfileHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "AppManager.h"
#import "WXWImageCache.h"
#import "CommonUtils.h"
#import "WXWLabel.h"
#import "UIImageButton.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "ECPlainButton.h"


#define CAMERA_SIDE_LENGTH  24.0f

#define BUTTON_WIDTH        100.0f
#define BUTTON_HEIGHT       30.0f

@implementation UserProfileHeaderView

#pragma mark - show big picture
- (void)showBigPicture:(id)sender {
    
    if (_clickableElementDelegate && [AppManager instance].userImgUrl) {
        [_clickableElementDelegate showBigPhoto:[AppManager instance].userImgUrl];
    }
}


#pragma mark - lifecycle methods
- (void)initViews {
    
    _avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _avatarButton.backgroundColor = [UIColor whiteColor];
    _avatarButton.frame = CGRectMake(MARGIN * 2,
                                     MARGIN * 2,
                                     USERDETAIL_PHOTO_WIDTH,
                                     USERDETAIL_PHOTO_HEIGHT);
    [_avatarButton addTarget:_target action:_action forControlEvents:UIControlEventTouchUpInside];
    [_avatarButton setImage:[CommonUtils cutPartImage:[UIImage imageNamed:@"uploadAvatarPhoto.png"]
                                                width:USERDETAIL_PHOTO_WIDTH
                                               height:USERDETAIL_PHOTO_HEIGHT]
                   forState:UIControlStateNormal];
    [self addSubview:_avatarButton];
    
    UIImageView *cameraIcon = [[[UIImageView alloc] initWithImage:IMAGE_WITH_NAME(@"whiteTakePhoto.png")] autorelease];
    cameraIcon.frame = CGRectMake(MARGIN,
                                  _avatarButton.frame.size.height - cameraIcon.frame.size.height - MARGIN,
                                  cameraIcon.frame.size.width, cameraIcon.frame.size.height);
    [_avatarButton addSubview:cameraIcon];
    
    UIImageView *arrow = [[[UIImageView alloc] initWithImage:IMAGE_WITH_NAME(@"blueRightArrow.png")] autorelease];
    CGFloat offset = 0;
    if (CURRENT_OS_VERSION >= IOS7) {
        offset = 16;
    } else {
        offset = 20;
    }
    arrow.frame = CGRectMake(self.frame.size.width - arrow.frame.size.width - offset,
                             (self.frame.size.height - arrow.frame.size.height)/2.0f,
                             arrow.frame.size.width, arrow.frame.size.height);
    [self addSubview:arrow];
    
    _nameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                        textColor:DARK_TEXT_COLOR
                                      shadowColor:[UIColor whiteColor]] autorelease];
    _nameLabel.font = BOLD_FONT(18);
    _nameLabel.numberOfLines = 0;
    _nameLabel.text = [AppManager instance].userName;
    CGSize size = [CommonUtils sizeForText:_nameLabel.text
                                      font:_nameLabel.font
                         constrainedToSize:CGSizeMake(arrow.frame.origin.x - MARGIN * 4 - USERDETAIL_PHOTO_WIDTH - MARGIN * 2, _avatarButton.frame.size.height)
                             lineBreakMode:BREAK_BY_WORD_WRAPPING];
    _nameLabel.frame = CGRectMake(_avatarButton.frame.origin.x +
                                  _avatarButton.frame.size.width + MARGIN * 2,
                                  (self.frame.size.height - size.height)/2.0f, size.width, size.height);
    [self addSubview:_nameLabel];
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
             target:(id)target
             action:(SEL)action {
    self = [super initWithFrame:frame];
    if (self) {
        
        _target = target;
        
        _action = action;
        
        self.backgroundColor = TRANSPARENT_COLOR;
        
        _imageDisplayerDelegate = imageDisplayerDelegate;
        
        _clickableElementDelegate = clickableElementDelegate;
        
        [self initViews];
        
        if (_imageDisplayerDelegate) {
            [_imageDisplayerDelegate registerImageUrl:[AppManager instance].userImgUrl];
        }
        
        [[WXWImageManager instance] fetchImage:[AppManager instance].userImgUrl
                                        caller:self
                                      forceNew:NO];
    }
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

#pragma mark - update avatar
- (void)updateAvatar:(UIImage *)avatar {
    CATransition *imageFadein = [CATransition animation];
    imageFadein.duration = FADE_IN_DURATION;
    imageFadein.type = kCATransitionFade;
    
    [_avatarButton.layer addAnimation:imageFadein forKey:nil];
    
    [_avatarButton setImage:[CommonUtils cutPartImage:avatar
                                                width:USERDETAIL_PHOTO_WIDTH
                                               height:USERDETAIL_PHOTO_HEIGHT]
                   forState:UIControlStateNormal];
}

- (void)refreshModifyButtonTitle {
    
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
    
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
    
    [self updateAvatar:image];
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
    
    [_avatarButton setImage:[CommonUtils cutPartImage:image
                                                width:USERDETAIL_PHOTO_WIDTH
                                               height:USERDETAIL_PHOTO_HEIGHT]
                   forState:UIControlStateNormal];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
}


@end
