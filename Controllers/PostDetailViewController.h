//
//  PostDetailViewController.h
//  iAlumni
//
//  Created by Adam on 12-4-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECItemUploaderDelegate.h"
#import "ECClickableElementDelegate.h"
#import "WXWConnectionTriggerHolderDelegate.h"
#import "ECPhotoPickerOverlayDelegate.h"
#import "ECPhotoPickerDelegate.h"
#import "WXApi.h"

@class Post;
@class ItemListSectionView;
@class ECAsyncConnectorFacade;
@class NoticeableCommentComposerView;
@class ECPhotoPickerOverlayViewController;

@interface PostDetailViewController : BaseListViewController <ECItemUploaderDelegate, ECClickableElementDelegate, UIActionSheetDelegate, WXWConnectionTriggerHolderDelegate, ECPhotoPickerDelegate, UIImagePickerControllerDelegate, ECPhotoPickerOverlayDelegate, WXApiDelegate, UIAlertViewDelegate> {
    
@private
    Post *_post;
    
    PostType _postType;
    
    ItemListSectionView *_sectionView;
    
    NoticeableCommentComposerView *_commentComposerView;
    
    CGFloat _noCommentComposerTableHeight;
    
    long long _beDeletedCommentId;
    
    BOOL _loadingComments;
    
    NSString *_lastSectionTitle;
    
    CGFloat _textContentHeight;
    BOOL _textContentLoaded;
    
    BOOL _scrollDirectoinType;
    
    CGFloat _scrollPreviousValue;
    
    // as view will be modified if user select photo from album, 
    // we need a var to store the height of view visible area
    CGFloat _visibleViewHeight;
    
    // image stuff
    NSInteger _actionSheetOwnerType;
    
    UIImage *_selectedPhoto;
    
    UIImagePickerControllerSourceType _photoSourceType;
    
    ECPhotoPickerOverlayViewController *_pickerOverlayVC;
    
    BOOL _needMoveDown20px;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction 
             post:(Post *)post
         postType:(PostType)postType;

- (void)openProfile:(NSString*)userId userType:(NSString*)userType;
- (void)showImagePicker;
- (void)addOrRemovePhoto;

@end
