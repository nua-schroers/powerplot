//
//  WSData.m
//  PowerPlot
//
//  Created by Wolfram Schroers on 24.09.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "WSData+Private.h"
#import "WSDatum.h"
#import "WSAuxiliary.h"

@implementation WSData

@synthesize sorted = WS_sorted;

+ (NSArray *)arrayOfZerosWithLen:(NSUInteger)len {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:len];

    for (NSUInteger i=0; i<len; i++) {
        [result addObject:@0];
    }
    return [NSArray arrayWithArray:result];
}

+ (instancetype)data {
    return [[self alloc] init];
}

+ (instancetype)dataWithValues:(NSArray *)vals {
    return [[self alloc] initWithValues:vals];
}

+ (instancetype)dataWithValues:(NSArray *)vals
                   annotations:(NSArray *)annos {
    return [[self alloc] initWithValues:vals
                            annotations:annos];
}

+ (instancetype)dataWithValues:(NSArray *)vals
                       valuesX:(NSArray *)valsX {
    return [[self alloc] initWithValues:vals
                                valuesX:valsX];
}

+ (instancetype)dataWithValues:(NSArray *)vals
                       valuesX:(NSArray *)valsX
                   annotations:(NSArray *)annos {
    return [[self alloc] initWithValues:vals
                                valuesX:valsX
                            annotations:annos];
}

+ (instancetype)dataWithValues:(NSArray *)vals
                       valuesX:(NSArray *)valsX
                     errorMinY:(NSArray *)errMinY
                     errorMaxY:(NSArray *)errMaxY
                     errorMinX:(NSArray *)errMinX
                     errorMaxX:(NSArray *)errMaxX {
    return [[self alloc] initWithValues:vals
                                valuesX:valsX
                              errorMinY:errMinY
                              errorMaxY:errMaxY
                              errorMinX:errMinX
                              errorMaxX:errMaxX];
}

- (WSData *)sortedDataUsingValueX {
    WSData *sorted = [WSData data];
    sorted.nameTag = self.nameTag;
    sorted.values = [[NSMutableArray alloc] initWithArray:self.ws_values
                                                copyItems:NO];
    [sorted sortDataUsingValueX];
    return sorted;
}

- (WSData *)indexedData {
    WSData *indexed = [[WSData alloc] init];
    
    indexed.nameTag = self.nameTag;
    indexed.values = [[NSMutableArray alloc] initWithArray:self.ws_values
                                                 copyItems:NO];
    for (NSUInteger i=0; i<[indexed count]; i++) {
        [[indexed datumAtIndex:i] setValueX:(NAFloat)i];
    }
    indexed.sorted = YES;
    return indexed;
}

- (instancetype)init {
    return [self initWithValues:@[]];
}

- (instancetype)initWithValues:(NSArray *)vals {
    return [self initWithValues:vals
                        valuesX:[WSData arrayOfZerosWithLen:[vals count]]];
}

- (instancetype)initWithValues:(NSArray *)vals
                   annotations:(NSArray *)annos {
    NSParameterAssert([vals count] == [annos count]);

    self = [super init];
    if (self) {
        self.nameTag = @"";
        self.ws_values = [NSMutableArray arrayWithCapacity:[vals count]];
        self.sorted = NO;

        for (NSUInteger i=0; i<[vals count]; i++) {
            WSDatum *tmp = [WSDatum datumWithValue:[vals[i]
                                                    floatValue]
                                        annotation:annos[i]];
            [self.ws_values addObject:tmp];
            [self WS_observeDatum:tmp];
        }
    }
    return self;
}

- (instancetype)initWithValues:(NSArray *)vals
                       valuesX:(NSArray *)valsX {
    return [self initWithValues:vals
                        valuesX:valsX
                      errorMinY:@[]
                      errorMaxY:@[]
                      errorMinX:@[]
                      errorMaxX:@[]];
}

- (instancetype)initWithValues:(NSArray *)vals
                       valuesX:(NSArray *)valsX
                   annotations:(NSArray *)annos {
    NSParameterAssert(([vals count] == [valsX count]) &&
                      ([vals count] == [annos count]));

    self = [self initWithValues:vals
                        valuesX:valsX];
    if (self) {
        for (NSUInteger i=0; i<[annos count]; i++) {
            WSDatum *tmp = self.ws_values[i];
            tmp.annotation = annos[i];
        }
    }
    return self;
}

- (instancetype)initWithValues:(NSArray *)vals
                       valuesX:(NSArray *)valsX
                     errorMinY:(NSArray *)errMinY
                     errorMaxY:(NSArray *)errMaxY
                     errorMinX:(NSArray *)errMinX
                     errorMaxX:(NSArray *)errMaxX {
    // This methods needs both Y and X values; there have to be equal numbers!
    // Furthermore, if uncertainties are provided, the numbers have to match, too.
    NSUInteger len = [vals count];
    NSParameterAssert((len == [valsX count]) &&
                      (([errMinY count] == 0) || ([errMinY count] == len)) &&
                      (([errMinX count] == 0) || ([errMinY count] == len)) &&
                      (([errMaxY count] == 0) || ([errMaxY count] == len)) &&
                      (([errMaxX count] == 0) || ([errMaxX count] == len)));

    // It is evident that all uncertainties need to be positive numbers.
    for (NSUInteger i=0; i<[vals count]; i++) {
        if ([errMinY count] > 0 )
            NSParameterAssert([errMinY[i] floatValue] >= 0.0);
        if ([errMaxY count] > 0 )
            NSParameterAssert([errMaxY[i] floatValue] >= 0.0);
        if ([errMinX count] > 0 )
            NSParameterAssert([errMinX[i] floatValue] >= 0.0);
        if ([errMaxX count] > 0 )
            NSParameterAssert([errMaxX[i] floatValue] >= 0.0);
    }

    self = [super init];
    if (self) {
        self.nameTag = @"";
        self.ws_values = [NSMutableArray arrayWithCapacity:[vals count]];
        self.sorted = NO;

        // Fill in all values provided into the internal data structure.
        for (NSUInteger i=0; i<len; i++) {
            WSDatum *tmp = [WSDatum datumWithValue:[vals[i] floatValue]
                                        valueX:[valsX[i] floatValue]];
            if ([errMinY count] > 0) {
                tmp.errorMinY = [errMinY[i] floatValue];
                if ([errMaxY count] > 0) {
                    tmp.errorMaxY = [errMaxY[i] floatValue];
                } else {
                    tmp.errorMaxY = [errMinY[i] floatValue];
                }
            }
            if ([errMinX count] > 0) {
                tmp.errorMinX = [errMinX[i] floatValue];
                if ([errMaxX count] > 0) {
                    tmp.errorMaxX = [errMaxX[i] floatValue];
                } else {
                    tmp.errorMaxX = [errMinX[i] floatValue];
                }
            }
            [self.ws_values addObject:tmp];
            [self WS_observeDatum:tmp];
        }
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.nameTag forKey:kNameKey];
    [encoder encodeObject:self.ws_values forKey:kValuesKey];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.nameTag = [decoder decodeObjectForKey:kNameKey];
        self.ws_values = [[decoder decodeObjectForKey:kValuesKey] mutableCopy];
        for (WSDatum *datum in self.ws_values) {
            [self WS_observeDatum:datum];
        }
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WSData *copy = [[[self class] allocWithZone:zone] init];
    copy.nameTag = self.nameTag;
    copy.values = [[NSMutableArray alloc] initWithArray:self.ws_values
                                              copyItems:YES];
    return copy;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained *)stackbuf
                                    count:(NSUInteger)len {
    return [self.ws_values countByEnumeratingWithState:state
                                               objects:stackbuf
                                                 count:len];
}

#pragma mark - KVO

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {
    BOOL automatic = NO;
    
    if ([theKey isEqualToString:KVO_VALUES]) {
        automatic = NO;
    } else {
        automatic = [super automaticallyNotifiesObserversForKey:theKey];
    }
    return automatic;
}

- (void)WS_observeDatum:(WSDatum *)datum {
    [datum addObserver:self
            forKeyPath:KVO_DATUM
               options:0
               context:NULL];
}

- (void)WS_removeObserveDatum:(WSDatum *)datum {
    [datum removeObserver:self
               forKeyPath:KVO_DATUM];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (([keyPath isEqualToString:KVO_DATUM]) &&
        ([object isKindOfClass:[WSDatum class]])) {
        [self willChangeValueForKey:KVO_VALUES];
        [self didChangeValueForKey:KVO_VALUES];
    }
}

- (void)WS_observeAllValues {
    for (WSDatum *datum in self.ws_values) {
        [self WS_observeDatum:datum];
    }
}

- (void)WS_removeObserveAllValues {
    for (WSDatum *datum in self.ws_values) {
        [self WS_removeObserveDatum:datum];
    }
}

- (void)setValues:(NSArray *)values {
    @synchronized(self) {
        [self willChangeValueForKey:KVO_VALUES];
        [self WS_removeObserveAllValues];
        self.ws_values = [values mutableCopy];
        [self WS_observeAllValues];
        [self didChangeValueForKey:KVO_VALUES];
    }
}

- (NSArray *)values {
    return [NSArray arrayWithArray:self.ws_values];
}

#pragma mark -

- (void)sortDataUsingValueX {
    [self willChangeValueForKey:KVO_VALUES];
    self.ws_values = [NSMutableArray
                      arrayWithArray:[self.ws_values sortedArrayUsingSelector:@selector(valueXCompare:)]];
    [self didChangeValueForKey:KVO_VALUES];
    self.sorted = YES;
}

- (void)addDatum:(WSDatum *)aDatum {
    [self willChangeValueForKey:KVO_VALUES];
    [self WS_observeDatum:aDatum];
    [self.ws_values addObject:aDatum];
    self.sorted = NO;
    [self didChangeValueForKey:KVO_VALUES];
}

- (void)insertDatum:(WSDatum *)aDatum
            atIndex:(NSUInteger)index {
    [self willChangeValueForKey:KVO_VALUES];
    [self WS_observeDatum:aDatum];
    [self.ws_values insertObject:aDatum
                         atIndex:index];
    self.sorted = NO;
    [self didChangeValueForKey:KVO_VALUES];
}

- (void)replaceDatumAtIndex:(NSUInteger)index
                  withDatum:(WSDatum *)aDatum {
    [self willChangeValueForKey:KVO_VALUES];
    [self WS_removeObserveDatum:self.ws_values[index]];
    [self WS_observeDatum:aDatum];
    self.ws_values[index] = aDatum;
    self.sorted = NO;
    [self didChangeValueForKey:KVO_VALUES];
}

- (void)removeAllData {
    [self willChangeValueForKey:KVO_VALUES];
    for (WSDatum *datum in self.ws_values) {
        [self WS_removeObserveDatum:datum];
    }
    [self.ws_values removeAllObjects];
    self.sorted = NO;
    [self didChangeValueForKey:KVO_VALUES];
}

- (void)removeDatumAtIndex:(NSUInteger)index {
    [self willChangeValueForKey:KVO_VALUES];
    [self WS_removeObserveDatum:self.ws_values[index]];
    [self.ws_values removeObjectAtIndex:index];
    [self didChangeValueForKey:KVO_VALUES];
}

- (NSArray *)valuesWithSelector:(SEL)extractor {
    return [self valueForKeyPath:[NSString stringWithFormat:@"%@.%@",
                                  kValuesKey,
                                  NSStringFromSelector(extractor)]];
}

- (NSArray<NSNumber *> *)valuesFromDataX {
    return [self valuesWithSelector:@selector(valueX)];
}

- (NSArray<NSNumber *> *)valuesFromDataY {
    return [self valuesWithSelector:@selector(valueY)];
}

- (NSArray<NSString *> *)annotationsFromData {
    return [self valuesWithSelector:@selector(annotation)];
}

- (NSArray<NSNumber *> *)customFromData {
    return [self valuesWithSelector:@selector(customDatum)];
}

- (NAFloat)minimumValue {
    NAFloat retVal = NAN;
    
    if ([self count] > 0) {
        retVal = [[self datumAtIndex:0] value];
        for (WSDatum *item in self.ws_values) {
            retVal = fmin(retVal, item.value);
        }
    }
    return retVal;
}

- (NAFloat)minimumValueY {
    return [self minimumValue];
}

- (NAFloat)maximumValue {
    NAFloat retVal = NAN;
    
    if ([self count] > 0) {
        retVal = [[self datumAtIndex:0] value];
        for (WSDatum *item in self.ws_values) {
            retVal = fmax(retVal, item.value);
        }
    }
    return retVal;
}

- (NAFloat)maximumValueY {
    return [self maximumValue];
}

- (NAFloat)minimumValueX {
    NAFloat retVal = NAN;
    
    if ([self count] > 0) {
        retVal = ((WSDatum *)self.ws_values[0]).valueX;
        for (WSDatum *item in self.ws_values) {
            retVal = fmin(retVal, item.valueX);
        }
    }
    return retVal;
}

- (NAFloat)maximumValueX {
    NAFloat retVal = NAN;
    
    if ([self count] > 0) {
        retVal = ((WSDatum *)self.ws_values[0]).valueX;
        for (WSDatum *item in self.ws_values) {
            retVal = fmax(retVal, item.valueX);
        }
    }
    return retVal;
}

- (NAFloat)integrateValue {
    NAFloat retVal = 0.0;
    
    for (WSDatum *item in self.ws_values) {
        retVal += item.value;
    }
    return retVal;
}

- (NSUInteger)count {
    return [self.ws_values count];
}

- (NSUInteger)indexOfDatum:(WSDatum *)datum {
    return [self.ws_values indexOfObject:datum];
}

- (WSDatum *)datumAtIndex:(NSUInteger)index {
    return self.ws_values[index];
}

- (WSDatum *)lastDatum {
    return [self.ws_values lastObject];
}

- (WSDatum *)firstDatum {
    return [self.ws_values firstObject];
}

- (NAFloat)valueXAtIndex:(NSUInteger)index {
    return [[self datumAtIndex:index] valueX];
}

- (NAFloat)valueAtIndex:(NSUInteger)index {
    return [[self datumAtIndex:index] value];
}

- (WSDatum *)leftMostDatum {
    WSDatum *retVal = nil;
    NAFloat minValX = NAN;
    
    // Don't do anything when the data set is empty.
    if ([self.ws_values count] > 0) {
        retVal = [self datumAtIndex:0];
        minValX = retVal.valueX;
        for (WSDatum *item in self.ws_values) {
            NAFloat currentValX = item.valueX;
            if (currentValX < minValX) {
                minValX = currentValX;
                retVal = item;
            }
        }
    }
    return retVal;
}

- (WSDatum *)rightMostDatum {
    WSDatum *retVal = nil;
    NAFloat maxValX = NAN;
    
    // Don't do anything when the data set is empty.
    if ([self.ws_values count] > 0) {
        retVal = [self datumAtIndex:0];
        maxValX = retVal.valueX;
        for (WSDatum *item in self.ws_values) {
            NAFloat currentValX = item.valueX;
            if (currentValX > maxValX) {
                maxValX = currentValX;
                retVal = item;
            }
        }
    }
    return retVal;
}

- (WSDatum *)objectAtIndexedSubscript:(NSUInteger)idx {
    return self.ws_values[idx];
}

- (void)setObject:(id)obj
atIndexedSubscript:(NSUInteger)idx {
    [self willChangeValueForKey:KVO_VALUES];
    WSDatum *aDatum;
    if ([obj isKindOfClass:[WSDatum class]]) {
        aDatum = obj;
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        aDatum = [[WSDatum alloc] initWithValue:[obj floatValue]];
    } else {
        NSParameterAssert([obj isKindOfClass:[NSString class]]);
        aDatum = [[WSDatum alloc] initWithValue:0.0
                                     annotation:obj];
    }
    if (idx < [self count]) {
        [self WS_removeObserveDatum:self.ws_values[idx]];
    }
    [self WS_observeDatum:aDatum];
    self.ws_values[idx] = aDatum;
    self.sorted = NO;
    [self didChangeValueForKey:KVO_VALUES];
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key {
    NSPredicate *annotationFilter = [NSPredicate predicateWithBlock:^BOOL(WSDatum *evaluatedObject,
                                                                          NSDictionary *bindings) {
        return [evaluatedObject.annotation isEqualToString:(NSString *)key];
    }];
    NSArray *datumWithAnnotations = [self.ws_values filteredArrayUsingPredicate:annotationFilter];

    return (([datumWithAnnotations count] == 1) ?
            [datumWithAnnotations firstObject] :
            datumWithAnnotations);
}

- (void)setObject:(id)obj
forKeyedSubscript:(id<NSCopying>)key {
    NSParameterAssert([(id)key isKindOfClass:[NSString class]]);

    [self willChangeValueForKey:KVO_VALUES];
    WSDatum *aDatum;
    if ([obj isKindOfClass:[WSDatum class]]) {
        aDatum = obj;
        aDatum.annotation = (NSString *)key;
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        aDatum = [[WSDatum alloc] initWithValue:[obj floatValue]
                                     annotation:(NSString *)key];
    } else {
        NSParameterAssert([obj isKindOfClass:[NSString class]]);
        aDatum = [[WSDatum alloc] initWithValue:0.0
                                     annotation:obj];
    }
    __block NSInteger destinationIndex = -1;
    [self.ws_values enumerateObjectsUsingBlock:^(WSDatum *iter,
                                                 NSUInteger idx,
                                                 BOOL *stop) {
        if ([iter.annotation isEqualToString:(NSString *)key]) {
            destinationIndex = idx;
            *stop = YES;
        }
    }];
    if (destinationIndex == -1) {
        [self addDatum:aDatum];
    } else {
        [self replaceDatumAtIndex:destinationIndex withDatum:aDatum];
    }
    self.sorted = NO;
    [self didChangeValueForKey:KVO_VALUES];
}

#pragma mark -

- (NSString *)description {
    const NSUInteger descLen = 5;
    NSUInteger num = [self count];
    NSMutableString *prtCont = [NSMutableString stringWithString:@"["];
    
    NSUInteger i;
    // Iterate over all data points.
    for (i=0; i<num; i++) {
        // Print the contents of the first @p descLen points.
        if (i < descLen) {
            WSDatum *datum = self.ws_values[i];
            NSDictionary *tmpDict = [datum datum];
            NSString *anno = datum.annotation;
            float valX = datum.valueX;
            NSNumber *erriY = tmpDict[kErrorMinYKey];
            NSNumber *erraY = tmpDict[kErrorMaxYKey];
            NSNumber *erriX = tmpDict[kErrorMinXKey];
            NSNumber *erraX = tmpDict[kErrorMaxXKey];
            // If there is an X-value, print it. If it has an
            // uncertainty, append @p +; for uncertainties in both
            // directions, prepend @p +-.
            [prtCont appendString:@"("];
            if (!isnan(valX)) {
                [prtCont appendFormat:@"%f", valX];
                if (erraX) {
                    [prtCont appendString:@"+"];
                    if ([erriX floatValue] != [erraX floatValue]) {
                        [prtCont appendString:@"-"];
                    }
                }
                [prtCont appendString:@","];
            }
            // There always is a Y-value (at least it *should*). For
            // the uncertainty, proceed as before.
            [prtCont appendFormat:@"%f", datum.valueY];
            if (erraY) {
                [prtCont appendString:@"+"];
                if ([erriY floatValue] != [erraY floatValue]) {
                    [prtCont appendString:@"-"];
                }
            }
            [prtCont appendString:@")"];

            // Add an annotation if present.
            if (anno) {
                [prtCont appendFormat:@"{%@}", anno];
            }
            [prtCont appendString:@","];
        }
    }
    if (num > descLen) {
        [prtCont appendString:@"...,nil]"];
    } else
        [prtCont appendString:@"nil]"];

    return [NSString stringWithFormat:@"%@ of length %lu, content: %@.",
            [self class], (unsigned long)[self count], prtCont];
}

- (void)dealloc {
    [self WS_removeObserveAllValues];
}

@end
