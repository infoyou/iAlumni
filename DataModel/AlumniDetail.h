//
//  AlumniDetail.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AlumniDetail : NSManagedObject

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
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * isAdmin;
@property (nonatomic, retain) NSString * isApprove;
@property (nonatomic, retain) NSNumber * isCheckIn;
@property (nonatomic, retain) NSString * isMember;
@property (nonatomic, retain) NSString * jobTitle;
@property (nonatomic, retain) NSString * linkedin;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * orderId;
@property (nonatomic, retain) NSString * personId;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * profile;
@property (nonatomic, retain) NSString * sina;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userType;
@property (nonatomic, retain) NSString * weixin;

@end
