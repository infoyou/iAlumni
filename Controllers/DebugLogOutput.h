// Show full path of filename?
#define DEBUG_SHOW_FULLPATH YES
 
// Enable debug (NSLog) wrapper code?
#define DEBUG 1
 

#define debugLog(format,...) [[DebugLogOutput instance] output:__FILE__ lineNumber:__LINE__ input:(format), ##__VA_ARGS__]

// #define debug(format,...)

 
@interface DebugLogOutput : NSObject
{
}
+ (DebugLogOutput *) instance;
-(void)output:(char*)fileName lineNumber:(int)lineNumber
        input:(NSString*)input, ...;
@end