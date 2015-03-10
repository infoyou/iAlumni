//
//  AlumniLocationStatusView.m
//  iAlumni
//
//  Created by Adam on 12-11-17.
//
//

#import "AlumniLocationStatusView.h"
#import <QuartzCore/QuartzCore.h>
#import "ECEmbedMapView.h"
#import "ECInnerShadowMaskView.h"
#import "Alumni.h"
#import "ECMapAnnotation.h"
#import "WXWLabel.h"
#import "TextConstants.h"
#import "CommonUtils.h"


#define CORNER_RADIUS   5.0f

#define MAP_SIDE_LENGTH 70.0f

@implementation AlumniLocationStatusView

#pragma mark - lifecycle methods

- (void)initMapView:(id<ECClickableElementDelegate>)mapHolder alumni:(Alumni *)alumni {
  _mapView = [[[ECEmbedMapView alloc] initWithFrame:CGRectMake(self.frame.size.width - MARGIN * 2 - MAP_SIDE_LENGTH, (self.frame.size.height - MAP_SIDE_LENGTH)/2.0f, MAP_SIDE_LENGTH, MAP_SIDE_LENGTH)
                           clickableElementDelegate:mapHolder] autorelease];
  _mapView.scrollEnabled = NO;
  _mapView.zoomEnabled = NO;
  
  CLLocation *location = [[[CLLocation alloc] initWithLatitude:alumni.latitude.doubleValue
                                                     longitude:alumni.longitude.doubleValue] autorelease];
  _mapView.centerCoordinate = location.coordinate;
  _mapView.userInteractionEnabled = YES;
  MKCoordinateRegion region;
  region.center.latitude = alumni.latitude.doubleValue;
  region.center.longitude = alumni.longitude.doubleValue;
  MKCoordinateSpan span;
  span.latitudeDelta = INIT_EMBED_ZOOM_LEVEL;
  span.longitudeDelta = INIT_EMBED_ZOOM_LEVEL;
  region.span = span;
  _mapView.region = region;
  
  ECMapAnnotation *annotation = [[[ECMapAnnotation alloc] initWithCoordinate:location.coordinate] autorelease];
  [_mapView addAnnotation:annotation];
  
  [self addSubview:_mapView];
  
  _mapView.layer.masksToBounds = YES;
  //_mapView.layer.cornerRadius = MARGIN;
  
}

- (void)initProperties {
  
  self.layer.borderWidth = 0.5f;
  self.layer.borderColor = COLOR(199, 200, 204).CGColor;
  
  if (CURRENT_OS_VERSION < IOS7) {
    
    self.layer.cornerRadius = 4.0f;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(1, 2,
                                                                           self.frame.size.width - 2,
                                                                           self.frame.size.height - 2)];
    
    self.layer.shadowPath = shadowPath.CGPath;
    self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.layer.shadowOpacity = 0.9f;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.masksToBounds = NO;
  }
}

- (void)setStatus:(Alumni *)alumni {
  WXWLabel *addressLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                  textColor:DARK_TEXT_COLOR
                                                shadowColor:TEXT_SHADOW_COLOR] autorelease];
  addressLabel.numberOfLines = 2.0f;
  addressLabel.font = BOLD_FONT(14);
  addressLabel.text = alumni.shakePlace;
  
  CGFloat width = self.frame.size.width - MARGIN * 4 - MAP_SIDE_LENGTH - MARGIN * 2;
  CGSize size = [addressLabel.text sizeWithFont:addressLabel.font
                              constrainedToSize:CGSizeMake(width, MAP_SIDE_LENGTH/2.0f)
                                  lineBreakMode:NSLineBreakByWordWrapping];
  addressLabel.frame = CGRectMake(MARGIN * 3, MARGIN * 2, size.width, size.height);
  [self addSubview:addressLabel];
  
  WXWLabel *distanceLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                   textColor:BASE_INFO_COLOR
                                                 shadowColor:TEXT_SHADOW_COLOR] autorelease];
  distanceLabel.font = ITALIC_FONT(11);
  distanceLabel.text = [NSString stringWithFormat:@"%@%@", alumni.distance, LocaleStringForKey(NSKilometerTitle, nil)];
  size = [distanceLabel.text sizeWithFont:distanceLabel.font
                        constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                            lineBreakMode:NSLineBreakByWordWrapping];
  distanceLabel.frame = CGRectMake(MARGIN * 3, addressLabel.frame.origin.y + addressLabel.frame.size.height + MARGIN,
                                   size.width, size.height);
  [self addSubview:distanceLabel];
  
  if (alumni.shakeThing.length > 0) {
    WXWLabel *statusLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                   textColor:DARK_TEXT_COLOR
                                                 shadowColor:TEXT_SHADOW_COLOR] autorelease];
    statusLabel.font = BOLD_FONT(13);
    statusLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    statusLabel.text = alumni.shakeThing;
    size = [statusLabel.text sizeWithFont:statusLabel.font
                        constrainedToSize:CGSizeMake(width, MAP_SIDE_LENGTH - (addressLabel.frame.size.height + distanceLabel.frame.size.height + MARGIN))
                            lineBreakMode:statusLabel.lineBreakMode];
    statusLabel.frame = CGRectMake(MARGIN * 3, _mapView.frame.origin.y + _mapView.frame.size.height - size.height, size.width, size.height);
    [self addSubview:statusLabel];
  }
}

- (id)initWithFrame:(CGRect)frame
          mapHolder:(id<ECClickableElementDelegate>)mapHolder
             alumni:(Alumni *)alumni {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.backgroundColor = [UIColor whiteColor];
    
    _mapHolder = mapHolder;
    
    [self initProperties];
    
    [self initMapView:mapHolder alumni:alumni];
    
    /*
    ECInnerShadowMaskView *shadowMaskView = [[[ECInnerShadowMaskView alloc] initWithFrame:CGRectMake(self.frame.size.width - MARGIN * 2 - MAP_SIDE_LENGTH, (self.frame.size.height - MAP_SIDE_LENGTH)/2.0f, MAP_SIDE_LENGTH, MAP_SIDE_LENGTH) radius:MARGIN] autorelease];
    
    [self addSubview:shadowMaskView];
    */
    
    [self setStatus:alumni];
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

#pragma mark - touch event
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_mapHolder) {
    [_mapHolder openTraceMap];
  }
}


@end
