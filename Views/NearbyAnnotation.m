//
//  NearbyAnnotation.m
//  ExpatCircle
//
//  Created by Adam on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "NearbyAnnotation.h"
#import "Store.h"  


@implementation NearbyAnnotation

@synthesize sequenceNumber = _sequenceNumber;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                   store:(Store *)store
          sequenceNumber:(NSInteger)sequenceNumber {
  self = [super initWithCoordinate:coordinate];
  if (self) {
    self.store = store;
    self.sequenceNumber = sequenceNumber;
  }
  return self;
}

- (void)dealloc {
  
  self.store = nil;
  
  [super dealloc];
}

- (NSString *)title {
  return self.store.storeName;
}

- (NSString *)subtitle {
  return NULL_PARAM_VALUE;
}

@end
