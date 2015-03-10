//
//  CoreTextMarkupParser.m
//  iAlumni
//
//  Created by Adam on 12-10-5.
//
//

#import "CoreTextMarkupParser.h"

/* Callbacks */
static void deallocCallback( void* ref ){
  [(id)ref release];
}
static CGFloat ascentCallback( void *ref ){
  return [(NSString*)((NSDictionary*)ref)[@"height"] floatValue];
}
static CGFloat descentCallback( void *ref ){
  return [(NSString*)((NSDictionary*)ref)[@"descent"] floatValue];
}
static CGFloat widthCallback( void* ref ){
  return [(NSString*)((NSDictionary*)ref)[@"width"] floatValue];
}


@implementation CoreTextMarkupParser

@synthesize font, fontSize, color, strokeColor, strokeWidth;
@synthesize images;

- (id)initWithLineBreakMode:(CTLineBreakMode)lineBreakMode {
  self = [super init];
  if (self) {
    self.font = @"ArialMT";
    self.fontSize = 15.0f;
    self.color = [UIColor blackColor];
    self.strokeColor = [UIColor whiteColor];
    self.strokeWidth = 0.0;
    self.images = [NSMutableArray array];
    
    _lineBreakMode = lineBreakMode;
  }
  return self;
}

- (void)setLineBreakMode:(NSMutableAttributedString *)attributedString {
  CTParagraphStyleSetting lineBreakMode;
  CTLineBreakMode lineBreak = _lineBreakMode;
  lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
  lineBreakMode.value = &lineBreak;
  lineBreakMode.valueSize = sizeof(CTLineBreakMode);
  
  /*
   CTParagraphStyleSetting lineSpacing;
   CGFloat spacing = 5.0f;
   lineSpacing.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
   lineSpacing.value = &spacing;
   lineSpacing.valueSize = sizeof(CGFloat);
   
   CTParagraphStyleSetting settings[] = {lineBreakMode, lineSpacing};
   CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 2);
   */
  
  CTParagraphStyleSetting settings[] = {lineBreakMode};
  CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 1);
  
  [attributedString addAttribute:(NSString *)kCTParagraphStyleAttributeName
                           value:(id)paragraphStyle
                           range:NSMakeRange(0, attributedString.length)];
  
  
  /******* only iOS 6 support shadow setting
   NSShadow *fontShadow = [[NSShadow alloc] init];
   fontShadow.shadowColor = [UIColor whiteColor];
   fontShadow.shadowOffset = CGSizeMake(1.0f, 1.0f);
   NSMutableDictionary *fontAttributes = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:fontShadow, NSShadowAttributeName, nil] autorelease];
   
   [aString addAttributes:fontAttributes range:NSMakeRange(0, aString.length)];
   RELEASE_OBJ(fontShadow);
   */
  
}

- (NSAttributedString*)attrStringFromMarkup:(NSString*)markup {
  NSMutableAttributedString* aString =
  [[[NSMutableAttributedString alloc] initWithString:NULL_PARAM_VALUE] autorelease]; //1
  
  NSRegularExpression* regex = [[NSRegularExpression alloc]
                                initWithPattern:@"(.*?)(<[^>]+>|\\Z)"
                                options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators
                                error:nil]; //2
  NSArray* chunks = [regex matchesInString:markup
                                   options:0
                                     range:NSMakeRange(0, [markup length])];
  [regex release];
  
  for (NSTextCheckingResult* b in chunks) {
    NSArray* parts = [[markup substringWithRange:b.range]
                      componentsSeparatedByString:@"<"]; //1
    
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.font,
                                             self.fontSize, NULL);
    
    //apply the current text style //2
    NSDictionary* attrs = @{(id)kCTForegroundColorAttributeName: (id)self.color.CGColor,
                           (id)kCTFontAttributeName: (id)fontRef,
                           (NSString *) kCTStrokeColorAttributeName: (id)self.strokeColor.CGColor,
                           (NSString *)kCTStrokeWidthAttributeName: (id)@(self.strokeWidth)};
    [aString appendAttributedString:[[[NSAttributedString alloc] initWithString:parts[0]
                                                                     attributes:attrs] autorelease]];
    
    CFRelease(fontRef);
    
    //handle new formatting tag //3
    if ([parts count]>1) {
      NSString* tag = (NSString*)parts[1];
      if ([tag hasPrefix:@"font"]) {
        //stroke color
        NSRegularExpression* scolorRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=strokeColor=\")\\w+" options:0 error:NULL] autorelease];
        [scolorRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
          if ([[tag substringWithRange:match.range] isEqualToString:@"none"]) {
            self.strokeWidth = 0.0;
          } else {
            self.strokeWidth = -3.0;
            SEL colorSel = NSSelectorFromString([NSString stringWithFormat: @"%@Color", [tag substringWithRange:match.range]]);
            self.strokeColor = [UIColor performSelector:colorSel];
          }
        }];
        
        //color
        /******* get color be [UIColor colorTypeColor], e.g., [UIColor blueColor]
         NSRegularExpression* colorRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=color=\")\\w+" options:0 error:NULL] autorelease];
         SEL colorSel = NSSelectorFromString([NSString stringWithFormat: @"%@Color", [tag substringWithRange:match.range]]);
         self.color = [UIColor performSelector:colorSel];
         */
        NSRegularExpression* colorRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=color=\")[^\"]+" options:0 error:NULL] autorelease];
        [colorRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
          
          NSString *colorValues = [tag substringWithRange:match.range];
          if (colorValues.length > 0) {
            NSArray *rgbValues = [colorValues componentsSeparatedByString:RGB_SEPARATOR];
            if (rgbValues.count == RGB_COMPONENT_COUNT) {
              NSInteger redValue = ((NSString *)rgbValues[0]).intValue;
              NSInteger greenValue = ((NSString *)rgbValues[1]).intValue;
              NSInteger blueValue = ((NSString *)rgbValues[2]).intValue;
              
              self.color = COLOR(redValue, greenValue, blueValue);
            }
          }
          
        }];
        
        // font size
        NSRegularExpression* fontSizeRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=size=\")\\w+" options:0 error:NULL] autorelease];
        [fontSizeRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
          self.fontSize = [tag substringWithRange:match.range].floatValue;
        }];
        
        //face
        NSRegularExpression* faceRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=face=\")[^\"]+" options:0 error:NULL] autorelease];
        [faceRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
          self.font = [tag substringWithRange:match.range];
        }];
      } //end of font parsing
      if ([tag hasPrefix:@"img"]) {
        
        __block NSNumber* width = @0;
        __block NSNumber* height = @0;
        __block NSString* fileName = NULL_PARAM_VALUE;
        
        //width
        NSRegularExpression* widthRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=width=\")[^\"]+" options:0 error:NULL] autorelease];
        [widthRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
          width = @([[tag substringWithRange: match.range] intValue]);
        }];
        
        //height
        NSRegularExpression* faceRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=height=\")[^\"]+" options:0 error:NULL] autorelease];
        [faceRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
          height = @([[tag substringWithRange:match.range] intValue]);
        }];
        
        //image
        NSRegularExpression* srcRegex = [[[NSRegularExpression alloc] initWithPattern:@"(?<=src=\")[^\"]+" options:0 error:NULL] autorelease];
        [srcRegex enumerateMatchesInString:tag options:0 range:NSMakeRange(0, [tag length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
          fileName = [tag substringWithRange: match.range];
        }];
        
        //add the image for drawing
        [self.images addObject:
         @{@"width": width,
          @"height": height,
          @"fileName": fileName,
          @"location": [NSNumber numberWithInt: [aString length]]}
         ];
        
        //render empty space for drawing the image in the text //1
        CTRunDelegateCallbacks callbacks;
        callbacks.version = kCTRunDelegateVersion1;
        callbacks.getAscent = ascentCallback;
        callbacks.getDescent = descentCallback;
        callbacks.getWidth = widthCallback;
        callbacks.dealloc = deallocCallback;
        
        NSDictionary* imgAttr = [@{@"width": width,
                                  @"height": height} retain];
        
        CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, imgAttr); //3
        NSDictionary *attrDictionaryDelegate = @{(NSString*)kCTRunDelegateAttributeName: (id)delegate};
        
        //add a space to the text so that it can call the delegate
        [aString appendAttributedString:[[[NSAttributedString alloc] initWithString:@" " attributes:attrDictionaryDelegate] autorelease]];
      }
    }
  }
  
  
  [self setLineBreakMode:aString];
  
  return (NSAttributedString*)aString;
}

-(void)dealloc
{
  self.font = nil;
  self.color = nil;
  self.strokeColor = nil;
  self.images = nil;
  
  [super dealloc];
}

@end
