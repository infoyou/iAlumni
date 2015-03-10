//
//  Liker.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Member.h"

@class LikedItemId;

@interface Liker : Member

@property (nonatomic, retain) NSSet *likedItemIds;
@end

@interface Liker (CoreDataGeneratedAccessors)

- (void)addLikedItemIdsObject:(LikedItemId *)value;
- (void)removeLikedItemIdsObject:(LikedItemId *)value;
- (void)addLikedItemIds:(NSSet *)values;
- (void)removeLikedItemIds:(NSSet *)values;
@end
