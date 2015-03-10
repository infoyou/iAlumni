//
//  WechatIntroViewController.m
//  iAlumni
//
//  Created by Adam on 13-6-5.
//
//

#import "WechatIntroViewController.h"
#import "UIUtils.h"

#define BODY @"<html><body marginwidth=\"10\" marginheight=\"10\" leftmargin=\"10\" topmargin=\"10\" style=\"font-family:ArialMT;font-size:15px;word-wrap:break-word;\" ><p style=\"margin=10\"><b>%@</b></p><p>%@</br>%@</p><p>%@</br>%@</br><center><img src=\"qr.png\"></center></p></body></html>"

#define IMG_TAG @"IMG"
#define CENTER_TAG  @"CENTER"

@interface WechatIntroViewController ()
@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, copy) NSString *urlToSave;
@end

@implementation WechatIntroViewController

#pragma mark - lifecycle methods
- (id)init
{
  self = [super initWithMOC:nil
                     holder:nil
           backToHomeAction:nil
                 needGoHome:NO];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)dealloc {
  
  self.tapGesture.delegate = nil;
  self.tapGesture = nil;
  
  self.urlToSave = nil;
  
  [super dealloc];
}

- (void)addLongPressGesture {
  self.tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleTap:)] autorelease];
  self.tapGesture.delegate = self;
  [_contentWebView addGestureRecognizer:self.tapGesture];
}

- (void)initWebView {
  _contentWebView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT)] autorelease];
  _contentWebView.userInteractionEnabled = YES;
  _contentWebView.backgroundColor = CELL_COLOR;
  _contentWebView.layer.masksToBounds = NO;
  [self.view addSubview:_contentWebView];
  
  [self addLongPressGesture];
  
  NSString *path = [[NSBundle mainBundle] bundlePath];
  NSURL *baseUrl = [NSURL fileURLWithPath:path];
  
  NSString *content = STR_FORMAT(BODY, LocaleStringForKey(NSFollowWechatPublicNoNoteMsg, nil), LocaleStringForKey(NSOption1Title, nil), LocaleStringForKey(NSFollowMethod1Msg, nil), LocaleStringForKey(NSOption2Title, nil), LocaleStringForKey(NSFollowMethod2Msg, nil));
  
  [_contentWebView loadHTMLString:content baseURL:baseUrl];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	
  [self initWebView];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - save image

- (void)findImgTag:(UITapGestureRecognizer *)gesture {
  
  int x = [[_contentWebView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
  int y = [[_contentWebView stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] intValue];
  
  int displayWidth = [[_contentWebView stringByEvaluatingJavaScriptFromString:@"window.outerWidth"] intValue];
  CGFloat scale = _contentWebView.frame.size.width / displayWidth;
  
  CGPoint point = [gesture locationInView:_contentWebView];
  point.x *= scale;
  point.y *= scale;
  point.x += x;
  point.y += y;
  
  NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", point.x, point.y];
  NSString *tagName = [_contentWebView stringByEvaluatingJavaScriptFromString:js];
  
  if ([IMG_TAG isEqualToString:tagName]) {
    
    NSString *imgUrl = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", point.x, point.y];
    self.urlToSave = [_contentWebView stringByEvaluatingJavaScriptFromString:imgUrl];
    
    UIActionSheet *sh = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSSaveQRPicMsg, nil)
                                                     delegate:self
                                            cancelButtonTitle:LocaleStringForKey(NSCancelTitle, nil)
                                       destructiveButtonTitle:LocaleStringForKey(NSSaveTitle, nil)
                                            otherButtonTitles:nil, nil] autorelease];
    [sh showInView:self.view];
  }
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
  if (gesture.state == UIGestureRecognizerStateEnded) {
  
    [self findImgTag:gesture];
    
  }
}

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

  return YES;
}

#pragma mark - UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  if (buttonIndex == 0) {
    NSURL *url = [NSURL URLWithString:self.urlToSave];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSSaveImageSuccessMsg, nil)
                                  msgType:SUCCESS_TY
                       belowNavigationBar:YES];
  }
}

@end
