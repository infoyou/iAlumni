#import "DebugLogOutput.h"
#import <unistd.h>
#import "FileUtils.h"
#import "CommonUtils.h"

@implementation DebugLogOutput

static DebugLogOutput *sharedDebugInstance = nil;

/*---------------------------------------------------------------------*/
+ (DebugLogOutput *) instance
{
	@synchronized(self)
	{
		if (sharedDebugInstance == nil)
		{
			[[self alloc] init];
		}
	}
	return sharedDebugInstance;
}

/*---------------------------------------------------------------------*/
+ (id) allocWithZone:(NSZone *) zone
{
	@synchronized(self)
	{
		if (sharedDebugInstance == nil)
		{
			sharedDebugInstance = [super allocWithZone:zone];
			return sharedDebugInstance;
		}
	}
	return nil;
}

/*---------------------------------------------------------------------*/
- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

/*---------------------------------------------------------------------*/
- (id)retain
{
	return self;
}

/*---------------------------------------------------------------------*/
- (void)release
{
	// No action required...
}

/*---------------------------------------------------------------------*/
- (unsigned)retainCount
{
	return UINT_MAX;  // An object that cannot be released
}

/*---------------------------------------------------------------------*/
- (id)autorelease
{
	return self;
}

/*---------------------------------------------------------------------*/
-(void)output:(char*)fileName lineNumber:(int)lineNumber input:(NSString*)input, ...
{
	va_list argList;
	NSString *currentFilePath, *formatStr;
	
	// Build the path string
	currentFilePath = [[NSString alloc] initWithBytes:fileName
											   length:strlen(fileName)
											 encoding:NSUTF8StringEncoding];
	
	// Process arguments, resulting in a format string
	va_start(argList, input);
	formatStr = [[NSString alloc] initWithFormat:input
									   arguments:argList];
	va_end(argList);
	
	
	//----------------- begin of save into file ---------------------
	// Set permissions for our NSLog file
	umask(022);
	
	// Save stderr so it can be restored.
	int stderrSave = dup(STDERR_FILENO);
	
	// Get the log file path
	NSString *docDirectory = [FileUtils documentsDirectory];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	// create log folder if it does not exist
	NSString *logFolderPath = [docDirectory stringByAppendingFormat:@"/log"];
	BOOL isDir = YES;
	if (![fm fileExistsAtPath:logFolderPath 
				  isDirectory:&isDir]) {

        [fm createDirectoryAtPath:logFolderPath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
	}
	
	NSString *logFileName = [[NSString alloc] initWithFormat:@"/%@.log",/*[CommonUtils todaySimpleDate]*/[CommonUtils currentHourTime]];
	NSString *logFilePath = [logFolderPath stringByAppendingPathComponent:logFileName];
	
	freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a", stderr);
	
	// Call NSLog, prepending the filename and line number
	NSLog(@"File:%s Line:%d %@",[((DEBUG_SHOW_FULLPATH) ? currentFilePath :
								  [currentFilePath lastPathComponent]) UTF8String], lineNumber, formatStr);
	//----------------- end of save into file ---------------------	   
	
	// only display the debug info on console in debug model, no need to display it in release mode
#if DEBUG
	//----------------- begin of redirect to console ---------------------
	
	// Flush before restoring stderr
	fflush(stderr);
	
	// Now restore stderr, so new output goes to console.
	dup2(stderrSave, STDERR_FILENO);
	close(stderrSave);
	
	NSLog(@"File:%s Line:%d %@",[((DEBUG_SHOW_FULLPATH) ? currentFilePath :
								  [currentFilePath lastPathComponent]) UTF8String], lineNumber, formatStr);
	//----------------- end of redirect to console ---------------------
#endif
	
	[logFileName release];
	logFileName = nil;
	
	[currentFilePath release];
	currentFilePath = nil;
	
	[formatStr release];
	formatStr = nil;
}

@end