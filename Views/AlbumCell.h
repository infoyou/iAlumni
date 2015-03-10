//
//  AlbumCell.h
//  ExpatCircle
//
//  Created by Adam on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ECImageConsumerCell.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"


@interface AlbumCell : ECImageConsumerCell {
  @private
  id<ECClickableElementDelegate> _clickableElementDelegate;
  
  NSMutableDictionary *_photoDic;
  
  NSMutableDictionary *_buttonContainer;
  
  NSArray *_photos;
}

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate 
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawAlbumCell:(NSArray *)photos;

@end
