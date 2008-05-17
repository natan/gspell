//
//  Speller.h
//  gSpell
//
//  Created by Nathan Spindel on 12/9/05.
//

#import <Cocoa/Cocoa.h>


@interface Speller : NSObject

- (void)suggestSpellingCorrection:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error;

- (NSString *)googleSuggestionForPhrase:(NSString *)phrase;

@end
