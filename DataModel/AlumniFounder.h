//
//  AlumniFounder.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Alumni.h"


@interface AlumniFounder : Alumni

@property (nonatomic, retain) NSNumber * brandId;
@property (nonatomic, retain) NSString * title;

@end
