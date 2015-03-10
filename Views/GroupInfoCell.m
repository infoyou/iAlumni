//
//  GroupInfoCell.m
//  iAlumni
//
//  Created by Adam on 12-10-5.
//
//

#import "GroupInfoCell.h"
#import <CoreText/CoreText.h>
#import "CoreTextView.h"
#import "CoreTextMarkupParser.h"
#import "WXWLabel.h"
#import "Club.h"
#import "CommonUtils.h"
#import "NSAttributedString+Encoding.h"

#define LIMITED_WIDTH           270.0f
#define POST_LIMITED_WIDTH      300.0f
#define BASEINFO_LIMITED_WIDTH  220.0f
#define CELL_FIXED_HEIGHT       85.0f

@interface GroupInfoCell()
@property (nonatomic, retain) Club *club;
@end

@implementation GroupInfoCell

@synthesize club = _club;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    self.contentView.backgroundColor = CELL_COLOR;
    
    _groupNameLabel = [[self initLabel:CGRectZero
                             textColor:DARK_TEXT_COLOR
                           shadowColor:[UIColor whiteColor]] autorelease];
    _groupNameLabel.font = BOLD_FONT(15);
    _groupNameLabel.numberOfLines = 0;
    [self.contentView addSubview:_groupNameLabel];
    
    _postContentView = [[[CoreTextView alloc] initWithFrame:CGRectZero] autorelease];
    [self.contentView addSubview:_postContentView];
    
    
    _baseInfoView = [[[CoreTextView alloc] initWithFrame:CGRectZero] autorelease];
    
    [self.contentView addSubview:_baseInfoView];
    
    _dateTimeLabel = [[self initLabel:CGRectZero
                            textColor:BASE_INFO_COLOR
                          shadowColor:[UIColor whiteColor]] autorelease];
    _dateTimeLabel.font = BOLD_FONT(11);
    [self.contentView addSubview:_dateTimeLabel];
    
    _badgeImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badge.png"]] autorelease];
    _badgeImageView.backgroundColor = TRANSPARENT_COLOR;
    CGRect frame = _badgeImageView.frame;
    _badgeImageView.frame = CGRectMake(self.frame.size.width - frame.size.width - MARGIN,
                                       3.0f,
                                       frame.size.width, frame.size.height);
    [self.contentView addSubview:_badgeImageView];
    
    _badgeNumLabel = [[self initLabel:CGRectZero
                            textColor:[UIColor whiteColor]
                          shadowColor:TRANSPARENT_COLOR] autorelease];
    _badgeNumLabel.font = BOLD_FONT(10);
    [_badgeImageView addSubview:_badgeNumLabel];
  }
  return self;
}

- (void)dealloc {
  
  self.club = nil;
  
  [super dealloc];
}



- (void)drawPostContent:(NSData *)postInfoContentData
           limitedWidth:(CGFloat)limitedWidth {
  
  if (postInfoContentData) {
    
    _postContentView.hidden = NO;
    
    CTFrameRef textFrame;
    CGSize postContentSize = [self getTextFrameSizeBaseOnData:postInfoContentData
                                                 limitedWidth:limitedWidth
                                                    textFrame:&textFrame];
    
    _postContentView.frame = CGRectMake(MARGIN * 2,
                                        _groupNameLabel.frame.origin.y + _groupNameLabel.frame.size.height + MARGIN,
                                        postContentSize.width, postContentSize.height);
    
    //CGPathRef framePath = CTFrameGetPath(textFrame);
    //CGRect test = CGPathGetBoundingBox(framePath);
    
    [self renderCoreTextView:&_postContentView textFrame:textFrame];
  
  } else {
    _postContentView.hidden = YES;
  }
}

- (void)drawBaseInfo:(NSData *)baseInfoData
        limitedWidth:(CGFloat)limitedWidth {
  
  // if current group is for all scope, then no need to draw the base infos
  if (baseInfoData && self.club.clubId.intValue != ALL_SCOPE_GP_ID) {
    
    _baseInfoView.hidden = NO;
    
    CTFrameRef textFrame;
    CGSize textSize = [self getTextFrameSizeBaseOnData:baseInfoData
                                          limitedWidth:limitedWidth
                                             textFrame:&textFrame];
    
    _baseInfoView.frame = CGRectMake(MARGIN * 2,
                                     CELL_FIXED_HEIGHT - textSize.height - MARGIN,
                                     textSize.width, textSize.height);
    
    [self renderCoreTextView:&_baseInfoView textFrame:textFrame];
    
  } else {
    _baseInfoView.hidden = YES;
  }
}

- (void)drawCell:(Club *)club {
  
  self.club = club;
  
  _groupNameLabel.text = club.clubName;
  CGSize size = [_groupNameLabel.text sizeWithFont:_groupNameLabel.font
                                 constrainedToSize:CGSizeMake(LIMITED_WIDTH, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
  _groupNameLabel.frame = CGRectMake(MARGIN * 2, MARGIN * 2, size.width, size.height);
  
  [self drawPostContent:club.postInfoContentData
           limitedWidth:POST_LIMITED_WIDTH];
  
  [self drawBaseInfo:club.baseInfoData
        limitedWidth:BASEINFO_LIMITED_WIDTH];
  
  if (club.postTime.length > 0) {
    
    _dateTimeLabel.hidden = NO;
    
    _dateTimeLabel.text = club.postTime;
    size = [_dateTimeLabel.text sizeWithFont:_dateTimeLabel.font
                           constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    _dateTimeLabel.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - size.width,
                                      CELL_FIXED_HEIGHT - 3.0f - size.height,
                                      size.width, size.height);
  } else {
    _dateTimeLabel.hidden = YES;
  }
  
  if (club.badgeNum.intValue > 0) {
    _badgeImageView.hidden = NO;
    _badgeNumLabel.text = club.badgeNum;
    size = [_badgeNumLabel.text sizeWithFont:_badgeNumLabel.font
                           constrainedToSize:CGSizeMake(_badgeImageView.frame.size.width, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
    _badgeNumLabel.frame = CGRectMake((_badgeImageView.frame.size.width - size.width)/2.0f,
                                      (_badgeImageView.frame.size.height - size.height)/2.0f + 1.0f,
                                      size.width, size.height);
  } else {
    _badgeImageView.hidden = YES;
  }
}

#pragma mark - draw core text utilities
- (CFArrayRef)lineArrayOfString:(NSAttributedString *)attString
                           path:(CGPathRef)path
                    frameSetter:(CTFramesetterRef)frameSetter {
  
  CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
  
  return CTFrameGetLines(frame);
}

- (CGSize)sizeOfAttString:(NSAttributedString *)attString
        constrainedToSize:(CGSize)constrainedToSize
               withinPath:(CGPathRef)path
                textFrame:(CTFrameRef *)textFrame {
  
  CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
  
  CFArrayRef lines = [self lineArrayOfString:attString path:path frameSetter:frameSetter];
  
  
  /******* get CGRect from CTFrameRef
   CGPathRef framePath = CTFrameGetPath(textFrame);
   CGRect test = CGPathGetBoundingBox(framePath);
   NSLog(@"test height: %f", test.size.height);
   */
  
  // get first line of text
  CFRange range = CTLineGetStringRange(CFArrayGetValueAtIndex(lines, 0));
  
  CFRange fitRange;
  CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, range, nil, constrainedToSize, &fitRange);
  
  CGPathRef textPath = CGPathCreateWithRect(CGRectMake(0, 0, coreTextSize.width, coreTextSize.height), NULL);
  *textFrame = CTFramesetterCreateFrame(frameSetter, fitRange, textPath, NULL);
    
  CFRelease(textPath);
  
  return coreTextSize;
}

- (void)renderCoreTextView:(CoreTextView **)coreTextView textFrame:(CTFrameRef)textFrame {
  [(*coreTextView) setCTFrame:(id)textFrame];
  [(*coreTextView) setNeedsDisplay];
}

- (CGSize)getTextFrameSizeBaseOnData:(NSData *)data
                        limitedWidth:(CGFloat)limitedWidth
                           textFrame:(CTFrameRef *)textFrame {
  
  CGMutablePathRef postPath = CGPathCreateMutable();
  CGPathAddRect(postPath, NULL, CGRectMake(0, 0, limitedWidth, CGFLOAT_MAX));
  
  CGSize textSize = [self sizeOfAttString:[NSAttributedString attributedStringWithData:data]
                        constrainedToSize:CGSizeMake(limitedWidth, CGFLOAT_MAX)
                               withinPath:postPath
                                textFrame:textFrame];
  
  CFRelease(postPath);
  
  return textSize;
}

@end
