//
//  CompanyManagerCell.m
//  iAlumni
//
//  Created by Adam on 13-9-8.
//
//

#import "CompanyManagerCell.h"
#import "WXWLabel.h"
#import "HintEnlargedButton.h"
#import "Alumni.h"
#import "CommonUtils.h"

#define CHAT_WIDTH    20.0f
#define CHAT_HEIGHT   18.0f

#define WITH_TITLE_HEIGHT     105.0f
#define WITHOUT_TITLE_HEIGHT  70.0f

#define AVATAR_SIDE_LEN       50.0f

#define NAME_MAX_WIDTH        125.0f
#define CLASS_MAX_WIDTH       80.0f
#define JOB_TITLE_MAX_WIDTH   185.0f

@interface CompanyManagerCell ()
@property (nonatomic, retain) Alumni *currentAlumni;
@end

@implementation CompanyManagerCell

#pragma mark - user action
- (void)chatWithAlumni:(id)sender {
  if (_brandInfoVC && _chatAction) {
    [_brandInfoVC performSelector:_chatAction withObject:self.currentAlumni];
  }
}

#pragma mark - lifecycle methods
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
        brandInfoVC:(UIViewController *)brandInfoVC
         chatAction:(SEL)chatAction {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    _brandInfoVC = brandInfoVC;
    
    _chatAction = chatAction;
    
    _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:NAVIGATION_BAR_COLOR
                                       shadowColor:TRANSPARENT_COLOR
                                              font:BOLD_FONT(20)] autorelease];
    [self.contentView addSubview:_titleLabel];
    
    _avatar = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN * 2, 0, AVATAR_SIDE_LEN, AVATAR_SIDE_LEN)] autorelease];
    [self.contentView addSubview:_avatar];
    
    _nameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:DARK_TEXT_COLOR
                                       shadowColor:TRANSPARENT_COLOR
                                              font:BOLD_FONT(15)] autorelease];
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_nameLabel];

    _classLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:BASE_INFO_COLOR
                                       shadowColor:TRANSPARENT_COLOR
                                              font:BOLD_FONT(13)] autorelease];
    _classLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_classLabel];
    
    _separatorLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero textColor:[UIColor blackColor] shadowColor:TRANSPARENT_COLOR font:FONT(15)] autorelease];
    _separatorLabel.text = @"|";
    CGSize size = [_separatorLabel.text sizeWithFont:_separatorLabel.font];
    _separatorLabel.frame = CGRectMake(0, 0, size.width, size.height);
    [self.contentView addSubview:_separatorLabel];

    _jobTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:BASE_INFO_COLOR
                                       shadowColor:TRANSPARENT_COLOR
                                              font:BOLD_FONT(15)] autorelease];
    _jobTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_jobTitleLabel];
    
    _chatButton = [HintEnlargedButton buttonWithType:UIButtonTypeCustom];
    _chatButton.showsTouchWhenHighlighted = YES;
    [_chatButton setImage:[UIImage imageNamed:@"redChat.png"] forState:UIControlStateNormal];
    _chatButton.frame = CGRectMake(302 - 30 - CHAT_WIDTH,
                                    0, CHAT_WIDTH , CHAT_HEIGHT);
    [_chatButton addTarget:self
                    action:@selector(chatWithAlumni:)
          forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:_chatButton];

  }
  return self;
}

- (void)dealloc {
  
  self.currentAlumni = nil;
  
  [super dealloc];
}

- (void)drawCellWithAlumni:(Alumni *)alumni title:(NSString *)title {
  
  self.currentAlumni = alumni;
  
  if (alumni == nil) {
    return;
  }
  
  CGFloat imageY = MARGIN * 2;
  if (title.length > 0) {
    _titleLabel.text = title;
    CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font];
    _titleLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2, size.width, size.height);
    
    imageY = _titleLabel.frame.origin.y + size.height + MARGIN * 2;
  }
  
  _avatar.frame = CGRectMake(MARGIN * 2, imageY, AVATAR_SIDE_LEN, AVATAR_SIDE_LEN);
  if (alumni.imageUrl.length > 0) {
    [self fetchImage:[NSMutableArray arrayWithObject:alumni.imageUrl] forceNew:NO];
  }
  
  _nameLabel.text = alumni.name;
  CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font constrainedToSize:CGSizeMake(NAME_MAX_WIDTH, 15)];
  _nameLabel.frame = CGRectMake(_avatar.frame.origin.x + AVATAR_SIDE_LEN + MARGIN * 2, _avatar.frame.origin.y, size.width, size.height);
  
  _separatorLabel.frame = CGRectMake(_nameLabel.frame.origin.x + _nameLabel.frame.size.width + MARGIN, _nameLabel.frame.origin.y, _separatorLabel.frame.size.width, _separatorLabel.frame.size.height);
  
  _classLabel.text = alumni.classGroupName;
  size = [_classLabel.text sizeWithFont:_classLabel.font constrainedToSize:CGSizeMake(CLASS_MAX_WIDTH, 10)];
  _classLabel.frame = CGRectMake(_separatorLabel.frame.origin.x + _separatorLabel.frame.size.width + MARGIN, _separatorLabel.frame.origin.y, size.width, size.height);
  
  _jobTitleLabel.text = alumni.jobTitle;
  size = [_jobTitleLabel.text sizeWithFont:_jobTitleLabel.font constrainedToSize:CGSizeMake(JOB_TITLE_MAX_WIDTH, 20)];
  _jobTitleLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _avatar.frame.origin.y + _avatar.frame.size.height - size.height, size.width, size.height);
  
  _chatButton.frame = CGRectMake(_chatButton.frame.origin.x,
                                 _avatar.frame.origin.y + _avatar.frame.size.height - CHAT_HEIGHT,
                                 _chatButton.frame.size.width,
                                 _chatButton.frame.size.height);
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  [_avatar.layer addAnimation:[self imageTransition] forKey:nil];
  
  _avatar.image = [CommonUtils cutMiddlePartImage:image width:AVATAR_SIDE_LEN height:AVATAR_SIDE_LEN];
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  _avatar.image = [CommonUtils cutMiddlePartImage:image width:AVATAR_SIDE_LEN height:AVATAR_SIDE_LEN];
}
@end
