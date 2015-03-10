//
//  PostComment.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PostComment : NSManagedObject

@property (nonatomic, retain) NSString * authorId;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * authorPicUrl;
@property (nonatomic, retain) NSString * authorType;
@property (nonatomic, retain) NSNumber * commentId;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * couldBeDeleted;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSNumber * imageAttached;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * parentId;
@property (nonatomic, retain) NSNumber * showOrder;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSNumber * timestamp;

@end
