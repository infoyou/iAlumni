//
//  Post.h
//  iAlumni
//
//  Created by Adam on 13-9-20.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tag;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSNumber * approved;
@property (nonatomic, retain) NSString * authorId;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * authorPicUrl;
@property (nonatomic, retain) NSString * authorType;
@property (nonatomic, retain) NSString * clubId;
@property (nonatomic, retain) NSString * clubName;
@property (nonatomic, retain) NSString * clubType;
@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * couldBeDeleted;
@property (nonatomic, retain) NSString * createdAt;
@property (nonatomic, retain) NSString * createdTime;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * elapsedTime;
@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSNumber * groupId;
@property (nonatomic, retain) NSString * groupName;
@property (nonatomic, retain) NSString * hasLocation;
@property (nonatomic, retain) NSNumber * hot;
@property (nonatomic, retain) NSNumber * imageAttached;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * isHaveSurvey;
@property (nonatomic, retain) NSString * isSmsInform;
@property (nonatomic, retain) NSNumber * lastCommentTimestamp;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSNumber * liked;
@property (nonatomic, retain) NSNumber * locationAttached;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * originalImageHeight;
@property (nonatomic, retain) NSNumber * originalImageWidth;
@property (nonatomic, retain) NSString * place;
@property (nonatomic, retain) NSNumber * postId;
@property (nonatomic, retain) NSNumber * postType;
@property (nonatomic, retain) NSString * surveyResultUrl;
@property (nonatomic, retain) NSString * surveyUrl;
@property (nonatomic, retain) NSString * tagIds;
@property (nonatomic, retain) NSString * tagNames;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * userIsAnswered;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;
@end
