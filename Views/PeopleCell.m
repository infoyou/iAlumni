//
//  PeopleCell.m
//  iAlumni
//
//  Created by Adam on 12-7-31.
//
//

#import "PeopleCell.h"
#import "ECGradientButton.h"
#import "CommonUtils.h"
#import "ECAsyncConnectorFacade.h"
#import "AppManager.h"
#import "TextConstants.h"
#import "Alumni.h"
#import "Member.h"

#define FONT_SIZE                   14.0f
#define TOP_OFFSET                  5.0f
#define COMMENT_IND_PORTRAIT_X      265.0f
#define COMMENT_IND_WIDTH           20.0f
#define LOC_IND_PORTRAIT_X          282.0f
#define LOC_IND_WIDTH               10.0f
#define IMG_IND_PORTRAIT_X          298.0f
#define IMG_IND_HEIGHT              15.0f
#define IND_WIDTH                   15.0f
#define IND_HEIGHT                  10.0f
#define TIMELINE_PORTRAIT_X         235.0f

#define COMMENT_SUM_LABEL_WIDTH     60.0f

#define NEW_COMMENT_IND_WIDTH       40.0f//30.0f
#define NEW_COMMENT_IND_HEIGHT      40.0f//16.0f

#define OPEN_IMG_BTN_WIDTH          80.0f
#define OPEN_IMG_BTN_HEIGHT         20.0f
#define OPEN_IMG_BTN_X              PHOTO_SIDE_LEN + MARGIN * 2
#define OPEN_IMG_BTN_Y              MARGIN

#define CONTENT_X                   MARGIN * 2 + PHOTO_WIDTH + PHOTO_MARGIN * 2

#define CONTENT_W                   SCREEN_WIDTH - CONTENT_X - 9.0f
#define NAME_W                      144.0f
#define CLASS_W                     CONTENT_W - NAME_W
#define SHAKE_PLACE_W               150.0f
#define SHAKE_THING_W               CONTENT_W - SHAKE_PLACE_W

// landscape
#define CELL_CONTENT_LANDSCAPE_WIDTH  440.0f
#define TIMELINE_LANDSCAPE_X          395.0f
#define LOC_IND_LANDSCAPE_X           442.0f
#define IMG_IND_LANDSCAPE_X           458.0f
#define COMMENT_IND_LANDSCAPE_X       425.0f

#define PHOTO_WIDTH                   56.0f
#define PHOTO_HEIGHT                  58.0f



enum{
  iconTag = 0,
  companyTag,
  memberTag,
  classTag,
};

@interface PeopleCell()
@property (nonatomic, copy) NSString *alumniName;
@property (nonatomic, copy) NSString *classGroupName;
@property (nonatomic, copy) NSString *imageUrl;
@end

@implementation PeopleCell

@synthesize editorImageShadowView;
@synthesize companyLabel;
@synthesize nameLabel;
@synthesize classLabel;
@synthesize alumni = _alumni;

- (void)initView{
  
  // set editor image view
  _imageBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(MARGIN,
                                                                   MARGIN,
                                                                   PHOTO_WIDTH + PHOTO_MARGIN * 2,
                                                                   PHOTO_HEIGHT + PHOTO_MARGIN * 2)] autorelease];

  _imageBackgroundView.backgroundColor = [UIColor whiteColor];
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(1, 1,
                                                                         _imageBackgroundView.frame.size.width - 2,
                                                                         _imageBackgroundView.frame.size.height - 1)];
  
  _imageBackgroundView.layer.shadowPath = shadowPath.CGPath;
  _imageBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  _imageBackgroundView.layer.shadowOpacity = 0.9f;
  _imageBackgroundView.layer.shadowRadius = 1.0f;
  _imageBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
  _imageBackgroundView.layer.masksToBounds = NO;
  [self.contentView addSubview:_imageBackgroundView];
  
  _photoImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(PHOTO_MARGIN,
                                                                   PHOTO_MARGIN,
                                                                   PHOTO_WIDTH,
                                                                   PHOTO_HEIGHT)] autorelease];
  
  _photoImageView.backgroundColor = [UIColor whiteColor];
  [_imageBackgroundView addSubview:_photoImageView];
  
  // set name Label
  nameLabel = [self initLabel:CGRectZero
                    textColor:[UIColor blackColor]
                  shadowColor:[UIColor whiteColor]];
  nameLabel.tag = memberTag;
  nameLabel.font = Arial_FONT(FONT_SIZE);
  nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  [self.contentView addSubview:nameLabel];
  
  // set classLabel
  classLabel = [self initLabel:CGRectZero
                     textColor:[UIColor darkGrayColor]
                   shadowColor:[UIColor whiteColor]];
  classLabel.tag = classTag;
  [classLabel setFont:FONT(FONT_SIZE-1)];
  classLabel.backgroundColor = TRANSPARENT_COLOR;
  [self.contentView addSubview:classLabel];
  
  // set company Label
  companyLabel = [self initLabel:CGRectZero
                       textColor:BASE_INFO_COLOR
                     shadowColor:[UIColor whiteColor]];
  companyLabel.tag = companyTag;
  companyLabel.font = FONT(FONT_SIZE-1);
  companyLabel.numberOfLines = 0;
  [self.contentView addSubview:companyLabel];
  
  
  self.contentView.backgroundColor = CELL_COLOR;
  self.selectedBackgroundView.backgroundColor = [UIColor blueColor];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    [self initView];
  }
  return self;
}

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
		[self initView];
  }
	
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  
  [super setSelected:selected animated:animated];
}

- (void)dealloc {
  RELEASE_OBJ(nameLabel);
  RELEASE_OBJ(classLabel);
	RELEASE_OBJ(companyLabel);
  
  self.alumni = nil;
  
  self.imageUrl = nil;
  self.alumniName = nil;
  self.classGroupName = nil;
  
  [super dealloc];
}

#pragma mark - overwrite methods
- (void)openImg:(id)sender {
}

- (void)openChat:(id)sender {
  if (_delegate) {
    [_delegate doChat:self.alumni];
  }
}

- (void)drawAvatar:(NSString *)imageUrl {
  if (imageUrl && imageUrl.length > 0 ) {
    NSMutableArray *urls = [NSMutableArray array];
    [urls addObject:imageUrl];
    [self fetchImage:urls forceNew:NO];
  } else {
    _photoImageView.image = nil;
  }
}

#pragma mark - customize methods

- (void)drawContent {
  //NSString *companyName = alumni.companyName;
  
  CGSize constraint;
  
  // show avatar
  [self drawAvatar:self.imageUrl];
  
  // Name
  constraint = CGSizeMake(NAME_W, 20);
  
	CGSize nameSize = [self.alumniName sizeWithFont:Arial_FONT(FONT_SIZE)
                           constrainedToSize:constraint
                               lineBreakMode:NSLineBreakByTruncatingTail];
  
  nameLabel.frame = CGRectMake(CONTENT_X, TOP_OFFSET, constraint.width, nameSize.height);
	nameLabel.text = self.alumniName;
  
  // Class
  constraint = CGSizeMake(CLASS_W, 20);
  
  if (![NULL_PARAM_VALUE isEqualToString:self.classGroupName] && self.classGroupName.length > 0) {
    classLabel.text = [NSString stringWithFormat:@" | %@", self.classGroupName];
  }
  CGSize classNameSize = [classLabel.text sizeWithFont:FONT(FONT_SIZE-1)
                                     constrainedToSize:constraint
                                         lineBreakMode:NSLineBreakByTruncatingTail];
  
  classLabel.frame = CGRectMake(CONTENT_X+nameSize.width, TOP_OFFSET+1, CLASS_W, classNameSize.height);
}

- (void)drawCell:(Alumni*)alumni
{
  self.alumni = alumni;
  
  self.alumniName = alumni.name;
  self.classGroupName = alumni.classGroupName;
  self.imageUrl = alumni.imageUrl;

  [self drawContent];
}

- (void)drawCellWithAuthorImageUrl:(NSString *)imageUrl
                    classGroupName:(NSString *)classGroupName
                        authorName:(NSString *)authorName {
  
  self.alumniName = authorName;
  self.classGroupName = classGroupName;
  self.imageUrl = imageUrl;
  
  [self drawContent];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    _photoImageView.image = nil;
  }
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {

    CATransition *imageFadein = [CATransition animation];
    imageFadein.duration = FADE_IN_DURATION;
    imageFadein.type = kCATransitionFade;
    [_photoImageView.layer addAnimation:imageFadein forKey:nil];
        
    _photoImageView.image = [CommonUtils cutPartImage:image width:PHOTO_WIDTH height:PHOTO_HEIGHT];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  _photoImageView.image = [CommonUtils cutPartImage:image width:PHOTO_WIDTH height:PHOTO_HEIGHT];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}


@end
