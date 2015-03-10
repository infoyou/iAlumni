//
//  ItemProfileHeaderView.m
//  ExpatCircle
//
//  Created by Adam on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ItemProfileHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "Member.h"
#import "WXWLabel.h"
#import "ECGradientButton.h"
#import "AppManager.h"
#import "TextConstants.h"
#import "UIUtils.h"
#import "CommonUtils.h"

#define EDIT_BTN_WIDTH      70.0f
#define BUTTON_SIDE_LENGTH  70.0f

#define IMG_EDGE            UIEdgeInsetsMake(30.0, 55.0, 5.0, 5.0)  
#define TITLE_EDGE          UIEdgeInsetsMake(33.0, -7.0, 5.0, 12.0)

@implementation ItemProfileHeaderView

//@synthesize member = _member;
@synthesize userPhoto = _userPhoto;

#pragma mark - user actions

- (void)showBigPicture:(id)sender {
  
  if (_clickableElementDelegate && _member.bigPhotoUrl && _member.bigPhotoUrl.length > 0) {
    [_clickableElementDelegate showBigPhoto:_member.bigPhotoUrl];
  }
}

- (void)browseFeeds:(id)sender {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate browseSentFeeds];
  }
}

- (void)browseSentAnswers:(id)sender {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate browseSentAnswers];
  }
}

- (void)browseFavoritedItems:(id)sender {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate browseFavoriteItems];
  }

}

- (void)browsePoints:(id)sender {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate browsePoints];
  }
}

#pragma mark - lifecycle methods

- (void)initButtons {
  
}

- (void)initProfileBaseInfo {
  
  _authorPicBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2, 
                                                                      MARGIN * 2, 
                                                                      PHOTO_SIDE_LENGTH, 
                                                                      PHOTO_SIDE_LENGTH)];
  
  _authorPicBackgroundView.backgroundColor = TRANSPARENT_COLOR;
  UIBezierPath *shadowPath = [UIBezierPath bezierPath];
  [shadowPath moveToPoint:CGPointMake(2, 2)];
  [shadowPath addLineToPoint:CGPointMake(PHOTO_SIDE_LENGTH + 1, 2)];
  [shadowPath addLineToPoint:CGPointMake(PHOTO_SIDE_LENGTH + 1, PHOTO_SIDE_LENGTH + 1)];
  [shadowPath addLineToPoint:CGPointMake(2, PHOTO_SIDE_LENGTH + 1)];
  [shadowPath addLineToPoint:CGPointMake(2, 2)];
  _authorPicBackgroundView.layer.shadowPath = shadowPath.CGPath;
  _authorPicBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  _authorPicBackgroundView.layer.shadowOpacity = 0.9f;
  _authorPicBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
  _authorPicBackgroundView.layer.masksToBounds = NO;
  [self addSubview:_authorPicBackgroundView];
  
  _authorPicButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _authorPicButton.backgroundColor = [UIColor whiteColor];
  _authorPicButton.frame = CGRectMake(0, 0, PHOTO_SIDE_LENGTH, PHOTO_SIDE_LENGTH);
  _authorPicButton.layer.cornerRadius = 6.0f;
  _authorPicButton.layer.masksToBounds = YES;
  _authorPicButton.showsTouchWhenHighlighted = YES;
  [_authorPicButton addTarget:self action:@selector(showBigPicture:) forControlEvents:UIControlEventTouchUpInside];
  [_authorPicBackgroundView addSubview:_authorPicButton];
  _userNameLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(_authorPicBackgroundView.frame.origin.x + PHOTO_SIDE_LENGTH + MARGIN * 2, 
                                                             MARGIN * 2, 0, 20)
                                        textColor:[UIColor blackColor]
                                      shadowColor:[UIColor whiteColor]];
  _userNameLabel.font = BOLD_FONT(15);
  [self addSubview:_userNameLabel];
  
  _countryLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(_userNameLabel.frame.origin.x, MARGIN * 3, 0, 15) 
                                       textColor:COLOR(135.0f, 26.0f, 24.0f) 
                                     shadowColor:[UIColor whiteColor]];
  _countryLabel.font = FONT(13);
  _countryLabel.numberOfLines = 0;
  _countryLabel.lineBreakMode = NSLineBreakByWordWrapping;
  [self addSubview:_countryLabel];
  
  _bioLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(_userNameLabel.frame.origin.x, 
                                                        MARGIN * 8, 
                                                        0, MARGIN * 2)
                                   textColor:BASE_INFO_COLOR 
                                 shadowColor:[UIColor whiteColor]];
  _bioLabel.font = FONT(11);
  _bioLabel.numberOfLines = 0;
  _bioLabel.lineBreakMode = NSLineBreakByWordWrapping;
  [self addSubview:_bioLabel];
}

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = CELL_COLOR;
    
    _clickableElementDelegate = clickableElementDelegate;
    
    _imageDisplayerDelegate = imageDisplayerDelegate;
    
    [self initProfileBaseInfo];
    
    [self initButtons]; 
  
  }
  return self;
}

- (void)dealloc {
  
  //_member = nil;
  self.userPhoto = nil;
  
  RELEASE_OBJ(_authorPicBackgroundView);
  RELEASE_OBJ(_userNameLabel);
  RELEASE_OBJ(_countryLabel);
  RELEASE_OBJ(_bioLabel);
  RELEASE_OBJ(_feedsButton);
  RELEASE_OBJ(_feedsButtonBackgroundView);
  RELEASE_OBJ(_commentsButton);
  RELEASE_OBJ(_comentsButtonBackgroundView);
  RELEASE_OBJ(_pointButton);
  RELEASE_OBJ(_pointButtonBackgroundView);
  RELEASE_OBJ(_favoriteButton);
  RELEASE_OBJ(_favoriteButtonBackgroundView);
  RELEASE_OBJ(_buttonsBackgroundView);
  
  [super dealloc];
}

#pragma mark - update count
- (void)updateButtonCounts {
  [_feedsButton setTitle:[NSString stringWithFormat:@"%@", _member.feedCount]
                forState:UIControlStateNormal];
  [_commentsButton setTitle:[NSString stringWithFormat:@"%@", _member.answerCount]
                   forState:UIControlStateNormal];
  [_favoriteButton setTitle:[NSString stringWithFormat:@"%@", _member.favoriteCount]
                   forState:UIControlStateNormal];

}

#pragma mark - draw
- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0.0f, 0.0f) 
                endPoint:CGPointMake(self.frame.size.width, 0) 
                   color:COLOR(186, 186, 186).CGColor 
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];
  
  CGFloat y = _buttonsBackgroundView.frame.origin.y - 2;
  [UIUtils draw1PxStroke:context 
              startPoint:CGPointMake(0, y) 
                endPoint:CGPointMake(self.bounds.size.width, y)
                   color:COLOR(186, 186, 186).CGColor
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];

  
  y = USER_PROF_BUTTONS_BACKGROUND_HEIGHT + _buttonsBackgroundView.frame.origin.y;
  [UIUtils draw1PxStroke:context 
              startPoint:CGPointMake(0, y)
                endPoint:CGPointMake(self.bounds.size.width, y) 
                   color:COLOR(186, 186, 186).CGColor
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];

}

- (void)drawProfile:(Member *)member {
  _member = member;
  
  _userNameLabel.text = member.name;
  CGSize size = [_userNameLabel.text sizeWithFont:_userNameLabel.font 
                                constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                    lineBreakMode:NSLineBreakByWordWrapping];
  
  if (member.memberId.longLongValue == [AppManager instance].userId.longLongValue) {
    // display the email for current user
    _countryLabel.text = [NSString stringWithFormat:@"%@, %@", member.countryName, member.email];
  } else {
    _countryLabel.text = member.countryName;
  }
  
  CGFloat countryMaxWidth = self.bounds.size.width - _userNameLabel.frame.origin.x - MARGIN * 2;
  CGSize countrySize = [_countryLabel.text sizeWithFont:_countryLabel.font
                                      constrainedToSize:CGSizeMake(countryMaxWidth, CGFLOAT_MAX)
                                          lineBreakMode:NSLineBreakByWordWrapping];
  
  _bioLabel.text = [NSString stringWithFormat:LocaleStringForKey(NSLiveStatusTitle, nil), 
                   member.years.intValue, member.cityName];
  CGFloat bioWidth = self.bounds.size.width - _userNameLabel.frame.origin.x - MARGIN * 2;
  CGSize bioSize = [_bioLabel.text sizeWithFont:_bioLabel.font 
                              constrainedToSize:CGSizeMake(bioWidth, CGFLOAT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping];
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:FADE_IN_DURATION];
  
  _userNameLabel.frame = CGRectMake(_userNameLabel.frame.origin.x, 
                                    _userNameLabel.frame.origin.y, 
                                    size.width, size.height);
  
  _countryLabel.frame = CGRectMake(_userNameLabel.frame.origin.x, 
                                   _userNameLabel.frame.origin.y + size.height, 
                                   countrySize.width, countrySize.height);
  
  _bioLabel.frame = CGRectMake(_bioLabel.frame.origin.x, 
                               _countryLabel.frame.origin.y + countrySize.height, 
                               bioSize.width, 
                               bioSize.height);

  CGFloat y = _bioLabel.frame.origin.y + _bioLabel.frame.size.height + MARGIN/* * 2*/;
   
  _buttonsBackgroundView.frame = CGRectMake(0, y + 2, self.bounds.size.width, USER_PROF_BUTTONS_BACKGROUND_HEIGHT);
  
  [self setNeedsDisplay];
  
  [UIView commitAnimations];
  
  if (_imageDisplayerDelegate) {
    [_imageDisplayerDelegate registerImageUrl:member.bigPhotoUrl];
  }
  
  [[WXWImageManager instance].imageCache fetchImage:member.bigPhotoUrl caller:self forceNew:NO];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  self.userPhoto = [UIImage imageNamed:@"defaultUser.png"];
  [_authorPicButton setImage:[UIImage imageNamed:@"defaultUser.png"] forState:UIControlStateNormal];
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  self.userPhoto = image;
  [_authorPicButton setImage:[CommonUtils cutPartImage:image 
                                                 width:PHOTO_SIDE_LENGTH 
                                                height:PHOTO_SIDE_LENGTH]
                    forState:UIControlStateNormal];
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image
                   url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

@end
