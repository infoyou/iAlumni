//
//  UserCountry.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserCountry : NSManagedObject

@property (nonatomic, retain) NSString * cnName;
@property (nonatomic, retain) NSString * countryId;
@property (nonatomic, retain) NSString * enName;
@property (nonatomic, retain) NSNumber * order;

@end
