//
//  SearchAlumniEntranceView.h
//  iAlumni
//
//  Created by Adam on 13-1-11.
//
//

#import <UIKit/UIKit.h>

@interface SearchAlumniEntranceView : UIView {
  @private
  
  id _entrance;
  
  SEL _action;

}

- (id)initWithFrame:(CGRect)frame entrancce:(id)entrance action:(SEL)action;

@end
