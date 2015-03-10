//
//  CachedVideo.h
//  iAlumni
//
//  Created by Adam on 13-10-3.
//
//

#import <Foundation/Foundation.h>

@interface CachedVideo : NSObject <NSCoding> {
  
}

@property (nonatomic, copy) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, copy) NSString * duration;
@property (nonatomic, retain) NSNumber * videoId;
@property (nonatomic, copy) NSString * videoName;
@property (nonatomic, copy) NSString * videoUrl;
@property (nonatomic, copy) NSString * popularity;
@property (nonatomic, copy) NSString * createDate;


@end
