//
//  ItemGroup.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ItemGroup : NSManagedObject

@property (nonatomic, retain) NSString * firstTipsTitle;
@property (nonatomic, retain) NSNumber * groupId;
@property (nonatomic, retain) NSString * groupName;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * itemTotal;
@property (nonatomic, retain) NSNumber * sortKey;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * usageType;

@end
