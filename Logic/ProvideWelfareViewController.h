//
//  ProvideWelfareViewController.h
//  iAlumni
//
//  Created by Adam on 13-8-14.
//
//

#import "WXWRootViewController.h"

@interface ProvideWelfareViewController : WXWRootViewController {
  @private
  
  UIView *_headerView;
  
  CGFloat _labelX;
  CGFloat _fieldX;
  CGFloat _startX;
}

- (id)initWithMOC:(NSManagedObjectContext *)MOC;

@end
