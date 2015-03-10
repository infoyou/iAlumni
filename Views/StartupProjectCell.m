//
//  StartupProjectCell.m
//  iAlumni
//
//  Created by Adam on 13-3-7.
//
//

#import "StartupProjectCell.h"
#import "Event.h"
#import "UIImage-Extensions.h"

#define TITLE_HEIGHT      20.0f

#define SHORT_DESC_HEIGHT 15.0f

#define INDICATOR_TOP     25.0f
#define INDICATOR_WIDTH   16.0f
#define INDICATOR_HEIGHT  16.0f

#define FONT_SIZE         14.0f
#define POST_IMAGE_W          53.5f
#define POST_IMAGE_H          67.f

@implementation StartupProjectCell

@synthesize url = _url;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    UIImageView *_bgBackView = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN*2, MARGIN*2, 300.f, EVENT_LIST_CELL_HEIGHT-MARGIN)] autorelease];
    _bgBackView.backgroundColor = TRANSPARENT_COLOR;
    _bgBackView.image = [UIImage imageNamed:@"eventListCell.png"];
    [self.contentView addSubview:_bgBackView];
    
    // date line
    [self drawSplitLine:CGRectMake(MARGIN*2, MARGIN*2+27.5f, 296.f, 1.f) color:COLOR(216, 216, 216)];
    
    // date
    UIView *dateView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2, 300.f, 25.f)] autorelease];
    dateView.backgroundColor = TRANSPARENT_COLOR;
    [self.contentView addSubview:dateView];
    
    _dateLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN, 225.f, 20.f) textColor:COLOR(30, 30, 30) shadowColor:TRANSPARENT_COLOR] autorelease];
    _dateLabel.font = FONT(15);
    [dateView addSubview:_dateLabel];
    
    _eventDateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(252.f, 15.f, 59.5, 21)];
    _eventDateImageView.backgroundColor = TRANSPARENT_COLOR;
    _eventDateImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _eventDateImageView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    _eventDateImageView.image = [[UIImage imageNamed:@"eventDateLabel.png"] imageByScalingToSize:CGSizeMake(POST_IMAGE_W, POST_IMAGE_H)];
    [self.contentView addSubview:_eventDateImageView];
    
    _intervalDayLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(265.f, 15.f, 45.f, 18) textColor:COLOR(254, 254, 252) shadowColor:[UIColor clearColor]] autorelease];
    _intervalDayLabel.font = FONT(FONT_SIZE-2);
    [self.contentView addSubview:_intervalDayLabel];
    
    _postImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN*4, dateView.frame.origin.x+27.5f+MARGIN, POST_IMAGE_W, POST_IMAGE_H)];
    _postImageView.backgroundColor = TRANSPARENT_COLOR;
    _postImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _postImageView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    [self.contentView addSubview:_postImageView];
    
    _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero textColor:COLOR(50, 50, 50) shadowColor:[UIColor clearColor]] autorelease];
    _titleLabel.font = FONT(FONT_SIZE);
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:_titleLabel];
    
    _descLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero textColor:COLOR(102, 102, 102) shadowColor:[UIColor clearColor]] autorelease];
    _descLabel.font = FONT(FONT_SIZE-2);
    _descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_descLabel];
    
    _signUpCountLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero textColor:COLOR(168, 168, 168) shadowColor:[UIColor whiteColor]] autorelease];
    _signUpCountLabel.font = FONT(FONT_SIZE-1);
    [self.contentView addSubview:_signUpCountLabel];
        
  }
  
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_postImageView);
  
  self.url = nil;
  [super dealloc];
}

- (void)drawEvent:(Event *)event {
  
  // date
  NSDate *datetime = [CommonUtils convertDateTimeFromUnixTS:[event.date doubleValue]];
  if ([WXWSystemInfoManager instance].currentLanguageCode == EN_TY) {
    _dateLabel.text = [NSString stringWithFormat:@"%@-%@-%@ %@",
                       [CommonUtils datetimeWithFormat:@"MMM" datetime:datetime],
                       [CommonUtils datetimeWithFormat:@"d" datetime:datetime],
                       [CommonUtils datetimeWithFormat:@"yyyy" datetime:datetime],
                       [CommonUtils datetimeWithFormat:@"EEE" datetime:datetime]];
  } else {
    _dateLabel.text = [NSString stringWithFormat:@"%@%@%@%@%@ %@",
                       [CommonUtils datetimeWithFormat:@"yyyy" datetime:datetime],
                       LocaleStringForKey(NSYearTitle, nil),
                       [CommonUtils datetimeWithFormat:@"MMM" datetime:datetime],
                       [CommonUtils datetimeWithFormat:@"d" datetime:datetime],
                       LocaleStringForKey(NSDayTitle, nil),
                       [CommonUtils datetimeWithFormat:@"EEE" datetime:datetime]];
  }
  // interval day
  int interValDay = [event.intervalDayCount intValue];
  [self drawInterValDay:interValDay];
  
  // title
  _titleLabel.text = event.title;
  _titleLabel.frame = CGRectMake(_postImageView.frame.origin.x + POST_IMAGE_W + MARGIN*2, _postImageView.frame.origin.y, 205.f, TITLE_HEIGHT);
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                             constrainedToSize:CGSizeMake(_titleLabel.frame.size.width, 35.0f)
                                 lineBreakMode:NSLineBreakByTruncatingTail];
  _titleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y, _titleLabel.frame.size.width, size.height);
  
  // desc
  _descLabel.text = event.hostName;
  _descLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y + size.height + 4, _titleLabel.frame.size.width - MARGIN, SHORT_DESC_HEIGHT);
  
  // line
  [self drawSplitLine:CGRectMake(_descLabel.frame.origin.x-1, 94.f, 270-POST_IMAGE_W, 0.5) color:COLOR(206, 206, 206)];
  
  // sign up
  _signUpCountLabel.frame = CGRectMake(_descLabel.frame.origin.x, 97.f, 90.f, 13.f);
  _signUpCountLabel.text = [NSString stringWithFormat:@"%@: %d%@", LocaleStringForKey(NSBackedProjectTile, nil), [event.backerCount intValue], LocaleStringForKey(NSEventPersonTitle, nil)];
  
  
  // line
  [self drawSplitLine:CGRectMake(178.f, 98.f, 0.5, 12) color:COLOR(216, 216, 216)];
  [self drawSplitLine:CGRectMake(178.5f, 98.f, 0.5, 12) color:COLOR(228, 228, 228)];
  
  UIImageView *arrowImgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_arrow.png"]] autorelease];
  arrowImgView.frame = CGRectMake(292.5f, 60.f, 9.f, 14.f);
  arrowImgView.backgroundColor = TRANSPARENT_COLOR;
  [self.contentView addSubview:arrowImgView];
  
  [self drawImage:event.imageUrl];
  
  //    [self setCellStyle:EVENT_LIST_CELL_HEIGHT];
}

- (void)drawSplitLine:(CGRect)lineFrame color:(UIColor *)color {
  
  UIView *splitLine = [[[UIView alloc] initWithFrame:lineFrame] autorelease];
  splitLine.backgroundColor = color;
  
  [self.contentView addSubview:splitLine];
}

- (void)drawImage:(NSString *)imageUrl
{
  UIImage *image = nil;
  if (imageUrl && [imageUrl length] > 0 ) {
    self.url = imageUrl;
    
    image = [[WXWImageManager instance].imageCache getImage:self.url];
    if (!image) {
      ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                      interactionContentType:IMAGE_TY] autorelease];
      [connFacade fetchGets:self.url];
    }
  } else {
    image = [[UIImage imageNamed:@"eventDefault.png"] imageByScalingToSize:CGSizeMake(POST_IMAGE_W, POST_IMAGE_H)];
  }
  
  if (image) {
    _postImageView.image = [WXWCommonUtils cutPartImage:image
                                                  width:_postImageView.frame.size.width
                                                 height:_postImageView.frame.size.height];//image;
  }
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
  _postImageView.image = [[UIImage imageNamed:@"eventDefault.png"] imageByScalingToSize:CGSizeMake(POST_IMAGE_W, POST_IMAGE_H)];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  if (url && url.length > 0) {
    UIImage *image = [UIImage imageWithData:result];
    if (image) {
      [[WXWImageManager instance].imageCache saveImageIntoCache:url image:image];
    }
    
    if ([url isEqualToString:self.url]) {
      _postImageView.image = image;
    }
  }
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
  
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
  
}

- (void)drawInterValDay:(int)interValDay{
  if (interValDay < 0) {
    _intervalDayLabel.hidden = YES;
    _eventDateImageView.hidden = YES;
    return;
  } else {
    _intervalDayLabel.hidden = NO;
    _eventDateImageView.hidden = NO;
  }
  
  if (0 == interValDay) {
    _intervalDayLabel.text = LocaleStringForKey(NSInProcessTitle, nil);
  } else {
    _intervalDayLabel.text = [NSString stringWithFormat:@"%d %@", interValDay, LocaleStringForKey(NSHoldDayTitle, nil)];
  }
  
}
@end
