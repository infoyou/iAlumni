//
//  Video.m
//  iAlumni
//
//  Created by Adam on 13-1-11.
//
//

#import "Video.h"


@implementation Video

@dynamic imageUrl;
@dynamic order;
@dynamic duration;
@dynamic videoId;
@dynamic videoName;
@dynamic videoUrl;
@dynamic popularity;
@dynamic createDate;

- (id)initWithCoder:(NSCoder*)coder
{
  if (self = [super init]) {
  }
  return self;
}

@end
