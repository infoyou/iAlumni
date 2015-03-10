//
//  PhoneNumber.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ServiceItem, ServiceProvider;

@interface PhoneNumber : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) ServiceItem *item;
@property (nonatomic, retain) ServiceProvider *provider;

@end
