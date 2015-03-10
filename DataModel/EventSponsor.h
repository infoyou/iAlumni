//
//  EventSponsor.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EventSponsor : NSManagedObject

@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) NSNumber * eventId;
@property (nonatomic, retain) NSString * fee;
@property (nonatomic, retain) NSString * hostName;
@property (nonatomic, retain) NSString * hostType;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sponsorId;
@property (nonatomic, retain) NSString * url;

@end
