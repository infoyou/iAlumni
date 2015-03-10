//
//  FavoritedMember.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Member.h"


@interface FavoritedMember : Member

@property (nonatomic, retain) NSNumber * favoritedBy;

@end
