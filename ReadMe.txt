CONFIDENTIAL
============================================================
	Live2D Cubism SDK for iPhone Version 2.0.06_1

	(c) Live2D Inc.
============================================================

This is a Software Development Kit (SDK) for developing Live2D-Cubism-powered applications on iPhone
The SDK contains proprietary libraries and sample projects.
Read this document when using the SDK.

------------------------------
	License
------------------------------
	Read Live2D License Agreement
	for business
	http://live2d.com/en/sdk_license_cubism 

	for indie
	http://live2d.com/en/sdk_license_cubism_indie


------------------------------
	Operating environment
------------------------------
	Programming language : C++
	Library : (.a)
			arm64,armv7,armv7s
	
	Graphics environment : OpenGL ES1

	Platform : iOS 5.1.1 or later
	Development environment of sample : XCode 5.1.1


------------------------------
	Texture color API
------------------------------
	int textureNo = 0;
	float r = 0.5;
	float g = 0.5;
	float b = 0.5;

	live2DModel->setTextureColor(textureNo,r,g,b);

	// Multiplication (Default)
	live2DModel->setTextureBlendMode(textureNo, Live2D::L2D_COLOR_BLEND_MODE_MULT);

	// Adding
	live2DModel->setTextureBlendMode(textureNo, Live2D::L2D_COLOR_BLEND_MODE_ADD);

	// Interpolate
	// t * Texture + (1-t) * Color .
	float t=0.5;
	live2DModel->setTextureInterpolate(textureNo, t);
	live2DModel->setTextureBlendMode(textureNo, Live2D::L2D_COLOR_BLEND_MODE_INTERPOLATE);


------------------------------
	Release Note
------------------------------
	The latest release available here:
	http://sites.cybernoids.jp/cubism-sdk2_e

	2015/02/05  Version 2.0.06_1

	2014/10/20  Version 2.0.02_1
		New API for adding color to texture
		New API for interpolate color to texture
		Fix misspelling.
		setTexutureColor > setTextureColor
	
	2014/08/28  Version 2.0.00_1

	2014/01/07  Version 1.0.02_1
			Officially released Live2D Cubism SDK.

	Update notifications are sent to registered email address.


------------------------------
	Online Manual
------------------------------
	Live2D Manual
	http://sites.cybernoids.jp/cubism2_e/

	iPhone develop tutorial
	http://sites.cybernoids.jp/cubism2_e/sdk_tutorial/platform-setting/ios

	Live2D API Reference
	http://doc.live2d.com/api/core/cpp2.0e/
	

------------------------------
	Folder Structure
------------------------------
	ReadMe.txt	This document file
	lib			Folder containing libraries
	include		Folder containing include files for libraries 
	framework	Folder containing codes for Live2D framework used in samples
	sample		Folder containing sample projects


------------------------------
	Sample
------------------------------
	sample folder contains projects developed using XCode
	Sources of the sample projects can be accessed and modified for the sole purpose of developing Live2D-related applications.

	Simple
		Minimum sample.
		It describes all basic processes of Live2D in a single file.

	SampleApp1
		Sample with basic functions.
		It plays motions, controls expressions, switches poses, configures physics computations, etc.

	GLKit
		Minimum sample with GLKit.
		
	Benchmark
		Benchmark for Live2D.


------------------------------
	Support
------------------------------
	SDK support and customization services are available
	Contact Live2D through representatives or the website:

	http://live2d.com/en/


------------------------------
	User Community
------------------------------
	Find and build knowledge among creators and developers in the Live2D community.

	http://community.live2d.com/
	