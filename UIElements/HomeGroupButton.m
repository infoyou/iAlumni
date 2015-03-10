//
//  HomeGroupButton.m
//  iAlumni
//
//  Created by Adam on 12-8-4.
//
//

#import "HomeGroupButton.h"
#import <QuartzCore/QuartzCore.h>
#import "HomeGroup.h"
#import "AppManager.h"

#define BORDER_CORNER_RDU       4.0f
#define OVAL_CORNER_RDU         26.0f
#define INNER_AREA_CORNER_RDU   0.0f // because the rendering corner radius of inner area inconsistence with border corner radius, we make the inner area full, then the corner will be full with corresponding color
#define BORDER_WIDTH            1.0f

#define IMG_EDGE              UIEdgeInsetsMake(10.0, 0.0, 0.0, 0.0)
#define TITLE_EDGE            UIEdgeInsetsMake(32.0, -30.0, 0.0, 0.0)

@interface HomeGroupButton()
@property (nonatomic, copy) NSString *titleText;
@end

@implementation HomeGroupButton

@synthesize titleText = _titleText;
@synthesize itemGroup = _itemGroup;

- (void)setImageForGroup {
    NSString *imageName = self.itemGroup.imageUrl;
    self.imageEdgeInsets = UIEdgeInsetsMake(-10.0, 15.0, 0.0, 12.0);
    
    if (imageName) {
        [self setImage:[UIImage imageNamed:imageName]
              forState:UIControlStateNormal];
    } else {
        [_imageDisplayerDelegate registerImageUrl:self.itemGroup.imageUrl];
        [[WXWImageManager instance] fetchImage:self.itemGroup.imageUrl caller:self forceNew:NO];
    }
}

- (id)initWithFrame:(CGRect)frame
             target:(id)target
             action:(SEL)action
          colorType:(ButtonColorType)colorType
              title:(NSString *)title
         titleColor:(UIColor *)titleColor
   titleShadowColor:(UIColor *)titleShadowColor
          titleFont:(UIFont *)titleFont
    imageEdgeInsert:(UIEdgeInsets)imageEdgeInsert
    titleEdgeInsert:(UIEdgeInsets)titleEdgeInsert
          itemGroup:(HomeGroup *)itemGroup
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate {
    
    self = [super init];
    if (self) {
        
        self.itemGroup = itemGroup;
        
        _imageDisplayerDelegate = imageDisplayerDelegate;
        
        self.frame = frame;
        
        _colorType = colorType;
        
        [self addTarget:target
                 action:action
       forControlEvents:UIControlEventTouchUpInside];
        
        self.backgroundColor = TRANSPARENT_COLOR;
        
        [self setTitle:title forState:UIControlStateNormal];
        self.titleLabel.font = titleFont;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleText = title;
        
        if (titleColor) {
            self.titleLabel.textColor = titleColor;
        }
        [self setTitleColor:titleColor forState:UIControlStateNormal];
        [self setTitleShadowColor:titleShadowColor
                         forState:UIControlStateNormal];
        self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        if (!_hideBorder) {
            self.layer.borderWidth = BORDER_WIDTH;
            self.layer.masksToBounds = YES;
        } else {
            self.layer.borderWidth = 0.0f;
            self.layer.masksToBounds = NO;
        }
        
        self.layer.cornerRadius = BORDER_CORNER_RDU;
        
        self.titleEdgeInsets = titleEdgeInsert;
        self.imageEdgeInsets = imageEdgeInsert;
        self.contentMode = UIViewContentModeCenter;
        
        [self setImageForGroup];
        
    }
    return self;
}

- (void)dealloc {
    
    self.itemGroup = nil;
    self.titleText = nil;
    
    [[WXWImageManager instance] clearCallerFromCache:_itemGroup.imageUrl];
    
    [super dealloc];
}


#pragma mark - WXWImageFetcherDelegate methods
- (void)imageFetchStarted:(NSString *)url {
    
    [self setTitle:self.titleText forState:UIControlStateNormal];
}

- (void)imageFetchDone:(UIImage *)image url:(NSString *)url {
    
    if (nil == url || [url length] == 0) {
        return;
    }
    
    CATransition *imageFadein = [CATransition animation];
    imageFadein.duration = FADE_IN_DURATION;
    imageFadein.type = kCATransitionFade;
    
    [self.layer addAnimation:imageFadein forKey:nil];
    [self setTitle:self.titleText forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateNormal];
    
    self.imageEdgeInsets = IMG_EDGE;
    self.titleEdgeInsets = TITLE_EDGE;
}

- (void)imageFetchFromeCacheDone:(UIImage *)image url:(NSString *)url {
    [self imageFetchDone:image url:url];
}

- (void)imageFetchFailed:(NSError *)error url:(NSString *)url {
    [self setTitle:self.titleText forState:UIControlStateNormal];
}

#pragma mark - draw layout
- (void)drawLinearGradient:(CGContextRef)context
                      rect:(CGRect)rect
                startColor:(CGColorRef)startColor
                  endColor:(CGColorRef)endColor {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(id)startColor, (id)endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

- (void)drawGlossAndGradient:(CGContextRef)context
                        rect:(CGRect)rect
                  startColor:(CGColorRef)startColor
                    endColor:(CGColorRef)endColor {
    
    [self drawLinearGradient:context
                        rect:rect
                  startColor:startColor
                    endColor:endColor];
    
    CGColorRef glossColor1 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.35].CGColor;
    CGColorRef glossColor2 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1].CGColor;
    
    CGRect topHalf = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/2);
    
    [self drawLinearGradient:context
                        rect:topHalf
                  startColor:glossColor1
                    endColor:glossColor2];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat outerMargin = 0.0f;
    if (!_hideBorder) {
        outerMargin = 1.0f;
    }
    CGRect outerRect = CGRectInset(self.bounds, outerMargin, outerMargin);
    
    CGMutablePathRef path = CGPathCreateMutable();
    if (!_hideBorder) {
        
        CGPathMoveToPoint(path, NULL, CGRectGetMidX(outerRect), CGRectGetMinY(outerRect));
        CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), INNER_AREA_CORNER_RDU);
        
        CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), INNER_AREA_CORNER_RDU);
        
        CGPathAddArcToPoint(path, NULL, CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), INNER_AREA_CORNER_RDU);
        
        CGPathAddArcToPoint(path, NULL, CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), INNER_AREA_CORNER_RDU);
        
        CGPathCloseSubpath(path);
    }
    
    CGMutablePathRef outerPath = path;
    
    CGColorRef topColorRef;
    CGColorRef bottomColorRef;
    CGFloat actualBrightness = 1.0f;
    switch (_colorType) {
            
        case BLACK_BTN_COLOR_TY:
        {
            actualBrightness = 1.0f;
            if (self.state == UIControlStateHighlighted) {
                actualBrightness -= 0.20;
            }
            topColorRef = COLOR_HSB(240.0f, 7.0f, 6.0f, actualBrightness).CGColor;
            bottomColorRef = COLOR_HSB(206.0f, 12.0f, 24.0f, actualBrightness).CGColor;
            if (!_hideBorder) {
                self.layer.borderColor = LIGHT_GRAY_BTN_BORDER_COLOR.CGColor;
            }
            
            break;
        }
            
        case RED_BTN_COLOR_TY:
        {
            actualBrightness = 1.0f;
            if (self.state == UIControlStateHighlighted) {
                actualBrightness -= 0.20;
            }
            
            topColorRef = COLOR_HSB(360.0f, 100.0f, 78.0f, actualBrightness).CGColor;//COLOR(199, 0, 1).CGColor;
            bottomColorRef = COLOR_HSB(359.0f, 77.0f, 47.0f, actualBrightness).CGColor;//COLOR(119, 27, 28).CGColor;//
            if (!_hideBorder) {
                self.layer.borderColor = ORANGE_BTN_BORDER_COLOR.CGColor;
            }
            
            break;
        }
            
        case GRAY_BTN_COLOR_TY:
        {
            actualBrightness = 0.742f;
            if (self.state == UIControlStateHighlighted) {
                actualBrightness -= 0.20;
            }
            topColorRef = [UIColor colorWithHue:1 saturation:0 brightness:1.0*actualBrightness alpha:1.0].CGColor;
            bottomColorRef = [UIColor colorWithHue:0.8 saturation:0 brightness:0.8*actualBrightness alpha:1.0].CGColor;
            if (!_hideBorder) {
                self.layer.borderColor = GRAY_BTN_BORDER_COLOR.CGColor;
            }
            
            break;
        }
            
        case LIGHT_GRAY_BTN_COLOR_TY:
        {
            actualBrightness = 1.0f;
            if (self.state == UIControlStateHighlighted) {
                actualBrightness -= 0.20;
            }
            topColorRef = [UIColor colorWithHue:1 saturation:0 brightness:0.92*actualBrightness alpha:1.0].CGColor;
            bottomColorRef = [UIColor colorWithHue:0.667f saturation:0 brightness:0.731*actualBrightness alpha:1.0].CGColor;
            if (!_hideBorder) {
                self.layer.borderColor = LIGHT_GRAY_BTN_BORDER_COLOR.CGColor;
            }
            
            break;
        }
            
        case BLUE_BTN_COLOR_TY:
        {
            actualBrightness = 1.0f;
            if (self.state == UIControlStateHighlighted) {
                actualBrightness -= 0.20;
            }
            topColorRef = [UIColor colorWithHue:0.55f saturation:0.34f brightness:0.90*actualBrightness alpha:1.0].CGColor;
            bottomColorRef = [UIColor colorWithHue:0.58f saturation:0.59f brightness:0.81*actualBrightness alpha:1.0].CGColor;
            if (!_hideBorder) {
                self.layer.borderColor = BLUE_BTN_BORDER_COLOR.CGColor;
            }
            
            break;
        }
            
        case WHITE_BTN_COLOR_TY:
        {
            
            actualBrightness = 1.0f;
            if (self.state == UIControlStateHighlighted) {
                actualBrightness -= 0.20;
            }
            topColorRef = COLOR_HSB(0, 0, 100.0f, actualBrightness).CGColor;
            bottomColorRef = COLOR_HSB(231.0f, 3.0f, 94.0f, actualBrightness).CGColor;
            if (!_hideBorder) {
                self.layer.borderColor = COLOR(214, 214, 214).CGColor;
            }
            
            break;
        }
            
        default:
            topColorRef = [UIColor whiteColor].CGColor;
            bottomColorRef = [UIColor whiteColor].CGColor;
            break;
    }
    
    // Draw shadow
    if (self.state != UIControlStateHighlighted) {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, topColorRef);
        CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 3.0, COLOR_ALPHA(51, 51, 52, 0.5).CGColor);
        CGContextAddPath(context, outerPath);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
    }
    
    // Draw gradient for outer path
    CGContextSaveGState(context);
    
    if (!_hideBorder) {
        CGContextAddPath(context, outerPath);
        CGContextClip(context);
    }
    [self drawGlossAndGradient:context rect:outerRect startColor:topColorRef endColor:bottomColorRef];
    CGContextRestoreGState(context);
    
    CFRelease(outerPath);
}

#pragma mark - override touch methods to show highlight
- (void)hesitateUpdate {
    [self setNeedsDisplay];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self setNeedsDisplay];
    [self performSelector:@selector(hesitateUpdate) withObject:nil afterDelay:0.2];
}

@end
