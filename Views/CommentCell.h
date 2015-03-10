//
//  CommentCell.h
//  ExpatCircle
//
//  Created by Adam on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ECImageConsumerCell.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;
@class Comment;

@interface CommentCell : ECImageConsumerCell <UIWebViewDelegate> {
  @private
  WXWLabel *_timelineLabel;
  WXWLabel *_contentLabel;
  WXWLabel *_authorLabel;
  WXWLabel *_locationLabel;
  
  UIWebView *_contentWebView;
  UIView *_tempCoverView;
  
  UIView *_authorPicBackgroundView;
  UIButton *_authorPicButton;
  
  UIView *_imageBackgroundView;
  UIButton *_commentImageButton;

  NSString *_authorPicUrl;
  NSString *_imageUrl;
  NSString *_thumbnailUrl;
  
  id<ECClickableElementDelegate> _delegate;
  
  BOOL _imageLoaded;
  
  long long _commenterId;
  
  int _commenterType;
}

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawComment:(Comment *)comment showLocation:(BOOL)showLocation;

@end
