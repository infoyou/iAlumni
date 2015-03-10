//
//  NameCardSearchToolView.m
//  iAlumni
//
//  Created by Adam on 12-11-24.
//
//

#import "NameCardSearchToolView.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "UIImageButton.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "UIUtils.h"

#define SEARCHBAR_HEIGHT        30.0f

@implementation NameCardSearchToolView

#pragma mark - user actions
- (void)showIndustries:(id)sender {
  if (_searchManager) {
    [_searchManager showIndustries];
  }
}

#pragma mark - search bar properties
- (BOOL)searchBarFirstResponse {
  return _searchBar.isFirstResponder;
}

- (void)searchBarResignFirstResponder {
  [_searchBar resignFirstResponder];
}

- (void)selectKeyworkdFromHistory:(NSString *)keyword {
  _searchBar.text = keyword;
}

#pragma mark - lifecycle methods

- (void)addShadow {
  UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
  
  self.layer.shadowPath = shadowPath.CGPath;
  self.layer.masksToBounds = NO;
  self.layer.shadowOffset = CGSizeMake(0, 0);
  self.layer.shadowOpacity = 0.9f;
  self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
  self.layer.shadowRadius = 2.0f;
}

- (void)initSearchBar:(id<UISearchBarDelegate>)searchBarDelegate {
  _searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0,
                                                              self.frame.size.width,
                                                              SEARCHBAR_HEIGHT)] autorelease];
  _searchBar.delegate = searchBarDelegate;
  _searchBar.showsCancelButton = NO;
  _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
  [_searchBar sizeToFit];
  [_searchBar becomeFirstResponder];
  
  // remove background color
  [UIUtils clearSearchBarBackgroundColor:_searchBar];
  
  [self addSubview:_searchBar];

}

- (id)initWithFrame:(CGRect)frame
  searchBarDelegate:(id<UISearchBarDelegate>)searchBarDelegate
      searchManager:(id<ECClickableElementDelegate>)searchManager {
  self = [super initWithFrame:frame
                     topColor:COLOR(239, 239, 239)
                  bottomColor:COLOR(190, 190, 190)];
  if (self) {
    
    _searchManager = searchManager;
    
    [self initSearchBar:searchBarDelegate];
    
    _industryTitleLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                textColor:BASE_INFO_COLOR
                                              shadowColor:TEXT_SHADOW_COLOR] autorelease];
    _industryTitleLabel.font = BOLD_FONT(13);
    _industryTitleLabel.backgroundColor = TRANSPARENT_COLOR;
    _industryTitleLabel.text = LocaleStringForKey(NSIndustryTitle, nil);
    CGSize size = [_industryTitleLabel.text sizeWithFont:_industryTitleLabel.font
                                       constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    _industryTitleLabel.frame = CGRectMake(MARGIN * 2,
                                           _searchBar.frame.origin.y + _searchBar.frame.size.height + MARGIN + 2.0f,
                                           size.width, size.height);
    [self addSubview:_industryTitleLabel];
    
    _industryButton = [[[UIImageButton alloc] initImageButtonWithFrame:CGRectMake(_industryTitleLabel.frame.origin.x + _industryTitleLabel.frame.size.width + MARGIN * 2,
                                                                                  _searchBar.frame.origin.y + _searchBar.frame.size.height,
                                                                                  self.frame.size.width - MARGIN * 4 - _industryTitleLabel.frame.size.width - MARGIN * 2, 30)
                                                                target:self
                                                                action:@selector(showIndustries:)
                                                                 title:LocaleStringForKey(NSEntireTitle, nil)
                                                                 image:[UIImage imageNamed:@"rightArrow.png"]
                                                           backImgName:@"club_button.png"
                                                        selBackImgName:@"club_button_selected.png"
                                                             titleFont:BOLD_FONT(15)
                                                            titleColor:DARK_TEXT_COLOR
                                                      titleShadowColor:TEXT_SHADOW_COLOR
                                                           roundedType:HAS_ROUNDED
                                                       imageEdgeInsert:UIEdgeInsetsMake(0, 235, 0, 0)
                                                       titleEdgeInsert:UIEdgeInsetsMake(0, -30, 0, 20)] autorelease];
    [self addSubview:_industryButton];
    
    [self addShadow];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - update views
- (void)updateIndustryTitle:(NSString *)industry {
  [_industryButton setTitle:industry forState:UIControlStateNormal];
}


@end
