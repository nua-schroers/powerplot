//
//  PowerPlot.h
//  PowerPlot
//
//  Created by Dr. Wolfram Schroers on 7/8/16.
//  Copyright © 2016 Wolfram Schroers. All rights reserved.
//

///
/// Overview
///
/// PowerPlot is a Charting and Business Intelligence/Reporting
/// framework for iOS. It ships with a large collection of default
/// charts, plot and color styles and is highly configurable. Still,
/// it is easy to use and deploy.
///
/// License
///
/// Versions below 3.0 are subject to a dual license: licensees could
/// choose between a proprietary commercial license and the
/// GPLv3. Versions 3 and above are subject to the MIT license.
///
/// The MIT license
///
/// Copyright (c) 2009-2016 Numerik & Analyse Schroers
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///
/// Reference
///
/// The library can be obtained from
/// http://powerplot.nua-schroers.de
///

#import <UIKit/UIKit.h>

//! Project version number for PowerPlot.
FOUNDATION_EXPORT double PowerPlotVersionNumber;

//! Project version string for PowerPlot.
FOUNDATION_EXPORT const unsigned char PowerPlotVersionString[];

// Import of individual header files.
#import "NAAmethyst.h"
#import "NARange.h"
#import "WSAuxiliary.h"
#import "WSAxisLocation.h"
#import "WSAxisLocationDelegate.h"
#import "WSAxisProperties.h"
#import "WSBarPlotFactory.h"
#import "WSBarProperties.h"
#import "WSBinning.h"
#import "WSChart.h"
#import "WSChartAnimation.h"
#import "WSChartAnimationKeys.h"
#import "WSColor.h"
#import "WSColorScheme.h"
#import "WSConnection.h"
#import "WSConnectionDelegate.h"
#import "WSContour.h"
#import "WSControllerGestureDelegate.h"
#import "WSCoordinate.h"
#import "WSCoordinateDelegate.h"
#import "WSCoordinateDirection.h"
#import "WSCoordinateTransform.h"
#import "WSCustomProperties.h"
#import "WSData.h"
#import "WSDataDelegate.h"
#import "WSDataOperations.h"
#import "WSDataPointProperties.h"
#import "WSDatum.h"
#import "WSDatumCustomization.h"
#import "WSDiscProperties.h"
#import "WSGraph.h"
#import "WSGraphConnections.h"
#import "WSGraphPlotFactory.h"
#import "WSLinePlotFactory.h"
#import "WSNode.h"
#import "WSNodeProperties.h"
#import "WSPlot.h"
#import "WSPlotAxis.h"
#import "WSPlotBar.h"
#import "WSPlotController.h"
#import "WSPlotCustomView.h"
#import "WSPlotData.h"
#import "WSPlotDisc.h"
#import "WSPlotFactoryDefaults.h"
#import "WSPlotGraph.h"
#import "WSPlotRegion.h"
#import "WSPlotTemplate.h"
#import "WSTicks.h"
