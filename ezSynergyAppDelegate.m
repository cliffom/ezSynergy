/*
 * ezSynergyAppDelegate.m
 *
 * This file is part of ezSynergy.
 * 
 * ezSynergy is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * ezSynergy is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with ezSynergy.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "ezSynergyAppDelegate.h"

@implementation ezSynergyAppDelegate
@synthesize preferencesWindow;


- (id) init {
	if ((self = [super init])) {	 
		synergy = [[SynergyHelper alloc] init];
		synergyIcon = [NSImage imageNamed:@"syn_bw_norm"];
		synergyIconRunning = [NSImage imageNamed:@"syn_bw_on"];
	}
	
	return self;
}


- (void) applicationDidFinishLaunching: (NSNotification *)aNotification {
	// Insert code here to initialize your application
}


- (void) awakeFromNib {
	statusItem = [[[NSStatusBar systemStatusBar]
                   statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:statusMenu];
	[statusItem setImage:synergyIcon];
	[statusItem setHighlightMode:YES];
	
	if ([openPreferencesOnStartup state] == NSOnState) {		
		[self openPreferences:nil];
	}
	
	switch ([startupAction selectedColumn]) {
		case STARTUP_ACTION_NONE:
			break;
		case STARTUP_ACTION_CLIENT:
			[self toggleSynergy:startClient];
			break;
		case STARTUP_ACTION_SERVER:
			[self toggleSynergy:startServer];
			break;
		default:
			break;
	}
	[serverAddress addItemWithObjectValue:@"192.168.1.20"];
	[serverAddress addItemWithObjectValue:@"10.0.1.80"];
}


- (IBAction) toggleSynergy: (id)sender {
	if ([synergy running] && [synergy stop]) {
		[statusItem setImage:synergyIcon];
		switch ([sender tag]) {
			case MENU_START_SERVER:
				[startServer setTitle:@"Start Server"];
				[startClient setEnabled:YES];
				break;
			case MENU_START_CLIENT:
				[startClient setTitle:@"Start Client"];
				[startServer setEnabled:YES];
		}
	} else {
		switch ([sender tag]) {
			case MENU_START_SERVER:
				if ([self writeConfigFile]) {
					if ([synergy startServer]) {
						[startServer setTitle:@"Stop Server"];
						[startClient setEnabled:NO];
					}
				}
				break;
			case MENU_START_CLIENT:
				if ([synergy startClient:[serverAddress stringValue]]) {					
					[startClient setTitle:@"Stop Client"];
					[startServer setEnabled:NO];
				}
				break;
		}
		if ([synergy running]) {
			[statusItem setImage:synergyIconRunning];
		}
	}
}


- (NSString *) bundleVersionNumber {
	return [[[NSBundle mainBundle] infoDictionary]
            objectForKey:@"CFBundleVersion"];	
}


- (NSString *) hostName {
	return [[NSHost currentHost] name];	
}


- (IBAction) openPreferences: (id)sender {
	[NSApp activateIgnoringOtherApps:YES];
	[preferencesWindow makeKeyAndOrderFront:sender];
}


- (BOOL) writeConfigFile {
	NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain
                                         code:0 userInfo:nil];
	NSMutableString *line;
	NSString *localhost = [self hostName];
	NSString *up = [clientAbove stringValue];
	NSString *down = [clientBelow stringValue];
	NSString *left = [clientLeft stringValue];
	NSString *right = [clientRight stringValue];
	NSString *configFile = [NSString stringWithFormat:@"%@/.ezSynergy.config", NSHomeDirectory()];
	
	line = [[[NSMutableString alloc] init] autorelease];
	
	// Options
	[line appendString:@"section: options\n"];
    if ([screenSaverSync state] == NSOffState) {
        [line appendString:@"\tscreenSaverSync = false\n"];
    } else {
        [line appendString:@"\tscreenSaverSync = true\n"];
    }
    [line appendString:@"\tkeystroke(f12) = lockCursorToScreen(toggle)\n"];
	[line appendString:@"end\n\n"];
	
	// Screens
	[line appendString:@"section: screens\n"];
	[line appendFormat:@"\t%@:\n", localhost];
	if ([up compare:@""])
		[line appendFormat:@"\t%@:\n", up];
	if ([down compare:@""])
		[line appendFormat:@"\t%@:\n", down];
	if ([left compare:@""])
		[line appendFormat:@"\t%@:\n", left];
	if ([right compare:@""])
		[line appendFormat:@"\t%@:\n", right];
	[line appendString:@"end\n\n"];
	
	// Links
	[line appendString:@"section: links\n"];
	[line appendFormat:@"\t%@:\n", localhost];
	if ([up compare:@""])
		[line appendFormat:@"\t\tup\t= %@\n", up];
	if ([down compare:@""])
		[line appendFormat:@"\t\tdown\t= %@\n", down];
	if ([left compare:@""])
		[line appendFormat:@"\t\tleft\t= %@\n", left];
	if ([right compare:@""])
		[line appendFormat:@"\t\tright\t= %@\n", right];
	if ([up compare:@""]) {
		[line appendFormat:@"\t%@:\n", up];
		[line appendFormat:@"\t\tdown\t= %@\n", localhost];
	}
	if ([down compare:@""]) {
		[line appendFormat:@"\t%@:\n", down];
		[line appendFormat:@"\t\tup\t= %@\n", localhost];
	}
	if ([left compare:@""]) {
		[line appendFormat:@"\t%@:\n", left];
		[line appendFormat:@"\t\tright\t= %@\n", localhost];
	}
	if ([right compare:@""]) {
		[line appendFormat:@"\t%@:\n", right];
		[line appendFormat:@"\t\tleft\t= %@\n", localhost];
	}
	[line appendString:@"end\n"];
	
	[line writeToFile:configFile
		   atomically:YES
			 encoding:NSISOLatin1StringEncoding
				error:&error];
	
	if (![error code])
		NSLog(@"Error: %@", [error localizedDescription]);
	
	return TRUE;
}

-(IBAction)toggleOpenAtLogin:(id)sender {
	if ([sender state] == NSOnState) {
		[self addAppToLoginItems];
    } else {
		[self deleteAppFromLoginItems];
    }
}

-(void) addAppToLoginItems {
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
    
	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
        if (item){
            CFRelease(item);
        }
	}	

	CFRelease(loginItems);
}

-(void) deleteAppFromLoginItems {
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for(int i=0; i < [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)[loginItemsArray
                                                                        objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
		[loginItemsArray release];
	}
}

- (void) applicationWillTerminate: (NSNotification *)aNotification {
	if ([synergy running]) {
		[synergy stop];
	}
	[synergy release];
	[self release];
}


@end
