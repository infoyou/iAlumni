//
//  FlatTableCell.h
//  iAlumni
//
//  Created by Adam on 13-9-6.
//
//

#import <UIKit/UIKit.h>
#import "ECImageConsumerCell.h"

typedef enum {
  FLAT_CELL_TOP_POSITION = 0,
  FLAT_CELL_MIDDLE_POSITION,
  FLAT_CELL_BOTTOM_POSITION,
  FLAT_CELL_ALONE_POSITION
} FlatTableViewCellPosition;


@interface FlatTableCell : ECImageConsumerCell {
  
}

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) FlatTableViewCellPosition position;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)parserCellPositionAtIndexPath:(NSIndexPath *)indexPath elementTotalCount:(NSInteger)elementTotalCount;

@end
