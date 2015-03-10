//
//  ECItemUploaderDelegate.h
//  iAlumni
//
//  Created by Adam on 11-11-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ECItemUploaderDelegate <NSObject>

@required
- (void)afterUploadFinishAction:(WebItemType)actionType;

@end
