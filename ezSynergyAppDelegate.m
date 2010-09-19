/*
 * ezSynergyAppDelegate.m
 *
 * This file is part of ezSynergy.
 * 
 * Foobar is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Foobar is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "ezSynergyAppDelegate.h"

@implementation ezSynergyAppDelegate
@synthesize preferencesWindow;


- (id) init
{
	if ((self = [super init])) {     
        synergy = [[SynergyHelper alloc] init];
    }
	
	synergyIcon			= [NSImage imageNamed:@"syn_clr_norm"];
	synergyIconRunning	= [NSImage imageNamed:@"syn_clr_on"];
	
	return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

-(void)awakeFromNib {
	[statusMenu setAutoenablesItems:NO];	
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[statusItem setMenu:statusMenu];
	[statusItem setImage:(NSImage *)synergyIcon];
	[statusItem setHighlightMode:YES];
}


- (IBAction)startServer:(id)sender {
	if ([self writeConfigFile])
	{
		if ([synergy isSynergyRunning]) {
			[synergy stop];
			[statusItem setImage:(NSImage *)synergyIcon];
			[startServer setTitle:@"Start Server"];
			[startClient setEnabled:YES];
		}
		else {
			if ([synergy startServer]) {
				[statusItem setImage:(NSImage *)synergyIconRunning];
				[startServer setTitle:@"Stop Server"];
				[startClient setEnabled:NO];
			}
		}
	}
}


- (IBAction)startClient:(id)sender {
	if ([synergy isSynergyRunning]) {
		[synergy stop];
		[statusItem setImage:(NSImage *)synergyIcon];
		[startClient setTitle:@"Start Client"];
		[startServer setEnabled:YES];
	} else {
		if ([synergy connectToServer:[serverAddress stringValue]]) {
			[statusItem setImage:(NSImage *)synergyIconRunning];
			[startClient setTitle:@"Stop Client"];
			[startServer setEnabled:NO];
		}
	}
}


- (NSString *)bundleVersionNumber {
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];	
}


- (NSString *)thisHostname {
	return [[NSHost currentHost] name];	
}

- (IBAction)openPreferences:(id)sender {
	[NSApp activateIgnoringOtherApps:YES];
	[preferencesWindow makeKeyAndOrderFront:sender];
}


- (BOOL)writeConfigFile
{
    NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:0 userInfo:nil];
    NSMutableString *line;
    NSString *localhost = [self thisHostname];
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


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	if ([synergy isSynergyRunning]) {
		[synergy stop];
	}
	[synergy release];
	[self release];
}


@end
