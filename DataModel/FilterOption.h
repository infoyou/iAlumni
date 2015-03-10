//
//  FilterOption.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FilterOption : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * valueFloat;
@property (nonatomic, retain) NSString * valueString;

@end
