//
//  PanMoveProtocol.h
//  iAlumni
//
//  Created by Adam on 13-9-4.
//
//

#import <Foundation/Foundation.h>

typedef enum {
  RESET_MAIN_TY = 0,
  MOVE_TO_LEFT_TY,
} ScrollMoveWayType;

@protocol PanMoveProtocol <NSObject>

@optional
- (void)movePanelLeft;
- (void)setCurrentEventFlag:(BOOL)flag;

- (void)backToParent;

@required
- (void)resetPanelPosition;


@end
