//
//  Brand.h
//  iAlumni
//
//  Created by Adam on 13-8-21.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Alumni;

@interface Brand : NSManagedObject

@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * brandId;
@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSString * companyType;
@property (nonatomic, retain) NSString * couponInfo;
@property (nonatomic, retain) NSNumber * itemTotal;
@property (nonatomic, retain) NSString * latestComment;
@property (nonatomic, retain) NSString * latestCommentBranchName;
@property (nonatomic, retain) NSString * latestCommentElapsedTime;
@property (nonatomic, retain) NSNumber * latestCommenterId;
@property (nonatomic, retain) NSString * latestCommenterName;
@property (nonatomic, retain) NSNumber * latestCommentTimestamp;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * nearestDistance;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * engName;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSSet *brandAlumnus;
@end

@interface Brand (CoreDataGeneratedAccessors)

- (void)addBrandAlumnusObject:(Alumni *)value;
- (void)removeBrandAlumnusObject:(Alumni *)value;
- (void)addBrandAlumnus:(NSSet *)values;
- (void)removeBrandAlumnus:(NSSet *)values;
@end
