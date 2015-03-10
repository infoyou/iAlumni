//
//  StoreMapCell.m
//  iAlumni
//
//  Created by Adam on 13-8-21.
//
//

#import "StoreMapCell.h"
#import "ECEmbedMapView.h"
#import "Store.h"
#import "WelfareCellBoardView.h"
#import "ECMapAnnotation.h"

#define MAP_CELL_HEIGHT       140.0f

#define ICON_SIDE_LEN         20.0f

@implementation StoreMapCell

#pragma mark - life cycle methods

- (void )initBoardView {
  if (nil == _boardView) {
    _boardView = [[[WelfareCellBoardView alloc] initWithFrame:CGRectMake(WELFARE_CELL_MARGIN,
                                                                         WELFARE_CELL_MARGIN,
                                                                         self.frame.size.width - WELFARE_CELL_MARGIN * 2,
                                                                         0)] autorelease];
    _boardView.backgroundColor = [UIColor whiteColor];
    
    [self.contentView addSubview:_boardView];
    
  }
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
    
  }
  return self;
}

- (void)dealloc {
  
  [super dealloc];
}

- (void)drawCellWithStore:(Store *)store {
  
  if (_mapView == nil && store.latitude.doubleValue > 0 & store.longitude.doubleValue > 0) {
  
    [_boardView arrangeHeight:MAP_CELL_HEIGHT];
    
    _mapView = [[[ECEmbedMapView alloc] initWithFrame:CGRectMake(0, 0, _boardView.frame.size.width, _boardView.frame.size.height)
                             clickableElementDelegate:nil] autorelease];
    _mapView.scrollEnabled = NO;
    _mapView.zoomEnabled = NO;
    
    _location = [[[CLLocation alloc] initWithLatitude:store.latitude.doubleValue
                                            longitude:store.longitude.doubleValue] autorelease];
    _mapView.centerCoordinate = _location.coordinate;
    _mapView.userInteractionEnabled = NO;
    MKCoordinateRegion region;
    region.center.latitude = store.latitude.doubleValue;
    region.center.longitude = store.longitude.doubleValue;
    MKCoordinateSpan span;
    span.latitudeDelta = INIT_EMBED_ZOOM_LEVEL;
    span.longitudeDelta = INIT_EMBED_ZOOM_LEVEL;
    region.span = span;
    _mapView.region = region;
    
    _annotation = [[[ECMapAnnotation alloc] initWithCoordinate:_location.coordinate] autorelease];
    [_mapView addAnnotation:_annotation];
    
    [_boardView addSubview:_mapView];
    
    UIImageView *icon = [[[UIImageView alloc] initWithFrame:CGRectMake(_mapView.frame.size.width - ICON_SIDE_LEN - 3.0f, 3.0f, ICON_SIDE_LEN, ICON_SIDE_LEN)] autorelease];
    icon.image = [UIImage imageNamed:@"storeMagnifier.png"];
    [_boardView addSubview:icon];
  }
}

@end
