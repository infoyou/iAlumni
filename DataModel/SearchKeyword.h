//
//  SearchKeyword.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SearchKeyword : NSManagedObject

@property (nonatomic, retain) NSString * searchString;
@property (nonatomic, retain) NSNumber * timestamp;

@end
