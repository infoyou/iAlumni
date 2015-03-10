//
//  Video.h
//  iAlumni
//
//  Created by Adam on 13-1-11.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Video : NSManagedObject

@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * duration;
@property (nonatomic, retain) NSNumber * videoId;
@property (nonatomic, retain) NSString * videoName;
@property (nonatomic, retain) NSString * videoUrl;
@property (nonatomic, retain) NSString * popularity;
@property (nonatomic, retain) NSString * createDate;

@end
