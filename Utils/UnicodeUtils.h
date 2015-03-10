//
//  UnicodeUtils.h
//  iAlumni
//
//  Created by Adam on 11-12-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UnicodeUtils : NSObject {
  
}

+ (char)pinyinFirstLetter:(NSUInteger)hanzi;

+ (NSString *)Chinese_To_Hex:(NSString *)ChineseStr;

@end

