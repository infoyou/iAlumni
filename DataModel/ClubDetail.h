//
//  ClubDetail.h
//  iAlumni
//
//  Created by Adam on 13-8-16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ClubDetail : NSManagedObject

@property (nonatomic, retain) NSString * change;
@property (nonatomic, retain) NSString * createTime;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * eventcount;
@property (nonatomic, retain) NSNumber * feesValue;
@property (nonatomic, retain) NSString * hostSupTypeValue;
@property (nonatomic, retain) NSString * hostTypeValue;
@property (nonatomic, retain) NSString * ifadmin;
@property (nonatomic, retain) NSString * ifmember;
@property (nonatomic, retain) NSString * imgUrl;
@property (nonatomic, retain) NSString * isRead;
@property (nonatomic, retain) NSString * isWrite;
@property (nonatomic, retain) NSString * managerMsg;
@property (nonatomic, retain) NSNumber * membercount;
@property (nonatomic, retain) NSString * memberShipInfo;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * newPostCount;
@property (nonatomic, retain) NSString * orderTitle;
@property (nonatomic, retain) NSNumber * paymentStatus;
@property (nonatomic, retain) NSString * payNextTime;
@property (nonatomic, retain) NSString * payOrderId;
@property (nonatomic, retain) NSString * person;
@property (nonatomic, retain) NSString * skuMsg;
@property (nonatomic, retain) NSNumber * skuPrice;
@property (nonatomic, retain) NSNumber * sponsorId;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSString * webUrl;
@property (nonatomic, retain) NSString * weibo;
@property (nonatomic, retain) NSString * detailDescUrl;

@end
