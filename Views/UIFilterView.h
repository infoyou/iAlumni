//
//  UIFilterView.h
//  iAlumni
//
//  Created by Adam on 12-8-20.
//
//

#import <UIKit/UIKit.h>

@protocol UITableFilterDelegate <NSObject>

-(void)didSelectResult:(int)leftIndex rightStr:(int)rightIndex;

@end

@interface UIFilterView : UIView <UITableViewDataSource, UITableViewDelegate> {
}

- (id)initWithFrame:(CGRect)frame tableFilterDelegate:(id<UITableFilterDelegate>)tableFilterDelegate size:(int)size;

- (void)setFilterData:(NSMutableArray*)leftArray rightArray:(NSMutableArray*)rightArray;

@end
