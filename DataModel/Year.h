//
//  Year.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Year : NSManagedObject

@property (nonatomic, retain) NSString * count;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSNumber * yearId;

@end
