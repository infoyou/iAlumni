//
//  RecommendedItem.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ServiceItem;

@interface RecommendedItem : NSManagedObject

@property (nonatomic, retain) NSString * cnName;
@property (nonatomic, retain) NSString * enName;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * intro;
@property (nonatomic, retain) NSNumber * itemId;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSNumber * liked;
@property (nonatomic, retain) NSNumber * serviceItemId;
@property (nonatomic, retain) NSNumber * sortKey;
@property (nonatomic, retain) ServiceItem *serviceItem;

@end
