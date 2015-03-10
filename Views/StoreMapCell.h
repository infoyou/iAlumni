//
//  StoreMapCell.h
//  iAlumni
//
//  Created by Adam on 13-8-21.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class ECEmbedMapView;
@class WelfareCellBoardView;
@class ECMapAnnotation;
@class Store;

@interface StoreMapCell : UITableViewCell {
  @private
  
  ECEmbedMapView *_mapView;
  
  CLLocation *_location;
  
  ECMapAnnotation *_annotation;
  
  WelfareCellBoardView *_boardView;
}

- (void)drawCellWithStore:(Store *)store;

@end
