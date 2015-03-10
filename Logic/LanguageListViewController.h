//
//  LanguageListViewController.h
//  iAlumni
//
//  Created by Adam on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWRootViewController.h"
#import "ECAppSettingDelegate.h"

@interface LanguageListViewController : WXWRootViewController <UITableViewDelegate, UITableViewDataSource, ECAppSettingDelegate> {
  BOOL isFirst;
  
  UIViewController *_parentVC;
  
  id _entrance;
  SEL _refreshAction;

}

- (id)initWithParentVC:(UIViewController *)parentVC
              entrance:(id)entrance
         refreshAction:(SEL)refreshAction;

@end
