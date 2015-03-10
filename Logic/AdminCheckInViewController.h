//
//  AdminCheckInViewController.h
//  iAlumni
//
//  Created by Adam on 12-7-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWRootViewController.h"
#import "ECClickableElementDelegate.h"

@class Alumni;
@class Event;

@interface AdminCheckInViewController : WXWRootViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, ECClickableElementDelegate> {
    
    @private
    UITextField *_codeField;
    UITextField *_nameField;
    UITextField *_classField;
    
    BOOL _isCheckedStatus;
    
    Alumni  *_alumni;
    Event   *_event;
    NSMutableArray *_TableCellShowValArray;
    NSMutableArray *_TableCellSaveValArray;
    
    NSMutableArray *classFliters;
    
    NSInteger   type;
}

@property (nonatomic,retain) NSMutableArray *_SelCheckResult;

@property (nonatomic,retain) NSMutableArray *classFliters;
@property (nonatomic,assign) NSInteger type;

- (id)initWithMOC:(NSManagedObjectContext *)MOC event:(Event*)event;
- (void)clearFliter;
- (void)setTableCellVal:(int)index aShowVal:(NSString*)aShowVal aSaveVal:(NSString*)aSaveVal isFresh:(BOOL)isFresh;
- (void)openProfile:(NSString*)userId userType:(NSString*)userType;

@end
