//
//  EventListCell.h
//  iAlumni
//
//  Created by Adam on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BaseUITableViewCell.h"
#import "ECTextBoardCell.h"

@class Event;

@interface EventListCell : ECTextBoardCell {
  


}

- (void)drawEvent:(Event *)event;
@end

