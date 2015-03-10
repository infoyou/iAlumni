//
//  FeedbackViewController.h
//  iAlumni
//
//  Created by Adam on 12-2-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WXWRootViewController.h"
#import "Feedback.h"

@interface FeedbackViewController : WXWRootViewController <UITextViewDelegate, UIActionSheetDelegate, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UITextView *_textView;
    BOOL _textViewFirstResponder;
 
    NSMutableArray *_selCellArray;
    NSString *checkMsg;
    
    BOOL _autoLoaded;
    
    Feedback *_feedback;
    
    UIView *title0View;
    UIView *title1View;
    UIView *title2View;
}

@property (nonatomic, retain) Feedback *_feedback;

- (id)init:(NSManagedObjectContext*)MOC;

@end
