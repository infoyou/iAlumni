//
//  ServiceProvider.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhoneNumber;

@interface ServiceProvider : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * cnAddressPart1;
@property (nonatomic, retain) NSString * cnAddressPart2;
@property (nonatomic, retain) NSString * cnAddressPart3;
@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * grade;
@property (nonatomic, retain) NSNumber * hasLink;
@property (nonatomic, retain) NSNumber * hasTransit;
@property (nonatomic, retain) NSNumber * imageAttached;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * latlagAttached;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSNumber * liked;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * photoCount;
@property (nonatomic, retain) NSNumber * spId;
@property (nonatomic, retain) NSString * spName;
@property (nonatomic, retain) NSString * transit;
@property (nonatomic, retain) NSSet *phoneNumbers;
@end

@interface ServiceProvider (CoreDataGeneratedAccessors)

- (void)addPhoneNumbersObject:(PhoneNumber *)value;
- (void)removePhoneNumbersObject:(PhoneNumber *)value;
- (void)addPhoneNumbers:(NSSet *)values;
- (void)removePhoneNumbers:(NSSet *)values;
@end
