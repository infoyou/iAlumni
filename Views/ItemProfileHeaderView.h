//
//  ItemProfileHeaderView.h
//  ExpatCircle
//
//  Created by Adam on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXWImageFetcherDelegate.h"
#import "WXWImageDisplayerDelegate.h"
#import "ECClickableElementDelegate.h"

@class Member;
@class WXWLabel;
@class ECGradientButton;

@interface ItemProfileHeaderView : UIView <WXWImageFetcherDelegate> {
  Member *_member;
  
  id<ECClickableElementDelegate> _clickableElementDelegate;
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  
  UIView *_authorPicBackgroundView;
  UIButton *_authorPicButton;
  
  WXWLabel *_userNameLabel;
  WXWLabel *_countryLabel;
  WXWLabel *_bioLabel;
  
  UIView *_buttonsBackgroundView;
  ECGradientButton *_pointButton;
  UIView *_pointButtonBackgroundView;
  ECGradientButton *_feedsButton;
  UIView *_feedsButtonBackgroundView;
  ECGradientButton *_commentsButton;
  UIView *_comentsButtonBackgroundView;
  ECGradientButton *_favoriteButton;
  UIView *_favoriteButtonBackgroundView;
  
  UIImage *_userPhoto;
  
}

//@property (nonatomic, retain) Member *member;
@property (nonatomic, retain) UIImage *userPhoto;

- (id)initWithFrame:(CGRect)frame
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate;

- (void)initProfileBaseInfo;

- (void)drawProfile:(Member *)member;

- (void)updateButtonCounts;

@end
