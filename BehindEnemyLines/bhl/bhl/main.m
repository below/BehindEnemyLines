//
//  main.m
//  bhl
//
//  Created by Alexander v. Below on 13.09.13.
//  Copyright (c) 2013 Alexander v. Below. All rights reserved.
//

#import <Foundation/Foundation.h>

void printHelp () {
    NSLog(@"Usage: bhl <file>");
}

int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        
        if (arguments.count > 1) {
            BOOL objectiveC2Java = NO;
            BOOL java2ObjectiveC = NO;
            NSString *filepath = [arguments lastObject];
            
            if (arguments.count > 2) {
                NSUInteger i;
                for (i = 1; i < arguments.count-1; i++) {
                    NSString *argument = [arguments objectAtIndex:i];
                    NSString *option = nil;
                    if ([argument hasPrefix:@"--"])
                        option = [argument substringFromIndex:2];
                    else if ([argument hasPrefix:@"-"])
                        option = [argument substringFromIndex:1];
                    if (option != nil) {
                        if ([option isEqualToString:@"o2j"] || [option isEqualToString:@"objectiveC2Java"]) {
                            objectiveC2Java = YES;
                        } else if ([option isEqualToString:@"j2o"] || [option isEqualToString:@"java2ObjectiveC"]) {
                            java2ObjectiveC = YES;
                        }
                    }
                }
            }
            if (java2ObjectiveC == NO && objectiveC2Java == NO) {
                java2ObjectiveC = YES;
            }
            else if (objectiveC2Java == YES && java2ObjectiveC == YES) {
                fprintf(stderr, "-o2j and -j2o are mutally exclusive\n");
                return EXIT_FAILURE;
            }
            
            if (objectiveC2Java) {
                fprintf(stderr, "-o2j is currently not supported\n");
                return EXIT_FAILURE;
            }
            else {
                NSError *error;
                NSXMLDocument * xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath]
                                                                              options:0
                                                                                error:&error];
                if (error != nil) {
                    const char * cString = [[NSString stringWithFormat:@"Error reading file '%@': %@", filepath, [error localizedDescription]] cStringUsingEncoding:NSUTF8StringEncoding];
                    fprintf(stderr, "%s\n", cString);
                    return EXIT_FAILURE;
                }
                NSString *xq = @"for $x in //resources/string\n\
                return concat(\"&quot;\", string($x/@name), \"&quot;\",\" = \",  \"&quot;\", data($x), \"&quot;;\")";
                NSArray *result = [[xmlDoc rootElement] objectsForXQuery:xq error:&error];
                if (error != nil) {
                    const char * cString = [[NSString stringWithFormat:@"Error parsing file '%@': %@", filepath, [error localizedDescription]] cStringUsingEncoding:NSUTF8StringEncoding];
                    fprintf(stderr, "%s\n", cString);
                    return EXIT_FAILURE;
                }
                NSMutableString *resultString = [NSMutableString new];
                for (NSString *line in result) {
                    [resultString appendFormat:@"%@\n", line];
                }
                const char * cResult = [resultString cStringUsingEncoding:NSUTF8StringEncoding];
                fprintf(stdout, "%s", cResult);
            }
        }
        else {
            printHelp ();
            return EXIT_FAILURE;
        }
    }
    return EXIT_SUCCESS;
}

