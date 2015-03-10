//
//  AlbumPhoto.h
//  iAlumni
//
//  Created by Adam on 13-8-17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Welfare;

@interface AlbumPhoto : NSManagedObject

@property (nonatomic, retain) NSNumber * authorId;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * itemId;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) Welfare *welfare;

@end
