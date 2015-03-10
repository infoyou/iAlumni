//
//  ECMapAnnotation.m
//  iAlumni
//
//  Created by Adam on 11-12-1.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ECMapAnnotation.h"

@implementation ECMapAnnotation

@synthesize coordinate = _coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate {
  self = [super init];
  if (self) {
    _coordinate = coordinate;
  }
  return self;
}

- (void)dealloc {
  
  
  [super dealloc];
}
         

@end
