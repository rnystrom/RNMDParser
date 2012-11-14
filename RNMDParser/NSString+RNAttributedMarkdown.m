//
//  NSString+RNAttributedMarkdown.m
//  RNMDParser
//
//  Created by Ryan Nystrom on 11/12/12.
//  Copyright (c) 2012 Ryan Nystrom. All rights reserved.
//

#import "NSString+RNAttributedMarkdown.h"
#import <CoreText/CoreText.h>

@interface NSAttributedString (RNAttributedMarkdown)

- (NSAttributedString*)formattedBold;
- (NSAttributedString*)formattedItalic;
- (NSAttributedString*)formattedHeader;
- (NSAttributedString*)formattedBlockquote;
- (NSAttributedString*)formattedUnorderedList;
- (NSAttributedString*)formattedOrderedList;
- (NSAttributedString*)formattedLink;

@end

static CGFloat kDefaultFontSize = 15.f;

@implementation NSAttributedString (RNAttributedMarkdown)

// intended for use w/ single line markdown parsing, not bodies
// for entire NSString > Markdown conversion, see NSString+RNAttributedMarkdown
- (NSAttributedString*)formattedForSurroundingPattern:(NSString*)pattern stringComponents:(NSString*)stringComponents normalFont:(UIFont*)normalFont styledFont:(UIFont*)styledFont {
    NSMutableAttributedString *aString = [self mutableCopy];
    
    CTFontRef styleFontRef = CTFontCreateWithName((__bridge CFStringRef)styledFont.fontName, styledFont.pointSize, NULL);
    
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:&error];
    NSArray *matches = [regex matchesInString:self.string options:kNilOptions range:NSMakeRange(0, [self.string length])];
    
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    if ([matches count] > 0) {
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
            [aString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)styleFontRef range:match.range];
        }];
        
        [aString.mutableString replaceOccurrencesOfString:stringComponents withString:@"" options:kNilOptions range:NSMakeRange(0, [aString.mutableString length])];
    }
    
    return aString;
}

- (NSAttributedString*)formattedBold {
    UIFont *normalFont = [UIFont systemFontOfSize:kDefaultFontSize];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:kDefaultFontSize];
    return [self formattedForSurroundingPattern:@"(\\*{2}[^\\*]+\\*{2}|\\Z)" stringComponents:@"**" normalFont:normalFont styledFont:boldFont];
}

- (NSAttributedString*)formattedItalic {
    UIFont *normalFont = [UIFont systemFontOfSize:kDefaultFontSize];
    UIFont *italicFont = [UIFont italicSystemFontOfSize:kDefaultFontSize];
    return [self formattedForSurroundingPattern:@"([^\\*]\\*{1}[^\\*]+\\*{1}|\\Z)" stringComponents:@"*" normalFont:normalFont styledFont:italicFont];
}

// custom, not reusing previous
- (NSAttributedString*)formattedHeader {
    NSMutableAttributedString *aString = [self mutableCopy];
    
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"^#+[\\s*](.*)$" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:&error];
    NSArray *matches = [regex matchesInString:self.string options:kNilOptions range:NSMakeRange(0, [self.string length])];
    
    if ([matches count] > 0) {
        // get count of occurence of # character
        NSError *countError = nil;
        NSRegularExpression *countRegex = [[NSRegularExpression alloc] initWithPattern:@"#" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:&countError];
        NSArray *countMatches = [countRegex matchesInString:self.string options:kNilOptions range:NSMakeRange(0, [self.string length])];
        NSInteger headerCount = [countMatches count];
        CGFloat headerSize = kDefaultFontSize + 4.f * (6.f / (float)headerCount);
        
        UIFont *font = [UIFont boldSystemFontOfSize:headerSize];
        CTFontRef styledFontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
        [aString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)styledFontRef range:NSMakeRange(0, [self.string length])];
        
        [aString.mutableString replaceOccurrencesOfString:@"#" withString:@"" options:kNilOptions range:NSMakeRange(0, [self.string length])];
    }
    
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    return aString;
}

- (NSAttributedString*)formattedBlockquote {
    NSMutableAttributedString *aString = [self mutableCopy];
    
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"^#+[\\s*](.*)$" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:&error];
    NSArray *matches = [regex matchesInString:self.string options:kNilOptions range:NSMakeRange(0, [self.string length])];
    
    if ([matches count] > 0) {
        // get count of occurence of # character
        NSError *countError = nil;
        NSRegularExpression *countRegex = [[NSRegularExpression alloc] initWithPattern:@"#" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:&countError];
        NSArray *countMatches = [countRegex matchesInString:self.string options:kNilOptions range:NSMakeRange(0, [self.string length])];
        NSInteger headerCount = [countMatches count];
        CGFloat headerSize = kDefaultFontSize + 4.f * (6.f / (float)headerCount);
        
        UIFont *font = [UIFont boldSystemFontOfSize:headerSize];
        CTFontRef styledFontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
        [aString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)styledFontRef range:NSMakeRange(0, [self.string length])];
        
        [aString.mutableString replaceOccurrencesOfString:@"#" withString:@"" options:kNilOptions range:NSMakeRange(0, [self.string length])];
    }
    
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    return aString;
}

- (NSAttributedString*)formattedListOrdered:(BOOL)isOrdered {
    NSMutableAttributedString *aString = [self mutableCopy];
    
    NSError *error = nil;
    NSString *pattern = nil;
    if (isOrdered) {
        pattern = @"^\\d\\.(.*)$";
    }
    else {
        pattern = @"^\\*\\s(.*)$";
    }
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:&error];
    NSArray *matches = [regex matchesInString:self.string options:kNilOptions range:NSMakeRange(0, [self.string length])];
    
    if ([matches count] > 0) {
        // paragraph styling from
        // http://stackoverflow.com/questions/6644501/objective-c-nsattributedstring-inserting-a-bullet-point
        
        if (isOrdered) {
            // add tab after numbers
            NSString *orderPattern = @"^(\\d)\\..*$";
            NSError *orderError = nil;
            NSRegularExpression *orderRegex = [[NSRegularExpression alloc] initWithPattern:orderPattern options:kNilOptions error:&orderError];
            NSRange range = [orderRegex rangeOfFirstMatchInString:aString.string options:kNilOptions range:NSMakeRange(0, [aString.string length])];
            NSString *number = [aString.string substringWithRange:range];
            [aString.mutableString replaceOccurrencesOfString:number withString:[NSString stringWithFormat:@"%@\t",number] options:kNilOptions range:range];
            
            if (orderError) {
                NSLog(@"%@",orderError.localizedDescription);
            }
        }
        else {
            // replace * with bullet & tab
            [aString.mutableString replaceOccurrencesOfString:@"*" withString:@"•\t" options:kNilOptions range:NSMakeRange(0, [self.string length])];
        }
        
        // dimensions just from example on SO
        CTTextAlignment alignment = kCTLeftTextAlignment;
        CGFloat paragraphSpacing = 0.0;
        CGFloat paragraphSpacingBefore = 0.0;
        CGFloat firstLineHeadIndent = 15.0;
        CGFloat headIndent = 30.0;
        
        CGFloat firstTabStop = 15.0;
        CGFloat lineSpacing = 0.45;
        
        CTTextTabRef tabArray[] = { CTTextTabCreate(0, firstTabStop, NULL) };
        
        CFArrayRef tabStops = CFArrayCreate( kCFAllocatorDefault, (const void**) tabArray, 1, &kCFTypeArrayCallBacks );
        CFRelease(tabArray[0]);
        
        CTParagraphStyleSetting altSettings[] =
        {
            { kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing},
            { kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment},
            { kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &firstLineHeadIndent},
            { kCTParagraphStyleSpecifierHeadIndent, sizeof(CGFloat), &headIndent},
            { kCTParagraphStyleSpecifierTabStops, sizeof(CFArrayRef), &tabStops},
            { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing},
            { kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore}
        };
        
        CTParagraphStyleRef style;
        style = CTParagraphStyleCreate( altSettings, sizeof(altSettings) / sizeof(CTParagraphStyleSetting) );
        
        if ( style == NULL )
        {
            NSLog(@"*** Unable To Create CTParagraphStyle in apply paragraph formatting" );
            return nil;
        }
        
        [aString addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(__bridge id)style range:NSMakeRange(0, [aString.mutableString length])];
        
        CFRelease(tabStops);
        CFRelease(style);
    }
    
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    return aString;
}

- (NSAttributedString*)formattedUnorderedList {
    return [self formattedListOrdered:NO];
}

- (NSAttributedString*)formattedOrderedList {
    return [self formattedListOrdered:YES];
}

- (NSAttributedString*)formattedLink {
    NSMutableAttributedString *aString = [self mutableCopy];
    
    NSError *error = nil;
    // first group will be title
    // second group will be url
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\\[([^\\[]+)\\]\\(([^\\)]+)\\)" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:&error];
    NSArray *matches = [regex matchesInString:self.string options:kNilOptions range:NSMakeRange(0, [self.string length])];
    
    if ([matches count] > 0) {
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
            if ([match numberOfRanges] > 2) {
                NSString *entireLink = [self.string substringWithRange:match.range];
                NSString *title = [self.string substringWithRange:[match rangeAtIndex:1]];
                // not using link in demo
                //                NSString *link = [self.string substringWithRange:[match rangeAtIndex:2]];
                
                int style = kCTUnderlineStyleSingle | kCTUnderlinePatternSolid;
                [aString addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:style] range:match.range];
                
                [aString.mutableString replaceOccurrencesOfString:entireLink withString:title options:kNilOptions range:NSMakeRange(0, [self.string length])];
            }
        }];
    }
    
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    return aString;
}

@end

@implementation NSString (RNAttributedMarkdown)

// order matters here, somewhat
// bold MUST happen before italicsx 
- (NSAttributedString*)markdownAttributedString {
    // strip & break on newlines so we don't run into issues like UL being formmated as EM
    NSArray *splitString = [self componentsSeparatedByString:@"\n"];
    NSMutableAttributedString *combinedString = [[NSMutableAttributedString alloc] init];
    
    [splitString enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL *stop) {
        NSMutableAttributedString *attrString = [[[NSAttributedString alloc] initWithString:text] mutableCopy];
        // base font
        UIFont *font = [UIFont systemFontOfSize:kDefaultFontSize];
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
        [attrString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, [attrString.string length])];
        
        NSAttributedString *headerString = [attrString formattedHeader];
        NSAttributedString *ulString = [headerString formattedUnorderedList];
        NSAttributedString *olString = [ulString formattedOrderedList];
        NSAttributedString *boldString = [olString formattedBold];
        NSAttributedString *italicString = [boldString formattedItalic];
        NSAttributedString *urlString = [italicString formattedLink];
        
        NSAttributedString *completedString = urlString;
        [combinedString appendAttributedString:completedString];
        // re-add new line
        [combinedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }];
    
    return combinedString;
}

@end