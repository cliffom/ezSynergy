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

#import <Cocoa/Cocoa.h>
#import "SynergyHelper.h"

@interface ezSynergyAppDelegate : NSObject <NSApplicationDelegate> {
	SynergyHelper *synergy;
	
	NSWindow *preferencesWindow;
	
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSMenuItem *startServer;
	IBOutlet NSMenuItem *startClient;
	IBOutlet NSTextField *clientAbove;
	IBOutlet NSTextField *clientRight;
	IBOutlet NSTextField *clientBelow;
	IBOutlet NSTextField *clientLeft;
	IBOutlet NSTextField *serverAddress;
	
    NSStatusItem *statusItem;
	NSImage *synergyIcon;
	NSImage *synergyIconRunning;
}

@property (assign) IBOutlet NSWindow *preferencesWindow;

- (IBAction)startServer:(id)sender;
- (IBAction)startClient:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (NSString *)bundleVersionNumber;
- (NSString *)thisHostname;
- (BOOL)writeConfigFile;

@end
