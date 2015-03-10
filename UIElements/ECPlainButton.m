//
//  ECPlainButton.m
//  iAlumni
//
//  Created by Adam on 12-9-7.
//
//

#import "ECPlainButton.h"
#import <QuartzCore/QuartzCore.h>

#define HIGHLIGHT_KEYPATH @"highlighted"

@interface ECPlainButton()

@end

@implementation ECPlainButton

- (id)initPlainButtonWithFrame:(CGRect)frame
                        target:(id)target
                        action:(SEL)action
                         title:(NSString *)title
                         image:(UIImage*)image
                           hue:(CGFloat)hue
                    saturation:(CGFloat)saturation
                    brightness:(CGFloat)brightness
                   borderColor:(UIColor *)borderColor
                     titleFont:(UIFont *)titleFont
                    titleColor:(UIColor *)titleColor
              titleShadowColor:(UIColor *)titleShadowColor
                   roundedType:(ButtonRoundedType)roundedType
               imageEdgeInsert:(UIEdgeInsets)imageEdgeInsert
               titleEdgeInsert:(UIEdgeInsets)titleEdgeInsert {
  
  self = [super initWithFrame:frame];
  
  if (self) {
      
    _hue = hue;
    _saturation = saturation;
    _brightness = brightness;
    
    [self setTitle:title forState:UIControlStateNormal];
    self.titleLabel.font = titleFont;
    [self setTitleColor:titleColor forState:UIControlStateNormal];
    [self setTitleShadowColor:titleShadowColor forState:UIControlStateNormal];
    [self addTarget:target
             action:action
   forControlEvents:UIControlEventTouchUpInside];
    
      if (image) {
          self.titleEdgeInsets = titleEdgeInsert;
          
          [self setImage:image forState:UIControlStateNormal];
          self.imageEdgeInsets = imageEdgeInsert;
      }
      
    switch (roundedType) {
      case HAS_ROUNDED:
        self.layer.cornerRadius = 4.0f;
        break;
        
      case NO_ROUNDED:
        self.layer.cornerRadius = 0.0f;
        break;
        
      default:
        break;
    }
    
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = 1.0f;
    self.backgroundColor = COLOR_HSB(hue, saturation, brightness, 1.0f);
    
    [self addObserver:self
           forKeyPath:HIGHLIGHT_KEYPATH
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:nil];
    
  }
  
  return self;
}

- (void)dealloc {
  
  [self removeObserver:self forKeyPath:HIGHLIGHT_KEYPATH];
  
  [super dealloc];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  
  if ([keyPath isEqualToString:HIGHLIGHT_KEYPATH]) {
    
    NSNumber *new = change[@"new"];
    NSNumber *old = change[@"old"];
    
    if (old && ![new isEqualToNumber:old]) {

      // Highlight state has changed
      CGFloat fact = 1.0f;
      if ([self isHighlighted]) {
        fact -= 0.2f;
      }      
      self.backgroundColor = COLOR_HSB(_hue, _saturation, _brightness, fact);
    }
  }
}


@end
