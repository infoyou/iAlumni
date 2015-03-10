//
//  BrandInfoCell.m
//  iAlumni
//
//  Created by Adam on 13-8-21.
//
//

#import "BrandInfoCell.h"
#import "WelfareCellBoardView.h"
#import "WXWLabel.h"
#import "Brand.h"
#import "UIUtils.h"
#import "CommonUtils.h"

#define INNER_MARGIN  8.0f

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

#define CONTENT_HEADER  @"<html><body marginwidth=\"0\" marginheight=\"0\" leftmargin=\"0\" topmargin=\"0\" bgcolor=\"#FFFFFF\" style=\"font-family:HelveticaNeue;font-size:%f;word-wrap:break-word;\">"
#else

#define CONTENT_HEADER  @"<html><body marginwidth=\"0\" marginheight=\"0\" leftmargin=\"0\" topmargin=\"0\" bgcolor=\"#FFFFFF\" style=\"font-family:Arial-BoldMT;font-size:%f;word-wrap:break-word;\">"

#endif

#define TEXT_CONTENT_SIZE       15.0f

@implementation BrandInfoCell

#pragma mark - life cycle methods
- (WelfareCellBoardView *)initBoardView {
  if (nil == _boardView) {
    if (CURRENT_OS_VERSION >= IOS7) {
      _boardView = [[WelfareCellBoardView alloc] initWithFrame:CGRectMake(WELFARE_CELL_MARGIN,
                                                                          0,
                                                                          self.frame.size.width - WELFARE_CELL_MARGIN * 2,
                                                                          0)];
    } else {
      _boardView = [[WelfareCellBoardView alloc] initWithFrame:CGRectMake(0,//WELFARE_CELL_MARGIN,
                                                                          0,//WELFARE_CELL_MARGIN,
                                                                          302,// - WELFARE_CELL_MARGIN * 2,
                                                                          0)];
    }
    _boardView.backgroundColor = [UIColor whiteColor];
    
    [self.contentView addSubview:_boardView];
    
    _boardView.alpha = 0.0f;
    
    _textLimitedWidth = _boardView.frame.size.width - INNER_MARGIN * 2;
  }
  
  return _boardView;
}

- (void)disableWebViewScroll:(UIView *)scrollView {
  if ([scrollView isKindOfClass:[UIScrollView class]]) {
    ((UIScrollView *)scrollView).scrollEnabled = NO;
    ((UIScrollView *)scrollView).alwaysBounceVertical = NO;
    ((UIScrollView *)scrollView).alwaysBounceHorizontal = NO;
    ((UIScrollView *)scrollView).bouncesZoom = NO;
    ((UIScrollView *)scrollView).backgroundColor = [UIColor whiteColor];
  }
}

- (void)initWebView {
  _contentWebView = [[[UIWebView alloc] init] autorelease];
  _contentWebView.delegate = self;
  _contentWebView.userInteractionEnabled = YES;
  _contentWebView.backgroundColor = [UIColor whiteColor];
  _contentWebView.layer.masksToBounds = NO;
  _contentWebView.opaque = YES;
  
  // disable web view scroll
  [self disableWebViewScroll:[[_contentWebView subviews] lastObject]];
  
  [_boardView addSubview:_contentWebView];
  
  _contentWebView.hidden = NO;
  _contentWebView.frame = CGRectMake(INNER_MARGIN,
                                     0,
                                     _boardView.frame.size.width - INNER_MARGIN * 2, 90);
  
  
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    self.backgroundColor = TRANSPARENT_COLOR;
    self.contentView.backgroundColor = TRANSPARENT_COLOR;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self initBoardView];
    
    [self initWebView];
    
    _titleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                         textColor:NAVIGATION_BAR_COLOR
                                       shadowColor:TRANSPARENT_COLOR
                                              font:BOLD_FONT(25)] autorelease];
    _titleLabel.text = LocaleStringForKey(NSIntroTitle, nil);
    CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font];
    _titleLabel.frame = CGRectMake(INNER_MARGIN, INNER_MARGIN, size.width, size.height);
    [_boardView addSubview:_titleLabel];
    
    _nameLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                        textColor:DARK_TEXT_COLOR
                                      shadowColor:TRANSPARENT_COLOR
                                             font:BOLD_FONT(20)] autorelease];
    _nameLabel.numberOfLines = 0;
    [_boardView addSubview:_nameLabel];
    
    _callLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                        textColor:NAVIGATION_BAR_COLOR
                                      shadowColor:TRANSPARENT_COLOR
                                             font:BOLD_FONT(13)] autorelease];
    _callLabel.text = LocaleStringForKey(NSConsultTitle, nil);
    size = [_callLabel.text sizeWithFont:_callLabel.font];
    _callLabel.frame = CGRectMake(0, 0, size.width, size.height);
    [_boardView addSubview:_callLabel];
    
    _telLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                       textColor:[UIColor whiteColor]
                                     shadowColor:TRANSPARENT_COLOR
                                            font:BOLD_FONT(13)] autorelease];
    _telLabel.backgroundColor = NAVIGATION_BAR_COLOR;
    _telLabel.textAlignment = NSTextAlignmentCenter;
    [_boardView addSubview:_telLabel];
  }
  return self;
}

- (void)dealloc {
  
  _contentWebView.delegate = nil;
  
  RELEASE_OBJ(_boardView);
  
  [super dealloc];
}

- (void)drawCellWithBrand:(Brand *)brand height:(CGFloat)height {
  
  _brand = brand;
  
  _nameLabel.text = brand.name;
  
  CGSize size = [_nameLabel.text sizeWithFont:_nameLabel.font
                            constrainedToSize:CGSizeMake(_textLimitedWidth, CGFLOAT_MAX)];
  _nameLabel.frame = CGRectMake(INNER_MARGIN, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + INNER_MARGIN, size.width, size.height);
  
  if (brand.bio.length > 0 && !_textContentLoaded) {
    NSString *parseredContent = [CommonUtils parsedTextForHyperLink:brand.bio];
    NSString *htmlStr = [NSString stringWithFormat:@"%@%@<br/></body></html>", [NSString stringWithFormat:CONTENT_HEADER, TEXT_CONTENT_SIZE], parseredContent];
    
    [_contentWebView loadHTMLString:htmlStr baseURL:nil];
  }
}

- (void)arrangeViews {
  
  _contentWebView.frame = CGRectMake(_contentWebView.frame.origin.x,
                                     _nameLabel.frame.origin.y + _nameLabel.frame.size.height + INNER_MARGIN,
                                     _contentWebView.frame.size.width,
                                     _textContentHeight);
  
  CGFloat y = _contentWebView.frame.origin.y + _contentWebView.frame.size.height + INNER_MARGIN * 2;
  _callLabel.frame = CGRectMake(INNER_MARGIN, y + INNER_MARGIN, _callLabel.frame.size.width, _callLabel.frame.size.height);
  
  
  if (_brand.tel.length > 0) {
    _telLabel.text = _brand.tel;
    CGSize size = [_telLabel.text sizeWithFont:_telLabel.font];
    _telLabel.frame = CGRectMake(_callLabel.frame.origin.x + _callLabel.frame.size.width + MARGIN, _callLabel.frame.origin.y, size.width + MARGIN * 2, size.height);
  } else {
    _telLabel.frame = CGRectZero;
  }
  
  CGFloat height = _telLabel.frame.origin.y + _telLabel.frame.size.height + INNER_MARGIN;
  
  [_boardView arrangeWithoutLeftRedPadHeight:height
                                lineOrdinate:y];
  
  _boardView.alpha = 1.0f;
}


#pragma mark - adjust height
- (void)adjustWebViewHeight:(UIWebView *)webView {
  
  if (!_textContentLoaded) {
    
    _textContentLoaded = YES;
    
    NSString *height = [webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"];
    
    CGFloat offsetHeight = height.floatValue - _contentWebView.frame.size.height;
    
    CGRect newFrame = _contentWebView.frame;
    if (offsetHeight > 0) {
      newFrame = CGRectMake(newFrame.origin.x, newFrame.origin.y, newFrame.size.width, newFrame.size.height + offsetHeight + MARGIN * 4);
    }
    
    _textContentHeight = newFrame.size.height;
    
    NSMutableDictionary *heightDic = [NSMutableDictionary dictionary];
    heightDic[TEXT_CONTENT_HEIGHT_KEY] = @(newFrame.size.height);
    [[NSNotificationCenter defaultCenter] postNotificationName:TEXT_CONTENT_LOADED_NOTIFY
                                                        object:self
                                                      userInfo:heightDic];
    
    [self arrangeViews];
  }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [self adjustWebViewHeight:webView];
}

@end
