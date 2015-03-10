//
//  OrderViewController.h
//  iAlumni
//
//  Created by Adam on 13-8-7.
//
//

#import <UIKit/UIKit.h>
#import "WXWRootViewController.h"

@class ClubDetail;

@interface OrderViewController : WXWRootViewController {
  @private
  
  PaymentItemType _paymentItemType;
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext*)MOC
    paymentItemType:(PaymentItemType)paymentItemType;

- (void)setPayOrderId:(NSString *)payOrderId orderTitle:(NSString *)orderTitle
               skuMsg:(NSString *)skuMsg;
- (void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell;
- (void)loadOrderDetail;

@end

