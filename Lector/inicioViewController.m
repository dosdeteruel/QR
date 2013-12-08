//
//  inicioViewController.m
//  Lector
//
//  Created by German Bonilla Monterde on 07/12/13.
//  Copyright (c) 2013 German Bonilla Monterde. All rights reserved.
//

#import "inicioViewController.h"

@interface inicioViewController ()

@end

@implementation inicioViewController

@synthesize codigoEscaneadoLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.codeDetected = NO;
    [self setupCamera];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCamera
{
    // Inicializamos la sesión de captura de video
    self.session = [[AVCaptureSession alloc] init];
    
    // Configuramos como dispositivo la cámara de video
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Configuramos como dispositivo de entrada la cámara recien inicializada
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    [self.session addInput:self.input];
    
    // Configuramos como salida la captura de metadatos (para lectura de códigos)
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:self.output];
    
    // Configuramos como tipos de código a detectar, todos los disponibles
    // Es posible unicamente recoger códigos de unos tipos determinados
    self.output.metadataObjectTypes = [self.output availableMetadataObjectTypes];
    
    // Inicializamos una capa de previsualización para poder ver lo que la
    // cámara de video captura
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    [self.session startRunning];
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    // Éste método se ejecuta cada vez que se detecta algún código de los
    // tipos indicados
    
    // Comprobamos que no hayamos detectado un código ya
    if (!self.codeDetected) {
        
        // Recorremos los metadatos obtenidos
        for (AVMetadataObject *metadata in metadataObjects) {
            
            // Recuperamos el valor textual del código de barras o QR
            NSString *code =[(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            
            // Si el código no esta vacío
            if (![code isEqualToString:@""]) {
                
                // Marcamos nuestro flag de detección a YES
                self.codeDetected = YES;
                
                // Mostramos al usuario un alert con los datos del tipo de código y valor
                // detectado en nuestra sesión
                
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Código detectado" message:[NSString stringWithFormat:@"%@ \n %@",metadata.type,code] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                //alert show];
                
                codigoEscaneadoLabel.text = code;
                
                SystemSoundID soundID;
                NSString *path = [[NSBundle mainBundle] pathForResource:@"risa"
                                                                 ofType:@"mp3"];
                
                
                AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)[NSURL fileURLWithPath:path],&soundID);
                
                AudioServicesPlaySystemSound (soundID);
                
                [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(cerrarCodigo:) userInfo:nil repeats:NO];
            }
        }
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Éste método se ejecuta cuando el usuario pulsa el botón aceptar
    // en el UIAlertView que le hemos mostrado tras la detección
    // del código de barras o QR.
    
    // Marcamos de nuevo el flag de detección a NO para permitir al
    // usuario leer un nuevo código.
    self.codeDetected = NO;
}


-(IBAction)cerrarCodigo:(id)sender{
    self.codeDetected = NO;

}
@end
