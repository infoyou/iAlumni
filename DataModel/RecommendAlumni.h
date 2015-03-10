//
//  RecommendAlumni.h
//  iAlumni
//
//  Created by Adam on 12-12-5.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Alumni.h"


/**
 * design principle https://www.evernote.com/shard/s69/sh/773d2d9a-26a6-4617-8b89-1b866ce8357a/039514f9587ba90ea30589d7de0b350e
 */

@class ReferenceRelationship;

@interface RecommendAlumni : Alumni

@property (nonatomic, retain) NSSet *links;
@end

@interface RecommendAlumni (CoreDataGeneratedAccessors)

- (void)addLinksObject:(ReferenceRelationship *)value;
- (void)removeLinksObject:(ReferenceRelationship *)value;
- (void)addLinks:(NSSet *)values;
- (void)removeLinks:(NSSet *)values;
@end
