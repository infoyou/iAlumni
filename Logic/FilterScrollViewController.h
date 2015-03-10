//
//  FilterScrollViewController.h
//  ExpansionTableView
//
//  Created by JianYe on 13-2-18.
//  Copyright (c) 2013年 JianYe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HorizontalScrollArrangeDelegate;

@interface FilterScrollViewController : UIViewController {
  @private
  
  BOOL _forGroup;
}

@property (nonatomic, retain) IBOutlet UITableView *expansionTableView;

@property (nonatomic, assign) id<HorizontalScrollArrangeDelegate> delegate;

- (void)setListData:(NSArray *)listArray
         paramArray:(NSMutableArray *)paramArray
           parentVC:(UIViewController *)parentVC
           forGroup:(BOOL)forGroup;
@end

@protocol HorizontalScrollArrangeDelegate <NSObject>

@optional
- (void)arrangeViewsForKeywordsSearch;
- (void)arrangeViewsForCancelKeywordsSearch;
@end

