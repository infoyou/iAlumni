//
//  PostListCell.h
//  iAlumni
//
//  Created by Adam on 11-11-28.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import <CoreData/CoreData.h>
#import "GlobalConstants.h"

@class WXWLabel;
@class ECHandyImageBrowser;
@class Post;

@interface PostListCell : BaseUITableViewCell {
    
    Post *_post;
    
    ClubViewType _showType;
    
@private
    UIButton *_authorImageButton;
    UIView *_authorImageBackgroundView;
    
    WXWLabel *_editorNameLabel;
	WXWLabel *_contentLabel;
    
    UIView *_postImageBackgroundView;
    UIButton *_postImageButton;
    
    id<ECClickableElementDelegate> _delegate;
    
    ECHandyImageBrowser *_imageBrowser;
    
    UIImage         *_postImage;
    
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
}

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
imageClickableDelegate:(id<ECClickableElementDelegate>)imageClickableDelegate
           showType:(ClubViewType)showType
                MOC:(NSManagedObjectContext *)MOC;

- (void)drawPost:(Post *)post;
- (void)initSmsArea;

@end
