//
//  HotNewsCell.m
//  iAlumni
//
//  Created by Adam on 12-10-25.
//
//

#import "HotNewsCell.h"
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "News.h"

#define SHORT_TITLE_WIDTH   220.0f
#define LONG_TITLE_WIDTH    300.0f
#define AUTHOR_WIDTH        120.0f
#define IMAGE_SIDE_LENGTH   70.0f
#define ICON_WIDTH          16.0f
#define TITLE_MAX_HEIGHT    70.0f

@implementation HotNewsCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC {
  
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];
  
  if (self) {
    
    self.contentView.backgroundColor = CELL_COLOR;
    _titleLabel = [self initLabel:CGRectZero
                        textColor:DARK_TEXT_COLOR
                      shadowColor:[UIColor whiteColor]];
    _titleLabel.font = BOLD_FONT(15);
    _titleLabel.backgroundColor = TRANSPARENT_COLOR;
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _titleLabel.numberOfLines = 0;
    [self.contentView addSubview:_titleLabel];
    
    _imageBackgroundView = [[UIView alloc] init];
    _imageBackgroundView.backgroundColor = [UIColor whiteColor];
    _imageBackgroundView.layer.borderWidth = 1.0f;
    _imageBackgroundView.layer.borderColor = COLOR(227, 227, 227).CGColor;
    [self.contentView addSubview:_imageBackgroundView];
    
    _newsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN, MARGIN,
                                                                   IMAGE_SIDE_LENGTH - MARGIN * 2,
                                                                   IMAGE_SIDE_LENGTH - MARGIN * 2)];
    _newsImageView.backgroundColor = TRANSPARENT_COLOR;
    [_imageBackgroundView addSubview:_newsImageView];
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_titleLabel);
  RELEASE_OBJ(_newsImageView);
  RELEASE_OBJ(_imageBackgroundView);
  
  [super dealloc];
}

- (void)drawNews:(News *)news {
  
  BOOL hasImage = (news.imageUrl && [news.imageUrl length] > 0) ? YES : NO;
  
  CGFloat titleWidth = 0;
  if (hasImage) {
    titleWidth = SHORT_TITLE_WIDTH;
  } else {
    titleWidth = LONG_TITLE_WIDTH;
  }
  
  if (news.title && [news.title length] > 0) {
    _titleLabel.text = news.title;
  } 
  
  CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font
                             constrainedToSize:CGSizeMake(titleWidth, TITLE_MAX_HEIGHT)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  
  _titleLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2, titleWidth, size.height);
  
  if (hasImage) {
    _imageBackgroundView.hidden = NO;
    _imageBackgroundView.frame = CGRectMake(self.bounds.size.width - MARGIN * 2 - IMAGE_SIDE_LENGTH, MARGIN * 2,
                                            IMAGE_SIDE_LENGTH, IMAGE_SIDE_LENGTH);
    
    [self fetchImage:[NSMutableArray arrayWithObject:news.imageUrl] forceNew:NO];
  } else {
    _imageBackgroundView.hidden = YES;
  }
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    _newsImageView.image = nil;
  }
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    [_newsImageView.layer addAnimation:[self imageTransition] forKey:nil];
    _newsImageView.image = [WXWCommonUtils cutPartImage:image
                                                  width:_newsImageView.frame.size.width
                                                 height:_newsImageView.frame.size.height];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  _newsImageView.image = [WXWCommonUtils cutMiddlePartImage:image
                                                width:_newsImageView.frame.size.width
                                               height:_newsImageView.frame.size.height];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}


@end