//
//  CheckinUserCell.h
//  iAlumni
//
//  Created by Adam on 12-8-17.
//
//

#import "ECImageConsumerCell.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;
@class Alumni;
@class CheckedinMember;

@interface CheckinUserCell : ECImageConsumerCell {
  @private
  
  UIView *_authorPicBackgroundView;
  UIImageView *_authorPic;

  WXWLabel *_nameLabel;
  WXWLabel *_classLabel;
  WXWLabel *_companyLabel;
  
  WXWLabel *_checkinTimeLabel;
  WXWLabel *_checkinCountLabel;
  
  UIButton *_dmButton;
  
  id<ECClickableElementDelegate> _delegate;
  
  CheckedinMember *_checkedinAlumni;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawCellWithAlumni:(CheckedinMember *)alumni;

@end
