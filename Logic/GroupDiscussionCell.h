//
//  GroupDiscussionCell.h
//  iAlumni
//
//  Created by Adam on 12-10-23.
//
//

#import "ECImageConsumerCell.h"
#import "ECClickableElementDelegate.h"

@class WXWLabel;
@class ECHandyImageBrowser;
@class Post;
@class TagsOmissionView;

@interface GroupDiscussionCell : ECImageConsumerCell {
  
@private
  
  Post *_post;
  
  UIButton *_authorImageButton;
  UIView *_authorImageBackgroundView;
  
  WXWLabel *_editorNameLabel;
  WXWLabel *_contentLabel;
  WXWLabel *_distanceLabel;
  
  UIView      *_postImageBackgroundView;
  UIButton    *_postImageButton;
  
  id<ECClickableElementDelegate> _delegate;
  
  ECHandyImageBrowser *_imageBrowser;
  
  NSString *_authorPicUrl;
  NSString *_imageUrl;
  NSString *_thumbnailUrl;
  
  // indicator
  UIImageView		*_locAttachedIndicator;
  WXWLabel         *_commentCountLabel;
  UIImageView     *_commentIcon;
  WXWLabel         *_likeCountLabel;
  UIImageView     *_likeIcon;
  WXWLabel         *_timeline;
  UIImageView     *_hotIndicaor;
  UILabel			*_smsLabel;
  
  TagsOmissionView *_tagsView;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawPost:(Post *)post MOC:(NSManagedObjectContext *)MOC;
- (void)initSmsArea;

@end
