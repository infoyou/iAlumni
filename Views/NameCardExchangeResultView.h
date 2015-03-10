//
//  NameCardExchangeResultView.h
//  iAlumni
//
//  Created by Adam on 12-12-4.
//
//

#import <UIKit/UIKit.h>
#import "GlobalConstants.h"

@interface NameCardExchangeResultView : UIView {
  @private
  
  UIView *_topView;
  
  id _holder;
  SEL _closeAction;
  SEL _reviewAction;
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext *)MOC
             holder:(id)holder
        closeAction:(SEL)closeAction
       reviewAction:(SEL)reviewAction;

@end
