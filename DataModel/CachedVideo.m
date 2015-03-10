//
//  CachedVideo.m
//  iAlumni
//
//  Created by Adam on 13-10-3.
//
//

#import "CachedVideo.h"

@implementation CachedVideo


- (void)dealloc {
  
  self.imageUrl = nil;
  self.duration = nil;
  self.videoName = nil;
  self.videoUrl = nil;
  self.popularity = nil;
  self.createDate = nil;
  
  [super dealloc];
}

#pragma mark - NSCoding methods
- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  
  self.imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
  self.order = [aDecoder decodeObjectForKey:@"order"];
  self.duration = [aDecoder decodeObjectForKey:@"duration"];
  self.videoId = [aDecoder decodeObjectForKey:@"videoId"];
  self.videoName = [aDecoder decodeObjectForKey:@"videoName"];
  self.videoUrl = [aDecoder decodeObjectForKey:@"videoUrl"];
  self.popularity = [aDecoder decodeObjectForKey:@"popularity"];
  self.createDate = [aDecoder decodeObjectForKey:@"createDate"];
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  
  [aCoder encodeObject:self.imageUrl forKey:@"imageUrl"];
  [aCoder encodeObject:self.order forKey:@"order"];
  [aCoder encodeObject:self.duration forKey:@"duration"];
  [aCoder encodeObject:self.videoId forKey:@"videoId"];
  [aCoder encodeObject:self.videoName forKey:@"videoName"];
  [aCoder encodeObject:self.videoUrl forKey:@"videoUrl"];
  [aCoder encodeObject:self.popularity forKey:@"popularity"];
  [aCoder encodeObject:self.createDate forKey:@"createDate"];
}


@end
