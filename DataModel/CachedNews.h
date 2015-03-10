//
//  CachedNews.h
//  iAlumni
//
//  Created by Adam on 13-10-4.
//
//

#import <Foundation/Foundation.h>

@interface CachedNews : NSObject <NSCoding> {
  
}

@property (nonatomic, copy) NSString * date;
@property (nonatomic, copy) NSString * dateSeparator;
@property (nonatomic, copy) NSString * drawnFrom;
@property (nonatomic, retain) NSNumber * elapsedDayCount;
@property (nonatomic, copy) NSString * elapsedTime;
@property (nonatomic, retain) NSNumber * imageAttached;
@property (nonatomic, copy) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * newsId;
@property (nonatomic, retain) NSNumber * originalImageHeight;
@property (nonatomic, retain) NSNumber * originalImageWidth;
@property (nonatomic, copy) NSString * thumbnailUrl;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subTitle;
@property (nonatomic, copy) NSString * url;
@property (nonatomic, retain) NSNumber * type;

@end
