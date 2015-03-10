//
//  SelectablePeopleCell.m
//  iAlumni
//
//  Created by Adam on 12-12-4.
//
//

#import "SelectablePeopleCell.h"
#import "NameCard.h"

#define ICON_SIDE_LENGTH   24.0f

#define PHOTO_WIDTH     56.0f
#define PHOTO_HEIGHT    58.0f

#define CONTENT_X       MARGIN * 2 + PHOTO_WIDTH + PHOTO_MARGIN * 2

@implementation SelectablePeopleCell

#pragma mark - lifecycle methods

- (void)addSelectButton {
  _selectIcon = [[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - MARGIN * 8,
                                                               25.0f,
                                                               ICON_SIDE_LENGTH,
                                                               ICON_SIDE_LENGTH)] autorelease];
  [self.contentView addSubview:_selectIcon];
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
        
    [self addSelectButton];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - draw cell
- (void)drawCell:(NameCard *)nameCard {
  [super drawCell:nameCard];
  
  if (nameCard.selected.boolValue) {
    _selectIcon.image = [UIImage imageNamed:@"selected.png"];
  } else {
    _selectIcon.image = [UIImage imageNamed:@"unselected.png"];
  }
  
  // Company
  companyLabel.text = nameCard.companyName;
  CGSize companyNameSize = [companyLabel.text sizeWithFont:companyLabel.font
                                         constrainedToSize:CGSizeMake(_selectIcon.frame.origin.x - MARGIN - (_imageBackgroundView.frame.origin.x + _imageBackgroundView.frame.size.width + MARGIN * 2), CGFLOAT_MAX)
                                             lineBreakMode:NSLineBreakByWordWrapping];
  
  companyLabel.frame = CGRectMake(CONTENT_X,
                                  nameLabel.frame.origin.y + nameLabel.frame.size.height + MARGIN,
                                  CELL_CONTENT_PORTRAIT_WIDTH - (CONTENT_X), companyNameSize.height);

}

@end
