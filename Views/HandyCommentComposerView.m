//
//  HandyCommentComposerView.m
//  ExpatCircle
//
//  Created by Adam on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HandyCommentComposerView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "News.h"
#import "ECGradientButton.h"
#import "ECInnerShadowTextView.h"
#import "UIUtils.h"

#define ADJUST_HEIGHT     40.0f
#define BTN_HEIGHT        20.0f
#define BTN_WIDTH         60.0f

@interface HandyCommentComposerView();
@property (nonatomic, retain) News *news;
@property (nonatomic, copy) NSString *composerTitle;
- (void)adjustLayout:(BOOL)enlarge;
@end

@implementation HandyCommentComposerView

@synthesize news = _news;
@synthesize enlarged = _enlarged;
@synthesize composerTitle = _composerTitle;

#pragma mark - user action
- (void)send:(id)sender {
  
  if (nil == _commentTextView.text || 0 == _commentTextView.text.length) {
    NSString *msg = LocaleStringForKey(NSCommentEmptyMsg, nil);
    if (_contentType == SEND_SERVICE_ITEM_COMMENT_TY) {
      msg = LocaleStringForKey(NSReviewsEmptyMsg, nil);
    }
    [UIUtils showNotificationOnTopWithMsg:msg
                                  msgType:WARNING_TY 
                       belowNavigationBar:YES];
    return;
  }
  
  if (_clickableElementDelegate) {
    [_clickableElementDelegate sendComment:_commentTextView.text];
    [self adjustLayout:NO];
  }
}

#pragma mark - lifecycle methods

- (id)initWithFrame:(CGRect)frame
              count:(NSInteger)count
        contentType:(NSInteger)contentType
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate {
  self = [super initWithFrame:frame];
  if (self) {
    
    _count = count;
    
    _clickableElementDelegate = clickableElementDelegate;
    
    _contentType = contentType;
    
    self.backgroundColor = CELL_COLOR;
    
    _title = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                   textColor:BASE_INFO_COLOR 
                                 shadowColor:[UIColor whiteColor]] autorelease];
    _title.font = BOLD_FONT(14);
    
    if (_contentType == SEND_SERVICE_ITEM_COMMENT_TY) {
      self.composerTitle = LocaleStringForKey(NSReviewsTitle, nil);
    } else {
      self.composerTitle = LocaleStringForKey(NSCommentsTitle, nil);
    }
    _title.text = self.composerTitle;
    CGSize size = [_title.text sizeWithFont:_title.font 
                                   forWidth:300.0f 
                              lineBreakMode:NSLineBreakByWordWrapping];
    _title.frame = CGRectMake(MARGIN * 2, MARGIN * 2, self.frame.size.width, size.height);
    [self addSubview:_title];
    
    _sendButton = [[[ECGradientButton alloc] initWithFrame:CGRectMake(frame.size.width - MARGIN * 2 - BTN_WIDTH, _title.frame.origin.y - 2.0f, BTN_WIDTH, BTN_HEIGHT) 
                                                    target:self
                                                    action:@selector(send:)
                                                 colorType:RED_BTN_COLOR_TY
                                                     title:LocaleStringForKey(NSSendTitle, nil)
                                                     image:nil
                                                titleColor:[UIColor whiteColor]
                                          titleShadowColor:[UIColor blackColor]
                                                 titleFont:BOLD_FONT(12)
                                               roundedType:HAS_ROUNDED
                                           imageEdgeInsert:ZERO_EDGE
                                           titleEdgeInsert:ZERO_EDGE] autorelease];
    _sendButton.layer.cornerRadius = BTN_HEIGHT/2.0f;
    _sendButton.alpha = 0.0f;
    _sendButton.enabled = NO;
    
    [self addSubview:_sendButton];
    
    _commentTextView = [[[ECInnerShadowTextView alloc] initWithFrame:CGRectMake(MARGIN * 2, _title.frame.origin.y + _title.frame.size.height + MARGIN, frame.size.width - MARGIN * 4, 40.0f)] autorelease];
    _commentTextView.delegate = self;
    _commentTextView.editable = YES;
    _commentTextView.backgroundColor = [UIColor whiteColor];
    _commentTextView.font = FONT(14);
    _commentTextView.layer.borderColor = LIGHT_GRAY_BTN_BORDER_COLOR.CGColor;
    _commentTextView.layer.borderWidth = 1.0f;
    _commentTextView.layer.cornerRadius = 6.0f;
    if (_contentType == SEND_SERVICE_ITEM_COMMENT_TY) {
      _commentTextView.placeholder = LocaleStringForKey(NSWriteReviewsTitle, nil);
    } else {
      _commentTextView.placeholder = LocaleStringForKey(NSWriteCommentTitle, nil);
    }

    [self addSubview:_commentTextView];
    
  }
  return self;
}

- (void)dealloc {
  
  self.news = nil;
  
  _commentTextView.delegate = nil;
  
  [super dealloc];
}

#pragma mark - update UI

- (void)adjustLayout:(BOOL)enlarge {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.2f];
  
  if (enlarge) {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + ADJUST_HEIGHT);
    _commentTextView.frame = CGRectMake(_commentTextView.frame.origin.x, _commentTextView.frame.origin.y, _commentTextView.frame.size.width, 80);

    _commentTextView.placeholder = nil;
    
    [_commentTextView hideAddCommentIcon];
    
    _sendButton.alpha = 1.0f;
    _sendButton.enabled = YES;
    
  } else {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height - ADJUST_HEIGHT);
    _commentTextView.frame = CGRectMake(_commentTextView.frame.origin.x, _commentTextView.frame.origin.y, _commentTextView.frame.size.width, 40);
    
    [_commentTextView resignFirstResponder];
    
    _commentTextView.text = nil;
    
    _commentTextView.placeholder = LocaleStringForKey(NSWriteCommentTitle, nil);
    
    [_commentTextView showAddCommentIcon];
    
    _sendButton.alpha = 0.0f;
    _sendButton.enabled = NO;
  }
  /*
  _sendButton.frame = CGRectMake(_sendButton.frame.origin.x, _commentTextView.frame.origin.y + _commentTextView.frame.size.height + MARGIN, _sendButton.frame.size.width, _sendButton.frame.size.height);
  */
  
  if (_clickableElementDelegate) {
    [_clickableElementDelegate tapGestureHandler];
  }
  
  [UIView commitAnimations];
  
  self.enlarged = enlarge;
}

- (void)updateCommentCount:(NSInteger)count {
  _title.text = [NSString stringWithFormat:@"%@(%d)", self.composerTitle, count];
}

#pragma mark - UITextViewDelegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  
  if (!self.enlarged) {
    [self adjustLayout:YES];
  }
  
  
  return YES;
}


@end
