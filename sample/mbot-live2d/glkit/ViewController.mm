/**
 *
 *  You can modify and use this source freely
 *  only for the development of application related Live2D.
 *
 *  (c) Live2D Inc. All rights reserved.
 *  Modified by Wang Yu on 11/27/15.
 */

#import "ViewController.h"
#import "Live2DModelIPhone.h"
#import "util/UtSystem.h"
#import "MBTTSDelegate.h"
#import "MBRecognizerDelegate.h"
#import "MBSimSimiRequestDelegate.h"

using namespace live2d;

@interface ViewController ()

@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController
{
	Live2DModelIPhone* live2DModel ;
	NSMutableArray* textures ;
    IBOutlet UILabel *textLabel;
    IBOutlet UILabel *statusLabel;
}

- (void)dealloc
{
	
	delete live2DModel;
	
	
	for (int i=0; i<[textures count]; i++)
	{
		GLuint glTexNo=[[textures objectAtIndex:i] intValue];
		glDeleteTextures(1,&glTexNo);
	}

    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [_context release];
    [textLabel release];
    [statusLabel release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1] autorelease];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
	
	NSString* MODEL_FILE = @"haru" ;
	NSString* TEXTURE_PATH[] ={
		@"texture_00" ,
		@"texture_01" ,
		@"texture_02" ,
		NULL
	} ;
	
	NSString *modelpath = [[NSBundle mainBundle] pathForResource:MODEL_FILE ofType:@"moc"];
	
	live2DModel = Live2DModelIPhone::loadModel( [modelpath UTF8String] ) ;
	
	for( int i = 0 ; TEXTURE_PATH[i] != NULL ; i++ ){
		NSString* texturePath = [[NSBundle mainBundle] pathForResource:TEXTURE_PATH[i] ofType:@"png"];
		GLKTextureInfo* textureInfo =
		[GLKTextureLoader textureWithContentsOfFile:texturePath
											options:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSNumber numberWithBool:YES] ,GLKTextureLoaderApplyPremultiplication,
													 [NSNumber numberWithBool:YES] ,GLKTextureLoaderGenerateMipmaps,nil
													 ]
											  error:nil];
				
		int glTexNo = [textureInfo name] ;
		live2DModel->setTexture( i , glTexNo ) ;
		[textures addObject:[NSNumber numberWithInt:glTexNo]];
	}
	
	float modelWidth = live2DModel->getCanvasWidth(); 
    float width = [[UIScreen mainScreen] bounds].size.width;
	float height = [[UIScreen mainScreen] bounds].size.height;
	
	glOrthof(
             0,
             modelWidth,
             modelWidth / (width/height),
             0,
             0.5f, -0.5f
             );
    
    
    // init xunfei api
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",@"55f9671c"];
    
    [IFlySpeechUtility createUtility:initString];
    self.voiceRSynthesizer = [[MBTTSDelegate alloc] init];
    self.voiceRecognizer = [[MBRecognizerDelegate alloc] init];
    self.simSimiRequestDelegate = [[MBSimSimiRequestDelegate alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRecognizerStartListening:) name:@"RecognizerStartListening" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStartSpeaking:) name:@"TTSSpeakStarted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveRecognitionResult:) name:@"ReceiveRecognitionResult" object:nil];
}


- (void)onRecognizerStartListening:(NSNotification*)note{
    [statusLabel setText:@"Listening"];
}

- (void)onStartSpeaking:(NSNotification*)note{
    [statusLabel setText:@"Speaking"];
}

- (void)onReceiveRecognitionResult:(NSNotification*)notification{
    [textLabel setText:notification.object];
    [statusLabel setText:@"Thinking"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
//    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClearColor(0, 0, 0, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	double t = UtSystem::getUserTimeMSec()/1000.0 ;
	live2DModel->setParamFloat("PARAM_ANGLE_X", 30 * sin( t ) );
    live2DModel->setParamFloat("PARAM_MOUTH_FORM", 30 * sin( t ) );
	
	live2DModel->update() ;
	live2DModel->draw() ;
    
}

@end
