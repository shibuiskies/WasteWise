//
//  WastetypeView.swift
//  WasteWise
//
//  Created by Aysha Hafizhatul on 23/05/23.
//

import SwiftUI

struct WastetypeView: View {
    
    @State var result: String
    @State private var showTips = false
    
    var body: some View {
        //MARK: BG
        ZStack{
            Image(uiImage: UIImage(named: "AppBG")!)
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                Text("Your kind of rubbish:")
                    .font(.system(size: 28, weight: .semibold))
                    .padding(.bottom, 50)
                
                //MARK: Rubbish Type
                if result == "Recycle"{
                    Image("Recycle")
                        .frame(width: 332, height: 291)
                    
                    //MARK: Recycle Tips
                    Button{
                        showTips.toggle()
                        print("toggle")
                    } label: {
                        Text("Tips for managing recyclable waste")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color("Font"))
                            .underline()
                            .padding(.top, 100)
                            .frame(width: 336, height: 100)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showTips){
                        RecycleTips()
                            .padding(.horizontal)
                            .padding(.top, 32)
                            .presentationDetents([.fraction(0.60)])
                            .presentationDragIndicator(.visible)
                    }
                } else if result == "Organic"{
                    Image("Organic")
                        .frame(width: 332, height: 291)
                    
                    //MARK: Organic Tips
                    Button{
                        showTips.toggle()
                        print("toggle")
                    } label: {
                        Text("Tips for managing organic waste")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color("Font"))
                            .underline()
                            .padding(.top, 100)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showTips){
                        OrganicTips()
                            .padding(.horizontal)
                            .padding(.top, 32)
                            .presentationDetents([.medium, .fraction(0.80)])
                            .presentationDragIndicator(.visible)
                    }
                }
                //MARK: Navigation Button
                NavigationLink(destination: CameraView()
                    .navigationBarBackButtonHidden(true))
                {
                    Text("Classify Other Rubbish")
                }
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: 270, maxHeight: 65)
                .background(Color("DarkGreen"))
                .cornerRadius(20)
                .padding(.top, 40)
                
                
                
            }
        }
    }
}

struct RecycleTips: View{
    var body: some View{
        VStack (alignment: .leading){
            HStack (alignment: .top){
                Text("•")
                Text("Ketahui panduan dan peraturan daur ulang setempat.")
            }
            .padding(.vertical, 4)
            
            HStack (alignment: .top){
                Text("•")
                Text("Pahami barang-barang umum yang dapat didaur ulang, seperti kertas, kardus, botol plastik, kaca, dan kaleng alumunium.")
            }
            .padding(.vertical, 4)
            
            HStack (alignment: .top){
                Text("•")
                Text("Periksa label daur ulang pada produk.")
            }
            .padding(.vertical, 4)
            
            HStack (alignment: .top){
                Text("•")
                Text("Bersihkan botol, kaleng, dan kotak untuk menghindari kontaminasi.")
            }
            .padding(.vertical, 4)
            
            
            HStack (alignment: .top){
                Text("•")
                Text("Lipat kardus untuk menghemat ruang dan pisahkan komponen yang tidak dapat didaur ulang, seperti kemasan plastik atau styrofoam.")
            }
            .padding(.vertical, 4)
            
            HStack (alignment: .top){
                Text("•")
                Text("Temukan fasilitas daur ulang terdekat atau program daur ulang yang tersedia di wilayah terdekat.")
            }
            .padding(.vertical, 4)
            
            HStack (alignment: .top){
                Text("•")
                Text("Gunakan reusable bag, botol minum, dan kotak untuk meminimalisir sampah plastik.")
            }
            .padding(.vertical, 4)
        }
        
    }
}

struct OrganicTips: View{
    var body: some View{
        VStack (alignment: .leading) {
            HStack (alignment: .top){
                Text("•")
                Text("Buat kompos sisa makanan, buah, kupasan sayur, ampas kopi, kantong teh, dan sisa tanaman pangkas.")
            }
            .padding(.vertical, 4)
            HStack (alignment: .top){
                Text("•")
                Text("Pisahkan sampah organik dari jenis sampah lainnya.")
            }
            .padding(.vertical, 4)
            HStack (alignment: .top){
                Text("•")
                Text("Buat kompos sisa makanan, buah, kupasan sayur, ampas kopi, kantong teh, dan sisa tanaman pangkas.")
            }
            .padding(.vertical, 4)
            HStack (alignment: .top){
                Text("•")
                Text("Periksa program pengelolaan limbah lokal yang disediakan oleh pemerintah kota.")
            }
            .padding(.vertical, 4)
            HStack (alignment: .top){
                Text("•")
                Text("Pelajari peraturan dan panduan setempat terkait pengelolaan sampah organik.")
            }
            .padding(.vertical, 4)
        }
    }
    
}
struct WastetypeView_Previews: PreviewProvider {
    static var previews: some View {
        WastetypeView(result: "Organic")
    }
}
