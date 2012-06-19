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

#import <Cocoa/Cocoa.h>
#import "SynergyHelper.h"

#define MENU_START_SERVER 0
#define MENU_START_CLIENT 1

#define STARTUP_ACTION_NONE 0
#define STARTUP_ACTION_CLIENT 1
#define STARTUP_ACTION_SERVER 2

@interface ezSynergyAppDelegate : NSObject <NSApplicationDelegate> {
	SynergyHelper *synergy;
	
	NSWindow *preferencesWindow;
	
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSMenuItem *startServer;
	IBOutlet NSMenuItem *startClient;
	IBOutlet NSMatrix *startupAction;
	IBOutlet NSButton *openPreferencesOnStartup;
    IBOutlet NSButton *screenSaverSync;
	IBOutlet NSTextField *clientAbove;
	IBOutlet NSTextField *clientRight;
	IBOutlet NSTextField *clientBelow;
	IBOutlet NSTextField *clientLeft;
	IBOutlet NSComboBox *serverAddress;
	
	NSStatusItem *statusItem;
	NSImage *synergyIcon;
	NSImage *synergyIconRunning;
}

@property (assign) IBOutlet NSWindow *preferencesWindow;

- (IBAction) toggleSynergy: (id)sender;
- (IBAction) openPreferences: (id)sender;
- (NSString *) bundleVersionNumber;
- (NSString *) hostName;
- (BOOL) writeConfigFile;

@end
