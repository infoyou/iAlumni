//
//  LogUploader.h
//  iAlumni
//
//  Created by Adam on 11-11-2.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalConstants.h"

@interface LogUploader : NSObject {
  
@private
  NSMutableArray *_beDeletedFiles;
  
  NSString *_currentHourTime;
  
  NSString *_deviceModel;
  
  NSInteger _uploadLoopCount;
}

- (void)triggerUpload;

@end
