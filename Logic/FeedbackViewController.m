//
//  FeedbackViewController.m
//  iAlumni
//
//  Created by Adam on 12-2-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedbackViewController.h"
#import "UIWebViewController.h"
#import "ECGradientButton.h"
#import "ECAsyncConnectorFacade.h"
#import "CommonUtils.h"
#import "AppManager.h"
#import "UIUtils.h"
#import "XMLParser.h"
#import "UIImageButton.h"

#define FONT_SIZE           14
#define LABEL_Y             10
#define TITLE_HEIGHT        200
#define TextFieldHeight     120

#define HTML_VIEW_TAG         100
#define FEEDBACK_LABEL_1_TAG  200
#define FEEDBACK_LABEL_2_TAG  300

#define BTN_WIDTH           100
#define BTN_HEIGHT          30

static int  OneHeight = 0;
static int  InputSize = 0;
static int  Section0Height = 0;
static int  Section1Height = 0;
static int  Section2Height = 0;

@implementation FeedbackViewController
@synthesize _feedback;

- (id)init:(NSManagedObjectContext*)MOC
{
  self = [super initWithMOC:MOC holder:nil backToHomeAction:nil needGoHome:NO];
  if (self) {
    // Custom initialization
    _selCellArray = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc
{
  RELEASE_OBJ(title0View);
  RELEASE_OBJ(title1View);
  RELEASE_OBJ(title2View);
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

- (void)loadFeedback
{
  ECAsyncConnectorFacade *connFacade = [[ECAsyncConnectorFacade alloc] initWithDelegate:self interactionContentType:FETCH_FEEDBACK_MSG_TY];
  [connFacade fetchGets:[NSString stringWithFormat:@"%@%@&locale=%@", [AppManager instance].hostUrl, SOFT_FEEDBACK_MSG_URL, [WXWSystemInfoManager instance].currentLanguageDesc]];
  [connFacade release];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (!_autoLoaded) {
    [self loadFeedback];
  }
}

- (void)getLogicSize
{
  CGSize fontSize =[LocaleStringForKey(NSFeedbackMsg, nil) sizeWithFont:FONT(FONT_SIZE)
                                                               forWidth:SCREEN_WIDTH-20
                                                          lineBreakMode:NSLineBreakByTruncatingTail];
  OneHeight = fontSize.height;
  
  CGSize feedbackConstraint = CGSizeMake(SCREEN_WIDTH-20, 2000.0f);
  CGSize feedbackSize = [LocaleStringForKey(NSFeedbackMsg, nil) sizeWithFont:FONT(FONT_SIZE) constrainedToSize:feedbackConstraint lineBreakMode:NSLineBreakByWordWrapping];
  Section0Height = feedbackSize.height;
  
  CGSize feedback1Constraint = CGSizeMake(SCREEN_WIDTH-20, 2000.0f);
  CGSize feedback1Size = [LocaleStringForKey(NSFeedbackMsg1, nil) sizeWithFont:FONT(FONT_SIZE) constrainedToSize:feedback1Constraint lineBreakMode:NSLineBreakByWordWrapping];
  Section1Height = feedback1Size.height;
  
  CGSize feedback2Constraint = CGSizeMake(SCREEN_WIDTH-20, 2000.0f);
  CGSize feedback2Size = [LocaleStringForKey(NSFeedbackMsg2, nil) sizeWithFont:FONT(FONT_SIZE) constrainedToSize:feedback2Constraint lineBreakMode:NSLineBreakByWordWrapping];
  Section2Height = feedback2Size.height;
}

- (void)initTableView
{
  CGRect mTabFrame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
	_tableView = [[UITableView alloc] initWithFrame:mTabFrame
                                            style:UITableViewStyleGrouped];
	
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.dataSource = self;
	_tableView.delegate = self;
  _tableView.backgroundView = nil;
	
	[self.view addSubview:_tableView];
  [super initTableView];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  
}

#pragma mark - Url
- (void)gotoUrl:(NSString*)url aTitle:(NSString*)title
{
  UIWebViewController *webVC = [[UIWebViewController alloc] initWithNeedAdjustForiOS7:YES];
  UINavigationController *webViewNav = [[UINavigationController alloc] initWithRootViewController:webVC];
  webViewNav.navigationBar.tintColor = TITLESTYLE_COLOR;
  webVC.strUrl = url;
  webVC.strTitle = title;
  
  [self.parentViewController presentModalViewController:webViewNav
                                               animated:YES];
  RELEASE_OBJ(webVC);
  RELEASE_OBJ(webViewNav);
}

#pragma mark - Tel
- (void)actionSheet:(UIActionSheet*)aSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case 0:
		{
			NSString *phoneStr = [[NSString alloc] initWithFormat:@"tel:%@", _feedback.tel];
			NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
			[[UIApplication sharedApplication] openURL:phoneURL];
			[phoneURL release];
			[phoneStr release];
			break;
		}
		case 1:
			return;
			
		default:
			break;
	}
}

- (void)goCallPhone {
  
  UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSCallActionSheetTitle, nil)
                                                  delegate:self
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:LocaleStringForKey(NSCallTitle, nil)
                                         otherButtonTitles:nil];
  
  [as addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  as.cancelButtonIndex = [as numberOfButtons] - 1;
  [as showInView:self.navigationController.view];
  
  [as release];
  as = nil;
}

#pragma mark - handle empty list
- (BOOL)listIsEmpty {
  return NO;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section) {
    case 0:
      return 1;
      break;
      
    case 1:
      return [[_feedback.sampleMsg componentsSeparatedByString:@"|"] count];
      break;
      
    case 2:
      return 2;
      break;
      
    default:
      return 0;
      break;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  int section = [indexPath section];
  switch (section) {
    case 0:
      return TextFieldHeight;
      break;
      
    case 1:
      return 40;
      break;
      
    case 2:
      return 40;
      break;
      
    default:
      return 0;
      break;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  switch (section) {
    case 0:
      return Section2Height*2 + 10;
      break;
      
    case 1:
    case 2:
      return Section2Height+10;
      break;
      
    default:
      return 0;
      break;
  }
}

- (UIView *)section0View
{
  
  if (nil == title0View) {
    title0View = [[UIView alloc] initWithFrame:CGRectZero];
    UIWebView *htmlView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
    htmlView.tag = HTML_VIEW_TAG;
    htmlView.delegate = self;
    htmlView.userInteractionEnabled = YES;
    htmlView.backgroundColor = TRANSPARENT_COLOR;
    htmlView.opaque = NO;
    
    [title0View addSubview:htmlView];
    [title0View setBackgroundColor:TRANSPARENT_COLOR];
    
  }
  title0View.frame = CGRectMake(0, 0, SCREEN_WIDTH, Section2Height*2+20);
  UIWebView *webView = (UIWebView *)[title0View viewWithTag:HTML_VIEW_TAG];
  webView.frame = title0View.frame;
  
  NSString *urlStr = [NSString stringWithFormat:@"%@%@%@", TEXT_HEADER, LocaleStringForKey(NSFeedbackMsg, nil), TEXT_FOOTER];
  NSURL *loadUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
  [webView loadHTMLString:urlStr baseURL:loadUrl];
  
  return title0View;
}

- (UIView *)section1View
{
  if (nil == title1View) {
    title1View = [[UIView alloc] initWithFrame:CGRectZero];
    
    UILabel *feedbackLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    feedbackLabel.tag = FEEDBACK_LABEL_1_TAG;
    feedbackLabel.textColor = [UIColor blackColor];
    feedbackLabel.font = FONT(FONT_SIZE);
    feedbackLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [feedbackLabel setBackgroundColor:TRANSPARENT_COLOR];
    
    [title1View addSubview:feedbackLabel];
  }
  
  title1View.frame = CGRectMake(0, 0, SCREEN_WIDTH, Section1Height+20);
  
  UILabel *label = (UILabel *)[title1View viewWithTag:FEEDBACK_LABEL_1_TAG];
  label.frame = CGRectMake(10, 10, SCREEN_WIDTH-20, Section2Height);
  if ( Section2Height % OneHeight == 0 ) {
    label.numberOfLines = Section2Height/OneHeight;
  }else{
    label.numberOfLines = Section2Height/OneHeight + 1;
  }

  return title1View;
}

- (UIView *)section2View
{
  
  if (nil == title2View) {
    title2View = [[UIView alloc] initWithFrame:CGRectZero];
    
    UILabel *feedbackLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    feedbackLabel.tag = FEEDBACK_LABEL_2_TAG;
    feedbackLabel.text = LocaleStringForKey(NSFeedbackMsg3, nil);
    feedbackLabel.textColor = [UIColor blackColor];
    feedbackLabel.font = FONT(FONT_SIZE);
    feedbackLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [feedbackLabel setBackgroundColor:TRANSPARENT_COLOR];

    [title2View addSubview:feedbackLabel];
  }
  
  title2View.frame = CGRectMake(0, 0, SCREEN_WIDTH, Section1Height+20);
  
  UILabel *label = (UILabel *)[title2View viewWithTag:FEEDBACK_LABEL_2_TAG];
  label.frame = CGRectMake(10, 10, SCREEN_WIDTH-20, Section2Height);
  
  if ( Section2Height % OneHeight == 0 ) {
    label.numberOfLines = Section2Height/OneHeight;
  }else{
    label.numberOfLines = Section2Height/OneHeight + 1;
  }

  return title2View;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)section {
  switch (section) {
    case 0:
      return [self section0View];
    case 1:
      return [self section1View];
    case 2:
      return [self section2View];
    default:
      return nil;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  switch (section) {
    case 1:
      return 40;
      break;
      
    case 0:
    case 2:
      return 10;
      break;
      
    default:
      return 0;
  }
}

- (UIView *)tableView:(UITableView *)aTableView viewForFooterInSection:(NSInteger)section {
  switch (section) {
    case 1:
    {
      UIView *mUIView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)] autorelease];
      
      UIImageButton *submitButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake((mUIView.frame.size.width - BTN_WIDTH)/2.0f, MARGIN, BTN_WIDTH, BTN_HEIGHT)
                                                                              target:self
                                                                              action:@selector(submitClick:)
                                                                               title:LocaleStringForKey(NSSubmitButTitle, nil)
                                                                               image:nil
                                                                         backImgName:@"orangeButton.png"
                                                                      selBackImgName:nil
                                                                           titleFont:BOLD_FONT(16.f)
                                                                          titleColor:[UIColor whiteColor]
                                                                    titleShadowColor:TRANSPARENT_COLOR
                                                                         roundedType:NO_ROUNDED
                                                                     imageEdgeInsert:ZERO_EDGE
                                                                     titleEdgeInsert:ZERO_EDGE] autorelease];
      
      [mUIView addSubview:submitButton];
      return mUIView;
    }
      break;
      
    default:
      return nil;
      break;
  }
}

-(void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell
{
  int line = [indexPath section];
  int row = [indexPath row];
  [cell setBackgroundColor:[UIColor whiteColor]];
  
  switch (line) {
    case 0:
    {
      CGRect textFrame = CGRectMake(0, 0, SCREEN_WIDTH-20, TextFieldHeight);
      _textView = [[[UITextView alloc] initWithFrame:textFrame] autorelease];
      _textView.textColor = [UIColor grayColor];
      _textView.font = FONT(FONT_SIZE);
      _textView.delegate = self;
      _textView.text = LocaleStringForKey(NSFeedbackPromptTitle, nil);
      _textView.backgroundColor = TRANSPARENT_COLOR;
      _textView.returnKeyType = UIReturnKeyDefault;
      _textView.keyboardType = UIKeyboardTypeDefault;
      // use the default type input method (entire keyboard)
      _textView.scrollEnabled = YES;
      
      // this will cause automatic vertical resize when the table is resized
      _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
      
      // note: for UITextView, if you don't like autocompletion while typing use:
      _textView.autocorrectionType = UITextAutocorrectionTypeNo;
      
      // keyboard view add Done Button
      UIToolbar * topView = [[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
      
      [topView setBarStyle:UIBarStyleBlack];
      
      UIBarButtonItem * helloButton = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:LocaleStringForKey(NSKeyboardTitle, nil), InputSize] style:UIBarButtonItemStylePlain target:self action:nil];
      
      UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
      
      UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
      
      NSArray * buttonsArray = @[helloButton,btnSpace,doneButton];
      
      [doneButton release];
      [btnSpace release];
      [helloButton release];
      [topView setItems:buttonsArray];
      
      [_textView setInputAccessoryView:topView];
      [cell.contentView addSubview:_textView];
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
      break;
      
    case 1:
    {
      // Label
      NSArray *aArray = [_feedback.sampleMsg componentsSeparatedByString:@"|"];
      NSString *mText = aArray[row];
      CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE)];
      UILabel *mUILable = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN * 2, LABEL_Y, mDescSize.width, mDescSize.height)];
      mUILable.text = mText;
      mUILable.textColor = [UIColor blackColor];
      [mUILable setBackgroundColor:TRANSPARENT_COLOR];
      mUILable.font = FONT(FONT_SIZE);
      mUILable.tag = row + 10;
      mUILable.highlightedTextColor = [UIColor whiteColor];
      [cell.contentView addSubview:mUILable];
      [mUILable release];
      
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
      break;
      
    case 2:
    {
      switch (row) {
        case 0:
        {
          // Label
          NSString *mText = LocaleStringForKey(NSTelTitle,nil);
          CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE)];
          UILabel *mUILable = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN * 2, LABEL_Y, mDescSize.width, mDescSize.height)];
          mUILable.text = mText;
          mUILable.textColor = COLOR(82, 82, 82);
          [mUILable setBackgroundColor:TRANSPARENT_COLOR];
          mUILable.font = FONT(FONT_SIZE);
          mUILable.tag = row + 20;
          mUILable.highlightedTextColor = [UIColor whiteColor];
          [cell.contentView addSubview:mUILable];
          [mUILable release];
          
          // Number
          NSString *mNumber = _feedback.tel;
          CGSize mNumberSize = [mNumber sizeWithFont:FONT(FONT_SIZE)];
          
          UILabel *mLable = [[UILabel alloc] init];
          mLable.text = mNumber;
          mLable.font = FONT(FONT_SIZE);
          mLable.textColor = [UIColor blackColor];
          mLable.highlightedTextColor = [UIColor whiteColor];
          [mLable setBackgroundColor:TRANSPARENT_COLOR];
          CGRect mLabelFrame = CGRectMake(80, LABEL_Y, mNumberSize.width, mNumberSize.height);
          mLable.lineBreakMode = NSLineBreakByTruncatingTail;
          mLable.frame = mLabelFrame;
          
          [cell.contentView addSubview:mLable];
          [mLable release];
          
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
          break;
          
        case 1:
        {
          // Label
          NSString *mText = LocaleStringForKey(NSEmailTitle,nil);
          CGSize mDescSize = [mText sizeWithFont:FONT(FONT_SIZE)];
          CGRect labelFrame = CGRectMake(MARGIN * 2, LABEL_Y, mDescSize.width, mDescSize.height);
          UILabel *mUILable = [[UILabel alloc] initWithFrame:labelFrame];
          mUILable.text = mText;
          mUILable.textColor = COLOR(82, 82, 82);
          [mUILable setBackgroundColor:TRANSPARENT_COLOR];
          mUILable.font = FONT(FONT_SIZE);
          mUILable.tag = row + 20;
          mUILable.highlightedTextColor = [UIColor whiteColor];
          [cell.contentView addSubview:mUILable];
          [mUILable release];
          
          // Number
          NSString *mNumber = _feedback.email;
          CGSize mNumberSize = [mNumber sizeWithFont:FONT(FONT_SIZE)];
          
          UILabel *mLable = [[UILabel alloc] init];
          mLable.text = mNumber;
          mLable.font = FONT(FONT_SIZE);
          mLable.textColor = [UIColor blackColor];
          mLable.highlightedTextColor = [UIColor whiteColor];
          [mLable setBackgroundColor:TRANSPARENT_COLOR];
          CGRect mLabelFrame = CGRectMake(80, LABEL_Y, mNumberSize.width, mNumberSize.height);
          mLable.lineBreakMode = NSLineBreakByTruncatingTail;
          mLable.frame = mLabelFrame;
          
          [cell.contentView addSubview:mLable];
          [mLable release];
          
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
          cell.selectionStyle = UITableViewCellSelectionStyleGray;
          break;
      }
    }
      break;
    default:
      break;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
  for (UIView *subview in subviews) {
    [subview removeFromSuperview];
  }
  [subviews release];
  
  if (![_selCellArray containsObject:indexPath]) {
    cell.accessoryType = UITableViewCellAccessoryNone;
  } else {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }
  
  // Configure the cell...
  [self configureCell:indexPath aCell:cell];
  return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  switch ([indexPath section]) {
      
    case 0:
    {
      if (![CommonUtils getDeviceAndOSInfo]) {
        [_textView becomeFirstResponder];
        if ([_textView isFirstResponder]) {
          [_textView resignFirstResponder];
        }
      }
    }
      break;
      
    case 1:
    {
      UITableViewCell *mCell = [tableView cellForRowAtIndexPath:indexPath];
      if (mCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        mCell.accessoryType = UITableViewCellAccessoryNone;
        [_selCellArray removeObject:indexPath];
      }else{
        mCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [_selCellArray addObject:indexPath];
        NSString *url = [NSString stringWithFormat:@"%@index=%d&user_id=%@&locale=%@", COOPRATION_SAMPLE_URL, [indexPath row]+1, [AppManager instance].userId, [WXWSystemInfoManager instance].currentLanguageDesc];
        [self gotoUrl:url aTitle:NULL_PARAM_VALUE];
      }
    }
      break;
      
    case 2:
    {
      int row = [indexPath row];
      switch (row) {
        case 0:
        {
          [self goCallPhone];
        }
          break;
          
        case 1:
        {
          NSString *url;
          url = [NSString stringWithFormat:@"mailto://%@", _feedback.email];
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
          break;
          
        default:
          break;
      }
      
    }
      break;
    default:
      break;
  }
  
  [super deselectCell];
}

#pragma mark - TextView
- (void)textViewDidBeginEditing:(UITextView *)textArea{
  NSString *temp = LocaleStringForKey(NSFeedbackPromptTitle, nil);
	if ([textArea.text isEqualToString:temp]) {
		textArea.textColor = [UIColor blackColor];
		textArea.text = NULL_PARAM_VALUE;
	}
}

- (void)textViewDidEndEditing:(UITextView *)textArea{
	if ([textArea.text isEqualToString:NULL_PARAM_VALUE]) {
		textArea.textColor = [UIColor grayColor];
		textArea.text = LocaleStringForKey(NSFeedbackPromptTitle, nil);
	}
}

-(IBAction)dismissKeyBoard
{
  [_textView resignFirstResponder];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
  InputSize = [_textView.text length];
  return YES;
}

#pragma mark - Core data
- (void)setFetchCondition {
  self.entityName = @"Feedback";
  self.descriptors = [NSMutableArray array];
  NSSortDescriptor *dateDesc = [[[NSSortDescriptor alloc] initWithKey:@"tel" ascending:YES] autorelease];
  [self.descriptors addObject:dateDesc];
}

- (void)fetchItems {
  [NSFetchedResultsController deleteCacheWithName:nil];
  
  NSError *error = nil;
  BOOL res = [[super prepareFetchRC] performFetch:&error];
  if (!res) {
		NSAssert1(0, @"Unhandled error performing fetch: %@", [error localizedDescription]);
	}
  
  NSArray *feedbackDetail = [CommonUtils objectsInMOC:_MOC
                                           entityName:self.entityName
                                         sortDescKeys:nil
                                            predicate:nil];
  
  if ([feedbackDetail count]) {
    _feedback = (Feedback*)[feedbackDetail lastObject];
  }
  
  [self getLogicSize];
  [self initTableView];
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
  [UIUtils showActivityView:self.view
                       text:LocaleStringForKey(NSLoadingTitle, nil)];
  
  [super connectStarted:url contentType:contentType];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType
{
  [UIUtils closeActivityView];
  switch (contentType) {
    case FETCH_FEEDBACK_SUBMIT_TY:
      if( RESP_OK == [XMLParser handleCommonResult:result showFlag:YES] ){
        _textView.text = NULL_PARAM_VALUE;
        [_selCellArray removeAllObjects];
        [_tableView reloadData];
      }
      break;
      
    case FETCH_FEEDBACK_MSG_TY:
    {
      if ([XMLParser parserResponseXml:result
                                  type:contentType
                                   MOC:_MOC
                     connectorDelegate:self
                                   url:url]) {
        _autoLoaded = YES;
        [self fetchItems];
      } else {
        [UIUtils showNotificationOnTopWithMsg:@"Failed Msg"
                                      msgType:ERROR_TY
                           belowNavigationBar:YES];
      }
    }
      break;
      
    default:
      break;
  }
  
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType
{
  [UIUtils closeActivityView];
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType
{
  [UIUtils closeActivityView];
  
  [super connectFailed:error url:url contentType:contentType];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  // Find the next entry field
  [_textView becomeFirstResponder];
  
  return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
  _textViewFirstResponder = _textView.isFirstResponder;
  
  if (_textView.isFirstResponder) {
    [_textView resignFirstResponder];
  }
  
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  if (_textViewFirstResponder) {
    [_textView becomeFirstResponder];
  }
}

- (void)getCheckMsg
{
  checkMsg = NULL_PARAM_VALUE;
  int size = [_selCellArray count];
    
  for (int i=0; i<size; i++) {
    NSIndexPath *mIndexPath = (NSIndexPath *)_selCellArray[i];
    if (![checkMsg isEqualToString:NULL_PARAM_VALUE]) {
      checkMsg = [NSString stringWithFormat:@"%@,%d",checkMsg,[mIndexPath row]];
    } else {
      checkMsg = [NSString stringWithFormat:@"%d",[mIndexPath row]];
    }
  }
}

#pragma mark - submit
-(void)submitClick:(id)sender
{
  
  //submit
  NSString *temp = LocaleStringForKey(NSFeedbackPromptTitle, nil);
  if ([_textView.text isEqualToString:temp] || [_textView.text length] == 0) {
    
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSFeecbackEmptyWarningMsg, nil)
                                  msgType:WARNING_TY
                       belowNavigationBar:YES];

	} else {
    [self getCheckMsg];
    NSString *param = [NSString stringWithFormat:@"<items_selected>%@</items_selected><message>%@</message><type>2</type>",
                       checkMsg,
                       _textView.text];
    ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self interactionContentType:FETCH_FEEDBACK_SUBMIT_TY] autorelease];
    [connFacade fetchGets:[CommonUtils geneUrl:param itemType:FETCH_FEEDBACK_SUBMIT_TY]];
  }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
  if ( inType == UIWebViewNavigationTypeLinkClicked ) {
    NSString *url = [[inRequest URL] absoluteString];
    url = [url stringByReplacingOccurrencesOfString:@"file:///%22" withString:NULL_PARAM_VALUE];
    url = [url stringByReplacingOccurrencesOfString:@"/%22" withString:NULL_PARAM_VALUE];
    if ([url isEqualToString:@"http://www.jitmarketing.cn"]) {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
      return NO;
    }else {
      return NO;
    }
  }
  
  return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{}
- (void)webViewDidFinishLoad:(UIWebView *)webView{}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{}
@end