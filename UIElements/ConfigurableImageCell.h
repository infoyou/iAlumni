//
//  ConfigurableImageCell.h
//  iAlumni
//
//  Created by Adam on 12-11-24.
//
//

#import "ConfigurableTextCell.h"
#import "GlobalConstants.h"
#import "WXWImageFetcherDelegate.h"
#import "WXWImageDisplayerDelegate.h"


@interface ConfigurableImageCell : ConfigurableTextCell <WXWImageFetcherDelegate> {
  
  id<WXWImageDisplayerDelegate> _imageDisplayerDelegate;
  
  NSManagedObjectContext *_MOC;
  
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (CATransition *)imageTransition;

- (BOOL)currentUrlMatchCell:(NSString *)url;

- (void)fetchImage:(NSMutableArray *)imageUrls forceNew:(BOOL)forceNew;


@end
