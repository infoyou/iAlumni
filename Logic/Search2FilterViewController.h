//
//  Search2FilterViewController.h
//  iAlumni
//
//  Created by Adam on 13-7-31.
//
//

#import <UIKit/UIKit.h>

@interface Search2FilterViewController : UITableViewController

- (id)initWithStyle:(UITableViewStyle)style mainVC:(UIViewController *)mainVC;
- (void)setListData:(NSArray *)listArray paramArray:(NSMutableArray *)paramArray;

@end
