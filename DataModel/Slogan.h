//
//  Slogan.h
//  iAlumni
//
//  Created by Adam on 13-11-13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Slogan : NSManagedObject

@property (nonatomic, retain) NSString * sloganId;
@property (nonatomic, retain) NSString * content;

@end
