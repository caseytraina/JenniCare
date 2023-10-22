//
//  HomeView.swift
//  JenniCare
//
//  Created by Casey Traina on 10/10/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appointment: Appointment

    @State var navActive = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
        GeometryReader { geo in
            VStack(alignment: .center) {
                MyText(text: "Jenni Care", size: geo.size.width * 0.07, bold: true, alignment: .center, color: .black)
                    .padding(.horizontal)
                    .frame(width: geo.size.width * 0.8)
                    .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(LIGHT_BLUE)
                    )
                
                Spacer()
                Spacer()
                
                NavigationLink(destination: ContentView(isActive: $navActive).environmentObject(appointment), isActive: $navActive) {
                    Image(systemName: "atom")
                        .foregroundColor(.black)
                        .font(.system(size: geo.size.width * 0.4))
                        .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.5)
                        .overlay(content: {
                            Circle()
                                .stroke(lineWidth: 20)
                                .foregroundColor(LIGHT_BLUE)
                                .frame(width: geo.size.width * 0.65, height: geo.size.width * 0.65)
                            
                        })
                }
                .frame(width: geo.size.width * 0.65, height: geo.size.width * 0.65)

                MyText(text: "Start", size: geo.size.width * 0.06, bold: false, alignment: .center, color: .black)
                    .padding()
                Spacer()
                
                MyText(text: "Start Appointment", size: geo.size.width * 0.08, bold: true, alignment: .center, color: .black)
                    .padding()


                
                Spacer()
                
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        }

    }
}
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}

let LIGHT_BLUE = Color(red: 183/255, green: 209/255, blue: 249/255)


struct MyText: View {
    var text: String
    var size: CGFloat
    var bold: Bool
    var alignment: TextAlignment
    var color: Color
    
    
    init(text: String, size: CGFloat, bold: Bool, alignment: TextAlignment, color: Color) {
        self.size = size
        self.bold = bold
        self.alignment = alignment
        self.text = text
        self.color = color

    }
    // A generalized text since Apple doesn't support a default text functionality
    // Allows user to input a string, font size, bold/unbold, and alignment
    var body: some View {
            Text(text)
                .foregroundColor(color)
                .font(Font.custom(bold ? "Helvetica Bold" : "Helvetica", size: size))
            //            .padding(.horizontal, 15)
                .padding(.vertical, bold ? 5 : 0)
                .multilineTextAlignment(alignment)

    }
}
