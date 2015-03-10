//
//  CachedNews.m
//  iAlumni
//
//  Created by Adam on 13-10-4.
//
//

#import "CachedNews.h"

@implementation CachedNews

- (void)dealloc {
  
  self.date = nil;
  self.dateSeparator = nil;
  self.drawnFrom = nil;
  self.elapsedDayCount = nil;
  self.elapsedTime = nil;
  self.imageAttached = nil;
  self.imageUrl = nil;
  self.newsId = nil;
  self.originalImageHeight = nil;
  self.originalImageWidth = nil;
  self.subTitle = nil;
  self.thumbnailUrl = nil;
  self.timestamp = nil;
  self.title = nil;
  self.url = nil;
  self.type = nil;
  
  [super dealloc];
}

#pragma mark - NSCoding methods
- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  
  self.date = [aDecoder decodeObjectForKey:@"date"];
  self.dateSeparator = [aDecoder decodeObjectForKey:@"dateSeparator"];
  self.drawnFrom = [aDecoder decodeObjectForKey:@"drawnFrom"];
  self.elapsedDayCount = [aDecoder decodeObjectForKey:@"elapsedDayCount"];
  self.elapsedTime = [aDecoder decodeObjectForKey:@"elapsedTime"];
  self.imageAttached = [aDecoder decodeObjectForKey:@"imageAttached"];
  self.imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
  self.newsId = [aDecoder decodeObjectForKey:@"newsId"];
  self.originalImageHeight = [aDecoder decodeObjectForKey:@"originalImageHeight"];
  self.originalImageWidth = [aDecoder decodeObjectForKey:@"originalImageWidth"];
  self.subTitle = [aDecoder decodeObjectForKey:@"subTitle"];
  self.thumbnailUrl = [aDecoder decodeObjectForKey:@"thumbnailUrl"];
  self.timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
  self.title = [aDecoder decodeObjectForKey:@"title"];
  self.url = [aDecoder decodeObjectForKey:@"url"];
  self.type = [aDecoder decodeObjectForKey:@"type"];
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:self.date forKey:@"date"];
  [aCoder encodeObject:self.dateSeparator forKey:@"dateSeparator"];
  [aCoder encodeObject:self.drawnFrom forKey:@"drawnFrom"];
  [aCoder encodeObject:self.elapsedDayCount forKey:@"elapsedDayCount"];
  [aCoder encodeObject:self.elapsedTime forKey:@"elapsedTime"];
  [aCoder encodeObject:self.imageAttached forKey:@"imageAttached"];
  [aCoder encodeObject:self.imageUrl forKey:@"imageUrl"];
  [aCoder encodeObject:self.newsId forKey:@"newsId"];
  [aCoder encodeObject:self.originalImageHeight forKey:@"originalImageHeight"];
  [aCoder encodeObject:self.originalImageWidth forKey:@"originalImageWidth"];
  [aCoder encodeObject:self.subTitle forKey:@"subTitle"];
  [aCoder encodeObject:self.thumbnailUrl forKey:@"thumbnailUrl"];
  [aCoder encodeObject:self.timestamp forKey:@"timestamp"];
  [aCoder encodeObject:self.title forKey:@"title"];
  [aCoder encodeObject:self.url forKey:@"url"];
  [aCoder encodeObject:self.type forKey:@"type"];
  
}

@end
