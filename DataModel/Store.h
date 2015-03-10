//
//  Store.h
//  iAlumni
//
//  Created by Adam on 13-8-20.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AlbumPhoto;

@interface Store : NSManagedObject

@property (nonatomic, retain) NSString * storeId;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * displayIndex;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * storeName;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * brandId;
@property (nonatomic, retain) NSString * brandName;
@property (nonatomic, retain) NSString * brandEngName;
@property (nonatomic, retain) NSSet *imageList;
@end

@interface Store (CoreDataGeneratedAccessors)

- (void)addImageListObject:(AlbumPhoto *)value;
- (void)removeImageListObject:(AlbumPhoto *)value;
- (void)addImageList:(NSSet *)values;
- (void)removeImageList:(NSSet *)values;
@end
