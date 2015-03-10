//
//  TodoEntranceView.m
//  iAlumni
//
//  Created by Adam on 13-1-11.
//
//

#import "TodoEntranceView.h"
#import <CoreText/CoreText.h>
#import "CoreTextView.h"
#import "CoreTextMarkupParser.h"
#import "NSAttributedString+Encoding.h"
#import "WXWLabel.h"
#import "AppManager.h"
#import "CommonUtils.h"

#define ICON_WIDTH  57.5f
#define ICON_HEIGHT 57.5f

#define TIMER_INTERVAL    8

@interface TodoEntranceView()
@property (nonatomic, retain) NSTimer *timer;
@end

@implementation TodoEntranceView

#pragma mark - lifecycle method

- (id)initWithFrame:(CGRect)frame entrancce:(id)entrance action:(SEL)action
{
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = COLOR(102, 153, 204);
    
    self.layer.masksToBounds = YES;
    
    _entrance = entrance;
    
    _action = action;
    
    _imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(85, (frame.size.height - ICON_HEIGHT)/2.0f - MARGIN * 2, ICON_WIDTH, ICON_HEIGHT)] autorelease];
    _imageView.image = [UIImage imageNamed:@"whiteEvent.png"];
    [self addSubview:_imageView];
    
    _emptyMsgLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                            textColor:[UIColor whiteColor]
                                          shadowColor:TRANSPARENT_COLOR] autorelease];
    _emptyMsgLabel.numberOfLines = 2;
    _emptyMsgLabel.font = BOLD_FONT(18);
    [self addSubview:_emptyMsgLabel];
    
    _emptyMsgLabel.text = LocaleStringForKey(NSTodoItemMsg, nil);
    CGSize size = [CommonUtils sizeForText:_emptyMsgLabel.text
                                      font:_emptyMsgLabel.font
                         constrainedToSize:CGSizeMake(self.frame.size.width - MARGIN * 3, self.frame.size.height)
                             lineBreakMode:BREAK_BY_TRUNCATING_TAIL];
    
    CGFloat y = 0;
    if ([CommonUtils screenHeightIs4Inch]) {
      y = self.frame.size.height - MARGIN * 3 - size.height;
    } else {
      y = self.frame.size.height - MARGIN - size.height;
    }

    _emptyMsgLabel.frame = CGRectMake(MARGIN * 2, y, size.width, size.height);
    
  }
  return self;
}

- (void)dealloc {
  
  //[self stopPlay];
  
  [super dealloc];
}

/*
#pragma mark - arrange titles

- (void)addGroupMsgView {
  _groupMsgView = [[[CoreTextView alloc] initWithFrame:CGRectZero] autorelease];
  [self addSubview:_groupMsgView];
  
}

- (void)addEventMsgView {
  _eventMsgView = [[[CoreTextView alloc] initWithFrame:CGRectZero] autorelease];
  [self addSubview:_eventMsgView];
  
}

- (void)setGroupMsg:(CGFloat)limitedWidth {
  
  [self addGroupMsgView];
  
  CTFrameRef textFrame;
  CGSize textSize = [self getTextFrameSizeBaseOnData:[AppManager instance].groupPaymentContent
                                        limitedWidth:limitedWidth
                                           textFrame:&textFrame];
  
  
  _groupMsgView.frame = CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width + MARGIN * 2, self.bounds.size.height, textSize.width, textSize.height);
  
  [self renderCoreTextView:&_groupMsgView textFrame:textFrame];
  
  _groupMsgView.alpha = 0.0f;
}

- (void)setEventMsg:(CGFloat)limitedWidth {
  
  [self addEventMsgView];
  
  CTFrameRef textFrame;
  CGSize textSize = [self getTextFrameSizeBaseOnData:[AppManager instance].eventPaymentContent
                                        limitedWidth:limitedWidth
                                           textFrame:&textFrame];
  
  
  _eventMsgView.frame = CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width + MARGIN * 2, self.bounds.size.height, textSize.width, textSize.height);
  
  [self renderCoreTextView:&_eventMsgView textFrame:textFrame];
  
  _eventMsgView.alpha = 0.0f;
}

- (void)setEmptyMsg:(CGFloat)limitedWidth {
  _emptyMsgLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                          textColor:[UIColor whiteColor]
                                        shadowColor:TRANSPARENT_COLOR] autorelease];
  _emptyMsgLabel.numberOfLines = 2;
  _emptyMsgLabel.font = BOLD_FONT(20);
  [self addSubview:_emptyMsgLabel];
  
  _emptyMsgLabel.text = [NSString stringWithFormat:@"%@0%@", LocaleStringForKey(NSYouHaveMsg, nil), LocaleStringForKey(NSTodoItemMsg, nil)];
  CGSize size = [CommonUtils sizeForText:_emptyMsgLabel.text
                                    font:_emptyMsgLabel.font
                       constrainedToSize:CGSizeMake(limitedWidth, self.frame.size.height)
                           lineBreakMode:NSLineBreakByTruncatingTail
                              attributes:@{NSFontAttributeName: _emptyMsgLabel.font}];
  _emptyMsgLabel.frame = CGRectMake(MARGIN * 3, self.frame.size.height - MARGIN * 3 - size.height, size.width, size.height);
}

- (void)displayOneTypeMsg {
  CoreTextView *textView = nil;
  if (_groupMsgView) {
    textView = _groupMsgView;
  } else {
    textView = _eventMsgView;
  }
  
  textView.frame = CGRectMake(textView.frame.origin.x,
                              (self.frame.size.height - textView.frame.size.height)/2.0f,
                              textView.frame.size.width,
                              textView.frame.size.height);
  textView.alpha = 1.0f;
}

- (void)autoScrollPlay {
  
  [UIView animateWithDuration:0.5f
                        delay:3
                      options:UIViewAnimationOptionAllowUserInteraction
                   animations:^{
                     
                     _groupMsgView.frame = CGRectOffset(_groupMsgView.bounds,
                                                        _groupMsgView.frame.origin.x,
                                                        (self.frame.size.height - _groupMsgView.frame.size.height)/2.0f);
                     _groupMsgView.alpha = 1.0f;            
                     
                     _eventMsgView.frame = CGRectOffset(_eventMsgView.bounds,
                                                        _eventMsgView.frame.origin.x,
                                                        -1*_eventMsgView.frame.size.height);
                     _eventMsgView.alpha = 0.0f;
                   }
                   completion:^(BOOL finished){
                     
                     _eventMsgView.frame = CGRectOffset(_eventMsgView.bounds,
                                                        _eventMsgView.frame.origin.x,
                                                        self.bounds.size.height);
                     
                     [UIView animateWithDuration:0.5f
                                           delay:3
                                         options:0
                                      animations:^{
                                        
                                        _eventMsgView.frame = CGRectOffset(_eventMsgView.bounds,
                                                                           _eventMsgView.frame.origin.x,
                                                                           (self.frame.size.height - _eventMsgView.frame.size.height)/2.0f);
                                        _eventMsgView.alpha = 1.0f;
                                        
                                        _groupMsgView.frame = CGRectOffset(_groupMsgView.bounds,
                                                                           _groupMsgView.frame.origin.x,
                                                                           -1 * _groupMsgView.frame.size.height);
                                        _groupMsgView.alpha = 0.0f;
                                        
                                      }
                                      completion:^(BOOL finished){
                                        
                                        _groupMsgView.frame = CGRectOffset(_groupMsgView.bounds,
                                                                           _groupMsgView.frame.origin.x,
                                                                           self.bounds.size.height);
                                        
                                      }];
                     
                   }];
}

- (void)stopPlay {
  
  if (self.timer && [self.timer isValid]) {
    [self.timer invalidate];
    
  }
  self.timer = nil;
  
  [self clearEventPaymentMessage];
  
  [self clearGroupPaymentMessage];
}

- (void)play {
  [self triggerPlayMsg];
}

- (void)triggerPlayMsg {
  
  if (_groupMsgView && _eventMsgView) {
    
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                  target:self
                                                selector:@selector(autoScrollPlay)
                                                userInfo:nil
                                                 repeats:YES];
    
    [self.timer fire];
    
  } else {
    [self displayOneTypeMsg];
  }
}

- (void)clearGroupPaymentMessage {
  if (_groupMsgView) {
    [_groupMsgView removeFromSuperview];
    _groupMsgView = nil;
  }
}

- (void)clearEventPaymentMessage {
  
  if (_eventMsgView) {
    [_eventMsgView removeFromSuperview];
    _eventMsgView = nil;
  }
}

- (void)arrangeMessages {
    
  CGFloat limitedWidth = self.frame.size.width - (_imageView.frame.origin.x + _imageView.frame.size.width + MARGIN * 2) - MARGIN * 2;
    
  if ([AppManager instance].groupPaymentItemCount == 0 &&
      [AppManager instance].eventPaymentItemCount == 0) {
    
    [self clearGroupPaymentMessage];
    
    [self clearEventPaymentMessage];
    
    [self setEmptyMsg:limitedWidth];
  } else {
    if ([AppManager instance].groupPaymentItemCount > 0) {
      [self setGroupMsg:limitedWidth];
    } else {
      [self clearGroupPaymentMessage];
    }
    
    if ([AppManager instance].eventPaymentItemCount > 0) {
      [self setEventMsg:limitedWidth];
    } else {
      [self clearEventPaymentMessage];
    }
    
    [self triggerPlayMsg];
  }
}
*/

#pragma mark - draw core text utilities
- (CGSize)sizeOfAttString:(NSAttributedString *)attString
        constrainedToSize:(CGSize)constrainedToSize
               withinPath:(CGPathRef)path
                textFrame:(CTFrameRef *)textFrame {
  
  CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
  
  CFRange range = CFRangeMake(0, 0);
  
  CFRange fitRange;
  CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, range, nil, constrainedToSize, &fitRange);
  
  // coreTextSize.height + 1 is a bit hacky, it solves CTFramesetterSuggestFrameSizeWithConstraints
  // method may return a height that only-just doesn't fit the given text and it's attributes. iOS 4.3
  // return float instead of integer for height and width
  CGPathRef textPath = CGPathCreateWithRect(CGRectMake(0, 0, coreTextSize.width, coreTextSize.height + 1), NULL);
  *textFrame = CTFramesetterCreateFrame(frameSetter, fitRange, textPath, NULL);
  
  CFRelease(textPath);
  
  return coreTextSize;
}

- (void)renderCoreTextView:(CoreTextView **)coreTextView
                 textFrame:(CTFrameRef)textFrame {
  [(*coreTextView) setCTFrame:(id)textFrame];
  [(*coreTextView) setNeedsDisplay];
}

- (CGSize)getTextFrameSizeBaseOnData:(NSData *)data
                        limitedWidth:(CGFloat)limitedWidth
                           textFrame:(CTFrameRef *)textFrame {
  
  CGMutablePathRef postPath = CGPathCreateMutable();
  CGPathAddRect(postPath, NULL, CGRectMake(0, 0, limitedWidth, self.frame.size.height - MARGIN * 2));
  
  CGSize textSize = [self sizeOfAttString:[NSAttributedString attributedStringWithData:data]
                        constrainedToSize:CGSizeMake(limitedWidth, self.frame.size.height - MARGIN * 2)
                               withinPath:postPath
                                textFrame:textFrame];
  
  CFRelease(postPath);
  
  return textSize;
}

#pragma mark - touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  NSInteger todoCount = [AppManager instance].groupPaymentItemCount + [AppManager instance].eventPaymentItemCount;
  
  if (0 == todoCount) {
    return;
  }
  
  if (_entrance && _action) {
    [_entrance performSelector:_action];
  }
}

@end
