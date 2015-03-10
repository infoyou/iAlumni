//
//  ProfileToolView.m
//  iAlumni
//
//  Created by Adam on 12-11-15.
//
//

#import "ProfileToolView.h"
#import "UIImageButton.h"
#import "CommonUtils.h"
#import "TextConstants.h"

#define BUTTON_WIDTH    143.0f
#define BUTTON_HEIGHT   33.0f

#define DM_IMG_EDGE       UIEdgeInsetsMake(0.0, -40.0, 0.0, 0.0)
#define ACCEPTED_IMG_EDGE UIEdgeInsetsMake(0.0, -30.0, 0.0, 0.0)
#define ADD_IMG_EDGE      UIEdgeInsetsMake(0.0, -15.0, 0.0, 0.0)
#define TITLE_EDGE        UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)

#define SPIN_VIEW_SIDE_LENGTH 26.0f


@interface ProfileToolView()
@property (nonatomic, retain) UIActivityIndicatorView *spinView;
@end

@implementation ProfileToolView

#pragma mark - user actions

- (void)enterDMList:(id)sender {
  if (_profileDelegate) {
    [_profileDelegate sendDirectMessage];
  }
}

- (void)addToAddressbook:(id)sender {
  if (_profileDelegate) {
    [_profileDelegate addToAddressbook];
  }
}

- (void)changeSaveStatus:(id)sender {
  if (_profileDelegate) {
    [_profileDelegate changeSaveStatus];
  }
}

#pragma mark - lifecycle methods
- (id)initWithFrame:(CGRect)frame
    profileDelegate:(id<ECClickableElementDelegate>)profileDelegate
{
  self = [super initWithFrame:frame];
  if (self) {
    
    _profileDelegate = profileDelegate;
    
    UIButton *dmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dmButton.frame = CGRectMake(14, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
    dmButton.backgroundColor = COLOR(42, 75, 123);
    dmButton.titleLabel.font = BOLD_FONT(12);
    [dmButton setImage:IMAGE_WITH_NAME(@"dm.png") forState:UIControlStateNormal];
    [dmButton setTitle:LocaleStringForKey(NSChatTitle, nil) forState:UIControlStateNormal];
    [dmButton addTarget:self action:@selector(enterDMList:) forControlEvents:UIControlEventTouchUpInside];
    dmButton.imageEdgeInsets = DM_IMG_EDGE;
    [self addSubview:dmButton];
         
    _favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _favoriteButton.frame = CGRectMake(dmButton.frame.origin.x + BUTTON_WIDTH + 6, dmButton.frame.origin.y, BUTTON_WIDTH, BUTTON_HEIGHT);
    _favoriteButton.backgroundColor = COLOR(237, 144, 50);
    _favoriteButton.titleLabel.font = BOLD_FONT(12);
    [_favoriteButton setImage:IMAGE_WITH_NAME(@"white5Star.png") forState:UIControlStateNormal];
    [_favoriteButton setTitle:LocaleStringForKey(NSSaveAlumniTitle, nil) forState:UIControlStateNormal];
    [_favoriteButton addTarget:self action:@selector(changeSaveStatus:) forControlEvents:UIControlEventTouchUpInside];
    _favoriteButton.imageEdgeInsets = ADD_IMG_EDGE;
    
    [self addSubview:_favoriteButton];
  }
  return self;
}

- (void)dealloc {
  
  self.spinView = nil;
  
  [super dealloc];
}

#pragma mark - update favorite status
- (void)setFavoriteButtonStatus {

  NSString *title = nil;
  
  switch (_relationshipType) {
    case WANT_TO_KNOW_TY:
      title = LocaleStringForKey(NSWantToKnowAlumniTitle, nil);
      break;
      
    case KNOWN_TY:
      title = LocaleStringForKey(NSKnownAlumnusTitle, nil);
      break;
      
    default:
      title = LocaleStringForKey(NSSaveAlumniTitle, nil);
      break;
  }
  
  [_favoriteButton setTitle:title forState:UIControlStateNormal];
  [_favoriteButton setImage:IMAGE_WITH_NAME(@"white5Star.png") forState:UIControlStateNormal];
  _favoriteButton.titleEdgeInsets = TITLE_EDGE;
}

- (void)updateFavoriteStatusWithType:(AlumniRelationshipType)relationType {
  
  _relationshipType = relationType;
  
  [self setFavoriteButtonStatus];
}

- (void)stopSpingForSuccess:(BOOL)success {

  if (self.spinView) {
    self.spinView.hidden = YES;
    [self.spinView stopAnimating];
    
    if (success) {
      [self setFavoriteButtonStatus];
    }
  }
}

- (void)startSpinView {
  if (nil == self.spinView) {
    self.spinView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.spinView.frame = CGRectMake(MARGIN * 2 + 3.0f, (BUTTON_HEIGHT - SPIN_VIEW_SIDE_LENGTH)/2.0f, SPIN_VIEW_SIDE_LENGTH, SPIN_VIEW_SIDE_LENGTH);
    
    [_favoriteButton addSubview:self.spinView];
  }
  
  self.spinView.hidden = NO;
  [self.spinView startAnimating];
  
  [_favoriteButton setImage:nil forState:UIControlStateNormal];
}

@end
