//
//  NearbyFilterContainerView.h
//  iAlumni
//
//  Created by Adam on 12-8-2.
//
//

#import <UIKit/UIKit.h>

@class ECNodeFilter;

@interface NearbyFilterContainerView : UIView {
  @private
  
  NSManagedObjectContext *_MOC;
  
  ECNodeFilter *_distanceFilter;
  ECNodeFilter *_timeFilter;
  
  NSArray *_distanceFilterOptions;
  NSArray *_timeFilterOptions;
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
 needDistanceFilter:(BOOL)needDistanceFilter
     needTimeFilter:(BOOL)needTimeFilter;

@end
