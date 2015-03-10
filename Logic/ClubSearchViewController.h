//
//  ClubSearchViewController.h
//  iAlumni
//
//  Created by Adam on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWRootViewController.h"

@class Club;

@interface ClubSearchViewController : WXWRootViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    
    UITextField *_nameField;
    UITextField *_classField;
    
    NSMutableArray *_TableCellShowValArray;
    NSMutableArray *_TableCellSaveValArray;
 
    CGFloat _animatedDistance;
    
    NSMutableArray *classFliters;
}

@property (nonatomic,retain) NSMutableArray *_TableCellShowValArray;
@property (nonatomic,retain) NSMutableArray *_TableCellSaveValArray;
@property (nonatomic,retain) NSMutableArray *_SelCheckResult;

@property (retain, nonatomic) NSMutableArray *classFliters;

- (id)initWithMOC:(NSManagedObjectContext *)MOC group:(Club *)group;
- (void)clearFliter;
- (void)setTableCellVal:(int)index aShowVal:(NSString*)aShowVal aSaveVal:(NSString*)aSaveVal isFresh:(BOOL)isFresh;

@end
