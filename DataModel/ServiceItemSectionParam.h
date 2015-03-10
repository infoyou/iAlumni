//
//  ServiceItemSectionParam.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ServiceItemSection;

@interface ServiceItemSectionParam : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sortKey;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) ServiceItemSection *section;

@end
