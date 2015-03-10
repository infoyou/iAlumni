//
//  AlbumListViewController.h
//  ExpatCircle
//
//  Created by Adam on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class ServiceItem;

@interface AlbumListViewController : BaseListViewController <ECClickableElementDelegate> {
  @private
  long long _itemId;
  
  NSInteger _rowCount;
  
  WebItemType _contentType;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
           itemId:(long long)itemId
      contentType:(NSInteger)contentType;

@end
