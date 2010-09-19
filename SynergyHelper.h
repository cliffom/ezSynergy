/*
 * SynergyHelper.h
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


@interface SynergyHelper : NSObject
{
    NSTask *synergy2;
}

- (BOOL)isSynergyRunning;
- (BOOL)connectToServer:(NSString *)serverName;
- (BOOL)startServer;
- (void)stop;

@end