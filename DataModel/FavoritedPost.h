//
//  FavoritedPost.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FavoritedPost : NSManagedObject

@property (nonatomic, retain) NSNumber * favoritedBy;

@end
