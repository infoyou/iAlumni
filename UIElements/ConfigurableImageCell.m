//
//  ConfigurableImageCell.m
//  iAlumni
//
//  Created by Adam on 12-11-24.
//
//

#import "ConfigurableImageCell.h"
#import "AppManager.h"

@interface ConfigurableImageCell()
@property (nonatomic, retain) NSMutableArray *imageUrls;
@end

@implementation ConfigurableImageCell


#pragma mark - lifecycle methods
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _imageDisplayerDelegate = imageDisplayerDelegate;
    
    _MOC = MOC;
  }
  return self;
}

- (void)dealloc {
  
  for (NSString *url in self.imageUrls) {
    [[WXWImageManager instance] clearCallerFromCache:url];
  }
  
  self.imageUrls = nil;
  
  [super dealloc];
}

- (void)fetchImage:(NSMutableArray *)imageUrls forceNew:(BOOL)forceNew {
  
  if (imageUrls.count == 0) {
    return;
  }
  
  self.imageUrls = imageUrls;
  
  for (NSString *url in imageUrls) {
    
    // register image url, when the displayer (view controller) be pop up from view controller stack, if
    // image still being loaded, the process could be cancelled
    [_imageDisplayerDelegate registerImageUrl:url];
    
    [[WXWImageManager instance] fetchImage:url caller:self forceNew:forceNew];
  }
}

- (CATransition *)imageTransition {
  CATransition *imageFadein = [CATransition animation];
  imageFadein.duration = FADE_IN_DURATION;
  imageFadein.type = kCATransitionFade;
  return imageFadein;
}

- (BOOL)currentUrlMatchCell:(NSString *)url {
  // if the image of current url need be displayed in current cell, then return YES; otherwise return NO;
  return [self.imageUrls containsObject:url];
}

#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
  // implemented by sub class
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
  // implemented by sub class
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
  // implemented by sub class
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
  // implemented by sub class
}


@end
