//
//  NSMutableArray+Move.h
//  Giraffe
//
//  Created by Alex Nichol on 11/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Move)

- (void)swapValueAtIndex:(NSInteger)source withValueAtIndex:(NSInteger)destination;

@end
