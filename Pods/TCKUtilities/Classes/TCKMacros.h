//
//  TCKMacros.h
//  TripCraftKit
//
//  Created by David Deller on 5/11/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#ifndef TCKMacros_h
#define TCKMacros_h

// Less verbose way to throw exceptions
#define TCKRaise(message) @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:message userInfo:nil]
#define TCKRaiseFormat(message, format...) @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:message, format] userInfo:nil]
#define TCKRaiseException(name, message) @throw [NSException exceptionWithName:name reason:message userInfo:nil]
#define TCKRaiseExceptionFormat(name, message, format...) @throw [NSException exceptionWithName:name reason:[NSString stringWithFormat:message, format] userInfo:nil]

// iOS version checks
// http://stackoverflow.com/questions/7848766/how-can-we-programmatically-detect-which-ios-version-is-device-running-on
#define TCKiOSVersionEqualTo(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define TCKiOSVersionGreaterThan(v)             ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define TCKiOSVersionGreaterThanOrEqualTo(v)    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define TCKiOSVersionLessThan(v)                ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define TCKiOSVersionLessThanOrEqualTo(v)       ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define TCKRGBa(r, g, b, a) [UIColor colorWithRed:(r/256.0) green:(g/256.0) blue:(b/256.0) alpha:a]
#define TCKRGBA(r, g, b, a) TCKRGBa(r, g, b, (a/256.0))
#define TCKRGB(r, g, b) TCKRGBa(r, g, b, 1.0)
#define TCKHexColor(hexColor) TCKRGB(((hexColor >> 16) & 0xFF), ((hexColor >> 8) & 0xFF), (hexColor & 0xFF));

#define CGRectChangeHeight_tc(rect, height) CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height)
#define CGRectChangeWidth_tc(rect, width) CGRectMake(rect.origin.x, rect.origin.y, width, rect.size.height)
#define CGRectChangeX_tc(rect, x) CGRectMake(x, rect.origin.y, rect.size.width, rect.size.height)
#define CGRectChangeY_tc(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)

#define TCKWeakCapture(obj) __weak __typeof__(obj) _TCKWeak_##obj = obj
#define TCKWeakRef(obj) _TCKWeak_##obj

#endif
