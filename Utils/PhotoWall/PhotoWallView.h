//
//  PhotoWallView.h
//  PhotoDemo
//
//  Created by Harry on 12-12-6.
//  Copyright (c) 2012年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoWallDelegate <NSObject>

- (void)photoWallPhotoTaped:(NSUInteger)index;
- (void)photoWallMovePhotoFromIndex:(NSInteger)index toIndex:(NSInteger)newIndex;
- (void)photoWallAddAction;
- (void)photoWallAddFinish;
- (void)photoWallDeleteFinish;

@end

@interface PhotoWallView : UIView

@property (assign) id<PhotoWallDelegate> delegate;

- (void)setPhotos:(NSArray*)photos names:(NSArray*)names companys:(NSArray*)companys;
- (void)setEditModel:(BOOL)canEdit;
- (void)addPhoto:(NSString*)string;
- (void)deletePhotoByIndex:(NSUInteger)index;
- (void)reloadPhotos:(BOOL)add;

@end
