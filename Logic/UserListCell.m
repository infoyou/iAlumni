//
//  UserListCell.m
//  CEIBS
//
//  Created by Adam on 10-10-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserListCell.h"
#import "ECGradientButton.h"
#import "WXWImageCache.h"
#import "UIImageButton.h"
#import "WXWAsyncConnectorFacade.h"
#import "ECInnerShadowImageView.h"
#import "WXWNumberBadge.h"

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

#define CONTENT_X                   MARGIN * 2 + IMAGE_W

#define CONTENT_W                   SCREEN_WIDTH - CONTENT_X - 9.0f
#define NAME_W                      150.0f
#define CLASS_W                     CONTENT_W - NAME_W
#define SHAKE_PLACE_W               150.0f
#define SHAKE_THING_W               CONTENT_W - SHAKE_PLACE_W

// landscape
#define CELL_CONTENT_LANDSCAPE_WIDTH  440.0f
#define TIMELINE_LANDSCAPE_X          395.0f
#define LOC_IND_LANDSCAPE_X           442.0f
#define IMG_IND_LANDSCAPE_X           458.0f
#define COMMENT_IND_LANDSCAPE_X       425.0f

#define IMAGE_W      60.f//    53.5f
#define IMAGE_H      60.f//    67.f
#define AVATAR_RADIUS     30.0f

enum {
  iconTag = 0,
  companyTag,
  memberTag,
  classTag,
};

@interface UserListCell()
@property (nonatomic, assign) id<ECClickableElementDelegate> delegate;
@property (nonatomic, retain) ECInnerShadowImageView *userImgView;
@property (nonatomic, copy) NSString *url;
@end

@implementation UserListCell
@synthesize chatImgView;
@synthesize editorImageShadowView;
@synthesize companyLabel;
@synthesize nameLabel;
@synthesize classLabel;

- (void)initView {
  
  // set editor image view
  self.userImgView = [[[ECInnerShadowImageView alloc] initCircleWithCenterPoint:CGPointMake(45, MARGIN * 2 + AVATAR_RADIUS)
                                                                         radius:AVATAR_RADIUS] autorelease];
  self.userImgView.frame = CGRectMake(MARGIN, MARGIN, IMAGE_W, IMAGE_H);
  self.userImgView.contentMode = UIViewContentModeScaleAspectFill;
  self.userImgView.backgroundColor = COLOR(234, 234, 234);
  self.userImgView.tag = iconTag;
  self.userImgView.layer.cornerRadius = 6.0f;
  self.userImgView.layer.masksToBounds = YES;
  self.userImgView.backgroundColor = TRANSPARENT_COLOR;
  self.userImgView.userInteractionEnabled = YES;
  [self.contentView addSubview:self.userImgView];
  
  /*
   UIButton *userImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
   userImgButton.frame = CGRectMake(0, 0, IMAGE_W, IMAGE_H);
   userImgButton.layer.cornerRadius = 6.0f;
   userImgButton.layer.masksToBounds = YES;
   //  _userImgButton.layer.borderWidth = 1.0f;
   //  _userImgButton.layer.borderColor = [UIColor grayColor].CGColor;
   //    _userImgButton.showsTouchWhenHighlighted = YES;
   [userImgButton addTarget:self action:@selector(openProfile:) forControlEvents:UIControlEventTouchUpInside];
   [self.userImgView addSubview:userImgButton];
   */
  
  [self.userImgView addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(openProfile:)] autorelease]];
  
  // set name Label
  nameLabel = [[UILabel alloc] init];
  nameLabel.tag = memberTag;
  nameLabel.font = Arial_FONT(FONT_SIZE);
  nameLabel.textColor = [UIColor blackColor];
  nameLabel.backgroundColor = TRANSPARENT_COLOR;
  nameLabel.highlightedTextColor = [UIColor whiteColor];
  nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  [self.contentView addSubview:nameLabel];
  
  // set classLabel
  classLabel = [[UILabel alloc] init];
  classLabel.tag = classTag;
  [classLabel setFont:FONT(FONT_SIZE-1)];
  classLabel.backgroundColor = TRANSPARENT_COLOR;
  classLabel.textColor = [UIColor darkGrayColor];
  [classLabel setHighlightedTextColor:[UIColor whiteColor]];
  [self.contentView addSubview:classLabel];
  
  // set company Label
  companyLabel = [[UILabel alloc] init];
  companyLabel.tag = companyTag;
  companyLabel.font = FONT(FONT_SIZE-1);
  companyLabel.textColor = [UIColor blackColor];
  companyLabel.backgroundColor = TRANSPARENT_COLOR;
  companyLabel.highlightedTextColor = [UIColor whiteColor];
  companyLabel.lineBreakMode = NSLineBreakByWordWrapping;
  companyLabel.numberOfLines = 2;
  [self.contentView addSubview:companyLabel];
  
  // chat
  chatImgView = [[UIImageView alloc] init];
  chatImgView.frame = CGRectMake(280.0f, 25.f, 25.f, 19.f);
  chatImgView.contentMode = UIViewContentModeScaleAspectFill;
  chatImgView.backgroundColor = COLOR(234, 234, 234);
  chatImgView.tag = iconTag;
  chatImgView.layer.cornerRadius = 6.0f;
  chatImgView.layer.masksToBounds = YES;
  chatImgView.backgroundColor = TRANSPARENT_COLOR;
  chatImgView.userInteractionEnabled = YES;
  chatImgView.image = [UIImage imageNamed:@"chat.png"];
  [self.contentView addSubview:chatImgView];
  
  _chatImgBut = [UIButton buttonWithType:UIButtonTypeCustom];
  _chatImgBut.frame = CGRectMake(280.0f-20.f, 25.f-10.f, 25.f+40.f, 19.f+20.f);
  [_chatImgBut addTarget:self action:@selector(openChat:) forControlEvents:UIControlEventTouchUpInside];
  //    [chatImgView addSubview:_chatImgBut];
  [self.contentView addSubview:_chatImgBut];
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
    self.delegate = imageClickableDelegate;
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
  RELEASE_OBJ(_tableInfoLabel);
  RELEASE_OBJ(shakePlaceLabel);
  RELEASE_OBJ(shakeThingLabel);
  RELEASE_OBJ(_distance);
  RELEASE_OBJ(_time);
  RELEASE_OBJ(_plat);
  
  self.userImgView = nil;
  self.url = nil;
  
  self.delegate = nil;
  
  [super dealloc];
}

#pragma mark - overwrite methods
- (void)openImg:(id)sender {
}

- (void)openProfile:(id)sender {
  if (self.delegate) {
    [self.delegate openProfile:_alumni.personId userType:_alumni.userType];
  }
}

- (void)openChat:(id)sender {
  if (self.delegate) {
    [self.delegate doChat:_alumni];
  }
}

- (void)drawImage:(NSString *)imageUrl type:(NSString *)type
{
  UIImage *image = nil;
  if (imageUrl && [imageUrl length] > 0 ) {
    if (![@"1" isEqualToString:type]) {
      self.url = imageUrl;
    }else {
      self.url = [CommonUtils geneUrl:imageUrl itemType:IMAGE_TY];
    }
    
    image = [[WXWImageManager instance].imageCache getImage:self.url];
    if (!image) {
      ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                      interactionContentType:IMAGE_TY] autorelease];
      [connFacade fetchGets:self.url];
    }
  } else {
    image = [UIImage imageNamed:@"defaultUser.png"];
  }
  
  if (image) {
    self.userImgView.imageView.image = [CommonUtils cutPartImage:image
                                                           width:IMAGE_W
                                                          height:IMAGE_H];
  }
  
  
  //draw badge number
  int badgeNum = [_alumni.notReadMsgCount intValue];
  if (badgeNum == 0) {
    if (_dmNewNumberBadge != nil) {
      _dmNewNumberBadge.hidden = YES;
    }
    return;
  }
  
  if (nil == _dmNewNumberBadge) {
    _dmNewNumberBadge = [[[WXWNumberBadge alloc] initWithFrame:CGRectMake(self.userImgView.frame.origin.x + self.userImgView.frame.size.width - MARGIN * 4,
                                                                          self.userImgView.frame.origin.y, 0, NUMBER_BADGE_HEIGHT)
                                                      topColor:NUMBER_BADGE_TOP_COLOR
                                                   bottomColor:NUMBER_BADGE_TOP_COLOR
                                                          font:BOLD_FONT(12)] autorelease];
    
    [self.contentView addSubview:_dmNewNumberBadge];
  }
  
  _dmNewNumberBadge.hidden = NO;
  
  [_dmNewNumberBadge setNumberWithTitle:[NSString stringWithFormat:@"%d", badgeNum]];
  

}

#pragma mark - customize methods
- (void)drawCell:(Alumni*)alumni userListType:(WebItemType)userListType
{
  _alumni = alumni;
  
  NSString *memberName = alumni.name;
  NSString *className = alumni.classGroupName;
  NSString *companyName = alumni.companyName;
  
  CGSize constraint;
  
  if (alumni.tableInfo.length > 0) {
    if (nil == _tableInfoLabel) {
      _tableInfoLabel = [[WXWLabel alloc] initWithFrame:CGRectZero
                                              textColor:BASE_INFO_COLOR
                                            shadowColor:[UIColor whiteColor]];
      _tableInfoLabel.font = BOLD_FONT(12);
      [self.contentView addSubview:_tableInfoLabel];
    }
    _tableInfoLabel.text = alumni.tableInfo;
    CGSize size = [_tableInfoLabel.text sizeWithFont:_tableInfoLabel.font
                                   constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 2, CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    _tableInfoLabel.frame = CGRectMake(MARGIN * 2,
                                       self.userImgView.frame.origin.y + self.userImgView.frame.size.height + MARGIN,
                                       size.width, size.height);
    
    _tableInfoLabel.hidden = NO;
  } else {
    if (_tableInfoLabel) {
      _tableInfoLabel.hidden = YES;
    }
  }
  
  // Name
  constraint = CGSizeMake(NAME_W, 20);
  
	CGSize nameSize = [memberName sizeWithFont:Arial_FONT(FONT_SIZE)
                           constrainedToSize:constraint
                               lineBreakMode:NSLineBreakByTruncatingTail];
  
  nameLabel.frame = CGRectMake(CONTENT_X, TOP_OFFSET, constraint.width, nameSize.height);
	nameLabel.text = memberName;
  
  // Class
  constraint = CGSizeMake(CLASS_W, 20);
  
  if (![NULL_PARAM_VALUE isEqualToString:className]) {
    classLabel.text = [NSString stringWithFormat:@" | %@", className];
  }
  CGSize classNameSize = [classLabel.text sizeWithFont:FONT(FONT_SIZE-1)
                                     constrainedToSize:constraint
                                         lineBreakMode:NSLineBreakByTruncatingTail];
  
  classLabel.frame = CGRectMake(CONTENT_X+nameSize.width, TOP_OFFSET+1, CLASS_W, classNameSize.height);
  
  // Company
  constraint = CGSizeMake(CELL_CONTENT_PORTRAIT_WIDTH - (MARGIN * 2), CGFLOAT_MAX);
  CGSize companyNameSize = [companyName sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE-1]
                                   constrainedToSize:constraint
                                       lineBreakMode:NSLineBreakByWordWrapping];
  
  companyLabel.frame = CGRectMake(CONTENT_X, nameLabel.frame.origin.y + nameLabel.frame.size.height, CELL_CONTENT_PORTRAIT_WIDTH - (CONTENT_X), companyNameSize.height);
	companyLabel.text = companyName;
  
  [self drawImage:alumni.imageUrl type:alumni.userType];
  if (alumni.tableInfo.length > 0 && userListType == ADMIN_CHECK_IN_TY) {
    [self setCellStyle:USER_LIST_CELL_WITH_TABLE_HEIGHT];
  } else {
    [self setCellStyle:USER_LIST_CELL_HEIGHT];
  }
  
  
  if ([[AppManager instance].personId isEqualToString:alumni.personId]) {
    chatImgView.hidden = YES;
    _chatImgBut.hidden = YES;
  }
  
  switch (userListType) {
      
    case ADMIN_CHECK_IN_TY:
    {
      companyLabel.frame = CGRectMake(CONTENT_X, 18.f, 180.f, 30.f);
      companyLabel.text = companyName;
      companyLabel.numberOfLines = 1;
      companyLabel.lineBreakMode = NSLineBreakByTruncatingTail;
      
      chatImgView.hidden = YES;
      _chatImgBut.hidden = YES;
      
      // 已报名
      CGSize alumniIsAppliedConstraint = CGSizeMake(SHAKE_PLACE_W, 16);
      UILabel *isAppliedLabel = [[[UILabel alloc] init] autorelease];
      if (![@"1" isEqualToString:_alumni.hasApplied]) {
        isAppliedLabel.text = LocaleStringForKey(NSHaveNotSignedUpTitle, nil);
      } else {
        isAppliedLabel.text = LocaleStringForKey(NSHaveSignedUpTitle, nil);
      }
      
      isAppliedLabel.font = FONT(FONT_SIZE-2);
      
      CGSize isAppliedSize = [isAppliedLabel.text sizeWithFont:isAppliedLabel.font
                                             constrainedToSize:alumniIsAppliedConstraint
                                                 lineBreakMode:NSLineBreakByTruncatingTail];
      
      isAppliedLabel.frame = CGRectMake(CONTENT_X, nameLabel.frame.origin.y + 36, isAppliedSize.width, isAppliedSize.height);
      
      isAppliedLabel.textColor = [UIColor blackColor];
      isAppliedLabel.backgroundColor = TRANSPARENT_COLOR;
      [self.contentView addSubview:isAppliedLabel];
      
      // | 初级会员
      UILabel *memberLevelLabel = [[[UILabel alloc] init] autorelease];
      memberLevelLabel.frame = CGRectMake(CONTENT_X + isAppliedSize.width, isAppliedLabel.frame.origin.y, SHAKE_THING_W, isAppliedSize.height);
      memberLevelLabel.font = FONT(FONT_SIZE-2);
      if (![NULL_PARAM_VALUE isEqualToString:_alumni.memberLevel]) {
        memberLevelLabel.text = [NSString stringWithFormat:@" | %@", _alumni.memberLevel];
      }
      memberLevelLabel.textColor = [UIColor blackColor];
      memberLevelLabel.backgroundColor = TRANSPARENT_COLOR;
      [self.contentView addSubview:memberLevelLabel];
      
      // 应缴费：400元
      CGSize shakeConstraint = CGSizeMake(SHAKE_PLACE_W, 16);
      UILabel *feeToPayLabel = [[[UILabel alloc] init] autorelease];
      if (![NULL_PARAM_VALUE isEqualToString:_alumni.feeToPay]) {
        feeToPayLabel.text = [NSString stringWithFormat:@"应缴费: %@%@", _alumni.feeToPay, @"元"];
      }
      
      feeToPayLabel.font = FONT(FONT_SIZE-2);
      CGSize shakePlaceSize = [feeToPayLabel.text sizeWithFont:feeToPayLabel.font
                                             constrainedToSize:shakeConstraint
                                                 lineBreakMode:NSLineBreakByTruncatingTail];
      
      feeToPayLabel.frame = CGRectMake(CONTENT_X, nameLabel.frame.origin.y + 50, shakePlaceSize.width, shakePlaceSize.height);
      
      
      feeToPayLabel.textColor = [UIColor blackColor];
      feeToPayLabel.backgroundColor = TRANSPARENT_COLOR;
      [self.contentView addSubview:feeToPayLabel];
      
      // | 已缴费：400元
      UILabel *feePaidLabel = [[[UILabel alloc] init] autorelease];
      feePaidLabel.frame = CGRectMake(CONTENT_X + shakePlaceSize.width, feeToPayLabel.frame.origin.y, SHAKE_THING_W, shakePlaceSize.height);
      feePaidLabel.font = FONT(FONT_SIZE-2);
      if (![NULL_PARAM_VALUE isEqualToString:_alumni.feePaid]) {
        feePaidLabel.text = [NSString stringWithFormat:@" | %@: %@%@", LocaleStringForKey(NSHavePaidTitle, nil), _alumni.feePaid, @"元"];
      }
      feePaidLabel.textColor = [UIColor blackColor];
      feePaidLabel.backgroundColor = TRANSPARENT_COLOR;
      [self.contentView addSubview:feePaidLabel];
      
      // Login Button
      NSString *isCheckStr = LocaleStringForKey(NSUnCheckInButTitle, nil);
      if (!alumni.isCheckIn.boolValue) {
        isCheckStr = LocaleStringForKey(NSCheckInTitle, nil);
      }
      
      UIImageButton *checkBut = [[[UIImageButton alloc]
                                  initImageButtonWithFrame:CGRectMake(240.0f, 25.f, 70.f, 30.f)
                                  target:self
                                  action:@selector(doCheck:)
                                  title:isCheckStr
                                  image:nil
                                  backImgName:@"button_orange.png"
                                  selBackImgName:@"button_orange_selected.png"
                                  titleFont:BOLD_FONT(FONT_SIZE)
                                  titleColor:[UIColor whiteColor]
                                  titleShadowColor:TRANSPARENT_COLOR
                                  roundedType:HAS_ROUNDED
                                  imageEdgeInsert:ZERO_EDGE
                                  titleEdgeInsert:ZERO_EDGE] autorelease];
      
      checkBut.enabled = YES;
      checkBut.userInteractionEnabled = NO;
      [self.contentView addSubview:checkBut];
      break;
    }
      
    case SHAKE_USER_LIST_TY:
    {
      
      // Company
      CGSize companyNameSize = [@"Company" sizeWithFont:FONT(FONT_SIZE-1)
                                      constrainedToSize:constraint
                                          lineBreakMode:NSLineBreakByTruncatingTail];
      
      companyLabel.frame = CGRectMake(CONTENT_X, nameLabel.frame.origin.y + nameLabel.frame.size.height, CELL_CONTENT_PORTRAIT_WIDTH - (CONTENT_X), companyNameSize.height);
      companyLabel.text = companyName;
      companyLabel.numberOfLines = 1;
      
      // Shake Place
      //CGSize shakeConstraint = CGSizeMake(SHAKE_PLACE_W, 16);
      shakePlaceLabel = [[UILabel alloc] init];
      /*
       if (![NULL_PARAM_VALUE isEqualToString:_alumni.shakePlace]) {
       shakePlaceLabel.text = [NSString stringWithFormat:@"%@: %@", LocaleStringForKey(NSShakePlaceLabelTitle, nil), _alumni.shakePlace];
       }
       CGSize shakePlaceSize = [shakePlaceLabel.text sizeWithFont:FONT(FONT_SIZE-4)
       constrainedToSize:shakeConstraint
       lineBreakMode:NSLineBreakByTruncatingTail];
       
       shakePlaceLabel.frame = CGRectMake(CONTENT_X, companyLabel.frame.origin.y + 18, shakePlaceSize.width, shakePlaceSize.height);
       shakePlaceLabel.font = FONT(FONT_SIZE-4);
       
       shakePlaceLabel.textColor = [UIColor blackColor];
       shakePlaceLabel.backgroundColor = TRANSPARENT_COLOR;
       [self.contentView addSubview:shakePlaceLabel];
       
       
       // Shake Thing
       shakeThingLabel = [[UILabel alloc] init];
       shakeThingLabel.frame = CGRectMake(CONTENT_X + shakePlaceSize.width, shakePlaceLabel.frame.origin.y, SHAKE_THING_W, shakePlaceSize.height);
       shakeThingLabel.font = FONT(FONT_SIZE-4);
       if (![NULL_PARAM_VALUE isEqualToString:_alumni.shakeThing]) {
       shakeThingLabel.text = [NSString stringWithFormat:@" | %@", _alumni.shakeThing];
       }
       shakeThingLabel.textColor = [UIColor blackColor];
       shakeThingLabel.backgroundColor = TRANSPARENT_COLOR;
       //[self.contentView addSubview:shakeThingLabel]; DEBUG
       */
      
      CGSize size;
      // distance
      _distance = [[WXWLabel alloc] initWithFrame:CGRectZero
                                        textColor:BASE_INFO_COLOR
                                      shadowColor:[UIColor whiteColor]];
      _distance.font = FONT(FONT_SIZE-5);
      [self.contentView addSubview:_distance];
      
      _distance.text = [NSString stringWithFormat:@"%@km", _alumni.distance];
      size = [_distance.text sizeWithFont:_distance.font
                        constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByWordWrapping];
      _distance.frame = CGRectMake(CONTENT_X,
                                   USER_LIST_CELL_HEIGHT - 20 + MARGIN, size.width, size.height);
      
      // time
      _time = [[WXWLabel alloc] initWithFrame:CGRectZero
                                    textColor:BASE_INFO_COLOR
                                  shadowColor:[UIColor whiteColor]];
      _time.font = FONT(FONT_SIZE-5);
      [self.contentView addSubview:_time];
      
      _time.text = _alumni.time;
      size = [_time.text sizeWithFont:_time.font
                    constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
      _time.frame = CGRectMake(150,
                               USER_LIST_CELL_HEIGHT - 20 + MARGIN, size.width, size.height);
      
      // plat
      _plat = [[WXWLabel alloc] initWithFrame:CGRectZero
                                    textColor:BASE_INFO_COLOR
                                  shadowColor:[UIColor whiteColor]];
      _plat.font = FONT(FONT_SIZE-5);
      [self.contentView addSubview:_plat];
      
      _plat.text = [NSString stringWithFormat:@"%@ %@", _alumni.plat, _alumni.version];
      size = [_plat.text sizeWithFont:_plat.font
                    constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
      _plat.frame = CGRectMake(250,
                               USER_LIST_CELL_HEIGHT - 20 + MARGIN, size.width, size.height);
    }
      break;
      
    case CHAT_USER_LIST_TY:
    {
      chatImgView.hidden = YES;
      _chatImgBut.hidden = YES;
      
      // Company
      CGSize companyNameSize = [@"Company" sizeWithFont:FONT(FONT_SIZE-1)
                                      constrainedToSize:constraint
                                          lineBreakMode:NSLineBreakByTruncatingTail];
      
      companyLabel.frame = CGRectMake(CONTENT_X, nameLabel.frame.origin.y + nameLabel.frame.size.height, CELL_CONTENT_PORTRAIT_WIDTH - (CONTENT_X), companyNameSize.height);
      companyLabel.text = companyName;
      companyLabel.numberOfLines = 1;
      companyLabel.hidden = YES;
      
      // last chat msg
      //            CGSize shakeConstraint = CGSizeMake(CELL_CONTENT_PORTRAIT_WIDTH - (CONTENT_X), CGFLOAT_MAX);
      shakePlaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_X, nameLabel.frame.origin.y + nameLabel.frame.size.height+2.f, CELL_CONTENT_PORTRAIT_WIDTH - (CONTENT_X), 32.f)];
      
      shakePlaceLabel.font = FONT(FONT_SIZE-1);
      if ([_alumni.isLastMessageFromSelf boolValue]) {
        shakePlaceLabel.text = [NSString stringWithFormat:@"%@: %@", LocaleStringForKey(NSMeTitle, nil), _alumni.lastMsg];
      } else {
        shakePlaceLabel.text = _alumni.lastMsg;
      }
      
      shakePlaceLabel.frame = CGRectMake(shakePlaceLabel.frame.origin.x, shakePlaceLabel.frame.origin.y, shakePlaceLabel.frame.size.width, 32.f);
      
      shakePlaceLabel.lineBreakMode = NSLineBreakByWordWrapping;
      shakePlaceLabel.numberOfLines = 2;
      shakePlaceLabel.textColor = COLOR(123, 123, 122);
      shakePlaceLabel.backgroundColor = TRANSPARENT_COLOR;
      [self.contentView addSubview:shakePlaceLabel];
      
      // time
      _time = [[WXWLabel alloc] initWithFrame:CGRectZero
                                    textColor:BASE_INFO_COLOR
                                  shadowColor:[UIColor whiteColor]];
      _time.font = FONT(FONT_SIZE-5);
      [self.contentView addSubview:_time];
      
      _time.text = _alumni.time;
      CGSize timeSize = [_time.text sizeWithFont:_time.font
                               constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
      _time.frame = CGRectMake(CONTENT_X,
                               USER_LIST_CELL_HEIGHT - 20 + MARGIN, timeSize.width, timeSize.height);
    }
      break;
      
    default:
      break;
  }
  
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
  self.userImgView.imageView.image = nil;
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
  if (url && url.length > 0) {
    UIImage *image = [UIImage imageWithData:result];
    if (image) {
      [[WXWImageManager instance].imageCache saveImageIntoCache:url image:image];
    }
    
    if ([url isEqualToString:self.url]) {
      self.userImgView.imageView.image = [CommonUtils cutPartImage:image
                                                             width:IMAGE_W
                                                            height:IMAGE_H];
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

@end
