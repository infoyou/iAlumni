//
//  Messages.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Messages : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSNumber * quickViewed;
@property (nonatomic, retain) NSNumber * reviewed;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * paymentDone;

@end
