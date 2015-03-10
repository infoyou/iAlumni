//
//  SearchAlumniCell.m
//  iAlumni
//
//  Created by Adam on 12-11-30.
//
//

#import "SearchAlumniCell.h"
#define FONT_SIZE               18
#define CONTENT_X               100
#define CONTENT_WIDTH           SCREEN_WIDTH/2
typedef enum {
    CLASS_TAG = 0,
    NAME_TAG,
    GENDER_TAG,
    COUNTRY_TAG,
    COMPANY_TAG,
    ADDRESS_TAG,
    INDUSTRY_TAG,
} ALUMNI_QUERY_VIEW_TAG;

@implementation SearchAlumniCell
@synthesize nameTextField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        
        mLabelName = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 100, 30)];

        
        mLabelValue = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_X*2+40, 14, CONTENT_WIDTH, 25.f)];

        
        nameTextField = [[[UITextField alloc] initWithFrame:CGRectMake(CONTENT_X, 15, CONTENT_WIDTH+50, 25)] autorelease];

        [self.contentView addSubview:nameTextField];
        
        companyTextField = [[[UITextField alloc] initWithFrame:CGRectMake(CONTENT_X, 5, CONTENT_WIDTH, 25)] autorelease];
        companyTextField.tag = COMPANY_TAG;
        companyTextField.backgroundColor = TRANSPARENT_COLOR;
        companyTextField.adjustsFontSizeToFitWidth = YES;
        companyTextField.textColor = [UIColor blackColor];
        companyTextField.keyboardType = UIKeyboardTypeDefault;
        companyTextField.borderStyle = UITextBorderStyleBezel;
        companyTextField.returnKeyType = UIReturnKeyDone;
        companyTextField.font = BOLD_FONT(14);
        companyTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        companyTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        companyTextField.clearsOnBeginEditing = NO;
        companyTextField.textAlignment = UITextAlignmentLeft;
//        self.companyTextField.delegate = self;
        companyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        [self.companyTextField addTarget:self
//                                  action:@selector(hideKeyboard:)
//                        forControlEvents:UIControlEventEditingDidEndOnExit];
        [companyTextField setEnabled:YES];
        [self.contentView addSubview:companyTextField];
        
        addressTextField = [[[UITextField alloc] initWithFrame:CGRectMake(CONTENT_X, 5, CONTENT_WIDTH, 25)] autorelease];
        addressTextField.tag = ADDRESS_TAG;
        addressTextField.backgroundColor = TRANSPARENT_COLOR;
        addressTextField.adjustsFontSizeToFitWidth = YES;
        addressTextField.textColor = [UIColor blackColor];
        addressTextField.keyboardType = UIKeyboardTypeDefault;
        addressTextField.borderStyle = UITextBorderStyleBezel;
        addressTextField.returnKeyType = UIReturnKeyDone;
        addressTextField.font = BOLD_FONT(14);
        addressTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        addressTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        addressTextField.clearsOnBeginEditing = NO;
        addressTextField.textAlignment = UITextAlignmentLeft;
//        self.addressTextField.delegate = self;
        addressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        [self.addressTextField addTarget:self
//                                  action:@selector(hideKeyboard:)
//                        forControlEvents:UIControlEventEditingDidEndOnExit];
        [addressTextField setEnabled:YES];
        [self.contentView addSubview:addressTextField];
    }
    
    return self;
}

- (void)dealloc {
    
    RELEASE_OBJ(mLabelName);
    RELEASE_OBJ(mLabelValue);
    RELEASE_OBJ(nameTextField);
    RELEASE_OBJ(companyTextField);
    RELEASE_OBJ(addressTextField);
    
    [super dealloc];
}

- (void)drawSearch:(NSString*)title value:(NSString*)value textDelegate:(id)del{
    
    NSLog(@"%@",title);
    NSString *msg = title;
    msg = [msg stringByAppendingString:@":"];
    mLabelName.font = BOLD_FONT(FONT_SIZE);
    mLabelName.text = msg;
    mLabelName.backgroundColor = TRANSPARENT_COLOR;
    mLabelName.textColor = [UIColor grayColor];
    [self.contentView addSubview:mLabelName];

    mLabelValue.font = FONT(14);
    mLabelValue.backgroundColor = TRANSPARENT_COLOR;
    mLabelValue.textColor = [UIColor grayColor];
    //        NSString* mName = value;
    mLabelValue.text = value;
    [self.contentView addSubview:mLabelValue];
    
}



@end

