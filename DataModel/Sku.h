//
//  Sku.h
//  iAlumni
//
//  Created by Adam on 13-8-17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Welfare;

@interface Sku : NSManagedObject

@property (nonatomic, retain) NSNumber * discountRate;
@property (nonatomic, retain) NSNumber * integral;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * salesPrice;
@property (nonatomic, retain) NSString * skuId;
@property (nonatomic, retain) NSString * skuProp1;
@property (nonatomic, retain) Welfare *welfare;
@property (nonatomic, retain) NSNumber * allowMultiple;

@end
