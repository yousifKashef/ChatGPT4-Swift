//
//  ChatModel.swift
//  ChatGPT4-SwiftUI
//
//  Created by Yousif on 2023-10-07.
//

import Foundation

struct ChatRequest: Codable {
    var model: String
    var messages: [Message]
    var temperature: Double
    var max_tokens: Int
    var top_p: Double
    var frequency_penalty: Double
    var presence_penalty: Double
}

struct Message: Codable {
    var role: String
    var content: String
}

struct ChatResponse: Codable {
    var id: String
    var object: String
    var created: Int
    var model: String
    var choices: [Choice]
    var usage: Usage
}

struct Choice: Codable {
    var index: Int
    var message: Message
    var finish_reason: String
}

struct Usage: Codable {
    var total_tokens: Int
    var prompt_tokens: Int
    var completion_tokens: Int
}

