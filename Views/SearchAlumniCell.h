//
//  SearchAlumniCell.h
//  iAlumni
//
//  Created by Adam on 12-11-30.
//
//
#import "BaseUITableViewCell.h"
#import <Foundation/Foundation.h>

@interface SearchAlumniCell : BaseUITableViewCell<UITextFieldDelegate>{
    
    UILabel *mLabelName;
    UILabel *mLabelValue;
    UITextField *nameTextField;
    UITextField *companyTextField;
    UITextField *addressTextField;
    
}

@property(nonatomic,retain) UITextField *nameTextField;

- (void)drawSearch:(NSString*)title value:(NSString*)value textDelegate:(id)del;

@end
