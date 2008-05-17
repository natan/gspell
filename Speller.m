//
//  Speller.m
//  gSpell
//
//  Created by Nathan Spindel on 12/9/05.
//

#import "Speller.h"
#import "NSStringAdditions.h"


@implementation Speller

- (void)suggestSpellingCorrection:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
	NSString *pboardString;
	
	// Make sure input data is right-o
	NSArray *types = [pboard types];
	if (![types containsObject: NSStringPboardType] ||
		!(pboardString = [pboard stringForType: NSStringPboardType])) {
		*error = NSLocalizedString(@"Error: couldn't get Google spelling suggestion for text.", @"pboard couldn't give string.");
		return;
	}

	NSString *suggestionString = [pboardString googleSpellingSuggestion];
	
	// Check for empty string returns (ie. no suggestion from Google)
	if (!suggestionString) return;
	
	// Otherwise, slap the suggestion back on the pasteboard to be returned
	[pboard declareTypes: [NSArray arrayWithObject: NSStringPboardType] owner: nil];
	[pboard setString: suggestionString forType: NSStringPboardType];
		
	return;
}

@end