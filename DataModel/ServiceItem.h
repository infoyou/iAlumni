//
//  ServiceItem.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CouponItem, PhoneNumber, RecommendedItem, ServiceItemSection;

@interface ServiceItem : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSNumber * brandId;
@property (nonatomic, retain) NSNumber * categoryId;
@property (nonatomic, retain) NSString * categoryName;
@property (nonatomic, retain) NSNumber * checkedin;
@property (nonatomic, retain) NSNumber * checkinCount;
@property (nonatomic, retain) NSNumber * cityId;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) NSString * cnAddressPart1;
@property (nonatomic, retain) NSString * cnAddressPart2;
@property (nonatomic, retain) NSString * cnAddressPart3;
@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSString * couponInfo;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSNumber * grade;
@property (nonatomic, retain) NSNumber * hasCoupon;
@property (nonatomic, retain) NSNumber * hasLink;
@property (nonatomic, retain) NSNumber * hasRecommendedItem;
@property (nonatomic, retain) NSNumber * hasServiceProvider;
@property (nonatomic, retain) NSNumber * hasTransit;
@property (nonatomic, retain) NSString * headerParamName;
@property (nonatomic, retain) NSString * headerParamValue;
@property (nonatomic, retain) NSNumber * hot;
@property (nonatomic, retain) NSNumber * imageAttached;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * itemId;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSNumber * lastCommentTimestamp;
@property (nonatomic, retain) NSString * latestComment;
@property (nonatomic, retain) NSString * latestCommentElapsedTime;
@property (nonatomic, retain) NSNumber * latestCommenterId;
@property (nonatomic, retain) NSString * latestCommenterName;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * latlagAttached;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSNumber * liked;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * myCountryLikeCount;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * photoCount;
@property (nonatomic, retain) NSNumber * providerId;
@property (nonatomic, retain) NSString * providerName;
@property (nonatomic, retain) NSString * recommendedItemNames;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * tagNames;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSString * transit;
@property (nonatomic, retain) NSSet *couponInfos;
@property (nonatomic, retain) NSSet *phoneNumbers;
@property (nonatomic, retain) NSSet *recommendedItems;
@property (nonatomic, retain) NSSet *sections;
@end

@interface ServiceItem (CoreDataGeneratedAccessors)

- (void)addCouponInfosObject:(CouponItem *)value;
- (void)removeCouponInfosObject:(CouponItem *)value;
- (void)addCouponInfos:(NSSet *)values;
- (void)removeCouponInfos:(NSSet *)values;
- (void)addPhoneNumbersObject:(PhoneNumber *)value;
- (void)removePhoneNumbersObject:(PhoneNumber *)value;
- (void)addPhoneNumbers:(NSSet *)values;
- (void)removePhoneNumbers:(NSSet *)values;
- (void)addRecommendedItemsObject:(RecommendedItem *)value;
- (void)removeRecommendedItemsObject:(RecommendedItem *)value;
- (void)addRecommendedItems:(NSSet *)values;
- (void)removeRecommendedItems:(NSSet *)values;
- (void)addSectionsObject:(ServiceItemSection *)value;
- (void)removeSectionsObject:(ServiceItemSection *)value;
- (void)addSections:(NSSet *)values;
- (void)removeSections:(NSSet *)values;
@end
