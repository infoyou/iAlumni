//
//  Comment.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Comment : NSManagedObject

@property (nonatomic, retain) NSNumber * authorId;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * authorPicUrl;
@property (nonatomic, retain) NSNumber * authorType;
@property (nonatomic, retain) NSNumber * commentId;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * elapsedTime;
@property (nonatomic, retain) NSNumber * imageAttached;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSNumber * parentId;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSNumber * timestamp;

@end
