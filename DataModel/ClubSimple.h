//
//  ClubSimple.h
//  iAlumni
//
//  Created by Adam on 13-7-28.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ClubSimple : NSManagedObject

@property (nonatomic, retain) NSNumber * clubId;
@property (nonatomic, retain) NSNumber * eventcount;
@property (nonatomic, retain) NSString * eventDesc;
@property (nonatomic, retain) NSString * ifadmin;
@property (nonatomic, retain) NSString * ifmember;
@property (nonatomic, retain) NSNumber * lastEventNum;
@property (nonatomic, retain) NSNumber * membercount;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * newEventNum;
@property (nonatomic, retain) NSString * orderId;
@property (nonatomic, retain) NSNumber * payType;
@property (nonatomic, retain) NSNumber * userPaid;
@property (nonatomic, retain) NSString * userPayDate;

@end
