/*
 * SynergyHelper.m
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

#import "SynergyHelper.h"


@implementation SynergyHelper

- (id) init {	
	if ((self = [super init])) {
	}
	return self;
}


- (BOOL) running; {
	return [synergy2 isRunning];
}


- (BOOL) startClient: (NSString *)serverAddress {
	NSArray *args;
	NSString *binaryPath;
	binaryPath = [[NSBundle mainBundle]
                  pathForAuxiliaryExecutable:@"Contents/Resources/synergyc"];
	args = [NSArray arrayWithObjects:@"-f", serverAddress, nil];
	
	return [self launch:binaryPath andArgs:args];		
}


- (BOOL) startServer {
	NSArray *args;
	NSString *binaryPath;
	NSString *configFile = [NSString stringWithFormat:@"%@/.ezSynergy.config",
                            NSHomeDirectory()];
	binaryPath = [[NSBundle mainBundle]
                  pathForAuxiliaryExecutable:@"Contents/Resources/synergys"];
	args = [NSArray arrayWithObjects:@"-f", @"-c", configFile, nil];
	
	return [self launch:binaryPath andArgs:args];	
}


- (BOOL) launch: (NSString*)binaryPath andArgs:(NSArray*)args {
	synergy2 = [[NSTask alloc] init];
	[synergy2 setLaunchPath:binaryPath];
	[synergy2 setArguments:args];
	[synergy2 launch];
	return [synergy2 isRunning];
}


- (BOOL) stop {
	[synergy2 interrupt];
	[synergy2 release];
	synergy2 = nil;
	
	return ![synergy2 isRunning];
}


@end