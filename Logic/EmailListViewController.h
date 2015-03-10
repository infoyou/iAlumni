//
//  EmailListViewController.h
//  iAlumni
//
//  Created by Adam on 12-11-5.
//
//

#import "BaseListViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GlobalConstants.h"

@interface EmailListViewController : BaseListViewController <MFMailComposeViewControllerDelegate> {
  @private
  NSArray *_emailList;
}

- (id)initWithEmails:(NSString *)emails;

@end
