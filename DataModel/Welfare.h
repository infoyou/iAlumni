//
//  Welfare.h
//  iAlumni
//
//  Created by Adam on 13-8-17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AlbumPhoto, Alumni, Sku;

@interface Welfare : NSManagedObject

@property (nonatomic, retain) NSString * brandEngName;
@property (nonatomic, retain) NSString * brandId;
@property (nonatomic, retain) NSString * brandLogoUrl;
@property (nonatomic, retain) NSString * brandName;
@property (nonatomic, retain) NSNumber * buyType;
@property (nonatomic, retain) NSString * buyTypeDesc;
@property (nonatomic, retain) NSString * couponUrl;
@property (nonatomic, retain) NSString * discountRate;
@property (nonatomic, retain) NSNumber * downloadPersonCount;
@property (nonatomic, retain) NSString * endTime;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * itemId;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSString * offersTips;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * overCount;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * pTypeCode;
@property (nonatomic, retain) NSString * pTypeId;
@property (nonatomic, retain) NSNumber * salesPersonCount;
@property (nonatomic, retain) NSString * salesPrice;
@property (nonatomic, retain) NSString * storeAddress;
@property (nonatomic, retain) NSNumber * storeCount;
@property (nonatomic, retain) NSString * storeId;
@property (nonatomic, retain) NSString * storeImageUrl;
@property (nonatomic, retain) NSString * storeName;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSString * useInfo;
@property (nonatomic, retain) NSSet *imageList;
@property (nonatomic, retain) NSSet *salesUserList;
@property (nonatomic, retain) NSSet *skuList;
@property (nonatomic, retain) NSNumber * favorited;
@end

@interface Welfare (CoreDataGeneratedAccessors)

- (void)addImageListObject:(AlbumPhoto *)value;
- (void)removeImageListObject:(AlbumPhoto *)value;
- (void)addImageList:(NSSet *)values;
- (void)removeImageList:(NSSet *)values;
- (void)addSalesUserListObject:(Alumni *)value;
- (void)removeSalesUserListObject:(Alumni *)value;
- (void)addSalesUserList:(NSSet *)values;
- (void)removeSalesUserList:(NSSet *)values;
- (void)addSkuListObject:(Sku *)value;
- (void)removeSkuListObject:(Sku *)value;
- (void)addSkuList:(NSSet *)values;
- (void)removeSkuList:(NSSet *)values;
@end
