//
//  WSData.h
//  PowerPlot
//
//  Created by Wolfram Schroers on 24.09.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import <math.h>
#import "NARange.h"

@class WSDatum;

/// @brief Store and manage a set of data to be plotted. This class
/// acts as a repository for @p WSDatum objects.
///
/// The data is stored as an @p NSMutableArray of @p NSDatum. The
/// array contains a entry for every separate datum point. A couple of
/// factory methods allows the construction both from Cocoa-style @p
/// NSArray of @p NSNumber and from C-style @p float[] arrays.
///
/// Starting with PowerPlot v1.3 this class supports KVO notifications
/// for the @p values property which are triggered if any element is
/// changed using any of the @p set... methods in the @p WSDatum class
/// or a method in this @p WSData class that modifies the data. Note
/// that the changes to the content are *not* reported when
/// notifications are posted!
///
/// With PowerPlot v2.0 this class supports the new collection literal
/// syntax. Using @p data[i] is equivalent to the @p datumAtIndex
/// methods and using @p data[@key] is a new way to access elements
/// directly with the annotations. Both setting and getting a @p
/// WSDatum object is possible using this syntax.
///
/// @note The convention used elsewhere that data coordinates are
///       prepended with a capital @p D does not apply here since
///       everything @p WSData handles is done in data coordinates,
///       anyway!
@interface WSData : NSObject <NSCopying, NSCoding, NSFastEnumeration>

@property (strong) NSArray<WSDatum *> *values;       ///< Array of @p NSDatum containing numerical data.
@property (readonly, getter = isSorted) BOOL sorted; ///< Flag if the data set is sorted by @p valueX.
@property (strong) NSString *nameTag;                ///< An (optional) name of the data set.

/** @brief Get an @p NSArray of zeros with specified length.
 
    This is an auxilliary method which makes life easier when using
    the initializers that ask for lots of data.
 */
+ (NSArray<NSNumber *> *)arrayOfZerosWithLen:(NSUInteger)len;

/** @return An empty data set (factory method). */
+ (instancetype)data;

/** @return Data set of Y-values (factory method). */
+ (instancetype)dataWithValues:(NSArray<NSNumber *> *)vals;

/** @return Data set of annotated Y-values (factory method). */
+ (instancetype)dataWithValues:(NSArray<NSNumber *> *)vals
                   annotations:(NSArray<NSNumber *> *)annos;

/** @return Data set of X,Y-pairs (factory method). */
+ (instancetype)dataWithValues:(NSArray<NSNumber *> *)vals
                       valuesX:(NSArray<NSNumber *> *)valsX;

/** @return Data set of annotated X,Y-pairs (factory method). */
+ (instancetype)dataWithValues:(NSArray<NSNumber *> *)vals
                       valuesX:(NSArray<NSNumber *> *)valsX
                   annotations:(NSArray<NSString *> *)annos;

/** @brief Return a data set of X,Y-pairs with uncertainties (factory
    method).
 
    @note See the methods @p
          initWithValues:withValuesX:withErrorMinY:with... for the
          conventions used for the uncertainties.
 */
+ (instancetype)dataWithValues:(NSArray<NSNumber *> *)vals
                       valuesX:(NSArray<NSNumber *> *)valsX
                     errorMinY:(NSArray<NSNumber *> *)errMinY
                     errorMaxY:(NSArray<NSNumber *> *)errMaxY
                     errorMinX:(NSArray<NSNumber *> *)errMinX
                     errorMaxX:(NSArray<NSNumber *> *)errMaxX;

/** @brief Sort the @p WSDatum objects in this class.

    Return an instance of @p WSData with the current data sorted by
    X-values (factory method). The content of the current instance is
    not affected.

    @return The new @p WSData set.
 */
- (WSData *)sortedDataUsingValueX;

/** @brief Return the @p WSDatum objects in this class with an index.

    Return an instance of @p WSData based on the current data in this
    instance. The new X-values set to integer numbers, i.e., indexed
    (factory method). The old content of X-values is not preserved in
    the new data set. The content of the current instance is not
    affected.

    @return The new @p WSData set.
 */
- (WSData *)indexedData;

/** Initialize an empty data set. */
- (instancetype)init;

/** @brief Initialize the data set with Y-values.
 
    After initialization, the data will only consist of Y-values, the
    other fields are empty.
 */
- (instancetype)initWithValues:(NSArray<NSNumber *> *)vals;

/** @brief Initialize the data set with annotated Y-values.
 
    The data will consist of Y-values and @p NSString values in the
    annotation field. The sizes of both arrays must match.
 */
- (instancetype)initWithValues:(NSArray<NSNumber *> *)vals
                   annotations:(NSArray<NSNumber *> *)annos;

/** @brief Initialize the data set with X,Y-pairs.
 
    The data will consist of pairs of X,Y-values. The sizes of both
    arrays must match.
 */
- (instancetype)initWithValues:(NSArray<NSNumber *> *)vals
                       valuesX:(NSArray<NSNumber *> *)valsX;

/** @brief Initialize the data set with annotated X,Y-pairs.
 
    The data will consist of pairs of X,Y-values and appropriate
    labels. The sizes of all three arrays must match.
 */
- (instancetype)initWithValues:(NSArray<NSNumber *> *)vals
                       valuesX:(NSArray<NSNumber *> *)valsX
                   annotations:(NSArray<NSString *> *)annos;

/** @brief Initialize the data set with X,Y-pairs with uncertainties.
 
    The data will consist of pairs of X,Y-values and (optional) their
    uncertainties. The sizes of @p vals and @p valsX must match. The
    arrays @p withErrorMin[X|Y] can either be empty or must match the
    X,Y-pairs. The array @p withErrorMax[X|Y] can either be empty or
    must match the X,Y-pairs. If the @p *Min* arrays are supplied, but
    the @p *Max* arrays are empty, the latter will be assumed to be
    identical to the former.  If neither errors are supplied (i.e.,
    the NSArray are empty), the data is assumed to have no uncertainty
    in X, Y or both.
 
    @note All uncertainties need to be positive!
 */
- (instancetype)initWithValues:(NSArray<NSNumber *> *)vals
                       valuesX:(NSArray<NSNumber *> *)valsX
                     errorMinY:(NSArray<NSNumber *> *)errMinY
                     errorMaxY:(NSArray<NSNumber *> *)errMaxY
                     errorMinX:(NSArray<NSNumber *> *)errMinX
                     errorMaxX:(NSArray<NSNumber *> *)errMaxX;

/** @brief Sort the current data by X-values.

    Unlike the @p sortedDataUsingValueX method this method acts on the
    current data content of the instance, i.e., the current content is
    changed.
 */
- (void)sortDataUsingValueX;

/** Add an individual data point.

    @param aDatum New datum which is appended.
 */
- (void)addDatum:(WSDatum *)aDatum;

/** Insert an individual data point.

    @param aDatum The new datum.
    @param index Location where the new datum is inserted.
 */
- (void)insertDatum:(WSDatum *)aDatum
            atIndex:(NSUInteger)index;

/** Replace a data point at a given index.

    @param index Location where the new datum is placed.
    @param aDatum The new datum.
 */
- (void)replaceDatumAtIndex:(NSUInteger)index
                  withDatum:(WSDatum *)aDatum;

/** Remove all data points. */
- (void)removeAllData;

/** Remove an individual data point.

    @param index Location where the datum will be removed.
 */
- (void)removeDatumAtIndex:(NSUInteger)index;

/** @brief Return an array of values extracted from data set.
 
    @param extractor The extraction selector returning a value from @p
           WSDatum.
    @return An array with the results.
 */
- (NSArray *)valuesWithSelector:(SEL)extractor;

/** @return Array of X-values extracted from data set. */
- (NSArray<NSNumber *> *)valuesFromDataX;

/** @return Array of Y-values extracted from data set. */
- (NSArray<NSNumber *> *)valuesFromDataY;

/** @return Array of annotations (type @p NSString) from data set.
 */
- (NSArray<NSString *> *)annotationsFromData;

/** @return Array of the customData slot from data set. */
- (NSArray *)customFromData;

/** @return Minimum data value. */
- (NAFloat)minimumValue;
- (NAFloat)minimumValueY;

/** @return Maximum data value. */
- (NAFloat)maximumValue;
- (NAFloat)maximumValueY;

/** @return Minimum X value. */
- (NAFloat)minimumValueX;

/** @return Maximum X value. */
- (NAFloat)maximumValueX;

/** @return Sum of all data values. */
- (NAFloat)integrateValue;

/** @return Number of data points in the set. */
- (NSUInteger)count;

/** @return Index of a specific datum. */
- (NSUInteger)indexOfDatum:(WSDatum *)datum;

/** @return A specific datum at index. */
- (WSDatum *)datumAtIndex:(NSUInteger)index;

/** @return The last datum or @p nil. */
- (WSDatum *)lastDatum;

/** @return The first datum or @p nil. */
- (WSDatum *)firstDatum;

/** @return X-value of a datum at index. */
- (NAFloat)valueXAtIndex:(NSUInteger)index;

/** @return Y-value of a datum at index. */
- (NAFloat)valueAtIndex:(NSUInteger)index;

/** @return The left-most data point (with smallest X-value). */
- (WSDatum *)leftMostDatum;

/** @return The right-most data point (with largest X-value). */
- (WSDatum *)rightMostDatum;

/** Objective-C array literal support. */
- (WSDatum *)objectAtIndexedSubscript:(NSUInteger)idx;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
- (id)objectForKeyedSubscript:(id<NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key;

@end
