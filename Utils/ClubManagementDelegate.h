//
//  ClubManagementDelegate.h
//  iAlumni
//
//  Created by Adam on 12-10-8.
//
//

#import <Foundation/Foundation.h>

@protocol ClubManagementDelegate <NSObject>

@optional

- (void)doJoin2Quit:(BOOL)joinStatus ifAdmin:(NSString*)ifAdmin;
- (void)doManage;
- (void)goClubActivity;
- (void)goClubUserList;
- (void)doPost;
- (void)showFilters;
- (void)payWithOrderId:(NSString *)orderId;

@end
