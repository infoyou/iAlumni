//
//  FavoritedServiceItem.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ServiceItem.h"


@interface FavoritedServiceItem : ServiceItem

@property (nonatomic, retain) NSNumber * favoritedBy;

@end
