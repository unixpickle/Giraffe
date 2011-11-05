//
//  NSMutableArray+Move.m
//  Giraffe
//
//  Created by Alex Nichol on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArray+Move.h"

@implementation NSMutableArray (Move)

- (void)swapValueAtIndex:(NSInteger)source withValueAtIndex:(NSInteger)destination {
	NSObject * object1 = [self objectAtIndex:source];
	NSObject * object2 = [self objectAtIndex:destination];
#if !__has_feature(objc_arc)
	[object1 retain];
	[object2 retain];
#endif
	
	[self replaceObjectAtIndex:source withObject:object2];
	[self replaceObjectAtIndex:destination withObject:object1];
	
#if !__has_feature(objc_arc)
	[object1 release];
	[object2 release];
#endif
}

@end
