//
//  SubmitOrderViewController.h
//  iAlumni
//
//  Created by Adam on 13-8-8.
//
//

#import <UIKit/UIKit.h>
#import "WXWRootViewController.h"

@class ClubDetail;

@interface SubmitOrderViewController : WXWRootViewController {
  @private
  PaymentItemType _paymentItemType;
  
  CGFloat _imageX;
  CGFloat _labelX;
}

- (id)initWithFrame:(CGRect)frame
                MOC:(NSManagedObjectContext*)MOC
    paymentItemType:(PaymentItemType)paymentItemType;

- (void)configureCell:(NSIndexPath *)indexPath aCell:(UITableViewCell *)cell;
- (void)loadOrderDetail;
- (void)setPayOrderId:(NSString *)payOrderId
           orderTitle:(NSString *)orderTitle
             selSkuId:(NSString *)selSkuId
     orderTotalAmount:(CGFloat)orderTotalAmount
               mobile:(NSString*)mobile
                email:(NSString*)email
                 desc:(NSString*)desc;
@end