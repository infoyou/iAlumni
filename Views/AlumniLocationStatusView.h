//
//  AlumniLocationStatusView.h
//  iAlumni
//
//  Created by Adam on 12-11-17.
//
//

#import <UIKit/UIKit.h>
#import "ECClickableElementDelegate.h"

@class ECEmbedMapView;
@class Alumni;

@interface AlumniLocationStatusView : UIView {
  @private
  
  ECEmbedMapView *_mapView;
  
  id<ECClickableElementDelegate> _mapHolder;
}

- (id)initWithFrame:(CGRect)frame
          mapHolder:(id<ECClickableElementDelegate>)mapHolder
             alumni:(Alumni *)alumni;

@end
