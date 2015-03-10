//
//  ServiceItemCell.h
//  ExpatCircle
//
//  Created by Adam on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ECImageConsumerCell.h"
#import "GlobalConstants.h"


@class WXWLabel;
@class ServiceItem;

@interface ServiceItemCell : ECImageConsumerCell {
  @private
  
  id _venueListVC;
  SEL _callAction;
  
  UIImageView *_avatarView;
  
  WXWLabel *_nameLabel;
  WXWLabel *_addressLabel;

  UIButton *_telButton;
  
  WXWLabel *_distanceLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
        venueListVC:(id)venueListVC
         callAction:(SEL)callAction;

- (void)drawItem:(ServiceItem *)item index:(NSInteger)index;

@end
