//
//  Photo.h
//  PhotoDemo
//
//  Created by Harry on 12-12-6.
//  Copyright (c) 2012年 Harry. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoElement;

@protocol HGPhotoDelegate <NSObject>

@optional
- (void)photoTaped:(PhotoElement*)photo;
- (void)photoMoveFinished:(PhotoElement*)photo;

@end

typedef NS_ENUM(NSInteger, PhotoType) {
    PhotoTypePhoto  = 0, //Default
    PhotoTypeAdd = 1,
};

@interface PhotoElement : UIView

@property (nonatomic, retain) id<HGPhotoDelegate> delegate;

- (id)initWithOrigin:(CGPoint)origin;

- (void)setPhotoType:(PhotoType)type;
- (PhotoType)getPhotoType;
- (void)setPhotoImageUrl:(NSString*)photoUrl;
- (void)moveToPosition:(CGPoint)point;
- (void)setEditModel:(BOOL)edit;

- (void)setUserNameValue:(NSString*)userName;
- (void)setCompanyValue:(NSString*)companyName;

@end
