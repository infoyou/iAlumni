//
//  Member.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Member : NSManagedObject

@property (nonatomic, retain) NSNumber * answerCount;
@property (nonatomic, retain) NSString * awardDesc;
@property (nonatomic, retain) NSString * bigPhotoUrl;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSNumber * cityId;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSNumber * commentPoints;
@property (nonatomic, retain) NSString * companyAddress;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSNumber * countryId;
@property (nonatomic, retain) NSString * countryName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * facebookPostCount;
@property (nonatomic, retain) NSNumber * favoriteCount;
@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSNumber * feedCount;
@property (nonatomic, retain) NSNumber * feedPoints;
@property (nonatomic, retain) NSNumber * grade;
@property (nonatomic, retain) NSString * groupClassName;
@property (nonatomic, retain) NSString * industry;
@property (nonatomic, retain) NSNumber * invitationDonePoints;
@property (nonatomic, retain) NSNumber * invitationPoints;
@property (nonatomic, retain) NSNumber * likeItems;
@property (nonatomic, retain) NSNumber * linkedinPostCount;
@property (nonatomic, retain) NSNumber * memberId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * okInvitationCount;
@property (nonatomic, retain) NSString * personId;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSNumber * sentInvitationCount;
@property (nonatomic, retain) NSNumber * twitterPostCount;
@property (nonatomic, retain) NSNumber * userType;
@property (nonatomic, retain) NSString * years;

@end
