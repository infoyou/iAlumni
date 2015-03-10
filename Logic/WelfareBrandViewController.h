//
//  WelfareBrandViewController.h
//  iAlumni
//
//  Created by Adam on 13-8-21.
//
//

#import "BaseListViewController.h"

@class Welfare;
@class Brand;

@interface WelfareBrandViewController : BaseListViewController <UIActionSheetDelegate> {
  @private
  
  Welfare *_welfare;
  
  CGFloat _textContentHeight;
  
  BOOL _textContentLoaded;
  
  BOOL _hasAlumni;
}

- (id)initWithWelfare:(Welfare *)welfare MOC:(NSManagedObjectContext *)MOC;

@end
