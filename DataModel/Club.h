//
//  Club.h
//  iAlumni
//
//  Created by Adam on 13-8-7.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Club : NSManagedObject

@property (nonatomic, retain) NSNumber * activity;
@property (nonatomic, retain) NSNumber * allowJoin;
@property (nonatomic, retain) NSNumber * allowPost;
@property (nonatomic, retain) NSNumber * allowQuit;
@property (nonatomic, retain) NSString * badgeNum;
@property (nonatomic, retain) id baseInfoData;
@property (nonatomic, retain) NSNumber * clubId;
@property (nonatomic, retain) NSString * clubName;
@property (nonatomic, retain) NSString * clubType;
@property (nonatomic, retain) NSString * forbidJoinReason;
@property (nonatomic, retain) NSString * forbidPostReason;
@property (nonatomic, retain) NSString * forbidQuitReason;
@property (nonatomic, retain) NSString * hostSupTypeValue;
@property (nonatomic, retain) NSString * hostTypeValue;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSNumber * member;
@property (nonatomic, retain) NSNumber * needPay;
@property (nonatomic, retain) NSString * postAuthor;
@property (nonatomic, retain) NSString * postDesc;
@property (nonatomic, retain) id postInfoContentData;
@property (nonatomic, retain) NSString * postNum;
@property (nonatomic, retain) NSString * postTime;
@property (nonatomic, retain) NSNumber * showOrder;
@property (nonatomic, retain) NSNumber * usageType;

@end
