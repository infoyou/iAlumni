//
//  Invitee.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Invitee : NSManagedObject

@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) NSString * countryName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSNumber * grade;
@property (nonatomic, retain) NSNumber * invited;
@property (nonatomic, retain) NSNumber * joined;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSString * snsUserId;
@property (nonatomic, retain) NSNumber * sourceType;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * years;

@end
