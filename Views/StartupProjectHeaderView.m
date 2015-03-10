//
//  StartupProjectHeaderView.m
//  iAlumni
//
//  Created by Adam on 13-3-4.
//
//

#import "StartupProjectHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "Event.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "ECPlainButton.h"
#import "ECGradientButton.h"
#import "UIImageButton.h"
#import "AppManager.h"
#import "UIImage-Extensions.h"

#define NAME_WIDTH     300.f

#define BUTTON_H       28.0f
#define FONT_SIZE      13.0f
#define POST_W         95.5f
#define POST_H         120.f
#define ACTIVITY_W     200.f
#define LINE_X         MARGIN
#define LINE_W         ACTIVITY_W - LINE_X * 2

enum {
  EVENT_SPONSOR_CELL = 0,
  EVENT_LOCATION_CELL,
  EVENT_CONTRACTS_CELL,
};

enum {
  NO_EVENT_ACTION_TYPE,
  SIGNUP_EVENT_ACTION_TYPE,
  PAY_EVENT_ACTION_TYPE,
  CHECKIN_EVENT_ACTION_TYPE,
} EVENT_ACTION_TYPE;


@implementation StartupProjectHeaderView

#pragma mark - view cycle
- (id)initWithFrame:(CGRect)frame
              event:(Event *)event
           delegate:(id<EventActionDelegate>)delegate
        imageHolder:(id)imageHolder
    saveImageAction:(SEL)saveImageAction
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = TRANSPARENT_COLOR;
    
    _delegate = delegate;
    self.event = event;
    
    _imageHolder = imageHolder;
    _saveImageAction = saveImageAction;
    
    [self initEventTop];
    
    [self initEventMiddle];
    
    [self initEventBottom];
    
    [[WXWImageManager instance] fetchImage:self.event.imageUrl
                                    caller:self
                                  forceNew:NO];
  }
  return self;
}

- (void)dealloc {
  
  self.event = nil;
  
  [super dealloc];
}

#pragma mark - action
- (void)doAddCalendar:(id)sender {
  [_delegate addCalendar];
}

- (void)doSignUp:(id)sender {
  [_delegate doSignUp];
}

- (void)doTapGesture:(UITapGestureRecognizer *)sender {
  int tapIndex = [(UIGestureRecognizer *)sender view].tag;
  
  switch (tapIndex) {
      
    case EVENT_SPONSOR_CELL:
      [_delegate goSponsor];
      break;
      
    case EVENT_LOCATION_CELL:
      [_delegate goLocation];
      break;
      
    case EVENT_CONTRACTS_CELL:
      [_delegate goContracts];
      break;
      
    default:
      break;
  }
}

- (void)goSignUpList:(id)sender {
  [_delegate goSignUpList];
}

- (void)goCheckInList:(id)sender {
  [_delegate goCheckInList];
}

#pragma mark - init event header view

- (void)initEventTop {
  _nameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                      textColor:CELL_TITLE_COLOR
                                    shadowColor:[UIColor whiteColor]] autorelease];
  _nameLabel.font = BOLD_FONT(17);
  _nameLabel.numberOfLines = 0;
  _nameLabel.textAlignment = UITextAlignmentLeft;
  [self addSubview:_nameLabel];
  
  _nameLabel.text = self.event.title;
  CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font
                            constrainedToSize:CGSizeMake(NAME_WIDTH, CGFLOAT_MAX)
                                lineBreakMode:NSLineBreakByWordWrapping];
  _nameLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2,
                                size.width, size.height);
  
  _timeLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                      textColor:[UIColor blackColor]
                                    shadowColor:[UIColor whiteColor]] autorelease];
  _timeLabel.font = FONT(13);
  [self addSubview:_timeLabel];
  _timeLabel.text = [NSString stringWithFormat:@"%@ %@", self.event.time, self.event.timeStr];
  size = [_timeLabel.text sizeWithFont:_timeLabel.font
                     constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4,
                                                  CGFLOAT_MAX)
                         lineBreakMode:NSLineBreakByWordWrapping];
  _timeLabel.frame = CGRectMake(MARGIN * 2,
                                _nameLabel.frame.origin.y + _nameLabel.frame.size.height + MARGIN*2,
                                size.width, size.height);
  
  UIImageButton *add2CalendarBut = [[[UIImageButton alloc]
                                     initImageButtonWithFrame:CGRectMake(215.f, _timeLabel.frame.origin.y-MARGIN, 95.0f, 23.0f)
                                     target:self
                                     action:@selector(doAddCalendar:)
                                     title:LocaleStringForKey(NSAdd2CalendarTitle, nil)
                                     image:nil
                                     backImgName:@"add2Calendar.png"
                                     selBackImgName:nil
                                     titleFont:BOLD_FONT(FONT_SIZE)
                                     titleColor:[UIColor whiteColor]
                                     titleShadowColor:TRANSPARENT_COLOR
                                     roundedType:HAS_ROUNDED
                                     imageEdgeInsert:ZERO_EDGE
                                     titleEdgeInsert:UIEdgeInsetsMake(0, 20, 0, 0)] autorelease];
  [self addSubview:add2CalendarBut];
}

- (void)initEventMiddle {
  
  // post image Button
  _postImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
  _postImgButton.backgroundColor = [UIColor whiteColor];
  _postImgButton.frame = CGRectMake(MARGIN*2, _timeLabel.frame.origin.y + _timeLabel.frame.size.height + MARGIN*3, POST_W, POST_H);
  [_postImgButton addTarget:self action:@selector(showBigPicture:) forControlEvents:UIControlEventTouchUpInside];
  [_postImgButton setImage:[[UIImage imageNamed:@"eventDefault.png"] imageByScalingToSize:CGSizeMake(POST_W, POST_H)]
                  forState:UIControlStateNormal];
  
  [self addSubview:_postImgButton];
  
  CGRect activityFrame = CGRectMake(POST_W+MARGIN*3, _postImgButton.frame.origin.y, ACTIVITY_W, POST_H);
  _activityView = [[[UIView alloc] initWithFrame:activityFrame] autorelease];
  [_activityView setBackgroundColor:[UIColor whiteColor]];
  [self addSubview:_activityView];
  
  // sponsor
  [self drawLogicCell:self.event.hostName imageName:@"sponsor.png" offset:EVENT_SPONSOR_CELL];
  
  // location
  [self drawLogicCell:self.event.address imageName:@"eventLocation.png" offset:EVENT_LOCATION_CELL];
  
  // contracts
  [self drawLogicCell:[NSString stringWithFormat:@"%@ %@", self.event.contact, self.event.tel] imageName:@"contacts.png" offset:EVENT_CONTRACTS_CELL];
  
  // split
  [self drawSplitLine:CGRectMake(LINE_X, 39.f, LINE_W, 0.5) color:COLOR(206, 206, 206)];
  
  // split
  [self drawSplitLine:CGRectMake(LINE_X, 79.f, LINE_W, 0.5) color:COLOR(206, 206, 206)];
  
}

- (void)addShadowForButton:(UIImageButton *)button {
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(2, 2, button.bounds.size.width - 4.0f, button.bounds.size.height - 2.0f)];

  button.layer.shadowPath = shadowPath.CGPath;
  button.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  button.layer.shadowOpacity = 0.9f;
  button.layer.shadowOffset = CGSizeMake(0, 0);
  button.layer.shadowRadius = 2.0f;
}

- (void)initEventBottom {
  
  _eventSignBut = [[[UIImageButton alloc]
                    initImageButtonWithFrame:CGRectMake(2 * MARGIN, _postImgButton.frame.origin.y + POST_H + 2 * MARGIN, 145.f, 40.f)
                    target:self
                    action:@selector(goSignUpList:)
                    title:LocaleStringForKey(NSBackedProjectTile, nil)
                    image:nil
                    backImgName:@"whiteButton.png"
                    selBackImgName:nil
                    titleFont:FONT(16.f)
                    titleColor:BASE_INFO_COLOR
                    titleShadowColor:TRANSPARENT_COLOR
                    roundedType:NO_ROUNDED
                    imageEdgeInsert:ZERO_EDGE
                    titleEdgeInsert:UIEdgeInsetsMake(15.f, 5.f, 10.f, 85.f)] autorelease];

  [self addShadowForButton:_eventSignBut];
  
  [self addSubview:_eventSignBut];
  
  WXWLabel *signUpNumLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(60.f, 11.f, 60.f, 20.f) textColor:[UIColor blackColor] shadowColor:TRANSPARENT_COLOR] autorelease];
  signUpNumLabel.font = FONT(22);
  signUpNumLabel.text = [NSString stringWithFormat:@"%@", self.event.backerCount];
  signUpNumLabel.textAlignment = NSTextAlignmentCenter;
  [_eventSignBut addSubview:signUpNumLabel];
  
  UIImageView *signUpArrowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventArrow.png"]] autorelease];
  signUpArrowView.frame = CGRectMake(124.f, 13.f, 7.f, 11.f);
  [_eventSignBut addSubview:signUpArrowView];
  
  /*
  _eventCheckinBut = [[[UIImageButton alloc]
                       initImageButtonWithFrame:CGRectMake(165.f, _postImgButton.frame.origin.y + POST_H + 2 * MARGIN, 145.f, 40.f)
                       target:self
                       action:@selector(goCheckInList:)
                       title:LocaleStringForKey(NSBackedProjectTile, nil)
                       image:nil
                       backImgName:@"whiteButton.png"
                       selBackImgName:nil
                       titleFont:FONT(16.f)
                       titleColor:BASE_INFO_COLOR
                       titleShadowColor:TRANSPARENT_COLOR
                       roundedType:NO_ROUNDED
                       imageEdgeInsert:ZERO_EDGE
                       titleEdgeInsert:UIEdgeInsetsMake(15.f, 5.f, 10.f, 85.f)] autorelease];
  
  [self addShadowForButton:_eventCheckinBut];
  
  [self addSubview:_eventCheckinBut];
  
  WXWLabel *checkInNumLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(60.f, 11.f, 60.f, 20.f) textColor:[UIColor blackColor] shadowColor:TRANSPARENT_COLOR] autorelease];
  checkInNumLabel.font = FONT(22);
  checkInNumLabel.textAlignment = NSTextAlignmentCenter;
  checkInNumLabel.text = [NSString stringWithFormat:@"%@", self.event.checkinCount];
  [_eventCheckinBut addSubview:checkInNumLabel];
  
  UIImageView *checkInArrowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventArrow.png"]] autorelease];
  checkInArrowView.frame = CGRectMake(124.f, 13.f, 7.f, 11.f);
  [_eventCheckinBut addSubview:checkInArrowView];
   */
}

#pragma mark - draw cell [sponsor, location, contracts]
- (void)drawLogicCell:labelText imageName:(NSString *)imageName offset:(int)offset{
  
  UIView *cellView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
  cellView.frame = CGRectMake(0, offset * (POST_H/3), ACTIVITY_W, POST_H/3);
  
  UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]] autorelease];
  imageView.frame = CGRectMake(MARGIN, 15.f, 10.f, 10.f);
  [cellView addSubview:imageView];
  
  WXWLabel *label = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                           textColor:[UIColor blackColor]
                                         shadowColor:[UIColor whiteColor]] autorelease];
  label.font = Arial_FONT(13);
  label.text = labelText;
  label.numberOfLines = 2;
  //label.textAlignment = UITextAlignmentCenter;
  [cellView addSubview:label];
  
  CGSize size = [label.text sizeWithFont:label.font
                       constrainedToSize:CGSizeMake(155.f, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByTruncatingTail];
  label.frame = CGRectMake(20.f, (POST_H/3-size.height)/2.f,
                           size.width, size.height);
  
  // arrow
  UIImageView *arrowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eventArrow.png"]] autorelease];
  arrowView.frame = CGRectMake(180.f, 13.f, 7.f, 11.f);
  [cellView addSubview:arrowView];
  
  cellView.tag = offset;
  cellView.userInteractionEnabled = YES;
  UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTapGesture:)];
  [cellView addGestureRecognizer:tapGesture];
  
  [_activityView addSubview:cellView];
}

#pragma mark - draw cell split line
- (void)drawSplitLine:(CGRect)lineFrame color:(UIColor *)color {
  
  UIView *topLine = [[[UIView alloc] initWithFrame:lineFrame] autorelease];
  topLine.backgroundColor = color;
  [_activityView addSubview:topLine];
}

#pragma mark - update event post
- (void)updateEventPostImg:(UIImage *)image {
  
  [_postImgButton setImage:[image imageByScalingToSize:CGSizeMake(POST_W, POST_H)]
                  forState:UIControlStateNormal];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  [self updateEventPostImg:image];
  
  if (_imageHolder && _saveImageAction) {
    [_imageHolder performSelector:_saveImageAction withObject:image];
  }
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  
  [_postImgButton setImage:[image imageByScalingToSize:CGSizeMake(POST_W, POST_H)]
                  forState:UIControlStateNormal];
  
  if (_imageHolder && _saveImageAction) {
    [_imageHolder performSelector:_saveImageAction withObject:image];
  }
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
}

#pragma mark - show big picture
- (void)showBigPicture:(id)sender {
  
  if (_delegate) {
    [_delegate showBigPhotoWithUrl:self.event.imageUrl
                        imageFrame:_postImgButton.frame];
  }
}

@end
