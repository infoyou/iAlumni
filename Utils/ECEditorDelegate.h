//
//  ECEditorDelegate.h
//  iAlumni
//
//  Created by Adam on 11-11-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalConstants.h"

@protocol ECEditorDelegate <NSObject>

@optional
- (void)textChanged:(NSString *)text;
- (void)chooseTags;
- (void)choosePlace;
- (void)chooseSMS:(BOOL)isSelectedSms;

#pragma mark - share filter methods
- (void)chooseDistance;
- (void)chooseFavoriteType:(ItemFavoriteCategory)favoriteType;

@end
