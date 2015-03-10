//
//  AlumniProfileViewController.h
//  iAlumni
//
//  Created by Adam on 12-11-13.
//
//

#import "BaseListViewController.h"
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GlobalConstants.h"
#import "ECClickableElementDelegate.h"

@class AlumniProfileAvatarView;
@class Alumni;
@class WXWLabel;

@interface AlumniProfileViewController : BaseListViewController <ECClickableElementDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate, ABUnknownPersonViewControllerDelegate> {
  @private
  AlumniProfileAvatarView *_avatarView;
  
  UserType _userType;
  
  NSInteger _asOwnerType;
  
  AlumniRelationshipType _selectedRelationshipType;
  
  BOOL _hideLocation;
  
  UIView *_userSignInInfoView;
  
  WXWLabel *_signInInfoLabel;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
         personId:(NSString *)personId
         userType:(UserType)userType;

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           alumni:(Alumni *)alumni
         userType:(UserType)userType;

- (id)initHideLocationWithMOC:(NSManagedObjectContext *)MOC
                       alumni:(Alumni *)alumni
                     userType:(UserType)userType;

@end
