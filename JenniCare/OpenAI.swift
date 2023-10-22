//
//  OpenAI.swift
//  JenniCare
//
//  Created by Casey Traina on 9/23/23.
//

import Foundation
import OpenAIKit
import AsyncHTTPClient
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift


class Appointment: ObservableObject {
    
    var transcription: String = ""
    var summary: String?
    var actionItems: [String]?
    var questions: [String]?
    
    var apiKey: String

    var organization: String
    
    var urlSession: URLSession
    var configuration: Configuration
    var openAIClient: Client
    
    @Published var summaryLoading = false
    @Published var itemsLoading = false
    @Published var questionsLoading = false


    
    init(summary: String? = nil, actionItems: [String]? = nil, questions: [String]? = nil) {
        
        self.apiKey = "ENTER_API_KEY_HERE" //       <--- TODO
        self.organization = "ORGANIZATION_ID" //    <--- TODO
        
        self.summary = summary
        self.actionItems = actionItems
        self.questions = questions
        
        self.urlSession = URLSession(configuration: .default)
        self.configuration = Configuration(apiKey: apiKey, organization: organization)
        self.openAIClient = OpenAIKit.Client(session: urlSession, configuration: configuration)
    }
    
    func sendChat(_ request: String) async {
        do {
            let completion = try await openAIClient.completions.create(
                model: Model.GPT3.davinci,
                prompts: [request]
            )
            print(completion)
        } catch {
            print(error)
        }
    }
    
    func getSummary() async -> String? {
        DispatchQueue.main.async {
            self.summaryLoading = true
        }
        do {
            let completion = try await openAIClient.chats.create(model: Model.GPT3.gpt3_5Turbo,
                                                           messages: [
                                                            Chat.Message.system(content: "You are a medical assistant. You are to only use the information given to you and to not infer at all."),
                                                            Chat.Message.user(content:
                            """
                            The following is a transcription of an appointment between a patient and their doctor: \(transcription). Please summarize it and return the summary in the following JSON form:
                            
                                {
                                items : ["Summary"]
                                }
                            
                            """
                                                           )],
                                                           maxTokens: 150)
//            let completion = try await openAIClient.completions.create(
//                model: Model.GPT3.davinci,
//                prompts: ["The following is a transcription of an appointment between a patient and their doctor. Summarize it into a maximum of 4-6 sentences: \(transcription)"]
//            )
            
            print(completion)

//            let summary = completion.choices[0].message.content
//            return summary
            
            let summary = completion.choices[0].message.content
//            var items =
            if let items = parseJSON(summary, isAction: false) {
                return items[0]
            }
            DispatchQueue.main.async {
                self.summaryLoading = false
            }
            return nil

            
            
            
        } catch {
            print(error)
        }
        return nil
    }
    
    func getActionItems() async -> [String] { //}[Substring]? {
        
        DispatchQueue.main.async {
            self.itemsLoading = true
        }
        
        do {
//            let completion = try await openAIClient.completions.create(
//                model: Model.GPT3.davinci,
//                prompts: ["The following is a transcription of an appointment between a patient and their doctor. Please provide a concise list of the action items that the doctor requests the patient to take: \(transcription). Please return an array of strings in the form: Item 1, Item 2, Item 3, etc."]
//            )
            
            let completion = try await openAIClient.chats.create(model: Model.GPT3.gpt3_5Turbo,
                                                           messages: [
                                                            Chat.Message.system(content: "You are a medical assistant. You are to only use the information given to you and to not infer at all. You are not to use any unnecessary header text."),
                                                            Chat.Message.user(content:
                    """
                    The following is a transcription of an appointment between a patient and their doctor: \(transcription).

                    Please provide a concise list of todos that the doctor has advised the patient to take. Only list items specificially mentioned in the transcription. Do not infer at all. If the doctor has not requested any, return an empty set. Please reply in the following JSON form:
                    {
                    items : ["Item 1", "Item 2", "Item 3"]
                    }
                    """
                                                                             )],
                                                           maxTokens: 150)
            
            

            let summary = completion.choices[0].message.content
            var items = parseJSON(summary, isAction: false)
            self.actionItems = items
            print(self.actionItems)
            
            DispatchQueue.main.async {
                self.itemsLoading = false
            }
            
            return items ?? []
            
        } catch {
            print(error)
        }
        return []
    }
    
    struct JSON: Codable {
        let items: [String]
    }
    
    func parseJSON(_ text: String, isAction: Bool) -> [String]? {
        do {
            // Convert the JSON string to Data
            let jsonData = Data(text.utf8)

            // Decode the JSON data to your defined structure
            let items = try JSONDecoder().decode(JSON.self, from: jsonData)

            // Print or use the array of strings
            print(items.items)
            return items.items
        } catch {
            print("Error decoding JSON: \(error)")
        }
        return nil
    }
    
    func getFollowUpQuestions() async -> [String] {//}[Substring]? {
        
        DispatchQueue.main.async {
            self.questionsLoading = true
        }
        
        do {
            let completion = try await openAIClient.chats.create(model: Model.GPT3.gpt3_5Turbo,
                                                           messages: [
                                                            Chat.Message.system(content: "You are a medical assistant. You are to only use the information give to you and to not infer at all. You are not to use any unnecessary header text."),
                                                            Chat.Message.user(content:
                     """
                     The following is a transcription of an appointment between a patient and their doctor: \(transcription).

                     Please provide a concise list of follow-up questions that the patient can ask the doctor to receive greater clarity on the doctor's responses. These questions should be from the point of view of the patient. Please provide them in the following JSON form:
                     {
                     items : ["Question 1", "Question 2", "Question 3"]
                     }
                     """
                                                                             )],
                                                           maxTokens: 150)

            
            
            
            
//            print(completion)

            let summary = completion.choices[0].message.content
            var items = parseJSON(summary, isAction: false)
            self.questions = items
            print(self.questions)
            DispatchQueue.main.async {
                self.questionsLoading = true
            }
            return items ?? []
            
        } catch {
            print(error)
        }
        return []
    }
    
    func transcribe(_ data: Data, fileName: String) async -> String? {
        do {
            let result = try await openAIClient.audio.transcribe(file: data, fileName: fileName, mimeType: .m4a, prompt: 
            """
                    \(transcription)
            
            This is an ongoing transcription of a conversation between a doctor and their patient. Please pick up where the last left off and finish it.
                    
            """)

            self.transcription += result.text
            
            return result.text
        } catch {
            print("Error transcribing audio: \(error)")
        }
        return nil
    }
    
    func addToDB(_ script: String, summary: String) async {
        let db = Firestore.firestore()
        
        let ref = db.collection("Appointments")
        
        do {
            try await ref.addDocument(data: [
                "transcription" : script,
                "summary"       : summary,
                "todos"         : actionItems,
                "questions"     : questions
            ])
            print("upload successful")
        } catch {
            print("Error uploading to Firebase: \(error)")
        }
        
    }
    
}


