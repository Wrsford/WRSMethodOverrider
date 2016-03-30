//
//  WRSMethodOverrider.m
//  methodOver
//
//  Created by Will Stafford on 1/5/15.
//  Copyright (c) 2015 iWill LLC. All rights reserved.
//



#import "WRSMethodOverrider.h"

/*int indexOfAddrExec() {
	jmp_buf buf;
	setjmp(buf);
	printf("cur: %p\n", indexOfAddrExec);
	int returnme = 0;
	int sizer = _JBLEN/(sizeof(void*)/sizeof(int));
	void **real = (void **)buf;
	for (int x = 0; x < sizer; x++) {
 //printf("%d: %p\n", x, real[x]);
 // 6 kinds of wrong: the buf will contain the PC a few instructions past indexOfAddrExec, so we check if it's "close"
 if (real[x] >= (void*)indexOfAddrExec-40 && real[x] <= (void*)indexOfAddrExec+40) {
 printf("index %d matches: %p\n", x, real[x]);
 returnme = x;
 }
	}
	return returnme;
 }
 
 void trampoline(void *blah, ...) {
	setjmp(buf);
	va_list list;
	va_start(list, blah);
	NSLogv((__bridge id)blah, list);
	va_end(list);
	return;
	int index = indexOfAddrExec();
	void **realArray = (void**)buf;
	printf("blah = %p\n", blah);
	for (int x = 0; x < 18; x++) {
 printf("realArray[%d] = %p\n", x, realArray[x] > 0x100000000000 ? *(void**)realArray[x] : realArray[x]);
	}
	printf("Trampoline: %p\n", trampoline);
	printf("This is the trampoline: %p\nOffset: %p\n", realArray[index], (void*)(realArray[index]-((void *)trampoline)));
	realArray[index] = trampoline;
	typeof(trampoline) *tramp = realArray[index];
	
	longjmp(buf, 101);
 }
 
 void* functionFromBlock(id block) {
	//IMP theIMP = imp_implementationWithBlock(block);
	// Note: Block functions take themselves as the first param.
	// You MUST pass an id as the first param (if there are other params).
	return ((__bridge __block_literal_generic *)block)->__FuncPtr;
 }*/

@implementation NSObject (WRSMethodOverrider)

+ (void)copySelector:(SEL)currentSelector toNewSelector:(SEL)newSelector {
	IMP oldIMP = class_getMethodImplementation([self class], currentSelector);
	Method m = class_getClassMethod([self class], currentSelector);
	class_addMethod([self class], newSelector, oldIMP, method_getTypeEncoding(m));
	class_replaceMethod([self class], newSelector, oldIMP, method_getTypeEncoding(m));
}

+ (void)overrideSelector:(SEL)theSelector withBlock:(id)theBlock {
	NSLog(@"OVERRIDING SELECTOR: %@", NSStringFromSelector(theSelector));
	[NSString cleanMethods];
	NSString *selName = NSStringFromSelector(theSelector);
	
	// Remaps the original selector to clean_selName
	NSString *origName = [@"clean_" stringByAppendingString:selName];
	
	[self copySelector:theSelector toNewSelector:NSSelectorFromString(origName)];
	[NSString taintMethods];
	IMP theIMP = imp_implementationWithBlock(theBlock);
	Method m = class_getClassMethod([self class], theSelector);
	
	[NSString cleanMethods];
	origName = [@"taint_" stringByAppendingString:selName];
	[NSString taintMethods];
	class_replaceMethod([self class], theSelector, theIMP, method_getTypeEncoding(m));
	
	[self copySelector:theSelector toNewSelector:NSSelectorFromString(origName)];
	NSLog(@"SELECTOR OVERRIDDEN: %@", NSStringFromSelector(theSelector));
}

+ (void)pointFunction:(void *)theFunction toSelector:(SEL)theSelector {
	//trampoline(NULL);
	IMP implementation = class_getMethodImplementation(self.class, theSelector);
	*(void**)theFunction = implementation;
}

+ (void)overrideSelector:(SEL)currentSelector copyToFunction:(void *)theFunction withBlock:(id)theBlock {
	// Something doesn't work...
	// PROLLY cuz your trying to use self in a static method....
	// ^^^^ Actually apparently I'm allowed to do this...
	[self pointFunction:theFunction toSelector:currentSelector];
	[self overrideSelector:currentSelector withBlock:theBlock];
}

+ (void)cleanMethod:(SEL)select {
	NSString *cleanName = [@"clean_" stringByAppendingString:NSStringFromSelector(select)];
	SEL cleanSel = NSSelectorFromString(cleanName);
	
	//if ([self resolveClassMethod:cleanSel] || [self resolveInstanceMethod:cleanSel]) {
		[self copySelector:cleanSel toNewSelector:select];
	//}
	
}

+ (void)taintMethod:(SEL)select {
	NSString *taintName = [@"taint_" stringByAppendingString:NSStringFromSelector(select)];
	SEL taintSel = NSSelectorFromString(taintName);
	
	//if ([self resolveClassMethod:taintSel] || [self resolveInstanceMethod:taintSel]) {
		[self copySelector:taintSel toNewSelector:select];
	//}
}


+ (void)cleanMethods {
	unsigned int outCount = 0;
	Method *myMethods = class_copyMethodList(self, &outCount);
	
	int x;
	for (x = 0; x < outCount; x++) {
		NSString *methodName = NSStringFromSelector(method_getName(myMethods[x]));
		NSRange range = [methodName rangeOfString:@"clean_"];
		if (range.location == 0) {
			[self copySelector:method_getName(myMethods[x]) toNewSelector:NSSelectorFromString([methodName substringFromIndex:range.length])];
		}
	}
}

+ (void)taintMethods {
	unsigned int outCount = 0;
	Method *myMethods = class_copyMethodList(self, &outCount);
	
	int x;
	for (x = 0; x < outCount; x++) {
		NSString *methodName = NSStringFromSelector(method_getName(myMethods[x]));
		NSRange range = [methodName rangeOfString:@"taint_"];
		if (range.location == 0) {
			[self copySelector:method_getName(myMethods[x]) toNewSelector:NSSelectorFromString([methodName substringFromIndex:range.length])];
		}
	}
}

static NSMutableDictionary* _taintedDictInternal;

- (NSMutableDictionary *)taintedDictionary {
	
	
	if (!objc_getAssociatedObject(self, &_taintedDictInternal)) {
		[self setTaintedDictionary:[NSMutableDictionary new]];
	}
	
	return objc_getAssociatedObject(self, &_taintedDictInternal) ;
}

- (void)setTaintedDictionary:(NSMutableDictionary *)taintedDictionary {
	objc_setAssociatedObject(self, &_taintedDictInternal, taintedDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}

@end

/*
@implementation UIWindow (WRSMethodOverrider)

- (void)modifyResolution:(CGSize)newResolution {
	self.clipsToBounds = YES;
	CGFloat scaleW = newResolution.width/self.bounds.size.width;
	CGFloat scaleH = newResolution.height/self.bounds.size.height;
	//
	
//	
	
	//self.transform = CGAffineTransformMakeScale([UIScreen mainScreen].bounds.size.width/newResolution.width, [UIScreen mainScreen].bounds.size.height/newResolution.height);
	[self setBounds:CGRectMake(0, 0, newResolution.width, newResolution.height)];
	self.transform = CGAffineTransformMakeScale(2, 2);
	//self.layer.contentsScale = 4.0;
	//self.transform = CGAffineTransformMakeTranslation(0 - newResolution.width/2, 0 - newResolution.height/2);
//
//self.layer.magnificationFilter = kCAFilterNearest;
//	self.contentScaleFactor = 4.0;
	//self.layer.bounds = CGRectMake(self.screen.bounds.origin.x * scaleW, self.screen.bounds.origin.y * scaleH, self.screen.bounds.size.width*scaleW, self.screen.bounds.size.height*scaleH);
	
	//[self.layer setContentsScale:8.0];
}

@end
*/

@implementation WRSMethodOverrider
/*
 + (void)copySelector:(SEL)theSelector toNewSelector:(SEL)newSelector {
	
 }
 
 + (void)overrideSelector:(SEL)theSelector inClass:(Class)theClass withBlock:(id)theBlock {
	IMP theIMP = imp_implementationWithBlock(theBlock);
	Method m = class_getClassMethod(theClass, theSelector);
	class_replaceMethod(theClass, theSelector, theIMP, method_getTypeEncoding(m));
 }
 
 + (void)overrideSelector:(SEL)theSelector moveTo:(SEL)old inClass:(Class)theClass withBlock:(id)block {
	IMP theIMP = imp_implementationWithBlock(block);
	IMP oldIMP = class_getMethodImplementation(theClass, theSelector);
	Method m = class_getClassMethod(theClass, theSelector);
	class_addMethod(theClass, old, oldIMP, method_getTypeEncoding(m));
	class_replaceMethod(theClass, theSelector, theIMP, method_getTypeEncoding(m));
 }
 
 + (void)invokeSelector:(SEL)theSelector target:(NSObject *)object existingSelector:(SEL)existingSelector withArgs:(void**)args count:(unsigned int)count returnVal:(id *)retVal {
	NSInvocation *anInvocation = [NSInvocation
 invocationWithMethodSignature:
 [object.class instanceMethodSignatureForSelector:existingSelector]];
	
	[anInvocation setSelector:theSelector];
	[anInvocation setTarget:object];
	
	for (int x = 0; x < count; x++) {
 [anInvocation setArgument:args[x] atIndex:x+2];
	}
	[anInvocation invoke];
	if (retVal) {
 [anInvocation getReturnValue:retVal];
	}
 }
 
 + (void)invokeSelector:(SEL)theSelector target:(NSObject *)object withArgs:(void**)args count:(unsigned int)count returnVal:(id *)retVal {
	return [WRSMethodOverrider invokeSelector:theSelector target:object existingSelector:theSelector withArgs:args count:count returnVal:retVal];
 }*/

@end
