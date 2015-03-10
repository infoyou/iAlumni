//
//  PeopleCell.h
//  iAlumni
//
//  Created by Adam on 12-7-31.
//
//

#import "ECImageConsumerCell.h"
#import "WXWLabel.h"
#import "ECClickableElementDelegate.h"

@class Alumni;
@class Member;

@interface PeopleCell : ECImageConsumerCell {
  
  Alumni  *_alumni;
  UIView *_imageBackgroundView;
  UIImageView *_photoImageView;
  UIButton *_authorImageButton;
  
	UIView *editorImageShadowView;
	UILabel *classLabel;
  UILabel *nameLabel;
  UILabel *companyLabel;
    
  id<ECClickableElementDelegate> _delegate;
}

@property (nonatomic, retain) Alumni *alumni;
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

- (void)drawCell:(Alumni *)alumni;

- (void)drawCellWithAuthorImageUrl:(NSString *)imageUrl
                    classGroupName:(NSString *)classGroupName
                        authorName:(NSString *)authorName;
@end
