//
//  ContentView.swift
//  JenniCare
//
//  Created by Casey Traina on 9/18/23.
//

import SwiftUI
import CoreData
import AVFoundation
import Combine

struct ContentView: View {

    @EnvironmentObject var appointment: Appointment
    @State var recorder: AVAudioRecorder?
    @State var isRecording = false
    
    @State var cancellable: AnyCancellable?

    @State var runningSummary = ""
    @State var summary = ""
    @State var questions: [String] = []
    @State var items: [String] = []

    @State var questionTapped = false
    @State var summaryTapped = false
    @State var itemsTapped = false
    
    @Binding var isActive: Bool
    
    @State var counter = 0
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            GeometryReader { geo in
                VStack(alignment: .center) {
                    
                    MyText(text: "Active", size: geo.size.width * 0.07, bold: true, alignment: .center, color: .black)
                        .padding(.horizontal)
                        .frame(width: geo.size.width * 0.8)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(LIGHT_BLUE)
                        )

                    
                    VStack {
                        HStack {
                            Image(systemName: "text.book.closed.fill")
                                .foregroundColor(.black)
                                .font(.system(size: geo.size.width * 0.1))
                            MyText(text: "Summary", size: geo.size.width * 0.065, bold: true, alignment: .center, color: .black)
                            
                            if appointment.summaryLoading {
                                ProgressView()
                                    .padding(.horizontal)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        
                        if (!itemsTapped && !questionTapped) {
                            
                            ScrollView(showsIndicators: false) {
                                VStack {
                                    MyText(text: summary, size: geo.size.width * 0.05, bold: false, alignment: .leading, color: .black)
                                        .textSelection(.enabled)
                                        .padding(10)
                                }
                                .frame(width: geo.size.width * 0.9)
                            }
                            
                        }
                        
                    }
                    .frame(width: geo.size.width * 0.9, height: summaryTapped ? geo.size.height * 0.55 : (questionTapped || itemsTapped) ? geo.size.height * 0.15 : geo.size.height * 0.3)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(LIGHT_BLUE)
                    )
                    .onTapGesture {
                        withAnimation {
                            summaryTapped.toggle()
                            itemsTapped = false
                            questionTapped = false
                        }
                    }
                    
                    VStack {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.black)
                                .font(.system(size: geo.size.width * 0.1))
                            MyText(text: "Questions", size: geo.size.width * 0.065, bold: true, alignment: .center, color: .black)
                            
                            if appointment.questionsLoading {
                                ProgressView()
                                    .padding(.horizontal)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        
                        if (!summaryTapped && !itemsTapped) {
                            
                            ScrollView(showsIndicators: false) {
                                VStack {
                                    ForEach(questions, id: \.self) { question in
                                        HStack {
                                            MyText(text: question, size: geo.size.width * 0.05, bold: false, alignment: .leading, color: .black)
                                                .textSelection(.enabled)
//                                                .frame(maxWidth: geo.size.width * 0.85)
                                            
                                            //                                            .frame(width: geo.size.width * 0.9)
                                                .padding(10)
                                            Spacer()
                                        }
                                    }
                                }
                                .frame(width: geo.size.width * 0.9)
                            }
                            
                        }
                    }
                    .frame(width: geo.size.width * 0.9, height: questionTapped ? geo.size.height * 0.55 : (summaryTapped || itemsTapped) ? geo.size.height * 0.15 : geo.size.height * 0.25)
//                    .frame(maxHeight: geo.size.height * 0.25)

                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(LIGHT_BLUE)
                    )
                    .onTapGesture {
                        withAnimation {
                            questionTapped.toggle()
                            summaryTapped = false
                            itemsTapped = false
                        }
                    }
                    //                .padding()
                    
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.black)
                                .font(.system(size: geo.size.width * 0.1))
                            MyText(text: "Todo", size: geo.size.width * 0.065, bold: true, alignment: .center, color: .black)
                            
                            if appointment.itemsLoading {
                                ProgressView()
                                    .padding(.horizontal)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        
                        if (!questionTapped && !summaryTapped) {
                            
                            ScrollView(showsIndicators: false) {
                                VStack {
                                    ForEach(items, id: \.self) { item in
                                        HStack {
                                            MyText(text: item, size: geo.size.width * 0.05, bold: false, alignment: .leading, color: .black)
                                                .padding(10)
                                                .textSelection(.enabled)
//                                                .frame(maxWidth: geo.size.width * 0.85)
                                            
                                            Spacer()
                                        }
                                    }
                                }
                                .frame(width: geo.size.width * 0.9)
                            }
                            
                        }
                            
                    }
                    .frame(width: geo.size.width * 0.9, height: itemsTapped ? geo.size.height * 0.55 : (questionTapped || summaryTapped) ? geo.size.height * 0.15 : geo.size.height * 0.25)
//                    .frame(maxHeight: geo.size.height * 0.25)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(LIGHT_BLUE)
                    )
                    .onTapGesture {
                        withAnimation {
                            itemsTapped.toggle()
                            summaryTapped = false
                            questionTapped = false
                        }
                    }
                    //                .padding()
                    
                    Button(action: {
                        if isRecording {
                            isRecording.toggle()
                        } else {
                            //done
//                            Task {
                               isActive = false
//                            }
                        }
                    }, label: {
                        MyText(text: isRecording ? "End" : "Done", size: geo.size.width * 0.065, bold: true, alignment: .center, color: .black)
                            .padding(5)
                            .frame(width: geo.size.width * 0.9)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(isRecording ? .red : LIGHT_BLUE)
                            )
                    })
                }
                .onChange(of: isRecording) { newRecording in
                    if newRecording {
                        startRecording()
                    } else {
                        Task {
                            await stopRecordingAndTranscribe()
                            await appointment.addToDB(runningSummary, summary: summary)
                        }
                    }
                }
                .onAppear {
                    requestRecordingPermission()
                    
                    cancellable = Timer.publish(every: 5.0, on: .main, in: .common)
                        .autoconnect()
                        .sink { _ in
                            if isRecording {
                                Task {
                                    counter += 1
                                    await stopRecordingAndTranscribe()
                                    questions = await appointment.getFollowUpQuestions()
                                    items = await appointment.getActionItems()
                                    
                                }
                            }
                        }
                    
                    isRecording.toggle()
                    
                    
                }
                .frame(width: geo.size.width)
            }
        }
    }
    
    private func requestRecordingPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            if !allowed {
                // Handle the case where the user denies the permission.
            }
        }
    }
    
    func stopRecordingAndTranscribe() async {
        
        recorder?.stop()
        
        if isRecording {
            startRecording()
        }
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(counter-1).m4a")
        
        do {
            let audioData = try Data(contentsOf: audioFilename)
            if let transcribedText = await appointment.transcribe(audioData, fileName: "recording\(counter-1).m4a") {
                print("Transcribed Text: \(transcribedText)")
                runningSummary += " \(transcribedText)"
                summary = await appointment.getSummary() ?? "There was an issue generating your summary"
                print(counter)
            } else {
                print("Transcription failed.")
            }
        } catch {
            print("Error reading the recorded file: \(error)")
        }
    }

    
    private func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording\(counter).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            recorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            recorder?.record()
        } catch {
            print("Could not start recording")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.temporaryDirectory
    }

}


//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
