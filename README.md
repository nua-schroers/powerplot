[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![platforms](https://img.shields.io/badge/platforms-iOS-lightgrey.svg) [![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/nua-schroers/powerplot/master/LICENSE) ![Travis build](https://travis-ci.org/nua-schroers/powerplot.svg?=master)

# PowerPlot v3: Charting and Business Intelligence/ Reporting for iOS

PowerPlot is a Charting and Business Intelligence/Reporting framework
for iOS. It ships with a large collection of default charts, plot and
color styles and is highly configurable. Still, it is easy to use and
deploy.

## Installing/using the framework

The framework can be installed in three ways:

* With the Carthage build tool (see below). This is the recommended
  way.
* By manually adding a specific build of the framework to the
  project. This is not recommended since the framework cannot be
  updated easily.
* By manully adding the source files to the project. This is not
  recommended since updating becomes very hard.

### Carthage

PowerPlot supports `iOS 8.0+`.

To add PowerPlot to your app:

  1. Add the following line to your `Cartfile` (or create the file if
it does not yet exist):
    
    github "nua-schroers/powerplot"

  2. As described on the
  [Carthage instructions page](https://github.com/Carthage/Carthage)
  run

    carthage update --platform iOS
    
  3. Add the resulting `PowerPlot.framework` framework to the "Linked
     Frameworks and Libraries" section of the "General" tab of the app
     project.
     
  4. Add the "copy-frameworks" build phase.
  
### CocoaPods

To this end, CocoaPods is not (yet) supported.

## Usage examples and apps

Usage examples are provided in a separate project; this can be found
at [Github](https://github.com/nua-schroers/powerplot-demo).


