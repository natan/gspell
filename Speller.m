//
//  Speller.m
//  gSpell
//
//  Created by Nathan Spindel on 12/9/05.
//

#import "Speller.h"

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

	NSString *suggestionString = [self googleSuggestionForPhrase: pboardString];
	
	// Check for empty string returns (ie. no suggestion from Google)
	if (!suggestionString) return;
	
	// Otherwise, slap the suggestion back on the pasteboard to be returned
	[pboard declareTypes: [NSArray arrayWithObject: NSStringPboardType] owner: nil];
	[pboard setString: suggestionString forType: NSStringPboardType];
		
	return;
}

/* request/response learned from http://weblogs.asp.net/pwelter34/archive/2005/07/19/419838.aspx */
- (NSString *)googleSuggestionForPhrase: (NSString *)phrase {
	NSString *preferredLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey: @"AppleLanguages"] objectAtIndex: 0];
	
	NSURL *updateURL = [NSURL URLWithString: [NSString stringWithFormat: @"https://www.google.com/tbproxy/spell?lang=%@&hl=%@", preferredLanguage, preferredLanguage]];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: updateURL];
	[request setHTTPMethod: @"POST"];
	
	NSString *body = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"utf-8\" ?><spellrequest textalreadyclipped=\"0\" ignoredups=\"0\" ignoredigits=\"1\" ignoreallcaps=\"0\"><text>%@</text></spellrequest>", phrase];
	[request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion: YES]];
	
	NSURLResponse *urlResponse = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest: request returningResponse: &urlResponse error: nil];
	
	NSMutableString *suggestionString = nil;
	
	if (responseData && ([(NSHTTPURLResponse *)urlResponse statusCode] == 200)) {
		suggestionString = [[phrase mutableCopy] autorelease];
		
		NSXMLDocument *responseXMLDocument = [[[NSXMLDocument alloc] initWithData: responseData options: nil error: nil] autorelease];
		
		NSArray *suggestions = [responseXMLDocument objectsForXQuery: @".//c" error: nil];
		
		int offsetModifier = 0;
		NSXMLElement *currentSuggestion = nil;
		NSEnumerator *suggestionsEnumerator = [suggestions objectEnumerator];
		while (currentSuggestion = [suggestionsEnumerator nextObject]) {
			int offset = [[[currentSuggestion attributeForName: @"o"] objectValue] intValue];
			int length = [[[currentSuggestion attributeForName: @"l"] objectValue] intValue];
			
			NSArray *suggestedSpellings = [[currentSuggestion stringValue] componentsSeparatedByString: @"\t"];
			if ([suggestedSpellings count]) {
				NSString *firstSuggestion = [suggestedSpellings objectAtIndex: 0];				
				[suggestionString replaceCharactersInRange: NSMakeRange(offset + offsetModifier, length) withString: firstSuggestion];
				offsetModifier += ([firstSuggestion length] - length);
			}
		}
	}
	
	return suggestionString;
}

@end