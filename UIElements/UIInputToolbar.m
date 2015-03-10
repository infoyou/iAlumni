#import "UIInputToolbar.h"
#import "TextConstants.h"
#import "CommonUtils.h"

@implementation UIInputToolbar

@synthesize textView;
@synthesize inputButton;
@synthesize delegate;

-(void)inputButtonPressed
{
  if ([delegate respondsToSelector:@selector(inputButtonPressed:)]) 
  {
    [delegate inputButtonPressed:self.textView.text];    
  }
  
  /* Remove the keyboard and clear the text */
  [self.textView resignFirstResponder];
  [self.textView clearText];
}

-(void)setupToolbar:(NSString *)buttonLabel
{
  self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
  self.tintColor = [UIColor lightGrayColor];
  
  /* Create custom send button*/
  UIImage *buttonImage = [UIImage imageNamed:@"buttonbg.png"];
  buttonImage          = [buttonImage stretchableImageWithLeftCapWidth:floorf(buttonImage.size.width/2) topCapHeight:floorf(buttonImage.size.height/2)];
  
  UIButton *button               = [UIButton buttonWithType:UIButtonTypeCustom];
  button.titleLabel.font         = [UIFont boldSystemFontOfSize:15.0f];
  button.titleLabel.shadowOffset = CGSizeMake(0, -1);
  button.titleEdgeInsets         = UIEdgeInsetsMake(0, 2, 0, 2);
  button.contentStretch          = CGRectMake(0.5, 0.5, 0, 0);
  button.contentMode             = UIViewContentModeScaleToFill;
  
  [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
  [button setTitle:buttonLabel forState:UIControlStateNormal];
  [button addTarget:self action:@selector(inputButtonPressed) forControlEvents:UIControlEventTouchDown];
  [button sizeToFit];
  
  self.inputButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
  self.inputButton.customView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
  /* Disable button initially */
  self.inputButton.enabled = NO;
  
  /* Create UIExpandingTextView input */
  self.textView = [[[UIExpandingTextView alloc] initWithFrame:CGRectMake(7, 7, 236, 26)] autorelease];
  self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(4.0f, 0.0f, 10.0f, 0.0f);
  self.textView.delegate = self;
  [self addSubview:self.textView];
  
  /* Right align the toolbar button */
  UIBarButtonItem *flexItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
  
  NSArray *items = @[flexItem, self.inputButton];
  [self setItems:items animated:NO];
}

-(id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    [self setupToolbar:LocaleStringForKey(NSSendTitle, nil)];
  }
  return self;
}

-(id)init
{
  if ((self = [super init])) {
    [self setupToolbar:LocaleStringForKey(NSSendTitle, nil)];
  }
  return self;
}

- (void)drawRect:(CGRect)rect 
{
  /* Draw custon toolbar background */
  UIImage *backgroundImage = [UIImage imageNamed:@"toolbarbg.png"];
  backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:floorf(backgroundImage.size.width/2) topCapHeight:floorf(backgroundImage.size.height/2)];
  [backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
  
  CGRect i = self.inputButton.customView.frame;
  i.origin.y = self.frame.size.height - i.size.height - 7;
  self.inputButton.customView.frame = i;
}

- (void)dealloc
{
  self.inputButton = nil;
  self.textView = nil;
  [super dealloc];
}


#pragma mark - UIExpandingTextView delegate

-(void)expandingTextView:(UIExpandingTextView *)expandingTextView willChangeHeight:(float)height
{
  /* Adjust the height of the toolbar when the input component expands */
  float diff = (textView.frame.size.height - height);
  CGRect r = self.frame;
  r.origin.y += diff;
  r.size.height -= diff;
  self.frame = r;
  
  [delegate notifyTableHeight];
}

-(void)expandingTextViewDidChange:(UIExpandingTextView *)expandingTextView
{
  /* Enable/Disable the button */
  if ([expandingTextView.text length] > 0)
    self.inputButton.enabled = YES;
  else
    self.inputButton.enabled = NO;
}

@end
