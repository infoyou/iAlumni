//
//  VideoPoster.h
//  iAlumni
//
//  Created by Adam on 13-11-17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VideoPoster : NSManagedObject

@property (nonatomic, retain) NSNumber * videoId;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * videoName;

@end
