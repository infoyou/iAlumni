//
//  ReferenceRelationship.h
//  iAlumni
//
//  Created by Adam on 12-12-5.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 * design principle https://www.evernote.com/shard/s69/sh/773d2d9a-26a6-4617-8b89-1b866ce8357a/039514f9587ba90ea30589d7de0b350e
 */

@class RecommendAlumni;

@interface ReferenceRelationship : NSManagedObject

@property (nonatomic, retain) NSNumber * startAlumniId;
@property (nonatomic, retain) NSNumber * endAlumniId;
@property (nonatomic, retain) NSNumber * referenceId;
@property (nonatomic, retain) RecommendAlumni *reference;

@end
