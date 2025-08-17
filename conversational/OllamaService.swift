//
//  OllamaService.swift
//  conversational
//
//  Created by Gregory on 8/18/25.
//

import Foundation

actor OllamaService {
    private let baseURL = "http://localhost:11434"
    private let model = "gemma3n:e4b"
    
    struct Message: Codable {
        let role: String
        let content: String
        
        static func user(_ content: String) -> Message {
            Message(role: "user", content: content)
        }
    }
    
    struct ChatRequest: Codable {
        let model: String
        let messages: [Message]
        let stream: Bool
    }
    
    struct ChatResponse: Codable {
        let message: Message
    }
    
    func predictURLs(for input: String) async -> [String] {
        guard !input.isEmpty else { return [] }
        
        return await performPrediction(for: input)
    }
    
    private func performPrediction(for input: String) async -> [String] {
        let prompt = createPrompt(for: input)
        let message = Message.user(prompt)
        
        let request = ChatRequest(
            model: model,
            messages: [message],
            stream: false
        )
        
        guard let url = URL(string: "\(baseURL)/api/chat") else {
            print("Invalid Ollama URL")
            return []
        }
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(request)
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // Check if task was cancelled
            if Task.isCancelled {
                return []
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Ollama request failed with status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return []
            }
            
            let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
            return parseURLPredictions(from: chatResponse.message.content)
            
        } catch {
            if !Task.isCancelled {
                print("Error calling Ollama: \(error)")
            }
            return []
        }
    }
    
    private func createPrompt(for input: String) -> String {
        guard let promptPath = Bundle.main.path(forResource: "url_predictor", ofType: "md"),
              let promptTemplate = try? String(contentsOfFile: promptPath) else {
            // Fallback prompt if file not found
            return """
            You are a URL predictor. Given the user input "\(input)", predict the most likely URLs they want to visit.
            Respond with a JSON array of URLs only.
            
            Example: ["https://github.com", "https://gitlab.com"]
            """
        }
        
        return promptTemplate
            .replacingOccurrences(of: "{user_input}", with: input)
            .replacingOccurrences(of: "{current_url}", with: "")
            .replacingOccurrences(of: "{anchor_urls}", with: "No anchor links available.")
    }
    
    private func parseURLPredictions(from response: String) -> [String] {
        // Extract JSON from response (handle markdown code blocks)
        let content = response.trimmingCharacters(in: .whitespacesAndNewlines)
        var jsonContent = content
        
        if content.hasPrefix("```json") && content.hasSuffix("```") {
            jsonContent = String(content.dropFirst(7).dropLast(3)).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if content.hasPrefix("```") && content.hasSuffix("```") {
            jsonContent = String(content.dropFirst(3).dropLast(3)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Try to parse as JSON array
        guard let data = jsonContent.data(using: .utf8),
              let urls = try? JSONSerialization.jsonObject(with: data) as? [String] else {
            print("Failed to parse URL predictions: \(response)")
            return []
        }
        
        // Validate URLs and return
        return urls.compactMap { urlString in
            guard URL(string: urlString) != nil else { return nil }
            return urlString
        }
    }
}
