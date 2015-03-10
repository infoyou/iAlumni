//
//  ClubListCell.h
//  iAlumni
//
//  Created by Adam on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ECImageConsumerCell.h"
#import "Club.h"
#import "ECClickableElementDelegate.h"

@interface ClubListCell : ECImageConsumerCell {

}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
imageDisplayerDelegate:(id<WXWImageDisplayerDelegate>)imageDisplayerDelegate
                MOC:(NSManagedObjectContext *)MOC
             target:(id)target
displayDetailAction:(SEL)displayDetailAction;

- (void)drawClub:(Club *)club;

@end
