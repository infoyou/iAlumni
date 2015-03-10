//
//  GroupDiscussionCell.m
//  iAlumni
//
//  Created by Adam on 12-10-23.
//
//

#import "GroupDiscussionCell.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Post.h"
#import "TagsOmissionView.h"
#import "Tag.h"
#import "CoreDataUtils.h"
#import "TextConstants.h"
#import "CommonUtils.h"

#define LOC_IND_PORTRAIT_X          278.0f

#define LOC_IND_WIDTH               10.0f
#define IND_HEIGHT                  10.0f

#define HOT_IND_X                   297.0f

#define ICON_WIDTH                  16.0f

#define TAG_HEIGHT                  20.0f

@interface GroupDiscussionCell()
@property (nonatomic, copy) NSString *authorPicUrl;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *thumbnailUrl;
@end

@implementation GroupDiscussionCell
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
                MOC:(NSManagedObjectContext *)MOC{
  
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];
  if (self) {
    
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
    _authorImageButton.layer.borderWidth = 2.0f;
    _authorImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _authorImageButton.showsTouchWhenHighlighted = YES;
    [_authorImageButton addTarget:self action:@selector(openProfile:) forControlEvents:UIControlEventTouchUpInside];
    [_authorImageBackgroundView addSubview:_authorImageButton];
    
    // set editor name label
		_editorNameLabel = [[self initLabel:CGRectMake(MARGIN * 2 + POSTLIST_PHOTO_WIDTH + MARGIN * 2,
                                                  MARGIN * 2, 230, 15)
                             textColor:DARK_TEXT_COLOR
                           shadowColor:[UIColor whiteColor]] autorelease];
    _editorNameLabel.font = BOLD_FONT(14);
    _editorNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _editorNameLabel.numberOfLines = 1;
    [self.contentView addSubview:_editorNameLabel];
    
    _contentLabel = [[self initLabel:CGRectZero
                          textColor:MAIN_LABEL_COLOR
                         shadowColor:[UIColor whiteColor]] autorelease];
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
    [self.contentView addSubview:_locAttachedIndicator];
    
    _commentCountLabel = [[self initLabel:CGRectZero
                               textColor:BASE_INFO_COLOR
                             shadowColor:[UIColor whiteColor]] autorelease];
    _commentCountLabel.font = BOLD_FONT(11);
    _commentCountLabel.numberOfLines = 1;
    _commentCountLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_commentCountLabel];
    
    _commentIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"commentGray.png"]];
    _commentIcon.backgroundColor = TRANSPARENT_COLOR;
    [self.contentView addSubview:_commentIcon];
    
    _timeline = [[self initLabel:CGRectZero
                      textColor:BASE_INFO_COLOR
                    shadowColor:[UIColor whiteColor]] autorelease];
		_timeline.font = FONT(10);
    [self.contentView addSubview:_timeline];
    
    _hotIndicaor = [[UIImageView alloc] initWithFrame:CGRectMake(HOT_IND_X, 0, 22, 22)];
    _hotIndicaor.image = [UIImage imageNamed:@"hot.png"];
    [self.contentView addSubview:_hotIndicaor];
    
    _likeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"like.png"]];
    _likeIcon.backgroundColor = TRANSPARENT_COLOR;
    [self.contentView addSubview:_likeIcon];
    
    _likeCountLabel = [[self initLabel:CGRectZero
                            textColor:BASE_INFO_COLOR
                          shadowColor:[UIColor whiteColor]] autorelease];
    _likeCountLabel.font = BOLD_FONT(11);
    [self.contentView addSubview:_likeCountLabel];
    
    [self initSmsArea];
    
    if (nil == _tagsView) {
      _tagsView = [[[TagsOmissionView alloc] initWithFrame:CGRectZero MOC:_MOC] autorelease];
      [self.contentView addSubview:_tagsView];
    }
    
    _distanceLabel = [[self initLabel:CGRectZero
                           textColor:BASE_INFO_COLOR
                          shadowColor:[UIColor whiteColor]] autorelease];
    _distanceLabel.font = FONT(11);
    _distanceLabel.hidden = YES;
    [self.contentView addSubview:_distanceLabel];
  }
  return self;
}

- (void)initSmsArea
{
  // set sms
  _smsLabel = [[self initLabel:CGRectZero
                     textColor:[UIColor darkGrayColor]
                   shadowColor:TRANSPARENT_COLOR] autorelease];
  [_smsLabel setFont:FONT(11)];
  [self.contentView addSubview:_smsLabel];
}

- (void)drawSmsInfos:(CGFloat)y {
  _smsLabel.frame = CGRectMake(160, y, 100, 16);
  if ([@"true" isEqualToString:_post.isSmsInform]) {
    _smsLabel.text = LocaleStringForKey(NSSMSTitle, nil);
  }else {
    _smsLabel.text = NULL_PARAM_VALUE;
  }
}

- (void)dealloc {
  
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:CLEAR_HANDY_IMAGE_BROWSER_NOTIF
                                                object:nil];
  RELEASE_OBJ(_authorImageBackgroundView);
  RELEASE_OBJ(_postImageBackgroundView);
  RELEASE_OBJ(_locAttachedIndicator);
  RELEASE_OBJ(_commentIcon);
  RELEASE_OBJ(_likeIcon);
  RELEASE_OBJ(_hotIndicaor);
  
  self.authorPicUrl = nil;
  self.imageUrl = nil;
  self.thumbnailUrl = nil;
  
  [super dealloc];
}

#pragma mark - draw Post
- (void)showImages:(Post *)post {
  
  if (post.authorPicUrl && post.authorPicUrl.length > 0) {
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
}

- (void)checkTagNames:(NSManagedObjectContext *)MOC {
  if ((nil == _post.tagNames || 0 == _post.tagNames.length) && _post.tagIds.length > 1) {
    NSMutableString *tagNameListStr = [NSMutableString stringWithString:NULL_PARAM_VALUE];
    
    NSArray *ids = [_post.tagIds componentsSeparatedByString:ITEM_TAG_ID_SEPARATOR];
    if (ids.count > 0) {
      
      NSInteger i = 0;
      for (NSString *itemId in ids) {
        
        i++;
        
        NSPredicate *tagIdPredicate = [NSPredicate predicateWithFormat:@"(tagId == %lld)", itemId.longLongValue];
        
        Tag *tag = (Tag *)[WXWCoreDataUtils fetchObjectFromMOC:MOC
                                                 entityName:@"Tag"
                                                  predicate:tagIdPredicate];
        
        if (nil == tag.tagName || 0 == tag.tagName.length) {
          continue;
        }
        if (i < ids.count) {
          [tagNameListStr appendFormat:@"%@    ", tag.tagName];
        } else {
          [tagNameListStr appendString:tag.tagName];
        }
      }
    }
    
    _post.tagNames = tagNameListStr;
    SAVE_MOC(MOC);
  }
}

- (void)drawTags:(NSManagedObjectContext *)MOC {
  
  if (_post.tagNames && _post.tagNames.length > 0) {
    
    _tagsView.hidden = NO;
    
    CGFloat x = MARGIN * 4 + POSTLIST_PHOTO_WIDTH;
    _tagsView.frame = CGRectMake(x,
                                 _timeline.frame.origin.y + _timeline.frame.size.height,
                                 self.frame.size.width - x - MARGIN * 2, TAG_HEIGHT);
    
    [self checkTagNames:MOC];
    
    [_tagsView arrangeViews:_post.tagNames];
    
  } else {
    _tagsView.hidden = YES;
  }
  
}

- (void)drawPost:(Post *)post MOC:(NSManagedObjectContext *)MOC {
  
  _post = post;
  _editorNameLabel.text = post.authorName;
  
  if (post.hot.boolValue) {
    _hotIndicaor.hidden = NO;
  } else {
    _hotIndicaor.hidden = YES;
  }
  
  _contentLabel.text = post.content;
  
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
  
  _timeline.text = post.elapsedTime;
  size = [_timeline.text sizeWithFont:_timeline.font
                    constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
  _timeline.frame = CGRectMake(x,
                               timeline_y + MARGIN, size.width, CELL_BASE_INFO_HEIGHT);
  
  if (post.distance.floatValue >= 0 && post.locationAttached.boolValue) {
    _distanceLabel.hidden = NO;
    _distanceLabel.text = [NSString stringWithFormat:@"%0.2f %@",
                           post.distance.floatValue, LocaleStringForKey(NSKMTitle, nil)];
    size = [_distanceLabel.text sizeWithFont:_distanceLabel.font
                           constrainedToSize:CGSizeMake(100.0f, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    _distanceLabel.frame = CGRectMake(self.frame.size.width - size.width - MARGIN * 2,
                                      timeline_y + MARGIN + 1.0f,
                                      size.width, size.height);
    
    x = _distanceLabel.frame.origin.x;
  } else {
    _distanceLabel.hidden = YES;
    x = self.frame.size.width;
  }
  
  if (post.locationAttached.boolValue) {
    _locAttachedIndicator.hidden = NO;
    _locAttachedIndicator.frame = CGRectMake(x - MARGIN - ICON_WIDTH,//self.frame.size.width - ICON_WIDTH - MARGIN * 2,
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
  
  [self drawTags:MOC];
  
  [self showImages:post];
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

@end
