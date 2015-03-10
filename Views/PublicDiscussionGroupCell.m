//
//  PublicDiscussionGroupCell.m
//  iAlumni
//
//  Created by Adam on 13-1-28.
//
//

#import "PublicDiscussionGroupCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Club.h"
#import "WXWLabel.h"

#define CONTENT_HEIGHT  62.0f
#define CONTENT_BACKGROUND_COLOR  COLOR(225,225,225)
#define ICON_SIDE_WIDTH  50.0f
#define ICON_SIDE_HEIGHT 39.0f

@implementation PublicDiscussionGroupCell

#pragma mark- lifecycle methods
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC {
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];
  if (self) {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    
    _contentBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2,
                                                                       MARGIN * 2,
                                                                       self.frame.size.width - MARGIN * 4,
                                                                       CONTENT_HEIGHT)] autorelease];
    _contentBackgroundView.backgroundColor = CONTENT_BACKGROUND_COLOR;
    [self.contentView addSubview:_contentBackgroundView];
    
    _thumbnailBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                         CONTENT_HEIGHT,
                                                                         CONTENT_HEIGHT)] autorelease];
    [_contentBackgroundView addSubview:_thumbnailBackgroundView];
    
    _thumbnial = [[[UIImageView alloc] initWithFrame:CGRectMake((_thumbnailBackgroundView.frame.size.width - ICON_SIDE_WIDTH)/2.0f, (_thumbnailBackgroundView.frame.size.height - ICON_SIDE_HEIGHT)/2.0f, ICON_SIDE_WIDTH, ICON_SIDE_HEIGHT)] autorelease];
    [_thumbnailBackgroundView addSubview:_thumbnial];
    
    _groupNameLabel = [[self initLabel:CGRectZero
                             textColor:DARK_TEXT_COLOR
                           shadowColor:[UIColor whiteColor]] autorelease];
    _groupNameLabel.font = BOLD_FONT(14);
    _groupNameLabel.numberOfLines = 1;
    _groupNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_contentBackgroundView addSubview:_groupNameLabel];
    
    _authorLabel = [[self initLabel:CGRectZero
                          textColor:DARK_TEXT_COLOR
                        shadowColor:[UIColor whiteColor]] autorelease];
    _authorLabel.font = BOLD_FONT(13);
    [_contentBackgroundView addSubview:_authorLabel];
    
    _contentLabel = [[self initLabel:CGRectZero
                           textColor:BASE_INFO_COLOR
                         shadowColor:[UIColor whiteColor]] autorelease];
    _contentLabel.font = BOLD_FONT(13);
    _contentLabel.numberOfLines = 1;
    [_contentBackgroundView addSubview:_contentLabel];
    
    _dateTimeLabel = [[self initLabel:CGRectZero
                            textColor:BASE_INFO_COLOR
                          shadowColor:[UIColor whiteColor]] autorelease];
    _dateTimeLabel.font = BOLD_FONT(11);
    [_contentBackgroundView addSubview:_dateTimeLabel];
    
  }
  return self;
}

- (void)dealloc {
  
  
  [super dealloc];
}


#pragma mark - draw cell
- (void)drawCellWithGroup:(Club *)group index:(NSInteger)index {

  if (group.iconUrl && group.iconUrl.length > 0) {
    [self fetchImage:[NSMutableArray arrayWithObject:group.iconUrl] forceNew:NO];
  }
  
  if (index % 2 == 0) {
    _thumbnailBackgroundView.backgroundColor = NAVIGATION_BAR_COLOR;
  } else {
    _thumbnailBackgroundView.backgroundColor = ORANGE_COLOR;
  }
  
  CGFloat limitedWidth = _contentBackgroundView.frame.size.width - _thumbnailBackgroundView.frame.size.width - MARGIN * 4;
  
  CGFloat nameLimitedWidth = limitedWidth;
  if (group.postTime.length && group.postTime.length > 0) {
    _dateTimeLabel.text = group.postTime;
    CGSize size = [_dateTimeLabel.text sizeWithFont:_dateTimeLabel.font
                                  constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                      lineBreakMode:NSLineBreakByWordWrapping];
    _dateTimeLabel.frame = CGRectMake(_contentBackgroundView.frame.size.width - MARGIN - size.width,
                                      MARGIN * 2 + 4.0f,
                                      size.width, size.height);
    _dateTimeLabel.hidden = NO;
    
    nameLimitedWidth -= (size.width + MARGIN * 2);
  } else {
    _dateTimeLabel.hidden = YES;
  }
  
  _groupNameLabel.text = group.clubName;
  CGSize size = [_groupNameLabel.text sizeWithFont:_groupNameLabel.font
                                 constrainedToSize:CGSizeMake(nameLimitedWidth, 20.0f)
                                     lineBreakMode:NSLineBreakByWordWrapping];
  _groupNameLabel.frame = CGRectMake(_thumbnailBackgroundView.frame.size.width + MARGIN * 2,
                                     MARGIN * 2,
                                     size.width, size.height);
  
  if (group.postAuthor && group.postAuthor.length > 0 &&
      group.postDesc && group.postDesc.length > 0) {
    
    _authorLabel.text = [NSString stringWithFormat:@"%@:", group.postAuthor];
    size = [_authorLabel.text sizeWithFont:_authorLabel.font
                         constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
    _authorLabel.frame = CGRectMake(_groupNameLabel.frame.origin.x,
                                    _groupNameLabel.frame.origin.y + _groupNameLabel.frame.size.height + MARGIN,
                                    size.width, size.height);
    
    _contentLabel.text = group.postDesc;
    size = [_contentLabel.text sizeWithFont:_contentLabel.font
                          constrainedToSize:CGSizeMake(limitedWidth - _authorLabel.frame.size.width - MARGIN, _authorLabel.frame.size.height)
                              lineBreakMode:NSLineBreakByTruncatingTail];
    _contentLabel.frame = CGRectMake(_authorLabel.frame.origin.x + _authorLabel.frame.size.width + MARGIN, _authorLabel.frame.origin.y, size.width, size.height);
    
    _authorLabel.hidden = NO;
    _contentLabel.hidden = NO;
  } else {
    _authorLabel.hidden = YES;
    _contentLabel.hidden = YES;
  }
}

#pragma mark - WXWImageFetcherDelegate methods

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {

  if ([self currentUrlMatchCell:url]) {
    [_thumbnial.layer addAnimation:[self imageTransition] forKey:nil];
    
    _thumbnial.image = [WXWCommonUtils cutPartImage:image
                                              width:ICON_SIDE_WIDTH
                                             height:ICON_SIDE_HEIGHT];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {

  if ([self currentUrlMatchCell:url]) {
    _thumbnial.image = [WXWCommonUtils cutPartImage:image
                                              width:ICON_SIDE_WIDTH
                                             height:ICON_SIDE_HEIGHT];
  }
}


@end
