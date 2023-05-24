//
//  ContentView.swift
//  WasteWise
//
//  Created by Aysha Hafizhatul on 21/05/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        NavigationView{
            
            //MARK: Page 1 BG
            ZStack{
                Image(uiImage: UIImage(named: "Page1")!)
                    .edgesIgnoringSafeArea(.all)
                
                //MARK: Navigation Button
                NavigationLink(destination: CameraView()
                    .navigationBarBackButtonHidden(true))
                {
                    Text("Get Started")
                }
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: 270, maxHeight: 65)
                .background(Color("DarkGreen"))
                .cornerRadius(20)
                .padding()
                .padding(.top, 610)
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
