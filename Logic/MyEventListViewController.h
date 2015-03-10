//
//  MyEventListViewController.h
//  iAlumni
//
//  Created by Adam on 11-10-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseListViewController.h"
#import "PlainTabView.h"


@interface MyEventListViewController : BaseListViewController <TapSwitchDelegate> {
    
@private
    BOOL _isPop;
    
    PlainTabView *_tabSwitchView;
        
    NSString *_hostTypeValue;
    NSString *_hostSubTypeValue;
    NSString *_cityId;
    
    NSInteger _eventCategory;
    
    CGRect _originalTableViewFrame;
    
    BOOL _tableViewDisplayed;
    
    BOOL _keepEventsInMOC;
    
    // if user switch the tab during table scrolling, the footer view of short list maybe
    // display "loading...", we need reset it after scrolling stop after user switch
    BOOL _userJustSwitched;
    
    WXWRootViewController *_parentVC;
}

@property (nonatomic, copy) NSString *_hostTypeValue;
@property (nonatomic, copy) NSString *_hostSubTypeValue;
@property (nonatomic, copy) NSString *cityId;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         parentVC:(WXWRootViewController *)parentVC
         tabIndex:(int)tabIndex;

- (void)clearFliter;

@end
