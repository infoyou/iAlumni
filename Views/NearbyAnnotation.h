//
//  NearbyAnnotation.h
//  ExpatCircle
//
//  Created by Adam on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ECMapAnnotation.h"
#import "GlobalConstants.h"

@class Store;

@interface NearbyAnnotation : ECMapAnnotation {
  
  NSInteger _sequenceNumber;
}

@property (nonatomic, retain) Store *store;

@property (nonatomic, assign) NSInteger sequenceNumber;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                   store:(Store *)store
          sequenceNumber:(NSInteger)sequenceNumber;

@end
