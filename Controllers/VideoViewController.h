//
//  VideoViewController.h
//  iAlumni
//
//  Created by Adam on 14-12-26.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "WXWRootViewController.h"

@class DirectionMPMoviePlayer;

@interface VideoViewController : WXWRootViewController{
    
    NSURLConnection *connection;
    NSMutableData *connectionData;
    NSString *url;
    DirectionMPMoviePlayer *_moviePlayerVC; 
    
}

@property (nonatomic,retain) NSURLConnection *connection;
@property (nonatomic,retain) NSMutableData *connectionData;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,retain) DirectionMPMoviePlayer *_moviePlayerVC; 

-(id)initWithURL:(NSString *)videoUrl;

@end
