//
//  Shake.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Shake : NSManagedObject

@property (nonatomic, retain) NSString * defaultPlace;
@property (nonatomic, retain) NSString * defaultThing;
@property (nonatomic, retain) NSString * places;
@property (nonatomic, retain) NSString * things;

@end
