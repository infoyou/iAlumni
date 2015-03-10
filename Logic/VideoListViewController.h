//
//  VideoListViewController.h
//  iAlumni
//
//  Created by Adam on 13-1-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "ECClickableElementDelegate.h"
#import "ECFilterListDelegate.h"
#import "WXApi.h"

@class VideoToolView;

@interface VideoListViewController : BaseListViewController
{
  NSInteger _selectedVideoId;
  
  VideoToolView *videoToolView;
  
  NSString *requestParam;
  
  NSMutableArray *_TableCellShowValArray;
  NSMutableArray *_TableCellSaveValArray;
  
  BOOL _autoScrolled;
  
  CGFloat _keyboardHeight;
  
  BOOL _inSearching;
}

@property (nonatomic, retain) NSString *requestParam;

- (id)initWithMOC:(NSManagedObjectContext *)MOC selectedVideoId:(NSInteger)selectedVideoId;

@end
