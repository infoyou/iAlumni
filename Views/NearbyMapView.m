//
//  NearbyMapView.m
//  ExpatCircle
//
//  Created by Adam on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NearbyMapView.h"
#import "WXWLabel.h"
#import "TextConstants.h"
#import "ItemCalloutView.h"
#import "CommonUtils.h"

#define TITLE_VIEW_HEIGHT 40.0f
#define LABEL_HEIGHT      20.0f
#define BUTTON_SIDE_LENGTH  32.0f

#define TOOL_HEIGHT  30.0f
#define TOOL_WIDTH   70.0f

@implementation NearbyMapView


#pragma mark - user actions
- (void)showPrevious20Items:(id)sender {
  if (_filterListDelegate) {
    [_filterListDelegate showPreviousItems:sender];
  }
}

- (void)showNext20Items:(id)sender {
  if (_filterListDelegate) {
    [_filterListDelegate showNextItems:sender];
  }
}

- (void)showFilterSortView:(id)sender {
  if (_filterListDelegate) {
    [_filterListDelegate showNearbyFilterSortView];
  }
}

#pragma mark - lifecycle methods

- (id)initWithFrame:(CGRect)frame 
 filterListDelegate:(id<ECFilterListDelegate>)filterListDelegate
             target:(id)target
  hideCalloutAction:(SEL)hideCalloutAction
     needFilterSort:(BOOL)needFilterSort {
  self = [super initWithFrame:frame];
  
  if (self) {
    
    _filterListDelegate = filterListDelegate;
    
    _target = target;
    _hideCalloutAction = hideCalloutAction;
    
    _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, TITLE_VIEW_HEIGHT)];
    _titleView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
    [self addSubview:_titleView];
    
    _spLabel = [[WXWLabel alloc] initWithFrame:CGRectZero textColor:[UIColor whiteColor] shadowColor:TRANSPARENT_COLOR];
    _spLabel.center = _titleView.center;
    _spLabel.font = BOLD_FONT(14);
    _spLabel.textAlignment = UITextAlignmentCenter;
    [_titleView addSubview:_spLabel];
    
    
    _previous20Button = [UIButton buttonWithType:UIButtonTypeCustom];
    _previous20Button.frame = CGRectMake(MARGIN * 2, 4, BUTTON_SIDE_LENGTH, BUTTON_SIDE_LENGTH);
    _previous20Button.showsTouchWhenHighlighted = YES;
    [_previous20Button setImage:[UIImage imageNamed:@"previousItems.png"] 
                       forState:UIControlStateNormal];
    [_previous20Button addTarget:self 
                          action:@selector(showPrevious20Items:) 
                forControlEvents:UIControlEventTouchUpInside];
    [_titleView addSubview:_previous20Button];

    _next20Button = [UIButton buttonWithType:UIButtonTypeCustom];
        _next20Button.showsTouchWhenHighlighted = YES;
    [_next20Button setImage:[UIImage imageNamed:@"nextItems.png"] 
                       forState:UIControlStateNormal];
    [_next20Button addTarget:self 
                          action:@selector(showNext20Items:) 
                forControlEvents:UIControlEventTouchUpInside];
    [_titleView addSubview:_next20Button];
    
    
    if (needFilterSort) {
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
      
      UIToolbar *searchToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(self.frame.size.width - MARGIN - TOOL_WIDTH, MARGIN, TOOL_WIDTH, TOOL_HEIGHT)] autorelease];
      searchToolbar.barStyle = -1;
      searchToolbar.tintColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
      [searchToolbar setItems:@[space1, showButton, space2]];
      [_titleView addSubview:searchToolbar];
      
      _next20Button.frame = CGRectMake(searchToolbar.frame.origin.x - MARGIN * 3 - BUTTON_SIDE_LENGTH, 4, BUTTON_SIDE_LENGTH, BUTTON_SIDE_LENGTH);
    } else {
      
      _next20Button.frame = CGRectMake(self.frame.size.width - MARGIN * 2 - BUTTON_SIDE_LENGTH, 4, BUTTON_SIDE_LENGTH, BUTTON_SIDE_LENGTH);
    }

  }
  
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_spLabel);
  RELEASE_OBJ(_titleView);
  
  [super dealloc];
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  for (UIView * view in self.subviews) {
    
    if ([view isKindOfClass:[ItemCalloutView class]]) {
      CGPoint convertedPoint = [self convertPoint:point toView:view];
      if (![view pointInside:convertedPoint withEvent:event]) {
        // hide annotation view in map view when user click the area out of the callout view scope
        if (_target && _hideCalloutAction) {
          [_target performSelector:_hideCalloutAction];
          break;
        }
      }
    }
    
  }
  return YES;
}

#pragma mark - adjust zoom level to cover all annotations
 
- (void)zoomToFitMapAnnotations {

  if ([self.annotations count] == 0) return;
  
  CLLocationCoordinate2D topLeftCoord;
  topLeftCoord.latitude = -90;
  topLeftCoord.longitude = 180;
  
  CLLocationCoordinate2D bottomRightCoord;
  bottomRightCoord.latitude = 90;
  bottomRightCoord.longitude = -180;
  
  for(id<MKAnnotation> annotation in self.annotations) {
    topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
    topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
    bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
    bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
  }
  
  MKCoordinateRegion region;
  region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
  region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
  region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
  
  // Add a little extra space on the sides
  region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
  
  region = [self regionThatFits:region];
  [self setRegion:region animated:YES];
}

#pragma mark - set service provider title
- (void)setSPTitleWithStartNumber:(NSInteger)startNumber
                        endNumber:(NSInteger)endNumber 
                        itemTotal:(NSInteger)itemTotal {
  
  _spLabel.text = [NSString stringWithFormat:LocaleStringForKey(NSVenuesTitle, nil),
                   startNumber, endNumber];
  CGSize size = [_spLabel.text sizeWithFont:_spLabel.font
                          constrainedToSize:CGSizeMake(320, CGFLOAT_MAX)
                              lineBreakMode:NSLineBreakByWordWrapping];
  _spLabel.frame = CGRectMake(_spLabel.frame.origin.x, _spLabel.frame.origin.y, size.width, size.height);
    _spLabel.center = CGPointMake((_next20Button.frame.origin.x - (_previous20Button.frame.size.width + _previous20Button.frame.origin.x))/2 + _previous20Button.frame.origin.x + _previous20Button.frame.size.width, _titleView.center.y);
  
  if (startNumber == 0 && endNumber == 0) {
    _previous20Button.enabled = NO;
    _next20Button.enabled = NO;
  } else if (startNumber == 1 && endNumber == itemTotal) {
    _previous20Button.enabled = NO;
    _next20Button.enabled = NO;
  } else if (startNumber == 1) {
    
    //indexPositionType = BEGIN_SP_LIST_TY;    
    _previous20Button.enabled = NO;
    _next20Button.enabled = YES;
    
  } else if (endNumber == itemTotal) {
    
    //indexPositionType = END_SP_LIST_TY;
    _previous20Button.enabled = YES;
    _next20Button.enabled = NO;
    
  } else {
    
    //indexPositionType = MIDDLE_SP_LIST_TY;
    _previous20Button.enabled = YES;
    _next20Button.enabled = YES;
    
  }
}

@end
