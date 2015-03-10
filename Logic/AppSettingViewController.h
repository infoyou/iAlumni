//
//  AppSettingViewController.h
//  iAlumni
//
//  Created by Adam on 12-9-29.
//
//

#import "BaseListViewController.h"

@interface AppSettingViewController : BaseListViewController <WXApiDelegate> {
  @private
  UIView *_footerView;
  
  NSInteger _alertOwnerType;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC
           holder:(id)holder
 backToHomeAction:(SEL)backToHomeAction;

@end
