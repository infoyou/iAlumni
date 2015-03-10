//
//  SupplyDemandCell.m
//  iAlumni
//
//  Created by Adam on 13-5-28.
//
//

#import "SupplyDemandCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Post.h"
#import "WXWLabel.h"
#import "ECColorfulButton.h"
#import "UIUtils.h"
#import "Tag.h"

#define CELL_HEIGHT   88.0f

#define FLAG_SIDE_LEN 42.0f

#define ICON_SIDE_LEN  16.0f

#pragma mark - tag button
@interface TagButton : UIButton {
  
}

@property (nonatomic, retain) Tag *bizTag;

+ (id)buttonWithType:(UIButtonType)buttonType;
@end

@implementation TagButton

+ (id)buttonWithType:(UIButtonType)buttonType {
  return [super buttonWithType:buttonType];
}

- (void)setBizTag:(Tag *)bizTag {
  
  if (bizTag == nil) {
    return;
  }
  
  RELEASE_OBJ(_bizTag);
  _bizTag = [bizTag retain];
  
  [self setTitle:bizTag.tagName forState:UIControlStateNormal];
}

- (void)dealloc {
  
  self.bizTag = nil;
  
  [super dealloc];
}

@end

@interface SupplyDemandCell()
@property (nonatomic, retain) NSMutableArray *buttons;
@end

@implementation SupplyDemandCell

#pragma mark - user action
- (void)selectTag:(id)sender {
  TagButton *button = (TagButton *)sender;
  
  NSNumber *tagId = button.bizTag.tagId;
  
  if (_searchDelegate && _searchAction && tagId.intValue > 0) {
    [_searchDelegate performSelector:_searchAction withObject:button.bizTag];
  }
}


#pragma mark - lifecycle methods

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
                MOC:(NSManagedObjectContext *)MOC {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    _MOC = MOC;
    
    self.contentView.backgroundColor = TRANSPARENT_COLOR;
    self.backgroundColor = TRANSPARENT_COLOR;
    
    // set name Label
    _nameLabel = [[self initLabel:CGRectZero
                       textColor:[UIColor blackColor]
                     shadowColor:[UIColor whiteColor]] autorelease];
    _nameLabel.font = BOLD_FONT(14);
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_nameLabel];
    
    // set _classLabel
    _classLabel = [[self initLabel:CGRectZero
                        textColor:[UIColor darkGrayColor]
                      shadowColor:[UIColor whiteColor]] autorelease];
    [_classLabel setFont:FONT(13)];
    [self.contentView addSubview:_classLabel];
    
    _timeline = [[self initLabel:CGRectZero
                       textColor:BASE_INFO_COLOR
                     shadowColor:[UIColor whiteColor]] autorelease];
		_timeline.font = FONT(10);
    [self.contentView addSubview:_timeline];

    _contentLabel = [[self initLabel:CGRectZero
                           textColor:DARK_TEXT_COLOR
                         shadowColor:[UIColor whiteColor]] autorelease];
		_contentLabel.font = BOLD_FONT(12);
    _contentLabel.numberOfLines = 1;
    _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_contentLabel];

    _tagIcon = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tag.png"]] autorelease];
    _tagIcon.frame = CGRectMake(MARGIN * 2 + FLAG_SIDE_LEN + MARGIN * 2, MARGIN * 2 + FLAG_SIDE_LEN + MARGIN * 2, ICON_SIDE_LEN, ICON_SIDE_LEN);
    [self.contentView addSubview:_tagIcon];
        
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.buttons = [NSMutableArray array];
  }
  return self;
}


- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
     searchDelegate:(id)searchDelegate
       searchAction:(SEL)searchAction
                MOC:(NSManagedObjectContext *)MOC {
  
  self = [self initWithStyle:style reuseIdentifier:reuseIdentifier MOC:MOC];
  if (self) {
    _searchDelegate = searchDelegate;
    _searchAction = searchAction;
  }
  
  return self;
}


- (void)dealloc {
  
  self.buttons = nil;
  
  [super dealloc];
}

#pragma mark - arrange views

- (void)arrangeFlagViewWithType:(PostType)type {
  
  if (nil == _flagIcon) {
    
    _flagIcon = [[[UIImageView alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2, FLAG_SIDE_LEN, FLAG_SIDE_LEN)] autorelease];
    
    [self.contentView addSubview:_flagIcon];
  }
  
  switch (type) {
    case SUPPLY_POST_TY:
      _flagIcon.image = [UIImage imageNamed:@"supply.png"];
      break;
      
    case DEMAND_POST_TY:
      _flagIcon.image = [UIImage imageNamed:@"demand.png"];
      break;
      
    default:
      break;
  }
}

- (void)arrangeTags:(NSString *)tagIds {
  
  if (tagIds.length > 0) {
    
    //tagIds = [tagIds stringByReplacingOccurrencesOfString:HALF_WIDTH_COMMA withString:FULL_WIDTH_COMMA];
    
    NSArray *tagIdList = [tagIds componentsSeparatedByString:FULL_WIDTH_COMMA];
    
    CGFloat startX = 0;
    
    NSInteger index = 0;
    
    for (NSString *tagId in tagIdList) {

      Tag *bizTag = (Tag *)[WXWCoreDataUtils fetchObjectFromMOC:_MOC
                                                     entityName:@"Tag"
                                                      predicate:[NSPredicate predicateWithFormat:@"(tagId == %@)", tagId]];
      
      CGSize size = [bizTag.tagName sizeWithFont:FONT(10)];
      
      CGFloat width = size.width + 4.0f;
      
      if (index++ == 0) {
        startX = _tagIcon.frame.origin.x + _tagIcon.frame.size.width + MARGIN;
      } else {
        startX = startX + width + MARGIN * 2;
      }
      
      if (startX > self.frame.size.width - MARGIN * 6) {
        break;
      }

      TagButton *button = [TagButton buttonWithType:UIButtonTypeCustom];
      button.frame = CGRectMake(startX, _tagIcon.frame.origin.y, width, size.height);
      //[button setTitle:tag forState:UIControlStateNormal];
      [button setBizTag:bizTag];
      [button setTitleColor:BASE_INFO_COLOR forState:UIControlStateNormal];
      [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
      [button setBackgroundImage:[UIImage imageNamed:@"darkBlueButton.png"]
                        forState:UIControlStateHighlighted];
      button.titleLabel.font = FONT(10);
      button.backgroundColor = TRANSPARENT_COLOR;
      [button addTarget:self
                 action:@selector(selectTag:)
       forControlEvents:UIControlEventTouchUpInside];
      
      [self.contentView addSubview:button];
      
      [self.buttons addObject:button];
      
    }
  }
}

- (void)clearTagButtons {
  for (UIButton *btn in self.buttons) {
    [btn removeFromSuperview];
  }
  
  [self.buttons removeAllObjects];
}

- (void)arrangeUnapproveStatus {
  if (nil == _approveStatusLabel) {
    _approveStatusLabel = [[self initLabel:CGRectZero
                                 textColor:NAVIGATION_BAR_COLOR
                               shadowColor:TRANSPARENT_COLOR] autorelease];
    _approveStatusLabel.font = BOLD_FONT(12);
    _approveStatusLabel.text = LocaleStringForKey(NSUnApprovedTitle, nil);
    CGSize size = [_approveStatusLabel.text sizeWithFont:_approveStatusLabel.font];
    _approveStatusLabel.frame = CGRectMake(_flagIcon.frame.origin.x + (_flagIcon.frame.size.width - size.width)/2.0f, _flagIcon.frame.origin.y + _flagIcon.frame.size.height + MARGIN , size.width, size.height);
    [self.contentView addSubview:_approveStatusLabel];
  }

  _approveStatusLabel.hidden = NO;
}

- (void)drawCellWithItem:(Post *)item {
  
  [self clearTagButtons];
  
  [self arrangeFlagViewWithType:item.postType.intValue];
  
  if (!item.approved.boolValue) {
    [self arrangeUnapproveStatus];
  } else {
    _approveStatusLabel.hidden = YES;
  }
  
  CGSize nameSize = [item.authorName sizeWithFont:_nameLabel.font
                                constrainedToSize:CGSizeMake(144, CGFLOAT_MAX)];
  
  _nameLabel.frame = CGRectMake(_flagIcon.frame.origin.x + _flagIcon.frame.size.width + MARGIN * 2, _flagIcon.frame.origin.y, nameSize.width, nameSize.height);
	_nameLabel.text = item.authorName;
  
  /*
  // Class
  CGSize constraint = CGSizeMake(144, 20);
  
  if (![NULL_PARAM_VALUE isEqualToString:className] && className.length > 0) {
    classLabel.text = [NSString stringWithFormat:@" | %@", className];
  }
  CGSize classNameSize = [classLabel.text sizeWithFont:FONT(FONT_SIZE-1)
                                     constrainedToSize:constraint
                                         lineBreakMode:NSLineBreakByTruncatingTail];
  
  classLabel.frame = CGRectMake(CONTENT_X+nameSize.width, TOP_OFFSET+1, CLASS_W, classNameSize.height);
  */
  
  _timeline.text = item.elapsedTime;
  CGSize size = [_timeline.text sizeWithFont:_timeline.font
                           constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
  _timeline.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - size.width, _flagIcon.frame.origin.y, size.width, size.height);
  
  _contentLabel.text = item.content;
  size = [_contentLabel.text sizeWithFont:_contentLabel.font
                        constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 2 - (_flagIcon.frame.origin.x + _flagIcon.frame.size.width + MARGIN * 2), 20.0f)
                            lineBreakMode:_contentLabel.lineBreakMode];
  _contentLabel.frame = CGRectMake(_nameLabel.frame.origin.x,
                                   _flagIcon.frame.origin.y + FLAG_SIDE_LEN - size.height,
                                   size.width, size.height);
  
  [self arrangeTags:item.tagIds];
}

- (void)drawRect:(CGRect)rect {
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGFloat pattern[2] = {2, 2};
  
  [UIUtils draw1PxDashLine:context
                   startPoint:CGPointMake(MARGIN * 2, CELL_HEIGHT - 1.0f)
                     endPoint:CGPointMake(self.frame.size.width - MARGIN * 2, CELL_HEIGHT - 1.0f)
                     colorRef:SEPARATOR_LINE_COLOR.CGColor
                 shadowOffset:CGSizeZero
                  shadowColor:TRANSPARENT_COLOR
                      pattern:pattern];
}

@end
