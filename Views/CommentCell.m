//
//  CommentCell.m
//  ExpatCircle
//
//  Created by Adam on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Comment.h"
#import "CommonUtils.h"
#import "UIUtils.h"
#import "TextConstants.h"

#define CONTENT_HEADER  @"<html><body marginwidth=\"0\" marginheight=\"0\" leftmargin=\"0\" topmargin=\"0\" bottommargin=\"0\" bgcolor=\"#EFEFEF\" padding=\"0\" style=\"font-family:ArialMT;font-size:13px;color:#82808C;text-shadow:1px 1px 1px white;word-wrap:break-word;\">"

@interface CommentCell()
@property (nonatomic, copy) NSString *authorPicUrl;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *thumbnailUrl;
@end

@implementation CommentCell

@synthesize authorPicUrl = _authorPicUrl;
@synthesize imageUrl = _imageUrl;
@synthesize thumbnailUrl = _thumbnailUrl;

#pragma mark - go to profile

- (void)openProfile:(id)sender {
  if (_delegate) {
    [_delegate openProfile:LLINT_TO_STRING(_commenterId)
                  userType:INT_TO_STRING(_commenterType)];
  }
}

- (void)showBigPicture:(id)sender {
  if (_delegate) {
    [_delegate openImageUrl:self.imageUrl];
  }
}

#pragma mark - lifecycle methods

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate 
                MOC:(NSManagedObjectContext *)MOC {
  
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier 
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];
  
  if (self) {
    
    _delegate = imageClickableDelegate;
    
    self.contentView.backgroundColor = CELL_COLOR;
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = CELL_BORDER_COLOR.CGColor;
    
    _authorPicBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2, 
                                                                        MARGIN * 2, 
                                                                        PHOTO_SIDE_LENGTH, 
                                                                        PHOTO_SIDE_LENGTH)];
    _authorPicBackgroundView.backgroundColor = TRANSPARENT_COLOR;
    //_authorPicBackgroundView.layer.cornerRadius = 2.0f;
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    [shadowPath addArcWithCenter:CGPointMake(PHOTO_SIDE_LENGTH/2 + 2, PHOTO_SIDE_LENGTH/2 + 2)
                          radius:PHOTO_SIDE_LENGTH/2 
                      startAngle:2 * M_PI 
                        endAngle:0 
                       clockwise:true];
    _authorPicBackgroundView.layer.shadowPath = shadowPath.CGPath;
    _authorPicBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _authorPicBackgroundView.layer.shadowOpacity = 0.9f;
    _authorPicBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
    _authorPicBackgroundView.layer.masksToBounds = NO;
    [self.contentView addSubview:_authorPicBackgroundView];
    
    _authorPicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _authorPicButton.frame = CGRectMake(0, 0, PHOTO_SIDE_LENGTH, PHOTO_SIDE_LENGTH);
    _authorPicButton.layer.cornerRadius = PHOTO_SIDE_LENGTH/2.0f;
    _authorPicButton.layer.masksToBounds = YES;
    _authorPicButton.showsTouchWhenHighlighted = YES;
    _authorPicButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _authorPicButton.layer.borderWidth = 2.0f;
    [_authorPicButton addTarget:self action:@selector(openProfile:) forControlEvents:UIControlEventTouchUpInside];
    [_authorPicBackgroundView addSubview:_authorPicButton];
    
    _authorLabel = [self initLabel:CGRectZero
                         textColor:COLOR(44, 45, 51) 
                       shadowColor:[UIColor whiteColor]];
    _authorLabel.font = BOLD_FONT(15);
    [self.contentView addSubview:_authorLabel];
    
    _timelineLabel = [self initLabel:CGRectZero
                           textColor:BASE_INFO_COLOR
                         shadowColor:[UIColor whiteColor]];
    _timelineLabel.font = FONT(12);
    [self.contentView addSubview:_timelineLabel];
    
    _locationLabel = [self initLabel:CGRectZero
                           textColor:NAVIGATION_BAR_COLOR
                         shadowColor:[UIColor whiteColor]];
    _locationLabel.font = BOLD_FONT(13);
    _locationLabel.numberOfLines = 0;
    [self.contentView addSubview:_locationLabel];
    
    /*
     _contentLabel = [self initLabel:CGRectZero
     textColor:BASE_INFO_COLOR
     shadowColor:[UIColor whiteColor]];
     _contentLabel.font = FONT(13);
     _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
     _contentLabel.numberOfLines = 10000;
     [self.contentView addSubview:_contentLabel];
     */
    
    _imageBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    _imageBackgroundView.backgroundColor = [UIColor whiteColor];
    _imageBackgroundView.layer.borderWidth = 1.0f;
    _imageBackgroundView.layer.borderColor = COLOR(227, 227, 227).CGColor;
    [self.contentView addSubview:_imageBackgroundView];
    
    _commentImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentImageButton.frame = CGRectMake(MARGIN, MARGIN, IMAGE_SIDE_LENGTH - MARGIN * 2, IMAGE_SIDE_LENGTH - MARGIN * 2);
    _commentImageButton.backgroundColor = TRANSPARENT_COLOR;
    [_commentImageButton addTarget:self action:@selector(showBigPicture:) forControlEvents:UIControlEventTouchUpInside];
    [_imageBackgroundView addSubview:_commentImageButton];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_authorPicBackgroundView);
  RELEASE_OBJ(_authorLabel);
  RELEASE_OBJ(_imageBackgroundView);
  RELEASE_OBJ(_contentLabel);
  RELEASE_OBJ(_timelineLabel);
  RELEASE_OBJ(_locationLabel);
  
  self.authorPicUrl = nil;
  self.imageUrl = nil;
  self.thumbnailUrl = nil;
  
  [super dealloc];
}

#pragma mark - remove temp cover view
- (void)removeTempCoverView {
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     _tempCoverView.alpha = 0.0f;                     
                   } 
                   completion:^(BOOL finished){                                     
                     [_tempCoverView removeFromSuperview];
                     _tempCoverView = nil;
                     [UIView animateWithDuration:0.2f
                                      animations:^{
                                        _contentWebView.alpha = 1.0f;
                                      } 
                                      completion:^(BOOL finished){
                                        _contentWebView.hidden = NO;
                                      }];
                   }];
}

#pragma mark - draw comment
- (void)initContentLabel {
  _contentLabel = [self initLabel:CGRectZero
                        textColor:BASE_INFO_COLOR
                      shadowColor:[UIColor whiteColor]];
  _contentLabel.font = FONT(13);
  _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
  _contentLabel.numberOfLines = 10000;
  [self.contentView addSubview:_contentLabel];
}

- (void)disableWebViewScroll:(UIView *)scrollView {
  if ([scrollView isKindOfClass:[UIScrollView class]]) {
    ((UIScrollView *)scrollView).scrollEnabled = NO;
    ((UIScrollView *)scrollView).alwaysBounceVertical = NO;
    ((UIScrollView *)scrollView).alwaysBounceHorizontal = NO;
    ((UIScrollView *)scrollView).bouncesZoom = NO;   
    ((UIScrollView *)scrollView).backgroundColor = CELL_COLOR;
  }
}

- (void)initContentWebView {
  _contentWebView = [[[UIWebView alloc] init] autorelease];
  _contentWebView.delegate = self;
  _contentWebView.userInteractionEnabled = YES;
  _contentWebView.backgroundColor = CELL_COLOR;
  _contentWebView.layer.masksToBounds = NO;
  _contentWebView.hidden = YES;
  _contentWebView.alpha = 0.0f;
  
  // disable web view scroll
  [self disableWebViewScroll:[[_contentWebView subviews] lastObject]];
  
  // add temp cover view to hide white color when content loading
  _tempCoverView = [[[UIView alloc] init] autorelease];
  _tempCoverView.backgroundColor = CELL_COLOR;
  [_contentWebView addSubview:_tempCoverView];
  
  [self.contentView addSubview:_contentWebView];
}

- (BOOL)containsUrl:(NSString *)text {
  if (nil == text || 0 == text.length) {
    return NO;
  }
  
  if ([text rangeOfString:@"http://" options:NSCaseInsensitiveSearch].length > 0 ||
      [text rangeOfString:@"https://" options:NSCaseInsensitiveSearch].length > 0 ||
      [text rangeOfString:@"www." options:NSCaseInsensitiveSearch].length > 0) {
    return YES;
  } else {
    return NO;
  }
}

- (void)drawAsWebContent:(CGFloat)width
                 content:(NSString *)content
            showLocation:(BOOL)showLocation
            locationName:(NSString *)locationName {
  
  if (_contentLabel) {
    [_contentLabel removeFromSuperview];
    RELEASE_OBJ(_contentLabel);
  }
  
  // set web view
  if (nil == _contentWebView) {
    [self initContentWebView];
  }
  
  CGSize size = [content sizeWithFont:FONT(13)
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) 
                        lineBreakMode:NSLineBreakByWordWrapping];
  
  if (showLocation && locationName && locationName.length > 0) {

    _locationLabel.text = locationName;
    CGSize locationSize = [_locationLabel.text sizeWithFont:_locationLabel.font
                                  constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    _locationLabel.hidden = NO;
    _locationLabel.frame = CGRectMake(_authorLabel.frame.origin.x,
                                      _authorLabel.frame.origin.y + _authorLabel.frame.size.height + MARGIN,
                                      locationSize.width, locationSize.height);
    
    _contentWebView.frame = CGRectMake(_authorLabel.frame.origin.x,
                                       _locationLabel.frame.origin.y + _locationLabel.frame.size.height + MARGIN,
                                       width, size.height);
  } else {
    
    _locationLabel.hidden = YES;
    _contentWebView.frame = CGRectMake(_authorLabel.frame.origin.x, 
                                     _authorLabel.frame.origin.y + _authorLabel.frame.size.height + MARGIN, 
                                     width, size.height);
  }
  
  NSString *parseredContent = [CommonUtils parsedTextForHyperLinkNoBold:content];
  NSString *htmlStr = [NSString stringWithFormat:@"%@%@<br /></body></html>", CONTENT_HEADER, parseredContent];
  
  [_contentWebView loadHTMLString:htmlStr baseURL:nil]; 
  
}

- (void)drawAsLabel:(CGFloat)width
            content:(NSString *)content
       showLocation:(BOOL)showLocation
       locationName:(NSString *)locationName {
  
  if (_contentWebView) {
    [_contentWebView removeFromSuperview];
    _contentWebView = nil;
  }
  
  // set label
  if (nil == _contentLabel) {
    [self initContentLabel];
  }
  
  _contentLabel.text = content;
  
  CGSize size = [_contentLabel.text sizeWithFont:_contentLabel.font
                               constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) 
                                   lineBreakMode:NSLineBreakByWordWrapping];
  
  if (showLocation && locationName && locationName.length > 0) {
    
    _locationLabel.text = locationName;
    CGSize locationSize = [_locationLabel.text sizeWithFont:_locationLabel.font
                                          constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                              lineBreakMode:NSLineBreakByWordWrapping];
    _locationLabel.hidden = NO;
    _locationLabel.frame = CGRectMake(_authorLabel.frame.origin.x,
                                      _authorLabel.frame.origin.y + _authorLabel.frame.size.height + MARGIN,
                                      locationSize.width, locationSize.height);
    
    _contentLabel.frame = CGRectMake(_authorLabel.frame.origin.x,
                                     _locationLabel.frame.origin.y + _locationLabel.frame.size.height + MARGIN,
                                     width, size.height);
  } else {
    
    _locationLabel.hidden = YES;
    
    _contentLabel.frame = CGRectMake(_authorLabel.frame.origin.x,
                                     _authorLabel.frame.origin.y + _authorLabel.frame.size.height + MARGIN,
                                     width, size.height);
  }
}

- (void)drawComment:(Comment *)comment forHeight:(CGFloat)height {
  _contentWebView.frame = CGRectMake(_contentWebView.frame.origin.x,
                                     _contentWebView.frame.origin.y,
                                     _contentWebView.frame.size.width, 
                                     height - MARGIN);
  if (_tempCoverView) {
    [self removeTempCoverView];
  }
}

- (void)drawComment:(Comment *)comment showLocation:(BOOL)showLocation {
  
  _commenterId = comment.authorId.longLongValue;
  
  _commenterType = comment.authorType.intValue;
  
  _imageLoaded = NO;
  
  BOOL hasImage = [comment.imageAttached boolValue];
  
  NSMutableArray *urls = [NSMutableArray array];
  [urls addObject:comment.authorPicUrl];
  self.authorPicUrl = comment.authorPicUrl;
  if (hasImage) {
    [urls addObject:comment.thumbnailUrl];
    self.imageUrl = comment.imageUrl;
    self.thumbnailUrl = comment.thumbnailUrl;
  } else {
    self.imageUrl = nil;
    self.thumbnailUrl = nil;
  }
  [self fetchImage:urls forceNew:NO];
  
  _authorLabel.text = comment.authorName;
  CGSize size = [_authorLabel.text sizeWithFont:_authorLabel.font
                              constrainedToSize:CGSizeMake(200, COMMENT_AUTHOR_HEIGHT)
                                  lineBreakMode:NSLineBreakByWordWrapping];
  _authorLabel.frame = CGRectMake(_authorPicBackgroundView.frame.origin.x + MARGIN + PHOTO_SIDE_LENGTH,
                                  _authorPicBackgroundView.frame.origin.y, size.width, COMMENT_AUTHOR_HEIGHT);
  
  _timelineLabel.text = comment.elapsedTime;
  size = [_timelineLabel.text sizeWithFont:_timelineLabel.font
                         constrainedToSize:CGSizeMake(200, CELL_BASE_INFO_HEIGHT)
                             lineBreakMode:NSLineBreakByWordWrapping];
  _timelineLabel.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - size.width, 
                                    _authorPicBackgroundView.frame.origin.y, 
                                    size.width, 
                                    CELL_BASE_INFO_HEIGHT);
  
  CGFloat width = 0;
  if (hasImage) {
    width = self.frame.size.width - MARGIN * 2 - IMAGE_SIDE_LENGTH - MARGIN - _authorLabel.frame.origin.x;
  } else {
    width = self.frame.size.width - MARGIN * 2 - _authorLabel.frame.origin.x;
  }
  
  if ([self containsUrl:comment.content]) {
    
    [self drawAsWebContent:width
                   content:comment.content
              showLocation:showLocation
              locationName:comment.locationName];
    
  } else {
    
    [self drawAsLabel:width
              content:comment.content
         showLocation:showLocation
         locationName:comment.locationName];
  }
  
  if (hasImage) {
    _imageBackgroundView.hidden = NO;
    _imageBackgroundView.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - IMAGE_SIDE_LENGTH, 
                                            _authorLabel.frame.origin.y + _authorLabel.frame.size.height + MARGIN,
                                            IMAGE_SIDE_LENGTH, IMAGE_SIDE_LENGTH);
  } else {
    _imageBackgroundView.hidden = YES;
  }
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    if ([url isEqualToString:self.authorPicUrl]) {
      [_authorPicButton.layer addAnimation:[self imageTransition]
                                    forKey:nil];
      [_authorPicButton setImage:[UIImage imageNamed:@"defaultUser.png"] 
                        forState:UIControlStateNormal];
    } else {
      [_commentImageButton.layer addAnimation:[self imageTransition] 
                                       forKey:nil];
      [_commentImageButton setImage:nil 
                           forState:UIControlStateNormal];
    }
  }
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    CATransition *imageFadein = [CATransition animation];
    imageFadein.duration = FADE_IN_DURATION;
    imageFadein.type = kCATransitionFade;
    if ([url isEqualToString:self.thumbnailUrl]) {
      
      [_commentImageButton.layer addAnimation:[self imageTransition] forKey:nil];
      [_commentImageButton setImage:[CommonUtils cutPartImage:image
                                                        width:_commentImageButton.frame.size.width
                                                       height:_commentImageButton.frame.size.height]
                           forState:UIControlStateNormal];
      
      _imageLoaded = YES;
      
    } else if ([url isEqualToString:self.authorPicUrl]) {
      [_authorPicButton.layer addAnimation:imageFadein forKey:nil];
      [_authorPicButton setImage:[CommonUtils cutPartImage:image
                                                     width:_authorPicButton.frame.size.width
                                                    height:_authorPicButton.frame.size.height]
                        forState:UIControlStateNormal];
    }
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  
  if ([self currentUrlMatchCell:url]) {
    if ([url isEqualToString:self.thumbnailUrl]) {
      
      [_commentImageButton setImage:[CommonUtils cutPartImage:image
                                                        width:_commentImageButton.frame.size.width
                                                       height:_commentImageButton.frame.size.height]
                           forState:UIControlStateNormal];    
      _imageLoaded = YES;
      
    } else if ([url isEqualToString:self.authorPicUrl]) {
      [_authorPicButton setImage:[CommonUtils cutPartImage:image
                                                     width:_authorPicButton.frame.size.width
                                                    height:_authorPicButton.frame.size.height]
                        forState:UIControlStateNormal];
    }
  }  
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView*)webView
shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
  
  if (navigationType == UIWebViewNavigationTypeLinkClicked) {
    
    NSURL *url = [request URL];
    
    NSString *urlStr = [url absoluteString];
    NSString *scheme = [url scheme];
    
    if ([scheme caseInsensitiveCompare:HTTP_PRIFIX] == 0 
        || [scheme caseInsensitiveCompare:HTTPS_PRIFIX] == 0) {
      if (_delegate) {
        [_delegate openUrl:urlStr];
        return NO;
      }
    } 
  }   
  return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  
  if (_tempCoverView) {
    [self removeTempCoverView];
  }
}
@end
