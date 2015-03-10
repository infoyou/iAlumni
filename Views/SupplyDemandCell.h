//
//  SupplyDemandCell.h
//  iAlumni
//
//  Created by Adam on 13-5-28.
//
//

#import "ECImageConsumerCell.h"

@class WXWLabel;

@interface SupplyDemandCell : ECImageConsumerCell {
  
  @private
  UIImageView *_flagIcon;
  WXWLabel *_nameLabel;
  WXWLabel *_classLabel;
  WXWLabel *_timeline;
  WXWLabel *_contentLabel;
  WXWLabel *_approveStatusLabel;
  UIImageView *_tagIcon;
 
  id _searchDelegate;
  SEL _searchAction;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
     searchDelegate:(id)searchDelegate
       searchAction:(SEL)searchAction
                MOC:(NSManagedObjectContext *)MOC;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawCellWithItem:(Post *)item;

@end
