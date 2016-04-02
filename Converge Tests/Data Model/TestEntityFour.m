#import "TestEntityFour.h"

@interface TestEntityFour ()

// Private interface goes here.

@end

@implementation TestEntityFour

+ (NSString *)IDAttributeName
{
    return nil;
}

+ (BOOL)shouldAlwaysCreateNew
{
    return YES;
}

@end
