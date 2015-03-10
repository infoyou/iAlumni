//
//  ClubListCell.m
//  iAlumni
//
//  Created by Adam on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ClubListCell.h"
#import "ECInnerShadowImageView.h"
#import "UIImageButton.h"
#import "WXWLabel.h"
#import "ECAsyncConnectorFacade.h"
#import "CommonUtils.h"
#import "HintEnlargedButton.h"

#define FONT_SIZE         14.0f
#define TITLE_HEIGHT      20.0f
#define NUMBER_W          5 * MARGIN
#define LABEL_H           20.0f
#define POST_LABEL_Y      CLUB_LIST_CELL_HEIGHT - MARGIN * 5
#define BOTTOM_LABEL_Y    8 * MARGIN
#define TITLE_X           64.f
#define AVATAR_RADIUS     35.0f

#define ICON_WIDTH          70.0f
#define ICON_HEIGHT         30.0f

#define IMAGE_W      47.5f//    53.5f
#define IMAGE_H      47.5f

#define LOGO_SIDE_LEN   47.5f

@interface ClubListCell()
{
    int LABEL_W;
}


@property (nonatomic, retain) UIImageView *groupLogo;
@property (nonatomic, retain) WXWLabel *groupNameLabel;
@property (nonatomic, retain) WXWLabel *lastPostLabel;
@property (nonatomic, retain) WXWLabel *dateLabel;
@property (nonatomic, retain) HintEnlargedButton *infoButton;


@property (nonatomic, retain) UILabel *name;
@property (nonatomic, retain) UILabel *post;

@property (nonatomic, retain) UILabel *postLabel;
@property (nonatomic, retain) UILabel *postNum;

@property (nonatomic, retain) UILabel *eventNum;
@property (nonatomic, retain) UILabel *eventLabel;
@property (nonatomic, retain) UILabel *memberNum;
@property (nonatomic, retain) UILabel *memberLabel;

@property (nonatomic, retain) WXWLabel *time;
//@property (nonatomic, retain) ECInnerShadowImageView *cellIconView;
@property (nonatomic, retain)   UIImageView *cellIconView;
@property (nonatomic, retain) id<ECClickableElementDelegate> delegate;
@property (nonatomic, copy) NSString *imageUrl;

@property (nonatomic, retain) UIImageView *groupUserListCellIcon;
@property (nonatomic, retain) UIImageView *groupActivityListCellIcon;

@property (nonatomic, retain) WXWLabel *clubDetailLabel;
@property (nonatomic, retain) UIImageView *clubDetailImage;
@end

@implementation ClubListCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
             target:(id)target
displayDetailAction:(SEL)displayDetailAction {
  
  self = [self initWithStyle:style
             reuseIdentifier:reuseIdentifier
      imageDisplayerDelegate:imageDisplayerDelegate
                         MOC:MOC];
  
  if (self) {
    
    self.backgroundColor = COLOR(251, 251, 251);
    self.contentView.backgroundColor = COLOR(251, 251, 251);
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.groupLogo = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2, LOGO_SIDE_LEN, LOGO_SIDE_LEN)] autorelease];
    self.groupLogo.image = IMAGE_WITH_NAME(@"defaultGroupLogo.png");
    [self.contentView addSubview:self.groupLogo];
    
    self.groupNameLabel = [[self initLabel:CGRectZero
                                 textColor:DARK_TEXT_COLOR
                               shadowColor:TRANSPARENT_COLOR] autorelease];
    self.groupNameLabel.numberOfLines = 0;
    self.groupNameLabel.font = FONT(15);
    self.groupNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:self.groupNameLabel]; 
    
    self.infoButton = [[[HintEnlargedButton alloc] init] autorelease];
    self.infoButton.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - 25, MARGIN * 2, 25, 24);
    self.infoButton.backgroundColor = TRANSPARENT_COLOR;
    [self.infoButton setImage:IMAGE_WITH_NAME(@"groupInfo.png") forState:UIControlStateNormal];
    [self.infoButton addTarget:target
                        action:displayDetailAction
              forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.infoButton];
    
    self.lastPostLabel = [[self initLabel:CGRectZero
                                textColor:BASE_INFO_COLOR
                              shadowColor:TRANSPARENT_COLOR] autorelease];
    self.lastPostLabel.font = FONT(13);
    self.lastPostLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:self.lastPostLabel];
    
    self.dateLabel = [[self initLabel:CGRectZero
                            textColor:BASE_INFO_COLOR
                          shadowColor:TRANSPARENT_COLOR] autorelease];
    self.dateLabel.font = FONT(13);
    [self.contentView addSubview:self.dateLabel];
  }
  return self;
}

- (void)dealloc {
  
  self.groupLogo = nil;
  self.groupNameLabel = nil;
  self.dateLabel = nil;
  self.lastPostLabel = nil;
  self.infoButton = nil;

  [super dealloc];
}

- (void)resetLabels {
  
  self.groupLogo.image = IMAGE_WITH_NAME(@"defaultGroupLogo.png");
  
  self.groupNameLabel.text = NULL_PARAM_VALUE;

  self.lastPostLabel.hidden = YES;
  
  self.dateLabel.hidden = YES;
}

- (void)drawClub:(Club *)club
{
  
  [self resetLabels];
  
  if (club.iconUrl.length > 1) {
    [self fetchImage:[NSMutableArray arrayWithObject:club.iconUrl] forceNew:NO];
  }
  
  self.groupNameLabel.text = club.clubName;
  CGSize size = [CommonUtils sizeForText:self.groupNameLabel.text
                                    font:self.groupNameLabel.font
                       constrainedToSize:CGSizeMake(206, 40)
                           lineBreakMode:BREAK_BY_TRUNCATING_TAIL];
  self.groupNameLabel.frame = CGRectMake(self.groupLogo.frame.origin.x + LOGO_SIDE_LEN + 9,
                                         self.groupLogo.frame.origin.y,
                                         size.width, size.height);
  
  
  if (club.postDesc.length > 0) {
    self.lastPostLabel.hidden = NO;
    self.lastPostLabel.text = STR_FORMAT(@"%@: %@", club.postAuthor, club.postDesc);
    size = [CommonUtils sizeForText:self.lastPostLabel.text
                               font:self.lastPostLabel.font
                  constrainedToSize:CGSizeMake(180, 20)
                      lineBreakMode:BREAK_BY_TRUNCATING_TAIL];
    
    self.lastPostLabel.frame = CGRectMake(self.groupNameLabel.frame.origin.x,
                                          self.groupLogo.frame.origin.y + self.groupLogo.frame.size.height - MARGIN,
                                          size.width, size.height);
    
    self.dateLabel.hidden = NO;
    self.dateLabel.text = club.postTime;
    size = [CommonUtils sizeForText:self.dateLabel.text
                               font:self.dateLabel.font];
    
    self.dateLabel.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - size.width,
                                      self.lastPostLabel.frame.origin.y,
                                      size.width, size.height);
  }
}

#pragma mark - WXWImageFetcherDelegate methods

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  
  if ([self currentUrlMatchCell:url]) {
    [self.groupLogo.layer addAnimation:[self imageTransition] forKey:nil];
    
    self.groupLogo.image = [CommonUtils cutMiddlePartImage:image
                                                     width:LOGO_SIDE_LEN
                                                    height:LOGO_SIDE_LEN];
  }
  
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  if ([self currentUrlMatchCell:url]) {
    self.groupLogo.image = [CommonUtils cutMiddlePartImage:image
                                                     width:LOGO_SIDE_LEN
                                                    height:LOGO_SIDE_LEN];
  }
}


@end
