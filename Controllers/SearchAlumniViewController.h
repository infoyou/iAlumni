//
//  SearchAlumniViewController.h
//  iAlumni
//
//  Created by Adam on 12-11-30.
//
//
#import "BaseListViewController.h"
#import <Foundation/Foundation.h>

@interface SearchAlumniViewController : BaseListViewController <UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate>{
  
  NSMutableArray *_DetailArray;
  NSMutableArray *_TableCellShowValArray;
  NSMutableArray *_TableCellSaveValArray;
  NSMutableArray *_SelCheckResult;
  
  UITextField *nameTextField;
  UITextField *companyTextField;
  UITextField *addressTextField;
  
  UIImageView *nameCancel;
  UIImageView *companyCancel;
  UIImageView *addressCancel;
  
  BOOL _needAdjustForiOS7;
  
  // send did finish method
  id _target;
  SEL _sendDidSuccessedAction;
  SEL _handleErrorAction;
  SEL _closeAction;
  long long _itemId;
  
  CGFloat _animatedDistance;
  UITextField *_textField;
  
  NSMutableArray *classFliters;
  
  BOOL _firstSessionRefresh;
}

@property(nonatomic,retain) NSMutableArray *_DetailArray;
@property(nonatomic,retain) NSMutableArray *_TableCellShowValArray;
@property(nonatomic,retain) NSMutableArray *_TableCellSaveValArray;
@property(nonatomic,retain) NSMutableArray *_SelCheckResult;
@property(nonatomic,retain) UITextField *_textField;

@property(nonatomic,retain) UITextField *nameTextField;
@property(nonatomic,retain) UITextField *companyTextField;
@property(nonatomic,retain) UITextField *addressTextField;
@property(nonatomic,retain) UIImageView *nameCancel;
@property(nonatomic,retain) UIImageView *companyCancel;
@property(nonatomic,retain) UIImageView *addressCancel;

@property (retain, nonatomic) NSMutableArray *classFliters;

- (id)initWithMOC:MOC needAdjustForiOS7:(BOOL)needAdjustForiOS7;
- (void)configureCell:(int)row aCell:(UITableViewCell *)cell;
- (void)setTableCellVal:(int)index aShowVal:(NSString*)aShowVal aSaveVal:(NSString*)aSaveVal isFresh:(BOOL)isFresh;
- (void)loadAlumniInfoIfNeeded;
- (void)clearFliter;

@end
