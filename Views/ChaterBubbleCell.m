//
//  ChaterBubbleCell.m
//  iAlumni
//
//  Created by Adam on 13-10-14.
//
//

#import "ChaterBubbleCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Post.h"
#import "WXWLabel.h"
#import "AppManager.h"
#import "CommonUtils.h"

#define AVATAR_SIDE_LEN     47.0f

#define MIN_BUBBLE_WIDTH    83.0f
#define MIN_BUBBLE_HEIGHT   51.0f

#define MAX_MSG_WIDTH       140.0f

#define BUBBLE_EDGE_X       50.0f
#define BUBBLE_EDGE_Y       30.0f

@interface ChaterBubbleCell ()
@property (nonatomic, retain) id currentPopTipViewTarget;
@property (nonatomic, retain) UIButton *messageButton;
@property (nonatomic, retain) WXWLabel *messageLabel;
@property (nonatomic, retain) UIButton *chaterAvatarButton;
@property (nonatomic, retain) WXWLabel *timelineLabel;
@property (nonatomic, copy) NSString *chatterId;
@property (nonatomic, retain) UIImageView *photoImageView;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *thumbnailUrl;
@property (nonatomic, retain) NSMutableArray *visiblePopTipViews;
@end

@implementation ChaterBubbleCell

#pragma mark - user action
- (void)openChatterProfile:(id)sender {
  if (_chatterDelegate) {
    [_chatterDelegate openProfile:self.chatterId];
  }
}

- (void)openPhoto:(id)sender {
  if (_chatterDelegate && self.imageUrl.length > 0) {
    [_chatterDelegate openPhotoWithImageUrl:self.imageUrl];
  }
}

- (void)userClickAction:(id)sender {
  if (self.imageUrl.length > 0 && self.thumbnailUrl.length > 0) {
    if (_chatterDelegate) {
      [_chatterDelegate openPhotoWithImageUrl:self.imageUrl];
    }
  } else {
    [self doPopView:sender];
    
    if (_chatterDelegate) {
      [_chatterDelegate registerIndexPathForPopViewCell:self];
    }
  }
}

#pragma mark - life cycle methods
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
    chatterDelegate:(id<ChatterDelegate>)chatterDelegate
{
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];
  if (self) {
    
    self.backgroundColor = TRANSPARENT_COLOR;
    self.contentView.backgroundColor = TRANSPARENT_COLOR;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    
    _chatterDelegate = chatterDelegate;
    
    self.messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.messageButton addTarget:self
                           action:@selector(userClickAction:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.messageButton];
    
    self.messageLabel = [[self initLabel:CGRectZero
                               textColor:DARK_TEXT_COLOR
                             shadowColor:TRANSPARENT_COLOR] autorelease];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.font = FONT(15);
    [self.messageButton addSubview:self.messageLabel];
    
    self.chaterAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.chaterAvatarButton.backgroundColor = [UIColor whiteColor];
    [self.chaterAvatarButton addTarget:self
                                action:@selector(openChatterProfile:)
                      forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.chaterAvatarButton];
    
    self.timelineLabel = [[self initLabel:CGRectZero
                                textColor:[UIColor whiteColor]
                              shadowColor:TRANSPARENT_COLOR] autorelease];
    self.timelineLabel.font = FONT(11);
    self.timelineLabel.backgroundColor = COLOR(190, 190, 190);
    self.timelineLabel.textAlignment = NSTextAlignmentCenter;
    self.timelineLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.timelineLabel.layer.cornerRadius = 4.0f;
    self.timelineLabel.layer.masksToBounds = YES;
    [self.contentView addSubview:self.timelineLabel];
    
    self.photoImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
    [self.messageButton addSubview:self.photoImageView];
  }
  return self;
}

- (void)dealloc {
  
  self.messageLabel = nil;
  self.messageButton = nil;
  self.photoImageView = nil;
  self.chaterAvatarButton = nil;
  self.timelineLabel = nil;
  
  self.chatterId = nil;
  
  self.imageUrl = nil;
  self.thumbnailUrl = nil;
  self.avatarUrl = nil;
  
  self.currentPopTipViewTarget = nil;
  
  for (CMPopTipView *popView in self.visiblePopTipViews) {
    popView.delegate = nil;
  }
  self.visiblePopTipViews = nil;
  
  [super dealloc];
}

#pragma mark - draw cell

- (void)prepareForReuse {
  [super prepareForReuse];
  
  [self.chaterAvatarButton setImage:nil forState:UIControlStateNormal];
  self.timelineLabel.hidden = YES;
  self.messageLabel.text = NULL_PARAM_VALUE;
  self.messageLabel.hidden = YES;
  self.messageLabel.enabled = NO;
  self.photoImageView.hidden = YES;
  self.photoImageView.image = nil;
  
  self.imageUrl = nil;
  self.avatarUrl = nil;
  
  self.currentPopTipViewTarget = nil;
  
  self.visiblePopTipViews = [NSMutableArray array];
}

- (void)drawTimeline:(NSString *)timeline {
  self.timelineLabel.text = timeline;
  self.timelineLabel.hidden = NO;
  CGSize size = [CommonUtils sizeForText:timeline
                                    font:self.timelineLabel.font];
  CGFloat timelineHeight = size.height + MARGIN * 2;
  CGFloat timelineWidth = size.width + MARGIN * 2;
  self.timelineLabel.frame = CGRectMake((self.frame.size.width - timelineWidth)/2.0f, 0, timelineWidth, timelineHeight);
}

- (void)arrangeMessageButtonForIsMe:(BOOL)isMe buttonWidth:(CGFloat)buttonWidth buttonHeight:(CGFloat)buttonHeight {
  
  [self.messageButton setBackgroundImage:nil forState:UIControlStateNormal];
  [self.messageButton setBackgroundImage:nil forState:UIControlStateHighlighted];
  
  NSString *normalImageName = nil;
  NSString *highlightImageName = nil;
  CGFloat x = 0;
  if (isMe) {
    normalImageName = @"myNormalBubble.png";
    highlightImageName = @"myHighlightBubble.png";
    x = self.chaterAvatarButton.frame.origin.x - MARGIN - buttonWidth;
  } else {
    normalImageName = @"friendNormalBubble.png";
    highlightImageName = @"friendHighlightBubble.png";
    x = self.chaterAvatarButton.frame.origin.x + self.chaterAvatarButton.frame.size.width + MARGIN;
  }
  
  self.messageButton.frame = CGRectMake(x,
                                        self.chaterAvatarButton.frame.origin.y - 2,
                                        buttonWidth, buttonHeight);
  
  UIImage *stretchedNormalImage = nil;
  UIImage *stretchedHighlightImage = nil;
  if (CURRENT_OS_VERSION < IOS5) {
    stretchedNormalImage = [IMAGE_WITH_NAME(normalImageName) stretchableImageWithLeftCapWidth:BUBBLE_EDGE_X
                                                                                 topCapHeight:BUBBLE_EDGE_Y];
    stretchedHighlightImage = [IMAGE_WITH_NAME(highlightImageName) stretchableImageWithLeftCapWidth:BUBBLE_EDGE_Y
                                                                                       topCapHeight:BUBBLE_EDGE_Y];
  } else {
    stretchedNormalImage = [IMAGE_WITH_NAME(normalImageName) resizableImageWithCapInsets:UIEdgeInsetsMake(BUBBLE_EDGE_Y,BUBBLE_EDGE_X, BUBBLE_EDGE_Y, BUBBLE_EDGE_X)];
    stretchedHighlightImage = [IMAGE_WITH_NAME(highlightImageName) resizableImageWithCapInsets:UIEdgeInsetsMake(BUBBLE_EDGE_Y,BUBBLE_EDGE_X, BUBBLE_EDGE_Y, BUBBLE_EDGE_X)];
  }
  
  [self.messageButton setBackgroundImage:stretchedNormalImage forState:UIControlStateNormal];
  [self.messageButton setBackgroundImage:stretchedHighlightImage forState:UIControlStateHighlighted];
  
}

- (void)drawPhotoWithChatInfo:(Post *)chatInfo isMe:(BOOL)isMe {
  
  self.thumbnailUrl = chatInfo.thumbnailUrl;
  self.imageUrl = chatInfo.imageUrl;
  
  NSMutableArray *urls = [NSMutableArray array];
  if (self.thumbnailUrl.length > 0) {
    [urls addObject:self.thumbnailUrl];
  }
  
  if (self.imageUrl.length > 0) {
    [urls addObject:self.imageUrl];
  }
  
  if (urls.count > 0) {
    
    self.photoImageView.hidden = NO;
    
    CGFloat height = MIN_BUBBLE_HEIGHT + MARGIN * 4;
    CGFloat width = MIN_BUBBLE_WIDTH + MARGIN * 4;
    
    [self arrangeMessageButtonForIsMe:isMe buttonWidth:width buttonHeight:height];
    
    CGFloat x = 0;
    if (isMe) {
      x = (width - MIN_BUBBLE_WIDTH)/2.0f - 3;
    } else {
      x = (width - MIN_BUBBLE_WIDTH)/2.0f + 3;
    }
    self.photoImageView.frame = CGRectMake(x, (height - MIN_BUBBLE_HEIGHT)/2.0f, MIN_BUBBLE_WIDTH, MIN_BUBBLE_HEIGHT);
    
    [self fetchImage:urls forceNew:NO];
  }
}

- (void)drawMessageButtonWithContent:(NSString *)messageContent isMe:(BOOL)isMe {
  
  [self.messageButton setBackgroundImage:nil forState:UIControlStateNormal];
  [self.messageButton setBackgroundImage:nil forState:UIControlStateHighlighted];
  
  self.messageLabel.text = messageContent;
  self.messageLabel.hidden = NO;
  self.messageLabel.enabled = YES;
  
  CGSize size = [CommonUtils sizeForText:messageContent
                                    font:self.messageLabel.font
                       constrainedToSize:CGSizeMake(MAX_MSG_WIDTH, CGFLOAT_MAX)
                           lineBreakMode:BREAK_BY_WORD_WRAPPING];
  
  CGFloat messageButtonHeight = size.height + MARGIN * 6;
  messageButtonHeight = messageButtonHeight < MIN_BUBBLE_HEIGHT ? MIN_BUBBLE_HEIGHT : messageButtonHeight;
  
  CGFloat messageButtonWidth = size.width + MARGIN * 4 + MARGIN;
  messageButtonWidth = messageButtonWidth < MIN_BUBBLE_WIDTH ? MIN_BUBBLE_WIDTH : messageButtonWidth;
  
  [self arrangeMessageButtonForIsMe:isMe buttonWidth:messageButtonWidth buttonHeight:messageButtonHeight];
  
  CGFloat x = 0;
  if (isMe) {
    x = (messageButtonWidth - MARGIN * 2 - size.width)/2.0f;
  } else {
    x = (messageButtonWidth - MARGIN * 2 - size.width)/2.0f + MARGIN * 2;
  }
  self.messageLabel.frame = CGRectMake(x, (messageButtonHeight - size.height)/2.0f, size.width, size.height);
}

- (void)drawAvatarWithImageUrl:(NSString *)imageUrl x:(CGFloat)x {
  
  self.avatarUrl = imageUrl;
  
  [self.chaterAvatarButton setImage:nil forState:UIControlStateNormal];
  
  self.chaterAvatarButton.frame = CGRectMake(x,
                                             self.timelineLabel.frame.origin.y + self.timelineLabel.frame.size.height
                                             + MARGIN * 2, AVATAR_SIDE_LEN, AVATAR_SIDE_LEN);
  [self fetchImage:[NSMutableArray arrayWithObject:imageUrl] forceNew:NO];
}

- (void)drawMyMessageWithChatInfo:(Post *)chatInfo {
  
  // timeline
  [self drawTimeline:chatInfo.elapsedTime];
  
  // avatar
  [self drawAvatarWithImageUrl:chatInfo.authorPicUrl
                             x:self.frame.size.width - MARGIN * 2 - AVATAR_SIDE_LEN];
  
  if (chatInfo.imageUrl.length > 0 && chatInfo.thumbnailUrl.length > 0) {
    [self drawPhotoWithChatInfo:chatInfo isMe:YES];
  } else {
    // message body
    [self drawMessageButtonWithContent:chatInfo.content isMe:YES];
  }
}

- (void)drawFriendMessageWithChatInfo:(Post *)chatInfo {
  // timeline
  [self drawTimeline:chatInfo.elapsedTime];
  
  // avatar
  [self drawAvatarWithImageUrl:chatInfo.authorPicUrl
                             x:MARGIN * 2];
  
  if (chatInfo.imageUrl.length > 0) {
    [self drawPhotoWithChatInfo:chatInfo isMe:NO];
  } else {
    // message body
    [self drawMessageButtonWithContent:chatInfo.content isMe:NO];
  }
}

- (void)drawCellWithChatInfo:(Post *)chatInfo {
  
  self.chatterId = chatInfo.authorId;
  
  if ([[AppManager instance].personId isEqualToString:chatInfo.authorId]) {
    [self drawMyMessageWithChatInfo:chatInfo];
  } else {
    [self drawFriendMessageWithChatInfo:chatInfo];
  }
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if ([url isEqualToString:self.avatarUrl]) {
    [self.chaterAvatarButton.layer addAnimation:[self imageTransition] forKey:nil];
    
    [self.chaterAvatarButton setImage:[CommonUtils cutPartImage:image
                                                          width:AVATAR_SIDE_LEN
                                                         height:AVATAR_SIDE_LEN]
                             forState:UIControlStateNormal];
  } else if ([url  isEqualToString:self.thumbnailUrl]) {
    [self.photoImageView.layer addAnimation:[self imageTransition] forKey:nil];
    
    self.photoImageView.image = [CommonUtils cutMiddlePartImage:image
                                                          width:MIN_BUBBLE_WIDTH
                                                         height:MIN_BUBBLE_HEIGHT];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  if ([url isEqualToString:self.avatarUrl]) {
    
    [self.chaterAvatarButton setImage:[CommonUtils cutPartImage:image
                                                          width:AVATAR_SIDE_LEN
                                                         height:AVATAR_SIDE_LEN]
                             forState:UIControlStateNormal];
  } else if ([url  isEqualToString:self.thumbnailUrl]) {
    self.photoImageView.image = [CommonUtils cutMiddlePartImage:image
                                                          width:MIN_BUBBLE_WIDTH
                                                         height:MIN_BUBBLE_HEIGHT];
  }
}

#pragma mark - arrange for pop view
- (void)dismissAllPopTipViews {
	while ([self.visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = (self.visiblePopTipViews)[0];
		[self.visiblePopTipViews removeObjectAtIndex:0];
		[popTipView dismissAnimated:YES];
	}
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
  [super setHighlighted:highlighted animated:animated];
  [self dismissAllPopTipViews];
}

- (void)doPopView:(id)sender {
  [self dismissAllPopTipViews];
  
  if (sender == self.currentPopTipViewTarget) {
		// Dismiss the popTipView and that is all
		self.currentPopTipViewTarget = nil;
	} else {
    CMPopTipView *popTipView = [[[CMPopTipView alloc] initWithMessage:LocaleStringForKey(NSCopyTitle, nil)] autorelease];
    popTipView.delegate = self;
    popTipView.backgroundColor = [UIColor blackColor];
    popTipView.textColor = [UIColor whiteColor];
    popTipView.animation = arc4random() % 2;
    
    UIViewController *vc = nil;
    if (_chatterDelegate) {
      vc = (UIViewController *)_chatterDelegate;
    }
    [popTipView presentPointingAtView:self.messageLabel inView:vc.view animated:YES];
    [self.visiblePopTipViews addObject:popTipView];
    self.currentPopTipViewTarget = sender;
  }
}

#pragma mark - CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
  [self.visiblePopTipViews removeObject:popTipView];
  self.currentPopTipViewTarget = nil;
  
  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
  [pasteboard setString:self.messageLabel.text];
}

@end
