#import "UIExpandingTextView.h"
#import "CommonUtils.h"

#define kTextInsetX 4
#define kTextInsetBottom 0

@implementation UIExpandingTextView

@synthesize internalTextView;
@synthesize delegate;

@synthesize text;
@synthesize font;
@synthesize textColor;
@synthesize textAlignment;
@synthesize selectedRange;
@synthesize editable;
@synthesize dataDetectorTypes;
@synthesize animateHeightChange;
@synthesize returnKeyType;
@synthesize textViewBackgroundImage;
@synthesize placeholder;

- (void)setPlaceholder:(NSString *)placeholders
{
  placeholder = placeholders;
  placeholderLabel.text = placeholders;
}

- (int)minimumNumberOfLines
{
  return minimumNumberOfLines;
}

- (int)maximumNumberOfLines
{
  return maximumNumberOfLines;
}

- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame]))
  {
    forceSizeUpdate = NO;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		CGRect backgroundFrame = frame;
    backgroundFrame.origin.y = 0;
		backgroundFrame.origin.x = 0;
    
    CGRect textViewFrame = CGRectInset(backgroundFrame, kTextInsetX, 0);
    
    /* Internal Text View component */
		internalTextView = [[UIExpandingTextViewInternal alloc] initWithFrame:textViewFrame];
		internalTextView.delegate        = self;
		internalTextView.font            = [UIFont systemFontOfSize:15.0];
		internalTextView.contentInset    = UIEdgeInsetsMake(-4,0,-4,0);
    internalTextView.text            = @"-";
		internalTextView.scrollEnabled   = NO;
    internalTextView.opaque          = NO;
    internalTextView.backgroundColor = TRANSPARENT_COLOR;
    internalTextView.showsHorizontalScrollIndicator = NO;
    [internalTextView sizeToFit];
    [internalTextView layoutIfNeeded];
    internalTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    /* set placeholder */
    placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(8,3,self.bounds.size.width - 16,self.bounds.size.height)];
    placeholderLabel.text = placeholder;
    placeholderLabel.font = internalTextView.font;
    placeholderLabel.backgroundColor = TRANSPARENT_COLOR;
    placeholderLabel.textColor = [UIColor grayColor];
    [internalTextView addSubview:placeholderLabel];
    
    /* Custom Background image */
    textViewBackgroundImage = [[UIImageView alloc] initWithFrame:backgroundFrame];
    textViewBackgroundImage.image          = [UIImage imageNamed:@"textbg"];
    textViewBackgroundImage.contentMode    = UIViewContentModeScaleToFill;
    textViewBackgroundImage.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    
    [self addSubview:textViewBackgroundImage];
    [self addSubview:internalTextView];
    
    /* Calculate the text view height */
		UIView *internal = (UIView*)[internalTextView subviews][0];
		minimumHeight = internal.frame.size.height;
		[self setMinimumNumberOfLines:1];
		animateHeightChange = YES;
		internalTextView.text = @" ";
		[self setMaximumNumberOfLines:13];
    
    [self sizeToFit];
    [self layoutIfNeeded];
  }
  return self;
}

-(void)sizeToFit
{
  CGRect r = self.frame;
  if ([self.text length] > 0)
  {
    /* No need to resize is text is not empty */
    return;
  }
  r.size.height = minimumHeight + kTextInsetBottom;
  self.frame = r;
}

-(void)setFrame:(CGRect)aframe
{
  CGRect backgroundFrame   = aframe;
  backgroundFrame.origin.y = 0;
  backgroundFrame.origin.x = 0;
  if (CURRENT_OS_VERSION >= IOS7) {
    backgroundFrame.size.height += 9;
  } else {
    backgroundFrame.size.height -= 8;
  }
  
  textViewBackgroundImage.frame = backgroundFrame;
  
  //internalTextView.frame = textViewBackgroundImage.frame;
  
  forceSizeUpdate = YES;
	[super setFrame:aframe];
}

-(void)clearText
{
  self.text = @" ";
  [self textViewDidChange:self.internalTextView];
}

-(void)setMaximumNumberOfLines:(int)n
{
  BOOL didChange            = NO;
  NSString *saveText        = internalTextView.text;
  NSString *newText         = @"-";
  internalTextView.hidden   = YES;
  internalTextView.delegate = nil;
  for (int i = 0; i < n; ++i)
  {
    newText = [newText stringByAppendingString:@"\n|W|"];
  }
  internalTextView.text     = newText;
  
  CGFloat contentHeight = internalTextView.contentSize.height;
  if (CURRENT_OS_VERSION >= IOS7) {
    contentHeight = [self getContentSizeHeightIniOS7ForText:newText];
  }
  
  didChange = (maximumHeight != contentHeight);
  maximumHeight             = contentHeight;
  maximumNumberOfLines      = n;
  internalTextView.text     = saveText;
  internalTextView.hidden   = NO;
  internalTextView.delegate = self;
  if (didChange) {
    forceSizeUpdate = YES;
    [self textViewDidChange:self.internalTextView];
  }
}

- (CGFloat)getContentSizeHeightIniOS7ForText:(NSString *)contentText {
  
  CGSize size = [CommonUtils sizeForText:contentText
                                    font:internalTextView.font
                       constrainedToSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)
                           lineBreakMode:BREAK_BY_WORD_WRAPPING];
  
  return size.height;
}

-(void)setMinimumNumberOfLines:(int)m
{
  NSString *saveText        = internalTextView.text;
  NSString *newText         = @"-";
  internalTextView.hidden   = YES;
  internalTextView.delegate = nil;
  for (int i = 2; i < m; ++i)
  {
    newText = [newText stringByAppendingString:@"\n|W|"];
  }
  internalTextView.text     = newText;
  
  if (CURRENT_OS_VERSION >= IOS7) {
    minimumHeight = [self getContentSizeHeightIniOS7ForText:internalTextView.text];
  } else {
    minimumHeight = internalTextView.contentSize.height;
  }
  
  internalTextView.text     = saveText;
  internalTextView.hidden   = NO;
  internalTextView.delegate = self;
  [self sizeToFit];
  [self layoutIfNeeded];
  minimumNumberOfLines = m;
}


- (void)textViewDidChange:(UITextView *)textView
{
  if(textView.text.length == 0)
    placeholderLabel.alpha = 1;
  else
    placeholderLabel.alpha = 0;
  
	NSInteger newHeight = internalTextView.contentSize.height;
  if (CURRENT_OS_VERSION >= IOS7) {
    NSString *temp = STR_FORMAT(@"%@W", internalTextView.text);
    newHeight = [self getContentSizeHeightIniOS7ForText:temp];
    
    newHeight += 18;
  }
  
	if(newHeight < minimumHeight || !internalTextView.hasText)
  {
    newHeight = minimumHeight;
  }
  
	if (internalTextView.frame.size.height != newHeight || forceSizeUpdate)
	{
    forceSizeUpdate = NO;
    if (newHeight > maximumHeight && internalTextView.frame.size.height <= maximumHeight)
    {
      newHeight = maximumHeight;
    }
		if (newHeight <= maximumHeight)
		{
			if(animateHeightChange)
      {
				[UIView beginAnimations:NULL_PARAM_VALUE context:nil];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(growDidStop)];
				[UIView setAnimationBeginsFromCurrentState:YES];
			}
			
			if ([delegate respondsToSelector:@selector(expandingTextView:willChangeHeight:)])
      {
				[delegate expandingTextView:self willChangeHeight:(newHeight+ kTextInsetBottom)];
			}
			
			/* Resize the frame */
			CGRect r = self.frame;
			r.size.height = newHeight + kTextInsetBottom;
			self.frame = r;
			r.origin.y = 0;
			r.origin.x = 0;
      r.size.height -= 8;
      textViewBackgroundImage.frame = r;
      internalTextView.frame = textViewBackgroundImage.frame;
      
			if(animateHeightChange)
      {
				[UIView commitAnimations];
			}
      else if ([delegate respondsToSelector:@selector(expandingTextView:didChangeHeight:)])
      {
        [delegate expandingTextView:self didChangeHeight:(newHeight+ kTextInsetBottom)];
      }
		}
		
		if (newHeight >= maximumHeight)
		{
      /* Enable vertical scrolling */
			if(!internalTextView.scrollEnabled)
      {
				internalTextView.scrollEnabled = YES;
				[internalTextView flashScrollIndicators];
			}
		}
    else
    {
      /* Disable vertical scrolling */
			internalTextView.scrollEnabled = NO;
		}
	}
	
	if ([delegate respondsToSelector:@selector(expandingTextViewDidChange:)])
  {
		[delegate expandingTextViewDidChange:self];
	}
  
	
}

-(void)growDidStop
{
	if ([delegate respondsToSelector:@selector(expandingTextView:didChangeHeight:)])
  {
		[delegate expandingTextView:self didChangeHeight:self.frame.size.height];
	}
}

-(BOOL)resignFirstResponder
{
	[super resignFirstResponder];
	return [internalTextView resignFirstResponder];
}

- (void)dealloc
{
	[internalTextView release];
  [textViewBackgroundImage release];
  [placeholderLabel release];
  [super dealloc];
}

#pragma mark UITextView properties

-(void)setText:(NSString *)atext
{
	internalTextView.text = atext;
  [self performSelector:@selector(textViewDidChange:) withObject:internalTextView];
}

-(NSString*)text
{
	return internalTextView.text;
}

-(void)setFont:(UIFont *)afont
{
	internalTextView.font= afont;
	[self setMaximumNumberOfLines:maximumNumberOfLines];
	[self setMinimumNumberOfLines:minimumNumberOfLines];
}

-(UIFont *)font
{
	return internalTextView.font;
}

-(void)setTextColor:(UIColor *)color
{
	internalTextView.textColor = color;
}

-(UIColor*)textColor
{
	return internalTextView.textColor;
}

-(void)setTextAlignment:(UITextAlignment)aligment
{
	internalTextView.textAlignment = aligment;
}

-(UITextAlignment)textAlignment
{
	return internalTextView.textAlignment;
}

-(void)setSelectedRange:(NSRange)range
{
	internalTextView.selectedRange = range;
}

-(NSRange)selectedRange
{
	return internalTextView.selectedRange;
}

-(void)setEditable:(BOOL)beditable
{
	internalTextView.editable = beditable;
}

-(BOOL)isEditable
{
	return internalTextView.editable;
}

-(void)setReturnKeyType:(UIReturnKeyType)keyType
{
	internalTextView.returnKeyType = keyType;
}

-(UIReturnKeyType)returnKeyType
{
	return internalTextView.returnKeyType;
}

-(void)setDataDetectorTypes:(UIDataDetectorTypes)datadetector
{
	internalTextView.dataDetectorTypes = datadetector;
}

-(UIDataDetectorTypes)dataDetectorTypes
{
	return internalTextView.dataDetectorTypes;
}

- (BOOL)hasText
{
	return [internalTextView hasText];
}

- (void)scrollRangeToVisible:(NSRange)range
{
	[internalTextView scrollRangeToVisible:range];
}

#pragma mark -
#pragma mark UIExpandingTextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	if ([delegate respondsToSelector:@selector(expandingTextViewShouldBeginEditing:)])
  {
		return [delegate expandingTextViewShouldBeginEditing:self];
	}
  else
  {
		return YES;
	}
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	if ([delegate respondsToSelector:@selector(expandingTextViewShouldEndEditing:)])
  {
		return [delegate expandingTextViewShouldEndEditing:self];
	}
  else
  {
		return YES;
	}
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if ([delegate respondsToSelector:@selector(expandingTextViewDidBeginEditing:)])
  {
		[delegate expandingTextViewDidBeginEditing:self];
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if ([delegate respondsToSelector:@selector(expandingTextViewDidEndEditing:)])
  {
		[delegate expandingTextViewDidEndEditing:self];
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)atext
{
	if(![textView hasText] && [atext isEqualToString:NULL_PARAM_VALUE])
  {
    return NO;
	}
  
	if ([atext isEqualToString:@"\n"])
  {
		if ([delegate respondsToSelector:@selector(expandingTextViewShouldReturn:)])
    {
			if (![delegate performSelector:@selector(expandingTextViewShouldReturn:) withObject:self])
      {
				return YES;
			}
      else
      {
				[textView resignFirstResponder];
				return NO;
			}
		}
	}
	return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
  NSLog(@"width: %f", internalTextView.contentSize.width);
  NSLog(@"height: %f", internalTextView.contentSize.height);
  
	if ([delegate respondsToSelector:@selector(expandingTextViewDidChangeSelection:)])
  {
		[delegate expandingTextViewDidChangeSelection:self];
	}
}

@end
