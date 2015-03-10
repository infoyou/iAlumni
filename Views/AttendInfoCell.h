//
//  AttendInfoCell.h
//  iAlumni
//
//  Created by Adam on 12-9-7.
//
//

#import <UIKit/UIKit.h>
#import "ECTextBoardCell.h"
#import "GlobalConstants.h"

@interface AttendInfoCell : ECTextBoardCell {
  @private
  UIButton *_signUpInfoButton;
  UIButton *_checkinInfoButton;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
             target:(id)target
   signUpInfoAction:(SEL)signUpInfoAction
  checkinInfoAction:(SEL)checkinInfoAction;

- (void)updateSignedUpCount:(NSInteger)signedUpCount
             checkedinCount:(NSInteger)checkedinCount;

@end
