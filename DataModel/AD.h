//
//  AD.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AD : NSManagedObject

@property (nonatomic, retain) NSNumber * adId;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * website;

@end
