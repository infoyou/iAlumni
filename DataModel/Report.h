//
//  Report.h
//  iAlumni
//
//  Created by Adam on 12-10-22.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Report : NSManagedObject

@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * languageType;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSNumber * newsId;
@property (nonatomic, retain) NSNumber * orderId;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSNumber * readCount;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;

@end
