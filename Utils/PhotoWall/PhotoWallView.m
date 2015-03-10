//
//  PhotoWall.m
//  PhotoDemo
//
//  Created by Harry on 12-12-6.
//  Copyright (c) 2012年 Harry. All rights reserved.
//

#import "PhotoWallView.h"
#import "PhotoElement.h"
#import "GlobalConstants.h"

@interface PhotoWallView() <HGPhotoDelegate>
{
    int photoCount;
}

@property (nonatomic, retain) UILabel *labelDescription;
@property (nonatomic, retain) NSMutableArray *arrayPositions;
@property (nonatomic, retain) NSMutableArray *arrayPhotos;
@property (nonatomic, assign) BOOL isEditModel;

@end

#define CELL_IMAGE_COUNT        3
#define PHOTO_W                 86.6f
#define PHOTO_H                 86.6f

#define kImagePositionx @"positionx"
#define kImagePositiony @"positiony"

@implementation PhotoWallView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0., 0., 320., 0.)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.arrayPhotos = [NSMutableArray arrayWithCapacity:1];
        
        self.labelDescription = [[[UILabel alloc] initWithFrame:CGRectMake(10., 0., 300., 18.)] autorelease];
        self.labelDescription.backgroundColor = [UIColor clearColor];
        self.labelDescription.textColor = [UIColor whiteColor];
        self.labelDescription.font = [UIFont systemFontOfSize:12.];
        self.labelDescription.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:self.labelDescription];
        
        self.labelDescription.hidden = YES;
        self.labelDescription.text = @"拖拽图片可以排列顺序, 点击添加照片.";
    }
    return self;
}

- (void)dealloc {
  
  self.labelDescription = nil;
  self.arrayPositions = nil;
  self.arrayPhotos = nil;
  
  [super dealloc];
}

- (void)setPhotos:(NSArray*)photos names:(NSArray*)names companys:(NSArray*)companys
{
    photoCount = [photos count];
    if (photoCount == 0) {
        return;
    }
    
    self.backgroundColor = [UIColor clearColor];
    
    self.arrayPositions = [NSMutableArray array];
    NSDictionary *positionDict = nil;
    
    for (int i=0; i<photoCount; i++) {
        switch (i%CELL_IMAGE_COUNT) {
            case 0:
                positionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"10", kImagePositionx, [NSString stringWithFormat:@"%f",(i/CELL_IMAGE_COUNT) * PHOTO_ONE_CELL_HEIGHT], kImagePositiony, nil];
                break;
                
            case 1:
                positionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"116.6", kImagePositionx, [NSString stringWithFormat:@"%f",(i/CELL_IMAGE_COUNT) * PHOTO_ONE_CELL_HEIGHT], kImagePositiony, nil];
                break;
                
            case 2:
                positionDict = [NSDictionary dictionaryWithObjectsAndKeys:@"223.4", kImagePositionx, [NSString stringWithFormat:@"%f",(i/CELL_IMAGE_COUNT) * PHOTO_ONE_CELL_HEIGHT], kImagePositiony, nil];
                break;
                                
            default:
                break;
        }
        
        [self.arrayPositions insertObject:positionDict atIndex:i];
        
    }
    
    [self.arrayPhotos removeAllObjects];

    for (int i=0; i<photoCount; i++) {
        NSDictionary *dictionaryTemp = [self.arrayPositions objectAtIndex:i];
        CGFloat originx = [[dictionaryTemp objectForKey:kImagePositionx] floatValue];
        CGFloat originy = [[dictionaryTemp objectForKey:kImagePositiony] floatValue];
        
        PhotoElement *photoTemp = [[PhotoElement alloc] initWithOrigin:CGPointMake(originx, originy)];
        photoTemp.delegate = self;
        [photoTemp setPhotoImageUrl:[photos objectAtIndex:i]];
        [photoTemp setUserNameValue:[names objectAtIndex:i]];
        [photoTemp setCompanyValue:[companys objectAtIndex:i]];
        [self addSubview:photoTemp];
        [self.arrayPhotos addObject:photoTemp];
    }
    
    NSDictionary *dictionaryTemp = [self.arrayPositions objectAtIndex:(photoCount-1)];
    CGFloat originx = [[dictionaryTemp objectForKey:kImagePositionx] floatValue];
    CGFloat originy = [[dictionaryTemp objectForKey:kImagePositiony] floatValue];
    PhotoElement *photoTemp = [[PhotoElement alloc] initWithOrigin:CGPointMake(originx, originy)];
    photoTemp.delegate = self;
    photoTemp.hidden = YES;
    [photoTemp setPhotoType:PhotoTypeAdd];
    [self.arrayPhotos addObject:photoTemp];
    [self addSubview:photoTemp];
    
    CGFloat frameHeight = -1;
    
    if (photoCount / CELL_IMAGE_COUNT > 0) {
        frameHeight = (photoCount / CELL_IMAGE_COUNT) * PHOTO_ONE_CELL_HEIGHT;
        if (photoCount % CELL_IMAGE_COUNT > 0) {
            frameHeight += PHOTO_ONE_CELL_HEIGHT;
        }
    } else {
        frameHeight = PHOTO_ONE_CELL_HEIGHT;
    }
    
    self.frame = CGRectMake(0., 0., 320., frameHeight);

}

- (void)setEditModel:(BOOL)canEdit
{
    self.isEditModel = canEdit;
    if (self.isEditModel) {
        PhotoElement *viewTemp = [self.arrayPhotos lastObject];
        viewTemp.hidden = NO;
        self.labelDescription.hidden = NO;
    } else {
        PhotoElement *viewTemp = [self.arrayPhotos lastObject];
        viewTemp.hidden = YES;
        self.labelDescription.hidden = YES;
    }
    
    NSUInteger count = [self.arrayPhotos count]-1;
    for (int i=0; i<count; i++) {
        PhotoElement *viewTemp = [self.arrayPhotos objectAtIndex:i];
        [viewTemp setEditModel:self.isEditModel];
    }
    [self reloadPhotos:NO];
}

- (void)addPhoto:(NSString*)string
{
    NSUInteger index = [self.arrayPhotos count] - 1;
    NSDictionary *dictionaryTemp = [self.arrayPositions objectAtIndex:index];
    CGFloat originx = [[dictionaryTemp objectForKey:kImagePositionx] floatValue];
    CGFloat originy = [[dictionaryTemp objectForKey:kImagePositiony] floatValue];
    
    PhotoElement *photoTemp = [[PhotoElement alloc] initWithOrigin:CGPointMake(originx, originy)];
    photoTemp.delegate = self;
    [photoTemp setPhotoImageUrl:string];
    
    [self.arrayPhotos insertObject:photoTemp atIndex:index];
    [self addSubview:photoTemp];
    [self reloadPhotos:YES];
}

- (void)deletePhotoByIndex:(NSUInteger)index
{
    if (index > [self.arrayPhotos count]) {
        return;
    }
    PhotoElement *photoTemp = [self.arrayPhotos objectAtIndex:index];
    [self.arrayPhotos removeObject:photoTemp];
    [photoTemp removeFromSuperview];
    [self reloadPhotos:YES];
}

#pragma mark - Photo

- (void)photoTaped:(PhotoElement*)photo
{
    NSUInteger type = [photo getPhotoType];
    if (type == PhotoTypeAdd) {
        if ([self.delegate respondsToSelector:@selector(photoWallAddAction)]) {
            [self.delegate photoWallAddAction];
        }
    } else if (type == PhotoTypePhoto) {
        NSUInteger index = [self.arrayPhotos indexOfObject:photo];
        if ([self.delegate respondsToSelector:@selector(photoWallPhotoTaped:)]) {
            [self.delegate photoWallPhotoTaped:index];
        }
    }
}

- (void)photoMoveFinished:(PhotoElement*)photo
{
    CGPoint pointPhoto = CGPointMake(photo.frame.origin.x, photo.frame.origin.y);
    CGFloat space = -1;
    NSUInteger oldIndex = [self.arrayPhotos indexOfObject:photo];
    NSUInteger newIndex = -1;
    
    NSUInteger count = [self.arrayPhotos count] - 1;
    for (int i=0; i<count; i++) {
        NSDictionary *dictionaryTemp = [self.arrayPositions objectAtIndex:i];
        CGFloat originx = [[dictionaryTemp objectForKey:kImagePositionx] floatValue];
        CGFloat originy = [[dictionaryTemp objectForKey:kImagePositiony] floatValue];
        CGPoint pointTemp = CGPointMake(originx, originy);
        CGFloat spaceTemp = [self spaceToPoint:pointPhoto FromPoint:pointTemp];
        if (space < 0) {
            space = spaceTemp;
            newIndex = i;
        } else {
            if (spaceTemp < space) {
                space = spaceTemp;
                newIndex = i;
            }
        }
    }
    
    [self.arrayPhotos removeObject:photo];
    [self.arrayPhotos insertObject:photo atIndex:newIndex];
    
    [self reloadPhotos:NO];
    
    if ([self.delegate respondsToSelector:@selector(photoWallMovePhotoFromIndex:toIndex:)]) {
        [self.delegate photoWallMovePhotoFromIndex:oldIndex toIndex:newIndex];
    }
}

- (void)reloadPhotos:(BOOL)add
{
    NSUInteger count = -1;
    if (add) {
        count = [self.arrayPhotos count];
    } else {
        count = [self.arrayPhotos count] - 1;
    }
    for (int i=0; i<count; i++) {
        NSDictionary *dictionaryTemp = [self.arrayPositions objectAtIndex:i];
        CGFloat originx = [[dictionaryTemp objectForKey:kImagePositionx] floatValue];
        CGFloat originy = [[dictionaryTemp objectForKey:kImagePositiony] floatValue];
        
        PhotoElement *photoTemp = [self.arrayPhotos objectAtIndex:i];
        [photoTemp moveToPosition:CGPointMake(originx, originy)];
    }
    
    CGFloat frameHeight = -1;
    NSUInteger countPhoto = [self.arrayPhotos count];
    if (self.isEditModel) {
        if (countPhoto / CELL_IMAGE_COUNT > 0) {
            frameHeight = (countPhoto / CELL_IMAGE_COUNT) * PHOTO_ONE_CELL_HEIGHT + 1;
            if (countPhoto % CELL_IMAGE_COUNT > 0) {
                frameHeight += PHOTO_ONE_CELL_HEIGHT;
            }
        } else {
            frameHeight = PHOTO_ONE_CELL_HEIGHT;
        }
        self.frame = CGRectMake(0., 0., 320., frameHeight);

        self.labelDescription.frame = CGRectMake(self.labelDescription.frame.origin.x, frameHeight - 20., self.labelDescription.frame.size.width, self.labelDescription.frame.size.height);
    } else {
        if (countPhoto / CELL_IMAGE_COUNT > 0) {
            frameHeight = (countPhoto / CELL_IMAGE_COUNT) * PHOTO_ONE_CELL_HEIGHT;
            if (countPhoto % CELL_IMAGE_COUNT > 0) {
                frameHeight += PHOTO_ONE_CELL_HEIGHT;
            }
        } else {
            frameHeight = PHOTO_ONE_CELL_HEIGHT;
        }
    }
    self.frame = CGRectMake(0., 0., 320., frameHeight);
}

- (CGFloat)spaceToPoint:(CGPoint)point FromPoint:(CGPoint)otherPoint
{
    float x = point.x - otherPoint.x;
    float y = point.y - otherPoint.y;
    return sqrt(x * x + y * y);
}

@end
