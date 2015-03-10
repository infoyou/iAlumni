//
//  QuestionnaireEntranceView.h
//  iAlumni
//
//  Created by Adam on 13-2-3.
//
//

#import <UIKit/UIKit.h>

@class WXWLabel;

@interface QuestionnaireEntranceView : UIView {

@private  
  id _entrance;
  
  SEL _action;
  
  UIImageView *_imageView;
  
  WXWLabel *_mainTitleLabel;
  WXWLabel *_subTitleLabel;

}

- (id)initWithFrame:(CGRect)frame entrancce:(id)entrance action:(SEL)action;

@end
