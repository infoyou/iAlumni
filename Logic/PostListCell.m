//
//  PostListCell.m
//  iAlumni
//
//  Created by Adam on 11-11-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PostListCell.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Post.h"

#define LOC_IND_PORTRAIT_X          278.0f

#define LOC_IND_WIDTH               10.0f
#define IND_HEIGHT                  10.0f

#define HOT_IND_X                   297.0f

#define ICON_WIDTH                  16.0f

@interface PostListCell()
@property (nonatomic, retain) UIImage *postImage;
@property (nonatomic, copy) NSString *authorPicUrl;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *thumbnailUrl;
@end

@implementation PostListCell
@synthesize postImage = _postImage;
@synthesize authorPicUrl = _authorPicUrl;
@synthesize imageUrl = _imageUrl;
@synthesize thumbnailUrl = _thumbnailUrl;

#pragma mark - clear image browser
- (void)clearHandyImageBrowser:(NSNotification *)notification {
  RELEASE_OBJ(_imageBrowser);
}

#pragma mark - lifecycle methods

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
           showType:(ClubViewType)showType
                MOC:(NSManagedObjectContext *)MOC{
  
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];
  if (self) {
    
    _showType = showType;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearHandyImageBrowser:)
                                                 name:CLEAR_HANDY_IMAGE_BROWSER_NOTIF
                                               object:nil];
    
    self.contentView.backgroundColor = CELL_COLOR;
    
    _delegate = imageClickableDelegate;
    
    _authorImageBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2,
                                                                          MARGIN * 2,
                                                                          POSTLIST_PHOTO_WIDTH,
                                                                          POSTLIST_PHOTO_HEIGHT)];
    _authorImageBackgroundView.backgroundColor = TRANSPARENT_COLOR;
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    [shadowPath addArcWithCenter:CGPointMake(POSTLIST_PHOTO_WIDTH/2 + 2, POSTLIST_PHOTO_HEIGHT/2 + 2)
                          radius:PHOTO_SIDE_LENGTH/2
                      startAngle:2 * M_PI
                        endAngle:0
                       clockwise:true];
    
    _authorImageBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _authorImageBackgroundView.layer.shadowOpacity = 0.9f;
    _authorImageBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
    _authorImageBackgroundView.layer.masksToBounds = NO;
    [self.contentView addSubview:_authorImageBackgroundView];
    
    _authorImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _authorImageButton.frame = CGRectMake(0, 0, POSTLIST_PHOTO_WIDTH, POSTLIST_PHOTO_HEIGHT);
    _authorImageButton.layer.cornerRadius = 6.0f;
    _authorImageButton.layer.masksToBounds = YES;
    _authorImageButton.layer.borderWidth = 1.0f;
    _authorImageButton.layer.borderColor = [UIColor grayColor].CGColor;
    _authorImageButton.showsTouchWhenHighlighted = YES;
    [_authorImageButton addTarget:self action:@selector(openProfile:) forControlEvents:UIControlEventTouchUpInside];
    [_authorImageBackgroundView addSubview:_authorImageButton];
    
    // set editor name label
		_editorNameLabel = [[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN * 2 + POSTLIST_PHOTO_WIDTH + MARGIN * 2,
                                                                 MARGIN * 2, 230, 15)
                                            textColor:DARK_TEXT_COLOR
                                          shadowColor:[UIColor whiteColor]];
    _editorNameLabel.font = BOLD_FONT(14);
    _editorNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _editorNameLabel.numberOfLines = 1;
    [self.contentView addSubview:_editorNameLabel];
    
    if (_showType != CLUB_SELF_VIEW && _showType != CLUB_ALL_ALUMNUS_VIEW) {
      UIButton *clubViewClick = [UIButton buttonWithType:UIButtonTypeCustom];
      clubViewClick.frame = _editorNameLabel.frame;
      [clubViewClick addTarget:self action:@selector(goPostClub:)forControlEvents:UIControlEventTouchUpInside];
      [self.contentView addSubview:clubViewClick];
    }
    
    _contentLabel = [[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:MAIN_LABEL_COLOR
                                       shadowColor:[UIColor whiteColor]];
		[_contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
		[_contentLabel setNumberOfLines:0];
    _contentLabel.font = FONT(15);
		[self.contentView addSubview:_contentLabel];
    
    _postImageBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2 + POSTLIST_PHOTO_WIDTH + MARGIN * 2,
                                                                        MARGIN,
                                                                        POST_IMG_LONG_SIDE,
                                                                        POST_IMG_LONG_SIDE)];
		_postImageBackgroundView.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
		_postImageBackgroundView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
		_postImageBackgroundView.layer.shadowOpacity = 0.8;
		_postImageBackgroundView.layer.shadowRadius = 2.0f;
		_postImageBackgroundView.layer.shouldRasterize = YES;
		[self.contentView addSubview:_postImageBackgroundView];
    
    _postImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _postImageButton.frame = CGRectMake(0, 0, POST_IMG_LONG_SIDE, POST_IMG_LONG_SIDE);
    _postImageButton.layer.cornerRadius = 6.0f;
    _postImageButton.layer.masksToBounds = YES;
    _postImageButton.showsTouchWhenHighlighted = YES;
    [_postImageButton addTarget:self
                         action:@selector(openPostImage:)
               forControlEvents:UIControlEventTouchDown];
    [_postImageBackgroundView addSubview:_postImageButton];
    
    _locAttachedIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map.png"]];
    _locAttachedIndicator.hidden = YES;
    //        [self.contentView addSubview:_locAttachedIndicator];
    
    _commentCountLabel = [[WXWLabel alloc] initWithFrame:CGRectZero
                                              textColor:BASE_INFO_COLOR
                                            shadowColor:[UIColor whiteColor]];
    _commentCountLabel.font = BOLD_FONT(11);
    _commentCountLabel.numberOfLines = 1;
    _commentCountLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_commentCountLabel];
    
    _commentIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentGray.png"]];
    _commentIcon.backgroundColor = TRANSPARENT_COLOR;
    [self.contentView addSubview:_commentIcon];
    
    _timeline = [[WXWLabel alloc] initWithFrame:CGRectZero
                                     textColor:BASE_INFO_COLOR
                                   shadowColor:[UIColor whiteColor]];
		_timeline.font = FONT(10);
    [self.contentView addSubview:_timeline];
    
    _hotIndicaor = [[UIImageView alloc] initWithFrame:CGRectMake(HOT_IND_X, 0, 22, 22)];
    _hotIndicaor.image = [UIImage imageNamed:@"hot.png"];
    [self.contentView addSubview:_hotIndicaor];
    
    _likeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"like.png"]];
    _likeIcon.backgroundColor = TRANSPARENT_COLOR;
    [self.contentView addSubview:_likeIcon];
    
    _likeCountLabel = [[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:BASE_INFO_COLOR
                                         shadowColor:[UIColor whiteColor]];
    _likeCountLabel.font = BOLD_FONT(11);
    [self.contentView addSubview:_likeCountLabel];
    
    [self initSmsArea];
  }
  return self;
}

- (void)initSmsArea
{
  // set sms
  _smsLabel = [[UILabel alloc] init];
  [_smsLabel setFont:FONT(11)];
  _smsLabel.backgroundColor = TRANSPARENT_COLOR;
  _smsLabel.textColor = [UIColor darkGrayColor];
  [_smsLabel setHighlightedTextColor:[UIColor whiteColor]];
  [self.contentView addSubview:_smsLabel];
}

- (void)drawSmsInfos:(CGFloat)y {
  _smsLabel.frame = CGRectMake(160, y, 100, 16);
  if ([@"true" isEqualToString:_post.isSmsInform]) {
    _smsLabel.text = @"短信通知";
  }else {
    _smsLabel.text = NULL_PARAM_VALUE;
  }
}

- (void)dealloc {
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:CLEAR_HANDY_IMAGE_BROWSER_NOTIF
                                                object:nil];
  
  RELEASE_OBJ(_smsLabel);
  RELEASE_OBJ(_editorNameLabel);
  RELEASE_OBJ(_authorImageBackgroundView);
  RELEASE_OBJ(_postImageBackgroundView);
  RELEASE_OBJ(_contentLabel);
  RELEASE_OBJ(_locAttachedIndicator);
  RELEASE_OBJ(_commentCountLabel);
  RELEASE_OBJ(_commentIcon);
  RELEASE_OBJ(_likeCountLabel);
  RELEASE_OBJ(_likeIcon);
  RELEASE_OBJ(_timeline);
  RELEASE_OBJ(_hotIndicaor);
  
  self.postImage = nil;
  self.authorPicUrl = nil;
  self.imageUrl = nil;
  self.thumbnailUrl = nil;
  
  [super dealloc];
}

#pragma mark - draw Post
- (void)showImages:(Post *)post {
  
  NSMutableArray *urls = [NSMutableArray array];
  [urls addObject:post.authorPicUrl];
  self.authorPicUrl = post.authorPicUrl;
  
  if (post.imageAttached.boolValue) {
    [urls addObject:post.thumbnailUrl];
    self.imageUrl = post.imageUrl;
    self.thumbnailUrl = post.thumbnailUrl;
  } else {
    self.imageUrl = nil;
    self.thumbnailUrl = nil;
  }
  [self fetchImage:urls forceNew:NO];
}

- (void)drawPost:(Post *)post {
  
  _post = post;
  
  if (_showType == CLUB_SELF_VIEW || _showType == CLUB_ALL_ALUMNUS_VIEW) {
    _editorNameLabel.text = post.authorName;
  } else {
    _editorNameLabel.text = post.clubName;
  }
  
  if (post.hot.boolValue) {
    _hotIndicaor.hidden = NO;
  } else {
    _hotIndicaor.hidden = YES;
  }
  
  if (_showType == CLUB_SELF_VIEW || _showType == CLUB_ALL_ALUMNUS_VIEW) {
    _contentLabel.text = post.content;
  } else {
    _contentLabel.text = [NSString stringWithFormat:@"%@: %@", post.authorName, post.content];
  }
  
  CGFloat x = MARGIN * 2 + POSTLIST_PHOTO_WIDTH + MARGIN * 2;
  CGFloat width = self.frame.size.width - x - MARGIN * 2;
  CGSize size = [_contentLabel.text sizeWithFont:_contentLabel.font
                               constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
  _contentLabel.frame = CGRectMake(x,
                                   MARGIN * 8,
                                   width, size.height);
  
  
  CGFloat timeline_y = 0;
  
  if (post.imageAttached.boolValue) {
    _postImageBackgroundView.hidden = NO;
    _postImageBackgroundView.frame = CGRectMake(_postImageBackgroundView.frame.origin.x,
                                                _contentLabel.frame.origin.y + size.height + MARGIN * 2,
                                                _postImageBackgroundView.frame.size.width,
                                                _postImageBackgroundView.frame.size.height);
    timeline_y = _postImageBackgroundView.frame.origin.y + _postImageBackgroundView.frame.size.height + MARGIN;
  } else {
    _postImageBackgroundView.hidden = YES;
    timeline_y = _contentLabel.frame.origin.y + size.height + MARGIN * 2;
  }
  
  /////////
  _timeline.text = post.elapsedTime;
  size = [_timeline.text sizeWithFont:_timeline.font
                    constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
  _timeline.frame = CGRectMake(x,
                               timeline_y + MARGIN, size.width, CELL_BASE_INFO_HEIGHT);
  
  if (post.locationAttached.boolValue) {
    _locAttachedIndicator.hidden = NO;
    _locAttachedIndicator.frame = CGRectMake(self.frame.size.width - ICON_WIDTH - MARGIN * 2,
                                             timeline_y + 3, ICON_WIDTH, CELL_BASE_INFO_HEIGHT);
    x = _locAttachedIndicator.frame.origin.x - MARGIN * 2;
  } else {
    _locAttachedIndicator.hidden = YES;
    x = self.frame.size.width - MARGIN * 2;
  }
  
  _commentCountLabel.text = [NSString stringWithFormat:@"%@", post.commentCount];
  size = [_commentCountLabel.text sizeWithFont:_commentCountLabel.font
                             constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  _commentCountLabel.frame = CGRectMake(x - size.width, timeline_y + MARGIN, size.width, CELL_BASE_INFO_HEIGHT);
  
  _commentIcon.frame = CGRectMake(_commentCountLabel.frame.origin.x - MARGIN - ICON_WIDTH,
                                  timeline_y + 3, ICON_WIDTH, CELL_BASE_INFO_HEIGHT);
  if (post.commentCount.intValue > 0) {
    _commentCountLabel.hidden = NO;
    _commentIcon.hidden = NO;
  } else {
    _commentCountLabel.hidden = YES;
    _commentIcon.hidden = YES;
  }
  
  
  _likeCountLabel.text = [NSString stringWithFormat:@"%@", post.likeCount];
  size = [_likeCountLabel.text sizeWithFont:_likeCountLabel.font
                          constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
  _likeCountLabel.frame = CGRectMake(_commentIcon.frame.origin.x - MARGIN * 2 - size.width,
                                     timeline_y + MARGIN, size.width, CELL_BASE_INFO_HEIGHT);
  
  _likeIcon.frame = CGRectMake(_likeCountLabel.frame.origin.x - MARGIN - ICON_WIDTH,
                               timeline_y + 1, ICON_WIDTH, CELL_BASE_INFO_HEIGHT);
  [self drawSmsInfos:timeline_y + MARGIN];
  
  NSString *imageName = post.liked.boolValue ? @"like.png" : @"unlike.png";
  _likeIcon.image = [UIImage imageNamed:imageName];
  
  if (post.likeCount.intValue > 0) {
    _likeCountLabel.hidden = NO;
    _likeIcon.hidden = NO;
  } else {
    _likeCountLabel.hidden = YES;
    _likeIcon.hidden = YES;
  }
  
  [self showImages:post];
}

- (void)hideLabelShadow {
  [self removeLabelShadowForHighlight:&_editorNameLabel];
  [self removeLabelShadowForHighlight:&_contentLabel];
  [self removeLabelShadowForHighlight:&_timeline];
  [self removeLabelShadowForHighlight:&_likeCountLabel];
  [self removeLabelShadowForHighlight:&_commentCountLabel];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  [super setHighlighted:highlighted animated:animated];
  
  if (highlighted) {
    
    [self hideLabelShadow];
    
  } else {
    [self addLabelShadowForHighlight:&_editorNameLabel];
    [self addLabelShadowForHighlight:&_contentLabel];
    [self addLabelShadowForHighlight:&_timeline];
    [self addLabelShadowForHighlight:&_likeCountLabel];
    [self addLabelShadowForHighlight:&_commentCountLabel];
  }
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    if ([url isEqualToString:self.thumbnailUrl]) {
      [_postImageButton setImage:[UIImage imageNamed:@"defaultFeedImage.png"]
                        forState:UIControlStateNormal];
    } else if ([url isEqualToString:self.authorPicUrl]) {
      [_authorImageButton setImage:[UIImage imageNamed:@"defaultUser.png"]
                          forState:UIControlStateNormal];
    }
  }
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    
    if ([url isEqualToString:self.thumbnailUrl]) {
      [_postImageButton.layer addAnimation:[self imageTransition] forKey:nil];
      [_postImageButton setImage:image
                        forState:UIControlStateNormal];
    } else if ([url isEqualToString:self.authorPicUrl]) {
      [_authorImageButton.layer addAnimation:[self imageTransition] forKey:nil];
      [_authorImageButton setImage:image
                          forState:UIControlStateNormal];
    }
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    if ([url isEqualToString:self.thumbnailUrl]) {
      [_postImageButton setImage:image
                        forState:UIControlStateNormal];
    } else if ([url isEqualToString:self.authorPicUrl]) {
      [_authorImageButton setImage:image
                          forState:UIControlStateNormal];
    }
  }
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

#pragma mark - browser Post image
- (void)openPostImage:(id)sender {
  
  if (_delegate) {
    [_delegate openImageUrl:self.imageUrl];
  }
}

#pragma mark - open profile
- (void)openProfile:(id)sender {
  
  if (_delegate) {
    [_delegate openProfile:_post.authorId userType:_post.authorType];
  }
}

- (void)goPostClub:(id)sender
{
  [_delegate goPostClub:nil];
}

@end
