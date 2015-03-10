//
//  BranchCell.m
//  iAlumni
//
//  Created by Adam on 12-8-24.
//
//

#import "BranchCell.h"
#import "WXWLabel.h"
#import "ServiceItem.h"
#import "TextConstants.h"
#import "AppManager.h"
#import "CommonUtils.h"


#define ITEM_IMG_WIDTH				50.0f
#define ITEM_IMG_HEIGHT				50.0f
#define ADDRESS_Y    					35.0f
#define BASE_INFO_HEIGHT      15.0f

#define STATUS_Y              58.0f
#define COMMENT_X             140.0f

#define ICON_WIDTH            16.0f
#define ICON_HEIGHT           16.0f

#define LABEL_WIDTH           120.0f
#define LABEL_HEIGHT          20.0f

#define ITEM_NAME_WIDTH				220.0f
#define ITEM_NAME_HEIGHT			20.0f

@implementation BranchCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC {
  
  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
                          MOC:MOC];
  
  if (self) {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.backgroundColor = SERVICE_ITEM_CELL_COLOR;
    
    CGFloat backgroundViewSideLength = ITEM_IMG_WIDTH + 10.0f;
    UIView *imageBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN,
                                                                            (80.0f - backgroundViewSideLength)/2,
                                                                            backgroundViewSideLength,
                                                                            backgroundViewSideLength)] autorelease];
    imageBackgroundView.backgroundColor = [UIColor whiteColor];
    imageBackgroundView.layer.borderWidth = 1.0f;
    imageBackgroundView.layer.borderColor = COLOR(227, 227, 227).CGColor;
    [self.contentView addSubview:imageBackgroundView];
    
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN, MARGIN, ITEM_IMG_WIDTH, ITEM_IMG_HEIGHT)];
    _avatarView.backgroundColor = TRANSPARENT_COLOR;
    [imageBackgroundView addSubview:_avatarView];
    
    _nameLabel = [self initLabel:CGRectMake(MARGIN + imageBackgroundView.frame.size.width + MARGIN * 2,
                                            MARGIN, ITEM_NAME_WIDTH, ITEM_NAME_HEIGHT)
                       textColor:DARK_TEXT_COLOR
                     shadowColor:[UIColor whiteColor]];
    _nameLabel.font = FONT(16);
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_nameLabel];
    
    _addressLabel = [self initLabel:CGRectMake(_nameLabel.frame.origin.x,
                                               ADDRESS_Y, 0, BASE_INFO_HEIGHT)
                          textColor:[UIColor blackColor]
                        shadowColor:[UIColor whiteColor]];
    _addressLabel.font = FONT(12);
    [self.contentView addSubview:_addressLabel];

    _likeIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x,
                                                                   STATUS_Y + 2, ICON_WIDTH, ICON_HEIGHT)];
    _likeIndicator.backgroundColor = TRANSPARENT_COLOR;
    _likeIndicator.image = [UIImage imageNamed:@"like.png"];
    [self.contentView addSubview:_likeIndicator];
    
    _likeCountLabel = [self initLabel:CGRectMake(_likeIndicator.frame.origin.x + ICON_WIDTH + MARGIN,
                                                 STATUS_Y + 2.0f, LABEL_WIDTH, LABEL_HEIGHT)
                            textColor:BASE_INFO_COLOR
                          shadowColor:[UIColor whiteColor]];
    _likeCountLabel.font = FONT(12);
    [self.contentView addSubview:_likeCountLabel];
    
    _commentIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(COMMENT_X,
                                                                      STATUS_Y + 2, ICON_WIDTH, ICON_HEIGHT)];
    _commentIndicator.backgroundColor = TRANSPARENT_COLOR;
    _commentIndicator.image = [UIImage imageNamed:@"commentGray.png"];
    [self.contentView addSubview:_commentIndicator];
    
    _commentCountLabel = [self initLabel:CGRectMake(COMMENT_X + ICON_WIDTH + MARGIN,
                                                    STATUS_Y + 2.0f,
                                                    LABEL_WIDTH, LABEL_HEIGHT)
                               textColor:BASE_INFO_COLOR
                             shadowColor:[UIColor whiteColor]];
    _commentCountLabel.font = FONT(12);
    [self.contentView addSubview:_commentCountLabel];
    
    _distanceLabel = [self initLabel:CGRectMake(0, STATUS_Y + MARGIN, 0, BASE_INFO_HEIGHT)
                           textColor:BASE_INFO_COLOR
                         shadowColor:[UIColor whiteColor]];
    _distanceLabel.font = FONT(12);
    [self.contentView addSubview:_distanceLabel];
    
  }
  
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_avatarView);
  RELEASE_OBJ(_nameLabel);
  RELEASE_OBJ(_addressLabel);
  RELEASE_OBJ(_likeIndicator);
  RELEASE_OBJ(_likeCountLabel);
  RELEASE_OBJ(_commentIndicator);
  RELEASE_OBJ(_commentCountLabel);
  RELEASE_OBJ(_distanceLabel);
  
  [super dealloc];
}

- (void)prepareForReuse {
  [super prepareForReuse];
  
  _avatarView.image = nil;
}

- (void)drawItem:(ServiceItem *)item index:(NSInteger)index {

  NSString *imageName = item.liked.boolValue ? @"like.png" : @"unlike.png";
  
  _likeIndicator.image = [UIImage imageNamed:imageName];
  
  _nameLabel.text = item.itemName;
  
  _addressLabel.text = item.address;

  _addressLabel.frame = CGRectMake(_addressLabel.frame.origin.x,
                                   _addressLabel.frame.origin.y,
                                   ITEM_NAME_WIDTH - 20.0f, _addressLabel.frame.size.height);
  
  _likeCountLabel.text = [NSString stringWithFormat:@"%@", item.likeCount];
  _commentCountLabel.text = [NSString stringWithFormat:@"%@", item.commentCount];
  if (item.likeCount.intValue > 0) {
    _likeCountLabel.hidden = NO;
    _likeIndicator.hidden = NO;
  } else {
    _likeCountLabel.hidden = YES;
    _likeIndicator.hidden = YES;
  }
  if (item.commentCount.intValue > 0) {
    _commentCountLabel.hidden = NO;
    _commentIndicator.hidden = NO;
  } else {
    _commentCountLabel.hidden = YES;
    _commentIndicator.hidden = YES;
  }
  
  _distanceLabel.text = [NSString stringWithFormat:@"%.2f %@",
                         item.distance.floatValue,
                         LocaleStringForKey(NSKMTitle, nil)];
  
  CGSize size = [_distanceLabel.text sizeWithFont:_distanceLabel.font
                         constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
  
  _distanceLabel.frame = CGRectMake(self.frame.size.width - MARGIN * 5 - size.width,
                                    _distanceLabel.frame.origin.y,
                                    size.width, _distanceLabel.frame.size.height);
  
  if (item.thumbnailUrl && item.thumbnailUrl.length > 0) {
    NSMutableArray *urls = [NSMutableArray array];
    [urls addObject:item.thumbnailUrl];
    [self fetchImage:urls forceNew:NO];
  } else {
    _avatarView.image = nil;
  }
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    _avatarView.image = nil;
  }
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    [_avatarView.layer addAnimation:[self imageTransition] forKey:nil];
    _avatarView.image = [CommonUtils cutPartImage:image width:ITEM_IMG_WIDTH height:ITEM_IMG_HEIGHT];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  _avatarView.image = [CommonUtils cutPartImage:image
                                          width:ITEM_IMG_WIDTH
                                         height:ITEM_IMG_HEIGHT];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

@end
