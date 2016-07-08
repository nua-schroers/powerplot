//
//  WSGraphConnections.h
//  PowerPlot
//
//  Created by Wolfram Schroers on 18.10.10.
//  Copyright 2010-2013 Numerik & Analyse Schroers. All rights reserved.
//

#import "NARange.h"
#import "WSDataDelegate.h"

@class WSConnection;

/// This class describes the connections of data in a graph as plotted
/// by the @p WSPlotGraph plot. The data itself must correspond to the
/// connection indices collected in a @p WSData object.
@interface WSGraphConnections : NSObject <NSCopying, NSCoding, NSFastEnumeration>

@property (strong) NSMutableSet *connections;                 ///< Connections of objects in a @p WSData object.
@property (weak, nonatomic) id <WSDataDelegate> dataDelegate; ///< Data delegate for nodes.

/** @return The total number of connections. */
- (NSUInteger)count;

/** @return The @p dataD name tag (if the delegate has been setup and
    there is any).
 */
- (NSString *)nameTag;

/** @return A random connection (or nil if there is none). */
- (WSConnection *)anyConnection;

/** Add a new connection. */
- (void)addConnection:(WSConnection *)connection;

/** Remove a single connection. */
- (void)removeConnection:(WSConnection *)connection;

/** Remove all connections. */
- (void)removeAllConnections;

/** Set all node connections to be undirected. */
- (void)removeAllDirections;

/** Set all connections to a given color. */
- (void)colorAllConnections:(UIColor *)color;

/** Set all connections to a given strength. */
- (void)strengthAllConnections:(NAFloat)strength;

/** @return The minimum connection strength. */
- (NAFloat)minimumStrength;

/** @return The maximum connection strength. */
- (NAFloat)maximumStrength;

/** @brief Return the connection between two nodes (or @p nil for
    none).
 
    @return The requested connection. In case of several connections,
            a random connection is returned.
 */
- (WSConnection *)connectionBetweenNode:(NSUInteger)a
                                andNode:(NSUInteger)b;

/** @brief Return a set of all connections between two nodes.

    Return a @p WSGraphConnections object containing all connections
    between two nodes (or nil if there is none). This method can be
    used to normalize a graph (combining similar connections into a
    single one) or to do specific analysis on the graph.

    @param a One graph node in a data set.
    @param b Another graph node in a data set.
    @return A @p WSGraphConnections object containing all connecting
            links.
 */
- (WSGraphConnections *)connectionsBetweenNode:(NSUInteger)a
                                       andNode:(NSUInteger)b;

/** @return The total number of connections a given node has.
 
    A circular connection is counted as one. The direction is
    irrelevant.

    @note In case of multiple connections to a single node connections
          are counted separately.
 */
- (NSUInteger)connectionsOfNode:(NSUInteger)a;

/** @return The total number of directed incoming connections.
 
    The total number of links a given node receives. An incoming
    connection is a connection whose direction property is either @p
    kGDirection with the given node a as the "to" link, @p
    kGDirectionInverse with the given node as the "from" link or a @p
    kGDirectionBoth with the given node as either the "to" or the
    "from" link.

    @note In case of multiple connections to a single node connections
          are counted separately.
 */
- (NSUInteger)incomingToNode:(NSUInteger)a;

/** @return The total number of directed outgoing connections.
 
    The total number of links a given node originates. The conventions
    regarding directions are as in @p incomingToNode: with the meaning
    of "from" and "to" reversed.
 */
- (NSUInteger)outgoingFromNode:(NSUInteger)a;

/** @return The total incoming connection strength.

    All directed incoming connections a given node receives are
    counted and their respective strength is summed up. The
    conventions regarding directions are as in @p incomingToNode:.
 */
- (NAFloat)incomingToNodeStrength:(NSUInteger)a;

/** @return The total outgoing connection strength.

    All directed outgoing connections a given node has are counted and
    their respectives strength is summed up. The conventions regarding
    directions are as in @p incomingToNode: with the meaning of "from"
    and "to" reversed.
 */
- (NAFloat)outgoingFromNodeStrength:(NSUInteger)a;

/** @return The total node connection strength.
 
    Sum of strengths of all directed incoming and outgoing
    connections.
 */
- (NAFloat)nodeActivity:(NSUInteger)a;

@end