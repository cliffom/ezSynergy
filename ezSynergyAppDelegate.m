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


- (id) init
{
	if ((self = [super init])) {	 
		synergy = [[SynergyHelper alloc] init];
		synergyIcon = [NSImage imageNamed:@"syn_clr_norm"];
		synergyIconRunning = [NSImage imageNamed:@"syn_clr_on"];
	}
	
	return self;
}


- (void) applicationDidFinishLaunching: (NSNotification *)aNotification {
	// Insert code here to initialize your application
}


- (void) awakeFromNib {
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:statusMenu];
	[statusItem setImage:synergyIcon];
	[statusItem setHighlightMode:YES];
	
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
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];	
}


- (NSString *)hostName {
	return [[NSHost currentHost] name];	
}


- (IBAction) openPreferences: (id)sender {
	[NSApp activateIgnoringOtherApps:YES];
	[preferencesWindow makeKeyAndOrderFront:sender];
}


- (BOOL) writeConfigFile
{
	NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:0 userInfo:nil];
	NSMutableString *line;
	NSString *localhost = [self hostName];
	NSString *up = [clientAbove stringValue];
	NSString *down = [clientBelow stringValue];
	NSString *left = [clientLeft stringValue];
	NSString *right = [clientRight stringValue];
	NSString *configFile = [NSString stringWithFormat:@"%@/.ezSynergy.config",
							NSHomeDirectory()];
	
	line = [[[NSMutableString alloc] init] autorelease];
	
	// Options
	[line appendString:@"section: options\n"];
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


- (void) applicationWillTerminate: (NSNotification *)aNotification
{
	if ([synergy running]) {
		[synergy stop];
	}
	[synergy release];
	[self release];
}


@end
