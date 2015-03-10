//
//  Feedback.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Feedback : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * sampleMsg;
@property (nonatomic, retain) NSString * tel;

@end
