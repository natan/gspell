//
//  main.m
//  gSpell
//
//  Created by Nathan Spindel on 12/9/05.
//

#import <Cocoa/Cocoa.h>
#import "Speller.h"

int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	Speller *spellerService = [[Speller alloc] init];
	
	/* Service magic */
	NSRegisterServicesProvider(spellerService, @"gSpell");
	[[NSRunLoop currentRunLoop] configureAsServer];
	[[NSRunLoop currentRunLoop] run];		
	
	[spellerService release];	
	[pool release];	
	
	return 0;
}
