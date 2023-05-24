//
//  CameraView.swift
//  WasteWise
//
//  Created by Aysha Hafizhatul on 21/05/23.
//

import SwiftUI
import AVFoundation
import Vision
import CoreML

struct CameraView: View{
    @StateObject private var cameraController = CameraController()
    @State private var classificationResult: String = ""
    
    @State private var capturedImage: UIImage?
    
    let wasteClassifier: VNCoreMLModel = {
        do {
            let config = MLModelConfiguration()
            let model = try WasteClassifier(configuration: config)
            return try VNCoreMLModel(for: model.model)
        } catch {
            fatalError("Failed to load Core ML model: \(error)")
        }
    }()
    
    var body: some View{
        
        //MARK: BG
        ZStack{
            Image(uiImage: UIImage(named: "AppBG")!)
                .edgesIgnoringSafeArea(.all)
            
            
            VStack{
                Text("Let's classify your rubbish")
                    .font(.system(size: 28, weight: .semibold))
                    .padding(.top, 83)
                if let image = capturedImage{
                    WastetypeView(result: classificationResult)
                }else {
                    CameraPreview(session: cameraController.session)
                        .frame(width: 310, height: 527)
                        .cornerRadius(5)
                }
                
                Spacer()
                //MARK: Camera Button
                HStack {
                    Button{
                        cameraController.capturePhoto(){photo in
                            capturedImage = photo
                            performImageAnalysis(image: photo)
                            
                        }
                        print("button pressed")
                    }label: {
                        ZStack{
                            Circle()
                                .strokeBorder(.black, lineWidth: 3)
                                .frame(width: 62, height: 62)
                            Circle()
                                .fill(.black)
                                .frame(width: 50, height: 50)
                        }
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear{
            cameraController.startSession()
        }
        .onDisappear{
            cameraController.stopSession()
        }
    }
    
    //MARK: Classify Image
    func performImageAnalysis(image: UIImage?){
        guard let image = image,
              let ciImage = CIImage(image: image) else {
            return
        }
        
        do {
            let request = VNCoreMLRequest(model: wasteClassifier) { request, error in
                if let error = error {
                    DispatchQueue.main.async {
                        print( "Error analyzing image: \(error.localizedDescription)")
                    }
                    return
                }
                
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    DispatchQueue.main.async {
                        self.classificationResult = "No results found"
                    }
                    return
                }
                
                let wasteName = topResult.identifier
                print(topResult.identifier)
                self.classificationResult = wasteName
            }
            
            let handler = VNImageRequestHandler(ciImage: ciImage)
            try handler.perform([request])
        } catch {
            DispatchQueue.main.async {
                print( "Error initializing VNCoreMLRequest: \(error.localizedDescription)")
            }
        }
        
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate{
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var isSaved = false
    @Published var picData = Data(count:0)
    @State var resultText: String = ""
    
    
    let wasteClassifier: VNCoreMLModel = {
        do {
            let config = MLModelConfiguration()
            let model = try WasteClassifier(configuration: config)
            return try VNCoreMLModel(for: model.model)
        } catch {
            fatalError("Failed to load Core ML model: \(error)")
        }
    }()
    
    func Check(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case.authorized:
            setUp()
            return
        case.notDetermined:
            AVCaptureDevice.requestAccess(for: .video) {(status) in
                if status{
                    self.setUp()
                }
            }
        case.denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setUp(){
        do{
            self.session.beginConfiguration()
            let device = AVCaptureDevice.default(for: .video)
            let input = try AVCaptureDeviceInput(device: device!)
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }
            self.session.commitConfiguration()
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func takePic(){
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.session.stopRunning()
            
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
            }
        }
        print("take pic")
    }
    
    func reTake(){
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
                self.isSaved = false
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil{
            return
        }
        print("pic taken...")
        
        guard let imageData = photo.fileDataRepresentation() else{return}
        self.picData = imageData
        
        guard let ciImage = CIImage(data: imageData) else {return}
        
        let imageClassifier = ImageClassifier()
        imageClassifier.processImage(for: ciImage)
        
        let classificationResult = imageClassifier.result
        print("Classification result:  \(classificationResult)")
        performImageAnalysis(image: UIImage(data : imageData))
    }
    
    func performImageAnalysis(image: UIImage?) {
        guard let image = image,
              let ciImage = CIImage(image: image) else {
            return
        }
        
        do {
            let request = VNCoreMLRequest(model: wasteClassifier) { request, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.resultText = "Error analyzing image: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    DispatchQueue.main.async {
                        self.resultText = "No results found"
                    }
                    return
                }
                
                let wasteName = topResult.identifier
                //                let confidence = topResult.confidence
                
                let resultString = "\(wasteName)"
                DispatchQueue.main.async {
                    self.resultText = resultString
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: ciImage)
            try handler.perform([request])
        } catch {
            DispatchQueue.main.async {
                self.resultText = "Error initializing VNCoreMLRequest: \(error.localizedDescription)"
            }
        }
    }
    
    func savePic(){
        let image = UIImage(data: self.picData)!
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.isSaved = true
        print("saved successfully...")
    }
}


class ImageClassifier: ObservableObject{
    var shared = createImageClassifier ()
    @Published var result : String = ""
    
    static func createImageClassifier () -> VNCoreMLModel{
        let defaultConfig = MLModelConfiguration ()
        
        let imageClassifierWrapper = try? WasteClassifier (configuration: defaultConfig)
        
        guard let imageClassifier = imageClassifierWrapper else{
            fatalError ("Failed to create an ML Model instance")
        }
        let imageClassifierModel = imageClassifier.model
        guard let imageClassifierVisionModel = try? VNCoreMLModel (for: imageClassifierModel) else{
            fatalError ("Failed to create VNCoreMLModel Instance")
        }
        return imageClassifierVisionModel
    }
    
    func processImage (for image : CIImage) {
        let imageClassificationRequest = VNCoreMLRequest(model: shared)
        let handler = VNImageRequestHandler(ciImage: image, orientation: .up)
        let requests : [VNRequest] = [imageClassificationRequest]
        try? handler.perform(requests)
        guard let observations = imageClassificationRequest.results as?
                [VNClassificationObservation] else{
            print("VNRequest produced the wrong result type :",(type(of:
                                                                        imageClassificationRequest.results)))
            return
        }
        if let firstResult = observations.first{
            self.result = firstResult.identifier
        }
    }
}


