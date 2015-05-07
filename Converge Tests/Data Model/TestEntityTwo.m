#import "TestEntityTwo.h"

#import "ConvergeRecord+Merging.h"

@interface TestEntityTwo ()

// Private interface goes here.

@end

@implementation TestEntityTwo

+ (ConvergeAttributeConversionBlock)conversionForAttribute:(NSString *)ourAttributeName
{
    if ([ourAttributeName isEqualToString:@"someDecimal"])
    {
        return self.stringToDecimalConversion;
    }
    
    return [super conversionForAttribute:ourAttributeName];
}

@end
