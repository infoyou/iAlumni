//
//  Alumni.h
//  iAlumni
//
//  Created by Adam on 13-8-17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Welfare;

@interface Alumni : NSManagedObject

@property (nonatomic, retain) NSNumber * allKnownAlumniCount;
@property (nonatomic, retain) NSNumber * bySearch;
@property (nonatomic, retain) NSString * classGroupName;
@property (nonatomic, retain) NSString * companyAddressC;
@property (nonatomic, retain) NSString * companyAddressE;
@property (nonatomic, retain) NSString * companyCity;
@property (nonatomic, retain) NSString * companyCountryC;
@property (nonatomic, retain) NSString * companyCountryE;
@property (nonatomic, retain) NSString * companyFax;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * companyPhone;
@property (nonatomic, retain) NSString * companyProvince;
@property (nonatomic, retain) NSNumber * containerType;
@property (nonatomic, retain) NSString * distance;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * feePaid;
@property (nonatomic, retain) NSString * feeToPay;
@property (nonatomic, retain) NSString * firstNamePinyinChar;
@property (nonatomic, retain) NSNumber * groupId;
@property (nonatomic, retain) NSString * hasApplied;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * isAdmin;
@property (nonatomic, retain) NSString * isApprove;
@property (nonatomic, retain) NSNumber * isCheckIn;
@property (nonatomic, retain) NSNumber * isLastMessageFromSelf;
@property (nonatomic, retain) NSString * isMember;
@property (nonatomic, retain) NSString * jobTitle;
@property (nonatomic, retain) NSNumber * joinedGroupCount;
@property (nonatomic, retain) NSString * lastMsg;
@property (nonatomic, retain) NSString * lastSignInTime;
@property (nonatomic, retain) NSString * platInfo;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * linkedin;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * memberLevel;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * notReadMsgCount;
@property (nonatomic, retain) NSNumber * orderId;
@property (nonatomic, retain) NSString * payDate;
@property (nonatomic, retain) NSString * personId;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * plat;
@property (nonatomic, retain) NSString * profile;
@property (nonatomic, retain) NSNumber * relationshipType;
@property (nonatomic, retain) NSString * shakePlace;
@property (nonatomic, retain) NSString * shakeThing;
@property (nonatomic, retain) NSString * sina;
@property (nonatomic, retain) NSString * tableInfo;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userType;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSString * weixin;
@property (nonatomic, retain) NSNumber * withMeConnectionCount;
@property (nonatomic, retain) Welfare *welfare;

@end
