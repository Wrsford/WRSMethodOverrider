//
//  WRSMethodOverrider.h
//  WRSMethodOverrider
//
//  Created by Will Stafford on 3/30/16.
//  Copyright © 2016 wrsford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

//! Project version number for WRSMethodOverrider.
FOUNDATION_EXPORT double WRSMethodOverriderVersionNumber;

//! Project version string for WRSMethodOverrider.
FOUNDATION_EXPORT const unsigned char WRSMethodOverriderVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <WRSMethodOverrider/PublicHeader.h>


//
//  WRSMethodOverrider.h
//  methodOver
//
//  Created by Will Stafford on 1/5/15.
//  Copyright (c) 2015 iWill LLC. All rights reserved.
//

typedef struct {
 unsigned long reserved;
	unsigned long Size;
} __block_descriptor;

typedef struct {
	void *__isa;
	int __flags;
	int __reserved;
	void *__FuncPtr;
	__block_descriptor *__descriptor;
} __block_literal_generic;

typedef struct {
	Class class;
	SEL oldSel;
	SEL newSel;
	__block_literal_generic *block;
	BOOL valid;
} replacedMethod;

//void patchGlobalFunctionWithLocalFunction(void *global, IMP *local);
/*void trampoline(void *blah, ...);
 void* functionFromBlock(id block);
 jmp_buf buf;*/

@interface NSObject (WRSMethodOverrider)

+ (void)copySelector:(SEL)currentSelector toNewSelector:(SEL)newSelector;
+ (void)overrideSelector:(SEL)theSelector withBlock:(id)theBlock;
+ (void)pointFunction:(void *)theFunction toSelector:(SEL)theSelector;
+ (void)cleanMethods;
+ (void)taintMethods;

@property (nonatomic, retain) NSMutableDictionary *taintedDictionary;
//+ (void)overrideSelector:(SEL)currentSelector copyToFunction:(void *)theFunction withBlock:(id)theBlock;

@end

@interface WRSMethodOverrider : NSObject

//+ (void)overrideSelector:(SEL)theSelector moveTo:(SEL)old inClass:(Class)theClass withBlock:(id (^)(id myself, SEL theCommand, replacedMethod rmeth))block;
/*
 + (void)overrideSelector:(SEL)theSelector inClass:(Class)theClass withBlock:(id)theBlock;
 
 + (void)overrideSelector:(SEL)theSelector moveTo:(SEL)old inClass:(Class)theClass withBlock:(id)block;
 
 #define startArgs()	va_list argumentList; va_start(argumentList, me)
 #define getArg(type, name) type name = va_arg(argumentList, type)
 #define endArgs()	va_end(argumentList)
 
 + (void)invokeSelector:(SEL)theSelector target:(NSObject *)object existingSelector:(SEL)existingSelector withArgs:(void**)args count:(unsigned int)count returnVal:(id *)retVal;
 + (void)invokeSelector:(SEL)theSelector target:(NSObject *)object withArgs:(void**)args count:(unsigned int)count returnVal:(id *)retVal;*/
@end
