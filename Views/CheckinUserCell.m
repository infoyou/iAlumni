//
//  CheckinUserCell.m
//  iAlumni
//
//  Created by Adam on 12-8-17.
//
//

#import "CheckinUserCell.h"
#import "WXWLabel.h"
#import "Alumni.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "CheckedinMember.h"
#import "CoreDataUtils.h"
#import "AppManager.h"

#define CELL_HEIGHT   75.0f

#define CHAT_ICON_WIDTH   25.0f
#define CHAT_ICON_HEIGHT  19.0f

#define PHOTO_WIDTH       56.0f
#define PHOTO_HEIGHT      60.0f

@interface CheckinUserCell()
@property (nonatomic, retain) CheckedinMember *checkedinAlumni;
@end

@implementation CheckinUserCell

@synthesize checkedinAlumni = _checkedinAlumni;

#pragma mark - user action

- (Alumni *)createFakeAlumniInstance {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(personId == %@)", self.checkedinAlumni.memberId];
  
  Alumni *alumni = (Alumni *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC entityName:@"Alumni" predicate:predicate];
  if (nil == alumni) {
    alumni = (Alumni *)[NSEntityDescription insertNewObjectForEntityForName:@"Alumni"
                                                     inManagedObjectContext:_MOC];
    alumni.personId = [NSString stringWithFormat:@"%@", self.checkedinAlumni.memberId];
    alumni.classGroupName = self.checkedinAlumni.groupClassName;
    alumni.name = self.checkedinAlumni.name;
    alumni.companyName = self.checkedinAlumni.companyName;
    alumni.imageUrl = self.checkedinAlumni.photoUrl;
    alumni.userType = [NSString stringWithFormat:@"%@", self.checkedinAlumni.userType];
    alumni.containerType = @(FETCH_SHAKE_USER_TY);
  }

  return alumni;
}

- (void)chat:(id)sender {
  if (_delegate) {
    [_delegate doChat:[self createFakeAlumniInstance]];
  }
}

#pragma mark - lifecycle methods

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
    
    self.contentView.backgroundColor = CELL_COLOR;
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = CELL_BORDER_COLOR.CGColor;
    
    _authorPicBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN,
                                                                        MARGIN,
                                                                        PHOTO_WIDTH + PHOTO_MARGIN * 2,
                                                                        PHOTO_HEIGHT + PHOTO_MARGIN * 2)];
    _authorPicBackgroundView.backgroundColor = [UIColor whiteColor];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(1, 1,
                                                                           _authorPicBackgroundView.frame.size.width - 2,
                                                                           _authorPicBackgroundView.frame.size.height - 1)];
    
    _authorPicBackgroundView.layer.shadowPath = shadowPath.CGPath;
    _authorPicBackgroundView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    _authorPicBackgroundView.layer.shadowOpacity = 0.9f;
    _authorPicBackgroundView.layer.shadowRadius = 1.0f;
    _authorPicBackgroundView.layer.shadowOffset = CGSizeMake(0, 0);
    _authorPicBackgroundView.layer.masksToBounds = NO;
    [self.contentView addSubview:_authorPicBackgroundView];
    
    _authorPic = [[[UIImageView alloc] initWithFrame:CGRectMake(PHOTO_MARGIN, PHOTO_MARGIN,
                                                                PHOTO_WIDTH, PHOTO_HEIGHT)] autorelease];
    _authorPic.backgroundColor = [UIColor whiteColor];
    [_authorPicBackgroundView addSubview:_authorPic];

    _nameLabel = [self initLabel:CGRectZero
                         textColor:COLOR(44, 45, 51)
                       shadowColor:[UIColor whiteColor]];
    _nameLabel.font = BOLD_FONT(15);
    _nameLabel.numberOfLines = 0;
    [self.contentView addSubview:_nameLabel];

    _classLabel = [self initLabel:CGRectZero
                        textColor:BASE_INFO_COLOR
                      shadowColor:[UIColor whiteColor]];
    _classLabel.font = BOLD_FONT(12);
    _classLabel.numberOfLines = 0;
    [self.contentView addSubview:_classLabel];
    
    _companyLabel = [self initLabel:CGRectZero
                          textColor:BASE_INFO_COLOR
                        shadowColor:[UIColor whiteColor]];
    _companyLabel.font = BOLD_FONT(12);
    _companyLabel.numberOfLines = 0;
    [self.contentView addSubview:_companyLabel];
    
    _checkinCountLabel = [self initLabel:CGRectZero
                               textColor:DARK_TEXT_COLOR
                             shadowColor:[UIColor whiteColor]];
    _checkinCountLabel.font = FONT(11);
    [self.contentView addSubview:_checkinCountLabel];
    
    _checkinTimeLabel = [self initLabel:CGRectZero
                              textColor:DARK_TEXT_COLOR
                            shadowColor:[UIColor whiteColor]];
    _checkinTimeLabel.font = FONT(11);
    [self.contentView addSubview:_checkinTimeLabel];
    
    _dmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _dmButton.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - CHAT_ICON_WIDTH,
                                 (CELL_HEIGHT - CHAT_ICON_HEIGHT)/2.0f,
                                 CHAT_ICON_WIDTH, CHAT_ICON_HEIGHT);
    [_dmButton addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    _dmButton.backgroundColor = TRANSPARENT_COLOR;
    [_dmButton setImage:[UIImage imageNamed:@"chat.png"]
               forState:UIControlStateNormal];
    [self.contentView addSubview:_dmButton];
    
  }
  
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_nameLabel);
  RELEASE_OBJ(_classLabel);
  RELEASE_OBJ(_companyLabel);
  RELEASE_OBJ(_checkinTimeLabel);
  RELEASE_OBJ(_checkinCountLabel);
  
  self.checkedinAlumni = nil;
  
  [super dealloc];
}

- (void)drawCellWithAlumni:(CheckedinMember *)alumni {
  
  if ([[AppManager instance].personId isEqualToString:alumni.personId]) {
    _dmButton.hidden = YES;
  } else {
    _dmButton.hidden = NO;
  }
  
  self.checkedinAlumni = alumni;
  
  _nameLabel.text = alumni.name;
  CGFloat x = _authorPicBackgroundView.frame.origin.x + _authorPicBackgroundView.frame.size.width + MARGIN;
  CGFloat limitedWidth = self.frame.size.width - x - MARGIN * 2 - (CHAT_ICON_WIDTH);
  CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font
                            constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                                lineBreakMode:NSLineBreakByWordWrapping];
  _nameLabel.frame = CGRectMake(x, MARGIN, size.width, size.height);
 
  _classLabel.text = alumni.groupClassName;
  size = [_classLabel.text sizeWithFont:_classLabel.font
                      constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
  _classLabel.frame = CGRectMake(x, _nameLabel.frame.origin.y + _nameLabel.frame.size.height + MARGIN,
                                 size.width, size.height);
  
  _companyLabel.text = alumni.companyName;
  size = [_companyLabel.text sizeWithFont:_companyLabel.font
                        constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByWordWrapping];
  _companyLabel.frame = CGRectMake(x, _classLabel.frame.origin.y + _classLabel.frame.size.height,
                                   size.width, size.height);
  
  _checkinTimeLabel.text = alumni.elapsedTime;
  size = [_checkinTimeLabel.text sizeWithFont:_checkinTimeLabel.font
                            constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                                lineBreakMode:NSLineBreakByWordWrapping];
  _checkinTimeLabel.frame = CGRectMake(x, _companyLabel.frame.origin.y + _companyLabel.frame.size.height + MARGIN,
                                       size.width, size.height);
  
  _checkinCountLabel.text = [NSString stringWithFormat:LocaleStringForKey(NSTotalCheckinCountMsg, nil),
                             alumni.totalCount.intValue];
  size = [_checkinCountLabel.text sizeWithFont:_checkinCountLabel.font
                             constrainedToSize:CGSizeMake(300, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
  _checkinCountLabel.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - size.width,
                                        _checkinTimeLabel.frame.origin.y, size.width, size.height);
  
  [self fetchImage:(NSMutableArray *)@[alumni.photoUrl] forceNew:NO];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    _authorPic.image = nil;
  }
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    CATransition *imageFadein = [CATransition animation];
    imageFadein.duration = FADE_IN_DURATION;
    imageFadein.type = kCATransitionFade;
    
    [_authorPic.layer addAnimation:imageFadein forKey:nil];
    
    _authorPic.image = [CommonUtils cutPartImage:image
                                           width:PHOTO_SIDE_LENGTH
                                          height:PHOTO_SIDE_LENGTH];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  
}

@end
