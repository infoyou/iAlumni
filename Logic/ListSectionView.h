//
//  ListSectionView.h
//  iAlumni
//
//  Created by Adam on 12-10-25.
//
//

#import <UIKit/UIKit.h>
#import "WXWGradientView.h"

@interface ListSectionView : WXWGradientView {
  
}

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title
          titleFont:(UIFont *)titleFont;

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title;

@end
