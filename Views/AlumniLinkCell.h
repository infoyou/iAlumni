//
//  AlumniLinkCell.h
//  iAlumni
//
//  Created by Adam on 12-11-28.
//
//

#import "ECImageConsumerCell.h"
#import "ECClickableElementDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"

@class WXWLabel;
@class RelationshipLink;
@class AlumniLinkView;

@interface AlumniLinkCell : ECImageConsumerCell {
  @private

  UIView *_contentBackgroundView;
  AlumniLinkView *_linkView;

}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
     linkListHolder:(id<ECClickableElementDelegate>)linkListHolder
connectTriggerDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectTriggerDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawCellWithLink:(RelationshipLink *)link cellHeight:(CGFloat)cellHeight;

@end
