//
//  EmailListViewController.m
//  iAlumni
//
//  Created by Adam on 12-11-5.
//
//

#import "EmailListViewController.h"
#import "VerticalLayoutItemInfoCell.h"
#import "UIUtils.h"

#define CELL_HEIGHT   44.0f

@interface EmailListViewController ()
@property (nonatomic, retain) NSArray *emailList;
@end

@implementation EmailListViewController

@synthesize emailList = _emailList;

#pragma mark - lifecycle methods
- (id)initWithEmails:(NSString *)emails {
  self = [super initNoNeedLoadBackendDataWithMOC:nil
                     holder:nil
           backToHomeAction:nil
      needRefreshHeaderView:NO
      needRefreshFooterView:NO
                 tableStyle:UITableViewStyleGrouped
                 needGoHome:NO];
  if (self) {
    
    if (emails && emails.length > 0) {
      self.emailList = [emails componentsSeparatedByString:EMAIL_SEPARATOR];
    }
    
  }
  return self;
}

- (void)dealloc {
  
  self.emailList = nil;
  
  
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  [_tableView reloadData];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - draw cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.emailList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < self.emailList.count - 1) {
    static NSString *noShadowCellIdentifier = @"noShadowCell";
    
    return [self drawNoShadowVerticalInfoCell:(self.emailList)[indexPath.row]
                                     subTitle:nil
                                      content:nil
                               cellIdentifier:noShadowCellIdentifier
                                    clickable:YES];
  } else {
    static NSString *shadowCellIdentifier = @"shadowCell";
    return [self drawShadowVerticalInfoCell:(self.emailList)[indexPath.row]
                                   subTitle:nil
                                    content:nil
                             cellIdentifier:shadowCellIdentifier
                                     height:CELL_HEIGHT - 1.0f
                                  clickable:YES];
  }
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  
  if ([MFMailComposeViewController canSendMail]) {
  
    MFMailComposeViewController *mailComposeVC = [[[MFMailComposeViewController alloc] init] autorelease];
    
    mailComposeVC.mailComposeDelegate = self;
    [mailComposeVC setToRecipients:@[(NSString *)(self.emailList)[indexPath.row]]];
    [self presentModalViewController:mailComposeVC animated:YES];
    
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCannotSendEmailMsg, nil)
                                  msgType:ERROR_TY
                       belowNavigationBar:YES];
  }
}

#pragma mark - MFMailComposeViewControllerDelegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
  switch (result)
	{
		case MFMailComposeResultCancelled:
			
			break;
		case MFMailComposeResultSaved:
			
			break;
		case MFMailComposeResultSent:
			
			break;
		case MFMailComposeResultFailed:
			
			break;
		default:
			
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


@end
