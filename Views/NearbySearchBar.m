//
//  NearbySearchBar.m
//  ExpatCircle
//
//  Created by Adam on 11-12-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NearbySearchBar.h"
#import "TextConstants.h"
#import "WXWLabel.h"
#import "UIUtils.h"
#import "CommonUtils.h"
#import "ECGradientButton.h"
#import "ECSearchBar.h"

#define LABEL_HEIGHT          20.0f
#define TOOL_HEIGHT        40.0f
#define TOOL_WIDTH         70.0f
#define TIPS_BTN_SIDE_LENGTH  24.0f
#define SEARCH_BUTTON_WIDTH   40.0f

@implementation NearbySearchBar

@synthesize searchResultLabel = _searchResultLabel;

#pragma mark - user actions
- (void)showFilterSortView:(id)sender {
  if (_filterListDelegate) {
    [_filterListDelegate showNearbyFilterSortView];
  }
}

- (void)searchItem:(id)sender {
  if (_filterListDelegate) {
    [_filterListDelegate activeSearchController];
  }
}

#pragma mark - lifecycle methods

- (void)addSearchButton {

  UIBarButtonItem *searchButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch 
                                                                                 target:self
                                                                                 action:@selector(searchItem:)] autorelease];

  UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(MARGIN * 2, 
                                                                    (self.frame.size.height - TOOL_HEIGHT)/2.0f, 
                                                                    SEARCH_BUTTON_WIDTH, 
                                                                    TOOL_HEIGHT)] autorelease];
  toolbar.barStyle = -1;
  toolbar.tintColor = NAVIGATION_BAR_COLOR;
  [toolbar setItems:@[searchButton]];
  [self addSubview:toolbar];
}

- (void)addFilterSortButton {
    
  self.searchResultLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2, self.frame.size.width - MARGIN * 2 - TOOL_WIDTH - MARGIN - MARGIN * 2, LABEL_HEIGHT) textColor:[UIColor whiteColor] shadowColor:[UIColor blackColor]] autorelease];
  self.searchResultLabel.font = BOLD_FONT(13);
  self.searchResultLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  [self addSubview:self.searchResultLabel];
  
  UIBarButtonItem *space1 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil] autorelease];
  UIBarButtonItem *showButton = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSFilterSortTitle, nil)
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(showFilterSortView:)] autorelease];
  
  UIBarButtonItem *space2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil] autorelease];
  
  _searchToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(self.frame.size.width - MARGIN * 2 - TOOL_WIDTH,
                                                               (self.frame.size.height - TOOL_HEIGHT)/2.0f,
                                                               TOOL_WIDTH,
                                                               TOOL_HEIGHT)];
  _searchToolbar.barStyle = -1;
  _searchToolbar.tintColor = NAVIGATION_BAR_COLOR;
  [_searchToolbar setItems:@[space1, showButton, space2]];
  [self addSubview:_searchToolbar];

  
   /******** comments for no keyword search temporarily 
   UIBarButtonItem *showButton = [[[UIBarButtonItem alloc] initWithTitle:LocaleStringForKey(NSFilterSortTitle, nil)
   style:UIBarButtonItemStyleBordered
   target:self
   action:@selector(showFilterSortView:)] autorelease];
  _searchToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(MARGIN * 2 + SEARCH_BUTTON_WIDTH +
                                                               MARGIN * 3,
                                                               (self.frame.size.height - TOOL_HEIGHT)/2.0f,
                                                               TOOL_WIDTH, TOOL_HEIGHT)];
  _searchToolbar.barStyle = -1;
  _searchToolbar.tintColor = NAVIGATION_BAR_COLOR;
  [_searchToolbar setItems:[NSArray arrayWithObjects:showButton, nil]];
  [self addSubview:_searchToolbar];
  
  CGFloat x = _searchToolbar.frame.origin.x + _searchToolbar.frame.size.width + MARGIN * 2;
  self.searchResultLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(x, 
                                                                      MARGIN * 2 + 2.0f, 
                                                                      self.frame.size.width - x - MARGIN * 2, 
                                                                      LABEL_HEIGHT)
                                                 textColor:[UIColor whiteColor]
                                               shadowColor:TRANSPARENT_COLOR] autorelease];
  self.searchResultLabel.font = BOLD_FONT(13);
  self.searchResultLabel.lineBreakMode = NSLineBreakByTruncatingTail;
  
  self.searchResultLabel.text = [NSString stringWithFormat:@"%@, %@", 
                                 LocaleStringForKey(NSWithin10kmTitle, nil),
                                 LocaleStringForKey(NSSortByDistanceTitle, nil)];
  [self addSubview:self.searchResultLabel];
   */
}

- (void)arrangeViews {
  
  //[self addSearchButton];
  
  [self addFilterSortButton];
}

- (id)initWithFrame:(CGRect)frame 
           topColor:(UIColor *)topColor 
        bottomColor:(UIColor *)bottomColor 
 filterListDelegate:(id<ECFilterListDelegate>)filterListDelegate {
  self = [super initWithFrame:frame topColor:topColor bottomColor:bottomColor];
  if (self) {
    
    _filterListDelegate = filterListDelegate;
      
    [self arrangeViews];
  
  }
  return self;
}

- (void)dealloc {
  
  self.searchResultLabel = nil;
    
  RELEASE_OBJ(_searchToolbar);
    
  [super dealloc];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();

  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0, self.bounds.size.height - 1)
                endPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height - 1)
                   color:LIGHT_GRAY_BTN_BORDER_COLOR.CGColor
            shadowOffset:CGSizeMake(0.0f, 0.0f)
             shadowColor:TRANSPARENT_COLOR];
}

/******** comments for no keyword search temporarily
- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  [UIUtils draw1PxStroke:context 
              startPoint:CGPointMake(0, 0)
                endPoint:CGPointMake(self.bounds.size.width, 0)
                   color:COLOR(218, 148, 148).CGColor 
            shadowOffset:CGSizeMake(0.0f, 0.0f)
             shadowColor:TRANSPARENT_COLOR];
    
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(0, self.bounds.size.height - 1) 
                endPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height - 1)
                   color:COLOR(58, 0, 0).CGColor
            shadowOffset:CGSizeMake(0.0f, 0.0f) 
             shadowColor:TRANSPARENT_COLOR];
  
  CGFloat x = MARGIN * 2 + SEARCH_BUTTON_WIDTH;
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(x, 1.0f)
                endPoint:CGPointMake(x, self.frame.size.height - 2.0f)
                   color:[UIColor whiteColor].CGColor
            shadowOffset:CGSizeMake(0.0f, 0.0f)
             shadowColor:TRANSPARENT_COLOR];
}
 */

- (void)needHideToolbar:(BOOL)hide {
  
  [UIView animateWithDuration:0.2f
                   animations:^{
                     _searchToolbar.hidden = hide;
                     _searchToolbar.userInteractionEnabled = !hide;
                   }];
}

@end
