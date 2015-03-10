//
//  FavoriteAlumniResultView.m
//  iAlumni
//
//  Created by Adam on 12-11-21.
//
//

#import "FavoriteAlumniResultView.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIImageButton.h"
#import "UIUtils.h"
#import "WXWLabel.h"
#import "Alumni.h"
#import "CoreDataUtils.h"

#define TOP_VIEW_HEIGHT   44.0f

#define DONE_BTN_WIDTH    60.0f
#define DONE_BTN_HEIGHT   30.0f

#define CHECK_BTN_WIDTH   150.0f
#define CHECK_BTN_HEIGHT  30.0f

#define ACCEPT_ICON_SIDE_LENGTH 32.0f
#define BUTTON_IMAGE_EDGE UIEdgeInsetsMake(0, -20, 0, 0)

@interface FavoriteAlumniResultView()
//@property (nonatomic, retain) UIImageView *acceptIcon;
@property (nonatomic, retain) Alumni *alumni;
@end

@implementation FavoriteAlumniResultView


#pragma mark - user actions
- (void)confirm:(id)sender {
  
  if (_holder && _favoriteAction) {
    [_holder performSelector:_favoriteAction withObject:@(_relationshipType)];
  }
  
  /*
  if (_relationshipType != WANT_TO_KNOW_TY &&
      _relationshipType != KNOWN_TY) {
    
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSMustSelectFavoriteTypeMsg, nil)
                                  msgType:WARNING_TY
                       belowNavigationBar:NO];

  } else {
    
    if (_holder && _favoriteAction) {
      [_holder performSelector:_favoriteAction withObject:@(_relationshipType)];
    }
  }
   */
}

- (void)close:(id)sender {
  if (_holder && _closeAction) {
    [_holder performSelector:_closeAction];
  }
}

- (void)saveToWantKnow:(id)sender {
  _relationshipType = WANT_TO_KNOW_TY;
  
  _userCancel = NO;
  
  [self displayAcceptIconForType:_relationshipType];
}

- (void)saveToKnown:(id)sender {
  _relationshipType = KNOWN_TY;
  
  _userCancel = NO;
  
  [self displayAcceptIconForType:_relationshipType];
}

- (void)deleteFavorite:(id)sender {
  _relationshipType = ORDINARY_FRIEND_TY;
  
  _userCancel = YES;
  
  [self displayAcceptIconForType:_relationshipType];
}

- (void)addToAddressbook:(id)sender {
  if (_holder && _closeAction) {
    
    [_holder addToAddressbook];
  }
}

#pragma mark - lifecycle methods

- (void)arrangeWantToKnowButtonImageName:(NSString **)wantToKnowButtonImageName
                    knownButtonImageName:(NSString **)knownButtonImageName
                        relationshipType:(AlumniRelationshipType)relationshipType {

  switch (relationshipType) {
    case WANT_TO_KNOW_TY:
    {
      *wantToKnowButtonImageName = @"radioButton.png";
      *knownButtonImageName = @"unselected.png";
      break;
    }
      
    case KNOWN_TY:
    {
      *wantToKnowButtonImageName = @"unselected.png";
      *knownButtonImageName = @"radioButton.png";
      break;
    }
      
    default:
    {
      *wantToKnowButtonImageName = @"unselected.png";
      *knownButtonImageName = @"unselected.png";
      break;
    }
  }
}

- (void)displayAcceptIconForType:(AlumniRelationshipType)relationshipType {
  
  NSString *wantToKnowBtnImageName = nil;
  NSString *knownBtnImageName = nil;
  [self arrangeWantToKnowButtonImageName:&wantToKnowBtnImageName
                    knownButtonImageName:&knownBtnImageName
                        relationshipType:relationshipType];
  
  [_wantToKnowButton setImage:[UIImage imageNamed:wantToKnowBtnImageName]
                     forState:UIControlStateNormal];
  _wantToKnowButton.imageEdgeInsets = BUTTON_IMAGE_EDGE;
  [_knownButton setImage:[UIImage imageNamed:knownBtnImageName]
                forState:UIControlStateNormal];
  _knownButton.imageEdgeInsets = BUTTON_IMAGE_EDGE;
  
  if (_userCancel) {
    [_deleteButton setImage:[UIImage imageNamed:@"radioButton.png"] forState:UIControlStateNormal];
  } else {
    [_deleteButton setImage:[UIImage imageNamed:@"unselected.png"] forState:UIControlStateNormal];
  }
}

- (void)initViews {
  _topView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                       self.frame.size.width,
                                                       TOP_VIEW_HEIGHT)] autorelease];
  _topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
  
  [self addSubview:_topView];
  
  /*
  UIImageButton *cancelButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake(MARGIN * 2, (TOP_VIEW_HEIGHT - DONE_BTN_HEIGHT)/2.0f, DONE_BTN_WIDTH, DONE_BTN_HEIGHT)
                                                                          target:self
                                                                          action:@selector(close:)
                                                                           title:LocaleStringForKey(NSCancelTitle, nil)
                                                                           image:nil
                                                                     backImgName:@"club_button.png"
                                                                  selBackImgName:@"club_button_selected.png"
                                                                       titleFont:BOLD_FONT(13)
                                                                      titleColor:DARK_TEXT_COLOR
                                                                titleShadowColor:TEXT_SHADOW_COLOR
                                                                     roundedType:HAS_ROUNDED
                                                                 imageEdgeInsert:ZERO_EDGE
                                                                 titleEdgeInsert:ZERO_EDGE] autorelease];
  [_topView addSubview:cancelButton];
*/
  
  UIImageButton *doneButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake(self.frame.size.width - MARGIN * 2 - DONE_BTN_WIDTH, (TOP_VIEW_HEIGHT - DONE_BTN_HEIGHT)/2.0f, DONE_BTN_WIDTH, DONE_BTN_HEIGHT)
                                                                        target:self
                                                                        action:@selector(confirm:)
                                                                         title:LocaleStringForKey(NSSureTitle, nil)
                                                                         image:nil
                                                                   backImgName:@"button_orange.png"
                                                                selBackImgName:@"button_orange_selected.png"
                                                                     titleFont:BOLD_FONT(13)
                                                                    titleColor:[UIColor whiteColor]
                                                              titleShadowColor:[UIColor darkGrayColor]
                                                                   roundedType:HAS_ROUNDED
                                                               imageEdgeInsert:ZERO_EDGE
                                                               titleEdgeInsert:ZERO_EDGE] autorelease];
  [_topView addSubview:doneButton];
  
  WXWLabel *msgLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                            textColor:DARK_TEXT_COLOR
                                          shadowColor:TEXT_SHADOW_COLOR] autorelease];
  msgLabel.font = BOLD_FONT(15);
  msgLabel.numberOfLines = 0;
  msgLabel.text = LocaleStringForKey(NSFavoriteAlumniDoneMsg, nil);
  CGSize size = [msgLabel.text sizeWithFont:msgLabel.font
                          constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
  msgLabel.frame = CGRectMake((self.frame.size.width - size.width)/2.0f,
                              TOP_VIEW_HEIGHT + MARGIN * 2,
                              size.width,
                              size.height);
  [self addSubview:msgLabel];
    
  _wantToKnowButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake((self.frame.size.width - CHECK_BTN_WIDTH)/2.0f, msgLabel.frame.origin.y + msgLabel.frame.size.height + MARGIN * 2, CHECK_BTN_WIDTH, CHECK_BTN_HEIGHT)
                                                                target:self
                                                                action:@selector(saveToWantKnow:)
                                                                 title:LocaleStringForKey(NSWantToKnowAlumniTitle, nil)
                                                                 image:nil
                                                           backImgName:@"club_button.png"
                                                        selBackImgName:@"club_button_selected.png"
                                                             titleFont:BOLD_FONT(13)
                                                            titleColor:DARK_TEXT_COLOR
                                                      titleShadowColor:TEXT_SHADOW_COLOR
                                                           roundedType:HAS_ROUNDED
                                                       imageEdgeInsert:BUTTON_IMAGE_EDGE
                                                       titleEdgeInsert:ZERO_EDGE] autorelease];
  [self addSubview:_wantToKnowButton];
  
  _knownButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake((self.frame.size.width - CHECK_BTN_WIDTH)/2.0f, _wantToKnowButton.frame.origin.y + _wantToKnowButton.frame.size.height + MARGIN * 2, CHECK_BTN_WIDTH, CHECK_BTN_HEIGHT)
                                                           target:self
                                                           action:@selector(saveToKnown:)
                                                            title:LocaleStringForKey(NSKnownAlumnusTitle, nil)
                                                            image:nil
                                                      backImgName:@"club_button.png"
                                                   selBackImgName:@"club_button_selected.png"
                                                        titleFont:BOLD_FONT(13)
                                                       titleColor:DARK_TEXT_COLOR
                                                 titleShadowColor:TEXT_SHADOW_COLOR
                                                      roundedType:HAS_ROUNDED
                                                  imageEdgeInsert:BUTTON_IMAGE_EDGE
                                                  titleEdgeInsert:ZERO_EDGE] autorelease];
  [self addSubview:_knownButton];
  
  WXWLabel *orLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                             textColor:BASE_INFO_COLOR  
                                           shadowColor:TEXT_SHADOW_COLOR
                                                  font:BOLD_FONT(13)] autorelease];
  orLabel.text = LocaleStringForKey(NSOrTitle, nil);
  CGSize orSize = [orLabel.text sizeWithFont:orLabel.font];
  orLabel.frame = CGRectMake((self.frame.size.width - orSize.width)/2.0f,
                             _knownButton.frame.origin.y + _knownButton.frame.size.height + MARGIN * 2,
                             orSize.width, orSize.height);
  [self addSubview:orLabel];
  
  _deleteButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake((self.frame.size.width - CHECK_BTN_WIDTH)/2.0f, orLabel.frame.origin.y + orLabel.frame.size.height + MARGIN, CHECK_BTN_WIDTH, CHECK_BTN_HEIGHT)
                                                            target:self
                                                            action:@selector(deleteFavorite:)
                                                             title:LocaleStringForKey(NSDeleteFavoriteTitle, nil)
                                                             image:[UIImage imageNamed:@"unselected.png"]
                                                       backImgName:@"club_button.png"
                                                    selBackImgName:@"club_button_selected.png"
                                                         titleFont:BOLD_FONT(13)
                                                        titleColor:DARK_TEXT_COLOR
                                                  titleShadowColor:TEXT_SHADOW_COLOR
                                                       roundedType:HAS_ROUNDED
                                                   imageEdgeInsert:UIEdgeInsetsMake(0, -32, 0, 0)
                                                   titleEdgeInsert:ZERO_EDGE] autorelease];
  [self addSubview:_deleteButton];
  
  [self displayAcceptIconForType:self.alumni.relationshipType.intValue];
    
  _checkButtonBottomY = _deleteButton.frame.origin.y + _deleteButton.frame.size.height + MARGIN * 2;
  
  UIImageButton *addToABButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake((self.frame.size.width - CHECK_BTN_WIDTH)/2.0f, (self.frame.size.height - _checkButtonBottomY - CHECK_BTN_HEIGHT)/2.0 + _checkButtonBottomY, CHECK_BTN_WIDTH, CHECK_BTN_HEIGHT)
                                                                           target:self
                                                                           action:@selector(addToAddressbook:)
                                                                            title:LocaleStringForKey(NSAddContactTitle, nil)
                                                                            image:nil
                                                                      backImgName:@"club_button.png"
                                                                   selBackImgName:@"club_button_selected.png"
                                                                        titleFont:BOLD_FONT(13)
                                                                       titleColor:DARK_TEXT_COLOR
                                                                 titleShadowColor:TEXT_SHADOW_COLOR
                                                                      roundedType:HAS_ROUNDED
                                                                  imageEdgeInsert:ZERO_EDGE
                                                                  titleEdgeInsert:ZERO_EDGE] autorelease];
  
  [self addSubview:addToABButton];
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
             holder:(id<ECClickableElementDelegate>)holder
        closeAction:(SEL)closeAction
     favoriteAction:(SEL)favoriteAction
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate
             alumni:(Alumni *)alumni {
  
  self = [super initWithFrame:frame
       imageDisplayerDelegate:imageDisplayerDelegate
       connectTriggerDelegate:connectTriggerDelegate];
  if (self) {

    self.backgroundColor = CELL_COLOR;
    
    _MOC = MOC;
    
    self.alumni = alumni;
    
    _relationshipType = alumni.relationshipType.intValue;
    
    _holder = holder;
    
    _closeAction = closeAction;
    
    _favoriteAction = favoriteAction;
    
    [self initViews];
  }
  return self;
}

- (void)dealloc {
  
  self.alumni = nil;
  //self.acceptIcon = nil;
  
  [super dealloc];
}


#pragma mark - arrange views
- (void)drawRect:(CGRect)rect {

  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0, TOP_VIEW_HEIGHT - 0.5f)
                endPoint:CGPointMake(self.frame.size.width, TOP_VIEW_HEIGHT - 0.5f)
                   color:SEPARATOR_LINE_COLOR.CGColor
            shadowOffset:CGSizeMake(0.0f, 0.5f)
             shadowColor:TEXT_SHADOW_COLOR];
  
  CGFloat pattern[2] = {1, 2};
  
  [UIUtils draw1PxDashLine:context
                startPoint:CGPointMake(MARGIN * 2, _checkButtonBottomY)
                  endPoint:CGPointMake(self.frame.size.width - MARGIN * 2, _checkButtonBottomY)
                  colorRef:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0.0f, 1.0f)
               shadowColor:TEXT_SHADOW_COLOR
                   pattern:pattern];
  
}


@end
