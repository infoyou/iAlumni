//
//  CoreTextMarkupParser.h
//  iAlumni
//
//  Created by Adam on 12-10-5.
//
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "GlobalConstants.h"

@interface CoreTextMarkupParser : NSObject {
  
  NSString* font;
  CGFloat fontSize;
  UIColor* color;
  UIColor* strokeColor;
  float strokeWidth;
  
  CTLineBreakMode _lineBreakMode;
  
  NSMutableArray* images;
}

@property (retain, nonatomic) NSString* font;
@property (assign, nonatomic) CGFloat fontSize;
@property (retain, nonatomic) UIColor* color;
@property (retain, nonatomic) UIColor* strokeColor;
@property (assign, readwrite) float strokeWidth;

@property (retain, nonatomic) NSMutableArray* images;

- (id)initWithLineBreakMode:(CTLineBreakMode)lineBreakMode;

- (NSAttributedString*)attrStringFromMarkup:(NSString*)html;

@end