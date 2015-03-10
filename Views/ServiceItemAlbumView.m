//
//  ServiceItemAlbumView.m
//  ExpatCircle
//
//  Created by Adam on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ServiceItemAlbumView.h"
#import <QuartzCore/QuartzCore.h>
#import "TextConstants.h"
#import "ECGradientButton.h"
#import "CommonUtils.h"
#import "HttpUtils.h"
#import "ServiceItem.h"
#import "UIUtils.h"
#import "WXWLabel.h"
#import "ServiceItemPhotoWall.h"

#define BUTTON_WIDTH  100.0f//40.0f
#define BUTTON_HEIGHT 30.0f//40.0f

#define PHOTO_WALL_HEIGHT  82.0f

@implementation ServiceItemAlbumView

@synthesize addPhotoButton = _addPhotoButton;

#pragma mark - user actions
- (void)addPhoto:(id)sender {
  if (_clickableElementDelegate) {
    [_clickableElementDelegate addPhoto];
  }
}

#pragma mark - append photo
- (void)appendPhoto {
  [_photoWall appendPhoto];
}

#pragma mark - add arrow
- (void)addArrow {
  [_photoWall addArrow];
}

#pragma mark - lifecycle methods

- (void)addPhotoWall {
  
  if (nil == _photoWall) {
    _photoWall = [[[ServiceItemPhotoWall alloc] initWithFrame:CGRectMake(0, _wall_y, self.frame.size.width, 0)
                                                          MOC:_MOC 
                                                         item:_item
                                       imageDisplayerDelegate:_imageDisplayerDelegate 
                                     clickableElementDelegate:_clickableElementDelegate 
                              connectionTriggerHolderDelegate:_connectionTriggerHolderDelegate] autorelease];
    [self addSubview:_photoWall];
    
    [_photoWall setNeedsDisplay];
  }
}

- (void)enlargePhotoWall {
  _photoWall.frame = CGRectMake(_photoWall.frame.origin.x, 
                                _photoWall.frame.origin.y,
                                _photoWall.frame.size.width, PHOTO_WALL_HEIGHT);
  
  [_photoWall setNeedsDisplay];
}

- (void)initLabelAndButton {
  
  self.addPhotoButton = [[[ECGradientButton alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN, BUTTON_WIDTH, BUTTON_HEIGHT)
                                                               target:self
                                                               action:@selector(addPhoto:)
                                                            colorType:LIGHT_GRAY_BTN_COLOR_TY
                                                                title:LocaleStringForKey(NSAddPhotoTitle, nil)
                                                                image:[UIImage imageNamed:@"handyTakePhoto.png"] 
                                                           titleColor:LIGHT_GRAY_BTN_TITLE_COLOR
                                                     titleShadowColor:LIGHT_GRAY_BTN_TITLE_SHADOW_COLOR
                                                            titleFont:BOLD_FONT(11)
                                                          roundedType:HAS_ROUNDED
                                                      imageEdgeInsert:UIEdgeInsetsMake(0.0f, -3.0f, 0.0f, 0.0f)
                                                      titleEdgeInsert:UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 0.0f)] autorelease];
  [self addSubview:self.addPhotoButton];
  
  _wall_y = self.addPhotoButton.frame.origin.y + self.addPhotoButton.frame.size.height + MARGIN;
  
}

- (id)initWithFrame:(CGRect)frame 
               item:(ServiceItem *)item
                MOC:(NSManagedObjectContext *)MOC
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate 
clickableElementDelegate:(id<ECClickableElementDelegate>)clickableElementDelegate
connectionTriggerHolderDelegate:(id<WXWConnectionTriggerHolderDelegate>)connectionTriggerHolderDelegate {
  
  self = [super initWithFrame:frame];
  
  if (self) {
    _item = item;
    
    _MOC = MOC;
    
    _imageDisplayerDelegate = imageDisplayerDelegate;
    _clickableElementDelegate = clickableElementDelegate;
    _connectionTriggerHolderDelegate = connectionTriggerHolderDelegate;
    
    self.backgroundColor = TRANSPARENT_COLOR;
    
    [self initLabelAndButton];
    
  }
  return self;
}

- (void)dealloc {
  
  self.addPhotoButton = nil;
  
  [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  if (_item.photoCount.intValue <= 0) {    
    [UIUtils draw1PxStroke:context
                startPoint:CGPointMake(MARGIN, self.frame.size.height - 2)
                  endPoint:CGPointMake(self.frame.size.width - MARGIN, self.frame.size.height - 2)
                     color:SEPARATOR_LINE_COLOR.CGColor
              shadowOffset:CGSizeMake(0.0f, 1.0f)
               shadowColor:[UIColor whiteColor]];
  } else {
    CGContextClearRect(context, CGRectMake(MARGIN, self.frame.size.height - 2, self.frame.size.width - MARGIN  *2, 2.0f));
  }
  
  [UIUtils draw1PxStroke:context
              startPoint:CGPointMake(MARGIN, 0.0) 
                endPoint:CGPointMake(self.frame.size.width - MARGIN, 0.0f)
                   color:SEPARATOR_LINE_COLOR.CGColor
            shadowOffset:CGSizeMake(0.0f, 1.0f)
             shadowColor:[UIColor whiteColor]];
}

@end
