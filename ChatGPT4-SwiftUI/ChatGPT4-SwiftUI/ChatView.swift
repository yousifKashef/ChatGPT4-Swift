//
//  ContentView.swift
//  ChatGPT4-SwiftUI
//
//  Created by Yousif on 2023-10-07.
//

import SwiftUI




struct ChatView: View {
    
    @State private var userMessage: String = ""
    @State private var messages: [Message] = [
            Message(role: "assistant", content:  """
YOUR PROMPT GOES HERE
"""),
            
                    Message(role: "assistant", content: "Hello! I'm your personal assistant. How can I assist you today?")
        ]
    
    @State private var isWaitingForResponse: Bool = false


    var body: some View {
        VStack {
            ScrollViewReader { proxy in  // Step 1: Wrap ScrollView inside ScrollViewReader
                            ScrollView {
                                ForEach(messages.indices, id: \.self) { index in
                                    if index != 0 {  // Skip the first (priming) message
                                        let message = messages[index]
                                        HStack {
                                            if message.role == "user" {
                                                Spacer()
                                                Text(message.content)
                                                    .padding()
                                                    .foregroundColor(.white)
                                                    .background(.gray)
                                                    .clipShape(BubbleShape(myMessage: true))
                                            } else {
                                                Text(message.content)
                                                    .padding()
                                                    .foregroundColor(.white)
                                                    .background(.blue)
                                                    .clipShape(BubbleShape(myMessage: false))
                                            }
                                        }
                                        .id(index)  // Step 2: Assign an id to each HStack
                                    }
                                }.padding()
                                if isWaitingForResponse {
                                    Spacer()
                                    ProgressView().scaleEffect(1.5, anchor: .center)
                                    Spacer().frame(height: 40)
                                }
                            }
                            .onChange(of: messages.count) { _ in
                                withAnimation {  // Wrap the scrollTo method inside withAnimation block
                                    proxy.scrollTo(messages.count - 1)
                                }
                            }
                        }


            HStack {
                TextField("Enter your message", text: $userMessage)
                Button("Send") {
                    self.sendMessage()
                }
            }.padding()
        }
    }

    func sendMessage() {
        let newMessage = Message(role: "user", content: userMessage)
        messages.append(newMessage)
        userMessage = ""
        isWaitingForResponse = true  // Set waiting to true as soon as the message is sent
        requestResponse(for: newMessage)
    }

    func requestResponse(for message: Message) {
        let apiKey = ""
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let jsonData: ChatRequest = ChatRequest(
            model: "gpt-4", //gpt-3.5-turbo
            messages: messages,
            temperature: 1,
            max_tokens: 1000,
            top_p: 1,
            frequency_penalty: 0,
            presence_penalty: 0
        )
        
        do {
            let data = try JSONEncoder().encode(jsonData)
            request.httpBody = data
        } catch {
            print("Error encoding jsonData:", error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
               DispatchQueue.main.async {
                   self.isWaitingForResponse = false  // Set waiting to false when the response is received
               }
            if let error = error {
                print("Error:", error)
                return
            }
            
            if let data = data {
                let rawString = String(data: data, encoding: .utf8)
                print("Raw JSON String:", rawString ?? "No Data")
                
                do {
                    let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                    if let responseMessage = chatResponse.choices.first?.message {
                        DispatchQueue.main.async {
                            self.messages.append(responseMessage)
                        }
                    }
                } catch {
                    print("Error decoding ChatResponse:", error)
                }
            }
        }

        
        task.resume()
    }

    
}

