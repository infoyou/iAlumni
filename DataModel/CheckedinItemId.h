//
//  CheckedinItemId.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CheckedinMember;

@interface CheckedinItemId : NSManagedObject

@property (nonatomic, retain) NSString * itemId;
@property (nonatomic, retain) CheckedinMember *checkedinBy;

@end
