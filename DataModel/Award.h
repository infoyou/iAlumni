//
//  Award.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Award : NSManagedObject

@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSNumber * experienceTotal;
@property (nonatomic, retain) NSNumber * experienceUnitValue;
@property (nonatomic, retain) NSNumber * memberId;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * pointTotal;
@property (nonatomic, retain) NSNumber * pointUnitValue;
@property (nonatomic, retain) NSNumber * type;

@end
