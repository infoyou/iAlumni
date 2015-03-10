//
//  ComposerTag.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ComposerTag : NSManagedObject

@property (nonatomic, retain) NSNumber * highlight;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * selected;
@property (nonatomic, retain) NSNumber * tagId;
@property (nonatomic, retain) NSString * tagName;
@property (nonatomic, retain) NSNumber * type;

@end
