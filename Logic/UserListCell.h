//
//  UserListCell.h
//  CEIBS
//
//  Created by Adam on 10-10-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import "Alumni.h"
#import "WXWLabel.h"

@class WXWNumberBadge;

@interface UserListCell : BaseUITableViewCell <UIGestureRecognizerDelegate> {
  
  Alumni  *_alumni;
  
  UIImageView *chatImgView;
  UIButton *_chatImgBut;
  
	UIView *editorImageShadowView;
	UILabel *classLabel;
  UILabel *nameLabel;
  UILabel *companyLabel;
  
  WXWLabel *_tableInfoLabel;
  
  UILabel *shakePlaceLabel;
  UILabel *shakeThingLabel;
  WXWLabel *_distance;
  WXWLabel *_time;
  WXWLabel *_plat;
  
  WXWNumberBadge *_dmNewNumberBadge;
}

@property (nonatomic, retain) UIImageView       *chatImgView;
@property (nonatomic, retain) UIView			*editorImageShadowView;
@property (nonatomic, retain) UILabel			*companyLabel;
@property (nonatomic, retain) UILabel			*nameLabel;
@property (nonatomic, retain) UILabel			*classLabel;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawCell:(Alumni*)alumni userListType:(WebItemType)userListType;

@end
