//
//  CouponDetailViewController.m
//  ExpatCircle
//
//  Created by Adam on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CouponDetailViewController.h"
#import "CouponItem.h"
#import "CouponInfoHeaderView.h"
#import "ECImageBrowseViewController.h"
#import "TextConstants.h"
#import "CommonUtils.h"
#import "WXWNavigationController.h"
#import "ECGradientButton.h"
#import "PhoneNumber.h"
#import "ServiceItem.h"
#import "UIUtils.h"
#import "AppManager.h"
#import "VerticalLayoutItemInfoCell.h"
#import "CouponPriceCell.h"
#import "WXWLabel.h"

enum {
  SHARE_AS_TY,
  CALL_AS_TY,
};

enum {
  PRICE_CELL,
  DESC_CELL,
  WEBSITE_CELL,
};

#define NO_SOURCE_FOOTER_HEIGHT   80.0f

#define IMAGE_AREA_HEIGHT  220.0f

#define DISCLAIM_BUTTON_WIDTH  150.0f
#define DISCLAIM_BUTTON_HEIGHT 20.0f

#define DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH    266.0f
#define DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH  280.0f

#define MAIL_BODY       @"<html><body marginwidth=\"0\" marginheight=\"0\" leftmargin=\"0\" topmargin=\"0\" style=\"font-family:ArialMT;font-size:15px;word-wrap:break-word;\"><p>%@: %@</p><p>%@: <a href=\"http://maps.google.com/maps?q=%@,%@&hl=en&sll=37.0625,-95.677068&sspn=40.460237,78.662109&t=m&z=17\">%@</a></p><p>%@: <a href=\"tel:%@\">%@</a></p><br /><img src=\"%@\" alt=\"\" /><p>------<br />%@<br />%@<br />%@</p></body></html>"

@interface CouponDetailViewController ()

@end

@implementation CouponDetailViewController

#pragma mark - user action
- (void)call:(id)sender {
  _actionOwnerType = CALL_AS_TY;
  
  UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSCallThisNumberTitle, nil)
                                                      delegate:self
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil] autorelease];
  for (PhoneNumber *phoneNumber in _item.serviceItem.phoneNumbers) {
    [sheet addButtonWithTitle:phoneNumber.desc];
  }
  
  [sheet addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
  [sheet showInView:self.view];
}

- (void)share:(id)sender {
  _actionOwnerType = SHARE_AS_TY;
  
  UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:LocaleStringForKey(NSShareToFriendTitle, nil)
                                                      delegate:self
                                             cancelButtonTitle:nil
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil] autorelease];
  [sheet addButtonWithTitle:LocaleStringForKey(NSSMSTitle, nil)];
  [sheet addButtonWithTitle:LocaleStringForKey(NSEmailTitle, nil)];
  [sheet addButtonWithTitle:LocaleStringForKey(NSCancelTitle, nil)];
  sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
  [sheet showInView:self.view];
}

- (void)shareBySMS {
  MFMessageComposeViewController *smsComposeVC = [[[MFMessageComposeViewController alloc] init] autorelease];
  if ([MFMessageComposeViewController canSendText]) {
    
    smsComposeVC.body = [NSString stringWithFormat:@"%@, %@, %@: %@ [iAlumni]", 
                         _item.name, 
                         _item.desc, 
                         LocaleStringForKey(NSPhoneTitle, nil),
                         _item.serviceItem.phoneNumber];
    smsComposeVC.messageComposeDelegate = self;
    [self presentModalViewController:smsComposeVC animated:YES];
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCannotSendSMSMsg, nil)
                                  msgType:ERROR_TY 
                       belowNavigationBar:YES];
  }
}

- (void)shareByEmail {
    
  NSString *body = [NSString stringWithFormat:MAIL_BODY,
                    LocaleStringForKey(NSIntroTitle, nil), _item.desc,
                    LocaleStringForKey(NSAddressTitle, nil),
                    _item.serviceItem.latitude,
                    _item.serviceItem.longitude,
                    _item.serviceItem.address,
                    LocaleStringForKey(NSPhoneTitle, nil),
                    _item.serviceItem.phoneNumber, _item.serviceItem.phoneNumber, 
                    _item.imageUrl,
                    LocaleStringForKey(NSSentFromExpatCircleAppTitle, nil), APP_STORE_URL,
                    [AppManager instance].host];
  
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *mailComposeVC = [[[MFMailComposeViewController alloc] init] autorelease];
    
    mailComposeVC.mailComposeDelegate = self;
    [mailComposeVC setSubject:[NSString stringWithFormat:@"%@: %@", 
                               LocaleStringForKey(NSShareTitle, nil), _item.name]];
    
    [mailComposeVC setMessageBody:body isHTML:YES];
    
    [self presentModalViewController:mailComposeVC animated:YES];
    
  } else {
    [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSCannotSendEmailMsg, nil)
                                  msgType:ERROR_TY 
                       belowNavigationBar:YES];
  }
}

- (void)openDisclaimer:(id)sender {
  NSString *url = [CommonUtils assembleUrl:@"?action=disclaimer"];
  
  [CommonUtils openWebView:self.navigationController
                     title:LocaleStringForKey(NSDisclaimersTitle, nil)
                       url:url
           needCloseButton:YES
            needNavigation:NO
            needHomeButton:NO];
}

#pragma mark - lifecycle methods
- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder 
 backToHomeAction:(SEL)backToHomeAction 
       couponItem:(CouponItem *)couponItem {
  self = [super initNoNeedLoadBackendDataWithMOC:MOC
                     holder:holder
           backToHomeAction:backToHomeAction
      needRefreshHeaderView:NO 
      needRefreshFooterView:NO 
                 tableStyle:UITableViewStyleGrouped
                 needGoHome:NO];
  if (self) {
    _item = couponItem;
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_headerView);
  RELEASE_OBJ(_footerView);
  
  [super dealloc];
}

- (void)initShareButton {
  [self addRightBarButtonWithTitle:LocaleStringForKey(NSShareTitle, nil)
                            target:self
                            action:@selector(share:)];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = CELL_COLOR;
  
  [self initShareButton];
  
  [_tableView reloadData];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - MFMessageComposeViewControllerDelegate method
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
  switch (result) {
    case MessageComposeResultCancelled:
      
      break;
      
    case MessageComposeResultFailed:
      [UIUtils showNotificationOnTopWithMsg:LocaleStringForKey(NSSMSSentFailed, nil) 
                                    msgType:ERROR_TY
                         belowNavigationBar:YES];
      break;
      
    case MessageComposeResultSent:
      
      break;
      
    default:
      break;
  }
  
  [self dismissModalViewControllerAnimated:YES];
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

#pragma mark - UIActionSheetDelegate method
- (void)actionSheet:(UIActionSheet *)actionSheet 
clickedButtonAtIndex:(NSInteger)buttonIndex {
  
  switch (_actionOwnerType) {
    case SHARE_AS_TY:
    {
      switch (buttonIndex) {
        case 0:
          [self shareBySMS];
          break;
          
        case 1:
          [self shareByEmail];
          break;
          
        default:
          break;
      }
      break;
    }
      
    case CALL_AS_TY:
    {
      if (buttonIndex != actionSheet.numberOfButtons - 1) {
        NSString *number = nil;
        NSString *desc = [actionSheet buttonTitleAtIndex:buttonIndex];
        for (PhoneNumber *phoneNumber in _item.serviceItem.phoneNumbers) {
          if ([desc isEqualToString:phoneNumber.desc]) {
            number = phoneNumber.number;
            break;
          }
        }
        NSString *phoneStr = [[[NSString alloc] initWithFormat:@"tel:%@", number] autorelease];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
        
      }
      break;
    }
    default:
      break;
  }
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  if (_item.website && _item.website.length > 0) {
    return 3;
  } else {
    return 2;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (_item.website && _item.website.length > 0) {
    switch (indexPath.row) {
      case PRICE_CELL:
      {
        static NSString *priceCellIdentifier = @"priceCellIdentifier";
        CouponPriceCell *cell = [_tableView dequeueReusableCellWithIdentifier:priceCellIdentifier];
        if (nil == cell) {
          cell = [[[CouponPriceCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:priceCellIdentifier] autorelease];
          
          cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell drawCell:_item];
        
        return cell;
      }
        
      case DESC_CELL:
      {
        static NSString *introCellIdentifier = @"introCellIdentifier";
        
        return [self drawNoShadowVerticalInfoCell:LocaleStringForKey(NSHighlightsTitle, nil)
                                       subTitle:nil
                                        content:_item.desc
                                 cellIdentifier:introCellIdentifier
                                      clickable:NO];

      }
        
      case WEBSITE_CELL:
      {
        static NSString *websiteCellIdentifier = @"websiteCellIdentifier";
        return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSWebSiteTitle, nil)
                                       subTitle:nil
                                        content:_item.website
                                 cellIdentifier:websiteCellIdentifier
                                         height:[self tableView:tableView 
                                        heightForRowAtIndexPath:indexPath] + 1.0f
                                      clickable:YES];
      }
        
      default:
        return nil;
    }
  } else {
    
    switch (indexPath.row) {
    
      case PRICE_CELL:
      {
        static NSString *priceCellIdentifier = @"priceCellIdentifier";
        CouponPriceCell *cell = [_tableView dequeueReusableCellWithIdentifier:priceCellIdentifier];
        if (nil == cell) {
          cell = [[[CouponPriceCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:priceCellIdentifier] autorelease];
          
          cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell drawCell:_item];
        
        return cell;
      }
      
      case DESC_CELL:
      {
        static NSString *introCellIdentifier = @"introCellIdentifier";
        return [self drawShadowVerticalInfoCell:LocaleStringForKey(NSHighlightsTitle, nil)
                                       subTitle:nil
                                        content:_item.desc
                                 cellIdentifier:introCellIdentifier
                                         height:[self tableView:tableView 
                                        heightForRowAtIndexPath:indexPath] + 1.0f
                                      clickable:NO];
      }
        
      default:
        return nil;
    }
    
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  CGSize size;
  CGFloat height = 0.0f;
  switch (indexPath.row) {
  
    case PRICE_CELL:
    {
      NSString *title = nil;
      height += MARGIN;
      if (_item.reducedPrice && _item.reducedPrice.length > 0) {
        title = [NSString stringWithFormat:@"%@: ", 
                 LocaleStringForKey(NSPriceDetailTitle, nil)];
        size = [title sizeWithFont:FONT(13)
                 constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                     lineBreakMode:NSLineBreakByWordWrapping];
        
        size = [_item.reducedPrice sizeWithFont:BOLD_FONT(15)
                              constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH - (MARGIN * 2 + size.width + MARGIN), CGFLOAT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        height += MARGIN + size.height;
      }

      if (_item.prp && _item.prp.length > 0) {
        title = [NSString stringWithFormat:@"%@: ", 
                 LocaleStringForKey(NSPrpTitle, nil)];
        size = [title sizeWithFont:FONT(13)
                 constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                     lineBreakMode:NSLineBreakByWordWrapping];
        
        size = [_item.prp sizeWithFont:FONT(13)
                     constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH - (MARGIN * 2 + size.width + MARGIN), CGFLOAT_MAX)
                         lineBreakMode:NSLineBreakByWordWrapping];
        height += MARGIN + size.height;
      }
      
      height += MARGIN;
      
      break;
    }
    
    case DESC_CELL:
    {
      size = [LocaleStringForKey(NSCouponDetailTitle, nil) sizeWithFont:BOLD_FONT(14) 
                                                      constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, 
                                                                            CGFLOAT_MAX)
                                                          lineBreakMode:NSLineBreakByWordWrapping];
      height += MARGIN * 2 + size.height + MARGIN * 2;
      
      if (_item.desc && _item.desc.length > 0) {
        size = [_item.desc sizeWithFont:BOLD_FONT(13)
                      constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
        height += size.height;
      }
      
      break;
    }
      
    case WEBSITE_CELL:
    {
      
      size = [LocaleStringForKey(NSWebSiteTitle, nil) sizeWithFont:BOLD_FONT(14)
                                                 constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, 
                                                                              CGFLOAT_MAX) 
                                                     lineBreakMode:NSLineBreakByWordWrapping];
      height += MARGIN * 2 + size.height + MARGIN * 2;
      
      if (_item.website && _item.website.length > 0) {
        size = [_item.website sizeWithFont:BOLD_FONT(13)
                      constrainedToSize:CGSizeMake(DEFAULT_CLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
        height += size.height;
      }
      
      break;
    }
    default:
      height = 0;
  }
  
  return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (nil == _headerView) {
    
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    
    _headerView = [[CouponInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0,
                                                                         self.view.frame.size.width, 
                                                                         height)
                                                         item:_item
                                       imageDisplayerDelegate:self
                                     clickableElementDelegate:self];
  }
  
  return _headerView;
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  CGFloat height = IMAGE_AREA_HEIGHT + MARGIN;//self.view.frame.size.width;
  CGSize size = [_item.name sizeWithFont:BOLD_FONT(13)
                       constrainedToSize:CGSizeMake(self.view.frame.size.width - MARGIN * 4, CGFLOAT_MAX)
                           lineBreakMode:NSLineBreakByWordWrapping];
  height += size.height + MARGIN;
  
  NSString *str = [NSString stringWithFormat:@"%@: ", LocaleStringForKey(NSValidityTitle, nil)];
  size = [str sizeWithFont:BOLD_FONT(13)
                  forWidth:self.view.frame.size.width - MARGIN * 4
             lineBreakMode:NSLineBreakByWordWrapping];
  CGFloat validityWidth = self.view.frame.size.width - MARGIN * 2 - size.width - MARGIN * 2;
  
  if (_item.validity && _item.validity.length > 0) {
    size = [_item.validity sizeWithFont:BOLD_FONT(13)
                      constrainedToSize:CGSizeMake(validityWidth, CGFLOAT_MAX)
                          lineBreakMode:NSLineBreakByWordWrapping];
    height += size.height + MARGIN * 2;
  }
  
  return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  if (nil == _footerView) {
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 
                                                           self.view.frame.size.width, 
                                                           [self tableView:tableView
                                                  heightForFooterInSection:section])];
    _footerView.backgroundColor = TRANSPARENT_COLOR;
    
    ECGradientButton *callButton = [[[ECGradientButton alloc] initWithFrame:CGRectMake(MARGIN * 2, MARGIN * 2, 
                                                                                       self.view.frame.size.width - 
                                                                                       MARGIN * 4, 30) 
                                                                     target:self 
                                                                     action:@selector(call:) 
                                                                  colorType:RED_BTN_COLOR_TY
                                                                      title:LocaleStringForKey(NSCallTitle, nil) 
                                                                      image:nil 
                                                                 titleColor:[UIColor whiteColor] 
                                                           titleShadowColor:[UIColor lightGrayColor] 
                                                                  titleFont:BOLD_FONT(16) 
                                                                roundedType:HAS_ROUNDED 
                                                            imageEdgeInsert:ZERO_EDGE 
                                                            titleEdgeInsert:ZERO_EDGE] autorelease];
    [_footerView addSubview:callButton];
    
    /*
    CGFloat disclaimerBtnY = callButton.frame.origin.y + callButton.frame.size.height + MARGIN * 3;
    
    if (_item.source && _item.source.length > 0) {
      WXWLabel *sourceLabel = [[[WXWLabel alloc] initWithFrame:CGRectZero
                                                   textColor:BASE_INFO_COLOR
                                                 shadowColor:[UIColor whiteColor]] autorelease];
      sourceLabel.font = FONT(11);
      sourceLabel.numberOfLines = 0;
      sourceLabel.text = [NSString stringWithFormat:@"%@: %@",
                          LocaleStringForKey(NSSourceTitle, nil),
                          _item.source];
      CGSize size = [sourceLabel.text sizeWithFont:sourceLabel.font
                                 constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
      sourceLabel.frame = CGRectMake(MARGIN * 2, 
                                     callButton.frame.origin.y + callButton.frame.size.height + MARGIN * 2,
                                     size.width, size.height);
      [_footerView addSubview:sourceLabel];
      
      disclaimerBtnY = sourceLabel.frame.origin.y + sourceLabel.frame.size.height + MARGIN * 2;
    }
    
    UIButton *disclaimerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    disclaimerButton.frame = CGRectMake((self.view.frame.size.width - DISCLAIM_BUTTON_WIDTH)/2.0f,
                                        disclaimerBtnY, 
                                        DISCLAIM_BUTTON_WIDTH, 
                                        DISCLAIM_BUTTON_HEIGHT);
    [disclaimerButton addTarget:self
                         action:@selector(openDisclaimer:)
               forControlEvents:UIControlEventTouchUpInside];

    disclaimerButton.backgroundColor = TRANSPARENT_COLOR;
    disclaimerButton.titleLabel.font = BOLD_FONT(12);
    [disclaimerButton setTitleColor:BASE_INFO_COLOR
                           forState:UIControlStateNormal];
    [disclaimerButton setTitleColor:NAVIGATION_BAR_COLOR
                           forState:UIControlStateHighlighted];
    [disclaimerButton setTitleShadowColor:[UIColor whiteColor]
                                 forState:UIControlStateNormal];
    [disclaimerButton setTitle:LocaleStringForKey(NSDisclaimersTitle, nil)
                      forState:UIControlStateNormal];
    [_footerView addSubview:disclaimerButton];
    */
  }
  return _footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  /*
  if (_item.source && _item.source.length > 0) {
    NSString *source = [NSString stringWithFormat:@"%@: %@", 
                        LocaleStringForKey(NSSourceTitle, nil),
                        _item.source];
    CGSize size = [source sizeWithFont:FONT(11)
                     constrainedToSize:CGSizeMake(DEFAULT_UNCLICKABLE_CELL_CONTENT_WIDTH, CGFLOAT_MAX)
                         lineBreakMode:NSLineBreakByWordWrapping];
    return NO_SOURCE_FOOTER_HEIGHT + size.height + MARGIN;
  } else {
    return NO_SOURCE_FOOTER_HEIGHT;
  }
   */
  return NO_SOURCE_FOOTER_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [super tableView:tableView didSelectRowAtIndexPath:indexPath];

  switch (indexPath.row) {
    case WEBSITE_CELL:
    {
      [CommonUtils openWebView:self.navigationController 
                         title:_item.name
                           url:_item.website
               needCloseButton:YES
                needNavigation:YES
                needHomeButton:NO];
      

      break;
    } 
    default:
      break;
  }
}

#pragma mark - ECClickableElementDelegate method
- (void)openImageUrl:(NSString *)imageUrl {
  ECImageBrowseViewController *imageBrowseVC = [[[ECImageBrowseViewController alloc] initWithImageUrl:imageUrl] autorelease];
  
  WXWNavigationController *imgBrowseNav = [[[WXWNavigationController alloc] initWithRootViewController:imageBrowseVC] autorelease];
  [self.navigationController presentModalViewController:imgBrowseNav animated:YES];
}

@end
