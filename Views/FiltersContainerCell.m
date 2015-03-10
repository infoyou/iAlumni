//
//  FiltersContainerCell.m
//  iAlumni
//
//  Created by Adam on 12-8-2.
//
//

#import "FiltersContainerCell.h"
#import "NearbyFilterContainerView.h"
#import "GlobalConstants.h"

@implementation FiltersContainerCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
                MOC:(NSManagedObjectContext *)MOC
 needDistanceFilter:(BOOL)needDistanceFilter
     needTimeFilter:(BOOL)needTimeFilter
    containerHeight:(CGFloat)containerHeight {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
        
    self.contentView.backgroundColor = TRANSPARENT_COLOR;
    
    _filterContainer = [[NearbyFilterContainerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,
                                                                                   containerHeight)
                                                                    MOC:MOC
                                                     needDistanceFilter:needDistanceFilter
                                                         needTimeFilter:needTimeFilter];
    _filterContainer.backgroundColor = TRANSPARENT_COLOR;
    [self.contentView addSubview:_filterContainer];
  }
  return self;
}

- (void)dealloc {
  
  RELEASE_OBJ(_filterContainer);
  
  [super dealloc];
}

@end
