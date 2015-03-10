//
//  Upcoming.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Upcoming : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * contract;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * eventId;
@property (nonatomic, retain) NSNumber * languageType;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * orderId;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;

@end
