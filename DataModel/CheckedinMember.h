//
//  CheckedinMember.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Member.h"

@class CheckedinItemId;

@interface CheckedinMember : Member

@property (nonatomic, retain) NSString * elapsedTime;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * totalCount;
@property (nonatomic, retain) NSSet *checkedinItemIds;
@end

@interface CheckedinMember (CoreDataGeneratedAccessors)

- (void)addCheckedinItemIdsObject:(CheckedinItemId *)value;
- (void)removeCheckedinItemIdsObject:(CheckedinItemId *)value;
- (void)addCheckedinItemIds:(NSSet *)values;
- (void)removeCheckedinItemIds:(NSSet *)values;
@end
