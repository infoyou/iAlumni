//
//  Photo.m
//  PhotoDemo
//
//  Created by Harry on 12-12-6.
//  Copyright (c) 2012年 Harry. All rights reserved.
//

#import "PhotoElement.h"
#import "ECAsyncConnectorFacade.h"
#import <QuartzCore/QuartzCore.h>
#import "WXWLabel.h"
#import "UIImage-Extensions.h"
#import "WXWConnectorDelegate.h"

@interface PhotoElement() <UIGestureRecognizerDelegate, WXWConnectorDelegate>

@property (nonatomic, retain) UIView *viewMask;
@property (nonatomic, retain) UIImageView *viewPhoto;
@property (nonatomic, retain) UIImageView *nameBGView;
@property (nonatomic, retain) WXWLabel *userNameLabel;
@property (nonatomic, retain) UIView *companyBGView;
@property (nonatomic, retain) WXWLabel *companyNameLabel;
@property (nonatomic, copy) NSString *photoUrl;
@property (nonatomic, assign) CGPoint pointOrigin;
@property (nonatomic, assign) BOOL editModel;

@property (nonatomic, assign) PhotoType type;

@end

#define PHOTO_Y         11.f
#define PHOTO_W         86.6f
#define PHOTO_H         86.6f

#define PHOTO_NAME_W    86.6f
#define PHOTO_NAME_H    14.68f
#define PHOTO_NAME_X    (PHOTO_Y + PHOTO_H) - PHOTO_NAME_H

#define COMPANY_NAME_H  15.f

@implementation PhotoElement

- (id)initWithOrigin:(CGPoint)origin
{
    self = [super initWithFrame:CGRectMake(origin.x, origin.y, PHOTO_ONE_CELL_HEIGHT, PHOTO_ONE_CELL_HEIGHT)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // Image
        self.viewPhoto = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        self.viewPhoto.layer.cornerRadius = 12;
        self.viewPhoto.frame = CGRectMake(0, PHOTO_Y, PHOTO_W, PHOTO_H);
        self.viewPhoto.layer.masksToBounds = YES;
        self.viewPhoto.userInteractionEnabled = YES;
        
        self.viewMask = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.viewMask.alpha = 0.6;
        self.viewMask.backgroundColor = [UIColor blackColor];
        self.viewMask.layer.cornerRadius = 11;
        self.viewMask.layer.masksToBounds = YES;
        self.viewMask.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
        
        [self addSubview:self.viewPhoto];
        [self addSubview:self.viewMask];
        [self addGestureRecognizer:tapRecognizer];
        
        // Name BG
        self.nameBGView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        self.nameBGView.image = [UIImage imageNamed:@"photoName.png"];
        self.nameBGView.frame = CGRectMake(0, PHOTO_NAME_X, PHOTO_NAME_W, PHOTO_NAME_H);
        self.nameBGView.layer.masksToBounds = YES;

        [self addSubview:self.nameBGView];
        
        // Name text
        self.userNameLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(10, 0.f, PHOTO_NAME_W-20, PHOTO_NAME_H)
                                                      textColor:[UIColor whiteColor]
                                                    shadowColor:TRANSPARENT_COLOR] autorelease];
        self.userNameLabel.font = BOLD_FONT(11);
        self.userNameLabel.numberOfLines = 1;
        self.userNameLabel.textAlignment = NSTextAlignmentLeft;
        [self.nameBGView addSubview:self.userNameLabel];
        
        // Company text
        self.companyBGView = [[[UIView alloc] initWithFrame:CGRectMake(0, PHOTO_ONE_CELL_HEIGHT - COMPANY_NAME_H, PHOTO_NAME_W, COMPANY_NAME_H)] autorelease];
        [self.companyBGView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]]];
        [self addSubview:self.companyBGView];
        
        self.companyNameLabel = [[[WXWLabel alloc] initWithFrame:CGRectMake(0, 0, PHOTO_NAME_W, COMPANY_NAME_H)
                                                    textColor:[UIColor blackColor]
                                                  shadowColor:TRANSPARENT_COLOR] autorelease];
        self.companyNameLabel.font = FONT(9);
        self.companyNameLabel.numberOfLines = 1;
        self.companyNameLabel.textAlignment = NSTextAlignmentLeft;
        self.companyNameLabel.text = NULL_PARAM_VALUE;
        [self.companyBGView addSubview:self.companyNameLabel];
        
        self.editModel = NO;
        self.viewMask.hidden = YES;
    }
    return self;
}

- (void)dealloc {
  
  self.viewMask = nil;
  self.viewPhoto = nil;
  self.nameBGView = nil;
  self.userNameLabel = nil;
  self.companyBGView = nil;
  self.companyNameLabel = nil;
  self.photoUrl = nil;

  
  [super dealloc];
}

- (void)setPhotoType:(PhotoType)type
{
    self.type = type;
    if (type == PhotoTypeAdd) {
        self.viewPhoto.image = [UIImage imageNamed:@"addPhoto"];
    }
}

- (PhotoType)getPhotoType
{
    return self.type;
}

- (void)setPhotoImageUrl:(NSString*)photoUrl
{
    [self drawImage:photoUrl];
}

- (void)setUserNameValue:(NSString*)userName
{
    [self.userNameLabel setText:userName];
}

- (void)setCompanyValue:(NSString*)companyName
{
    [self.companyNameLabel setText:companyName];
}

- (void)moveToPosition:(CGPoint)point
{
    if (self.type == PhotoTypePhoto) {
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
        } completion:nil];
    } else {
        self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
    }
}

- (void)setEditModel:(BOOL)edit
{
    if (self.type == PhotoTypePhoto) {
        if (edit) {
            UILongPressGestureRecognizer *longPressreRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            longPressreRecognizer.delegate = self;
            [self addGestureRecognizer:longPressreRecognizer];
        } else {
            for (UIGestureRecognizer *recognizer in [self gestureRecognizers]) {
                if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                    [self removeGestureRecognizer:recognizer];
                    break;
                }
            }
        }
    }
}

#pragma mark - UIGestureRecognizer

- (void)tapPress:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(photoTaped:)]) {
        [self.delegate photoTaped:self];
    }
}

- (void)handleLongPress:(id)sender
{
    UILongPressGestureRecognizer *recognizer = sender;
    CGPoint point = [recognizer locationInView:self];
    
    CGFloat diffx = 0.;
    CGFloat diffy = 0.;
    
    if (UIGestureRecognizerStateBegan == recognizer.state) {
        self.viewMask.hidden = NO;
        self.pointOrigin = point;
        [self.superview bringSubviewToFront:self];
    } else if (UIGestureRecognizerStateEnded == recognizer.state) {
        self.viewMask.hidden = YES;
        if ([self.delegate respondsToSelector:@selector(photoMoveFinished:)]) {
            [self.delegate photoMoveFinished:self];
        }
    } else {
        diffx = point.x - self.pointOrigin.x;
        diffy = point.y - self.pointOrigin.y;
    }
    
    CGFloat originx = self.frame.origin.x +diffx;
    CGFloat originy = self.frame.origin.y +diffy;
    
    self.frame = CGRectMake(originx, originy, self.frame.size.width, self.frame.size.height);
}

- (void)drawImage:(NSString *)imageUrl
{
    UIImage *image = nil;
    if (imageUrl && [imageUrl length] > 0 ) {
        self.photoUrl = imageUrl;
        
        image = [[WXWImageManager instance].imageCache getImage:self.photoUrl];
        if (!image) {
            ECAsyncConnectorFacade *connFacade = [[[ECAsyncConnectorFacade alloc] initWithDelegate:self
                                                                            interactionContentType:IMAGE_TY] autorelease];
            [connFacade fetchGets:self.photoUrl];
        }
    } else {
        image = [[UIImage imageNamed:@"photoWallIcon.png"] imageByScalingToSize:CGSizeMake(PHOTO_W, PHOTO_H)];
    }
    
    if (image) {
        self.viewPhoto.image = [WXWCommonUtils cutPartImage:image
                                                                   width:self.viewPhoto.frame.size.width
                                                                  height:self.viewPhoto.frame.size.height];
    }
}

#pragma mark - ECConnectorDelegate methods
- (void)connectStarted:(NSString *)url
           contentType:(NSInteger)contentType
{
    self.viewPhoto.image = [UIImage imageNamed:@"photoWallIcon.png"];
}

- (void)connectDone:(NSData *)result url:(NSString *)url contentType:(NSInteger)contentType {
    if (url && url.length > 0) {
        UIImage *image = [UIImage imageWithData:result];
        if (image) {
            [[WXWImageManager instance].imageCache saveImageIntoCache:url image:image];
            
        }
        
        if ([url isEqualToString:self.photoUrl]) {
            self.viewPhoto.image = [WXWCommonUtils cutPartImage:image
                                                          width:self.viewPhoto.frame.size.width
                                                         height:self.viewPhoto.frame.size.height];;
        }
    }
}

- (void)connectCancelled:(NSString *)url
             contentType:(NSInteger)contentType {
    
}

- (void)connectFailed:(NSError *)error
                  url:(NSString *)url
          contentType:(NSInteger)contentType {
    
}

@end
