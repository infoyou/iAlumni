//
//  PeopleWithChatCell.m
//  iAlumni
//
//  Created by Adam on 12-12-4.
//
//

#import "PeopleWithChatCell.h"
#import "AppManager.h"
#import "Alumni.h"

#define ICON_WIDTH  25.0f
#define ICON_HEIGHT 19.0f

#define PHOTO_WIDTH     56.0f
#define PHOTO_HEIGHT    58.0f

#define CONTENT_X       MARGIN * 2 + PHOTO_WIDTH + PHOTO_MARGIN * 2

@implementation PeopleWithChatCell

#pragma mark - user action
- (void)openChat:(id)sender {
  if (_delegate) {
    [_delegate doChat:self.alumni];
  } 
}


#pragma mark - lifecycle methods

- (void)addChatIcon {
  // chat
  _chatImgView = [[[UIImageView alloc] init] autorelease];
  _chatImgView.frame = CGRectMake(self.frame.size.width - MARGIN * 8,
                                 25.f, ICON_WIDTH, ICON_HEIGHT);
  _chatImgView.contentMode = UIViewContentModeScaleAspectFill;
  _chatImgView.backgroundColor = COLOR(234, 234, 234);
  _chatImgView.layer.cornerRadius = 6.0f;
  _chatImgView.layer.masksToBounds = YES;
  _chatImgView.backgroundColor = TRANSPARENT_COLOR;
  _chatImgView.userInteractionEnabled = YES;
  _chatImgView.image = [UIImage imageNamed:@"chat.png"];
  [self.contentView addSubview:_chatImgView];
  
  _chatImgBut = [UIButton buttonWithType:UIButtonTypeCustom];
  _chatImgBut.frame = CGRectMake(_chatImgView.frame.origin.x - MARGIN * 4,
                                 _chatImgView.frame.origin.y - MARGIN * 2,
                                 ICON_WIDTH + 40.f,
                                 ICON_HEIGHT + 20.f);
  _chatImgBut.layer.cornerRadius = 6.0f;
  _chatImgBut.layer.masksToBounds = YES;
  [_chatImgBut addTarget:self
                  action:@selector(openChat:)
        forControlEvents:UIControlEventTouchUpInside];
  [self.contentView addSubview:_chatImgBut];

}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
                MOC:(NSManagedObjectContext *)MOC {

  self = [super initWithStyle:style
              reuseIdentifier:reuseIdentifier
       imageDisplayerDelegate:imageDisplayerDelegate
       imageClickableDelegate:imageClickableDelegate
                          MOC:MOC];
  
  if (self) {
    
    
    [self addChatIcon];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - draw cell
- (void)drawCell:(Alumni*)alumni {
  [super drawCell:alumni];
  
  // Company
  companyLabel.text = alumni.companyName;
  CGSize companyNameSize = [companyLabel.text sizeWithFont:companyLabel.font
                                         constrainedToSize:CGSizeMake(_chatImgView.frame.origin.x - MARGIN - (_imageBackgroundView.frame.origin.x + _imageBackgroundView.frame.size.width + MARGIN * 2), CGFLOAT_MAX)
                                             lineBreakMode:NSLineBreakByWordWrapping];
  
  companyLabel.frame = CGRectMake(CONTENT_X,
                                  nameLabel.frame.origin.y + nameLabel.frame.size.height + MARGIN,
                                  CELL_CONTENT_PORTRAIT_WIDTH - (CONTENT_X), companyNameSize.height);
  
  if ([[AppManager instance].personId isEqualToString:alumni.personId]) {
    _chatImgView.hidden = YES;
    _chatImgBut.hidden = YES;
    _chatImgBut.enabled = NO;
  } else {
    _chatImgView.hidden = NO;
    _chatImgBut.hidden = NO;
    _chatImgBut.enabled = YES;
  }
}
@end
