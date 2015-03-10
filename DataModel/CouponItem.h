//
//  CouponItem.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ServiceItem;

@interface CouponItem : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * itemId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * priceRange;
@property (nonatomic, retain) NSString * prp;
@property (nonatomic, retain) NSString * reducedPrice;
@property (nonatomic, retain) NSString * savings;
@property (nonatomic, retain) NSNumber * serviceItemId;
@property (nonatomic, retain) NSNumber * sortKey;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * validity;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) ServiceItem *serviceItem;

@end
