//
//  UserDetailCell.h
//  CEIBS
//
//  Created by Adam on 11-2-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UserDetailCell : UITableViewCell {
	UILabel		*content;
	UILabel		*tips;
    UILabel     *actionName;
    UIButton    *button;
}

//@property (nonatomic, retain) UILabel	*content;
@property (nonatomic, retain) UILabel	*tips;
@property (nonatomic, retain) UIButton  *button;
@property (nonatomic, retain) UILabel   *content;

- (void)setContent:(NSString *)text breakLine:(BOOL)breakLine;
- (void)setButtonValues:(id)target action:(SEL)action imageName:(NSString *)imageName title:(NSString *)title contentType:(NSString *)contentType tipsText:(NSString *)tipsText actionNameText:(NSString *)actionNameText;

- (CGRect)getContentFrame;

@end
