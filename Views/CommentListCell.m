//
//  CommentListCell.m
//  iAlumni
//
//  Created by Adam on 11-11-14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CommentListCell.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "PostComment.h"
#import "CommonUtils.h"
#import "UIUtils.h"
#import "TextConstants.h"
#import "WXWRootViewController.h"

#define DELETE_BUTTON_WIDTH     32.0f
#define DELETE_BUTTON_HEIGHT    16.0f

@interface CommentListCell()
@property (nonatomic, copy) NSString *authorPicUrl;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *thumbnailUrl;
@end

@implementation CommentListCell

@synthesize authorPicUrl = _authorPicUrl;
@synthesize imageUrl = _imageUrl;
@synthesize thumbnailUrl = _thumbnailUrl;

#pragma mark - go to profile

- (void)openProfile:(id)sender {
  if (_delegate) {
    [_delegate openProfile:_comment.authorId userType:_comment.authorType];
  }
}

- (void)showBigPicture:(id)sender {
  if (_delegate) {
    [_delegate openImageUrl:self.imageUrl];
  }
}

- (void)deleteComment:(id)sender {
  if (_delegate) {
    [_delegate deleteComment:_comment.commentId.longLongValue];
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
    
    _userPicBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2, 
                                                                      MARGIN * 2, 
                                                                      PHOTO_SIDE_LENGTH, 
                                                                      PHOTO_SIDE_LENGTH)];
    _userPicBackgroundView.backgroundColor = TRANSPARENT_COLOR;
    _userPicBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _userPicBackgroundView.layer.shadowOpacity = 0.9f;
    _userPicBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
    _userPicBackgroundView.layer.masksToBounds = NO;
    [self.contentView addSubview:_userPicBackgroundView];
    
    _authorPicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _authorPicButton.frame = CGRectMake(0, 0, POST_COMMENT_PHOTO_WIDTH, POST_COMMENT_PHOTO_HEIGHT);
    _authorPicButton.layer.cornerRadius = 6.0f;
    _authorPicButton.layer.masksToBounds = YES;
    _authorPicButton.showsTouchWhenHighlighted = YES;
    _authorPicButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _authorPicButton.layer.borderWidth = 2.0f;
    [_authorPicButton addTarget:self action:@selector(openProfile:) forControlEvents:UIControlEventTouchUpInside];
    [_userPicBackgroundView addSubview:_authorPicButton];
    
    _authorLabel = [[WXWLabel alloc] initWithFrame:CGRectZero 
                                        textColor:COLOR(44, 45, 51) 
                                      shadowColor:[UIColor whiteColor]];
    _authorLabel.font = BOLD_FONT(15);
    [self.contentView addSubview:_authorLabel];
    
    _timelineLabel = [[WXWLabel alloc] initWithFrame:CGRectZero
                                          textColor:BASE_INFO_COLOR
                                        shadowColor:[UIColor whiteColor]];
    _timelineLabel.font = FONT(12);
    [self.contentView addSubview:_timelineLabel];
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
    _deleteButton.hidden = YES;
    [_deleteButton addTarget:self action:@selector(deleteComment:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteButton];
    
    _contentLabel = [[WXWLabel alloc] initWithFrame:CGRectZero textColor:BASE_INFO_COLOR shadowColor:[UIColor whiteColor]];
    _contentLabel.font = FONT(13);
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _contentLabel.numberOfLines = 10000;
    [self.contentView addSubview:_contentLabel];
    
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
  
  RELEASE_OBJ(_userPicBackgroundView);
  RELEASE_OBJ(_authorLabel);
  RELEASE_OBJ(_imageBackgroundView);
  
  self.authorPicUrl = nil;
  self.imageUrl = nil;
  self.thumbnailUrl = nil;
  
  [super dealloc];
}

#pragma mark - draw comment
- (void)drawComment:(PostComment *)comment {
  
  _comment = comment;
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
  _authorLabel.frame = CGRectMake(_userPicBackgroundView.frame.origin.x + MARGIN + PHOTO_SIDE_LENGTH,
                                  _userPicBackgroundView.frame.origin.y, size.width, COMMENT_AUTHOR_HEIGHT);
  
  _timelineLabel.text = comment.date;
  size = [_timelineLabel.text sizeWithFont:_timelineLabel.font
                         constrainedToSize:CGSizeMake(200, CELL_BASE_INFO_HEIGHT)
                             lineBreakMode:NSLineBreakByWordWrapping];
  _timelineLabel.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - size.width, 
                                    _userPicBackgroundView.frame.origin.y, 
                                    size.width, 
                                    CELL_BASE_INFO_HEIGHT);
  
  _contentLabel.text = comment.content;
  
  CGFloat width = 0;
  if (hasImage) {
    width = self.frame.size.width - MARGIN * 2 - IMAGE_SIDE_LENGTH - MARGIN - _authorLabel.frame.origin.x;
  } else {
    width = self.frame.size.width - MARGIN * 2 - _authorLabel.frame.origin.x;
  }
  size = [_contentLabel.text sizeWithFont:_contentLabel.font
                        constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) 
                            lineBreakMode:NSLineBreakByWordWrapping];
  _contentLabel.frame = CGRectMake(_authorLabel.frame.origin.x, 
                                   _authorLabel.frame.origin.y + _authorLabel.frame.size.height + MARGIN, 
                                   width, size.height);
  
  if (hasImage) {
    _imageBackgroundView.hidden = NO;
    _imageBackgroundView.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - IMAGE_SIDE_LENGTH, 
                                            _contentLabel.frame.origin.y,
                                            IMAGE_SIDE_LENGTH, IMAGE_SIDE_LENGTH);
  } else {
    _imageBackgroundView.hidden = YES;
  }
  
  
  if (comment.couldBeDeleted.boolValue) {
    _deleteButton.hidden = NO;
    _deleteButton.enabled = YES;
        
    CGFloat bottomY = 0;
    
    CGFloat contentY = _contentLabel.frame.size.height + _contentLabel.frame.origin.y;
    if (hasImage) {
      CGFloat imageY = _imageBackgroundView.frame.origin.y + _imageBackgroundView.frame.size.height;
            
      if (imageY < contentY) {
        bottomY = contentY;
      } else {
        bottomY = imageY;
      }
    } else {
      CGFloat avatarBottomY = _userPicBackgroundView.frame.origin.y + _userPicBackgroundView.frame.size.height;
      
      CGFloat deleteButtonArea = MARGIN + DELETE_BUTTON_HEIGHT;
      
      if (avatarBottomY + deleteButtonArea < contentY) {
        bottomY = contentY;
      } else {
        bottomY = avatarBottomY + deleteButtonArea + MARGIN;
      }
    }
    _deleteButton.frame = CGRectMake(_userPicBackgroundView.frame.origin.x, 
                                     bottomY - DELETE_BUTTON_HEIGHT, 
                                     DELETE_BUTTON_WIDTH, DELETE_BUTTON_HEIGHT);
  } else {
    _deleteButton.hidden = YES;
    _deleteButton.enabled = NO;
  }

}

- (void)hideLabelShadow {
  [self removeLabelShadowForHighlight:&_timelineLabel];
  [self removeLabelShadowForHighlight:&_contentLabel];
  [self removeLabelShadowForHighlight:&_authorLabel];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  [super setHighlighted:highlighted animated:animated];
  
  if (highlighted) {
    [self hideLabelShadow];
  } else {
    [self addLabelShadowForHighlight:&_timelineLabel];
    [self addLabelShadowForHighlight:&_contentLabel];
    [self addLabelShadowForHighlight:&_authorLabel];
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
      
      UIImage *resizedImage = [CommonUtils cutPartImage:image
                                                  width:_commentImageButton.frame.size.width
                                                 height:_commentImageButton.frame.size.height];
      
      [_commentImageButton.layer addAnimation:[self imageTransition] forKey:nil];
      [_commentImageButton setImage:resizedImage forState:UIControlStateNormal];
      
      _imageLoaded = YES;
      
    } else if ([url isEqualToString:self.authorPicUrl]) {
      [_authorPicButton.layer addAnimation:imageFadein forKey:nil];
      [_authorPicButton setImage:image forState:UIControlStateNormal];
    }
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  
  if ([self currentUrlMatchCell:url]) {
    
    if ([url isEqualToString:self.thumbnailUrl]) {
      UIImage *resizedImage = [CommonUtils cutPartImage:image
                                                  width:_commentImageButton.frame.size.width
                                                 height:_commentImageButton.frame.size.height];
      
      [_commentImageButton setImage:resizedImage forState:UIControlStateNormal];    
      _imageLoaded = YES;
      
    } else if ([url isEqualToString:self.authorPicUrl]) {
      [_authorPicButton setImage:image forState:UIControlStateNormal];
    }
  }  
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

@end
