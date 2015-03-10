//
//  NewsThumbnailView.h
//  iAlumni
//
//  Created by Adam on 13-1-11.
//
//

#import "WXWConnectorConsumerView.h"

@class WXWLabel;

@interface NewsThumbnailView : WXWConnectorConsumerView {
  @private
  
  id _entrance;
  
  SEL _action;
  
  NSManagedObjectContext *_MOC;
  NSInteger _currentIndex;
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate
           entrance:(id)entrance
             action:(SEL)action;

- (void)loadNewsImageWithUrl:(NSString *)imageUrl;

- (void)loadNews;

@end
