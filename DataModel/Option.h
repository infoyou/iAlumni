//
//  Option.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Option : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * optionId;
@property (nonatomic, retain) NSNumber * orderId;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSNumber * topicId;

@end
