//
//  SortOption.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SortOption : NSManagedObject

@property (nonatomic, retain) NSNumber * optionId;
@property (nonatomic, retain) NSString * optionName;
@property (nonatomic, retain) NSString * optionValue;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSNumber * usageType;

@end
