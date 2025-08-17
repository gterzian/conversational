//
//  ContentView.swift
//  conversational
//
//  Created by Gregory on 8/18/25.
//

import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.load(URLRequest(url: url))
    }
}

struct ContentView: View {
    @State private var urlString = "https://www.apple.com"
    @State private var currentURL = URL(string: "https://www.apple.com")!
    @State private var predictedURLs: [String] = []
    @State private var showPredictions = false
    @State private var ollamaService = OllamaService()
    
    // Debounce timer
    @State private var debounceTask: Task<Void, Never>?
    
    var body: some View {
        VStack(spacing: 0) {
            // URL input field with predictions
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    TextField("Enter URL", text: $urlString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            navigateToURL()
                        }
                        .onChange(of: urlString) { _, newValue in
                            handleURLInputChange(newValue)
                        }
                    
                    Button("Go") {
                        navigateToURL()
                    }
                }
                .padding()
                
                // URL predictions dropdown
                if showPredictions && !predictedURLs.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(predictedURLs.prefix(5), id: \.self) { url in
                            PredictionRow(url: url) {
                                selectPredictedURL(url)
                            }
                            
                            if url != predictedURLs.prefix(5).last {
                                Divider()
                            }
                        }
                    }
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
                    .shadow(radius: 4)
                    .padding(.horizontal)
                }
            }
            
            // WebView
            WebView(url: currentURL)
        }
        .frame(minWidth: 800, minHeight: 600)
        .onTapGesture {
            // Hide predictions when clicking outside
            showPredictions = false
        }
    }
    
    private func handleURLInputChange(_ newValue: String) {
        // Cancel previous debounce task
        debounceTask?.cancel()
        
        // Hide predictions if input is empty or looks like a complete URL
        if newValue.isEmpty || newValue.hasPrefix("http://") || newValue.hasPrefix("https://") {
            showPredictions = false
            predictedURLs = []
            return
        }
        
        // Start new debounce task
        debounceTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(500))
                
                if !Task.isCancelled {
                    await predictURLs(for: newValue)
                }
            } catch {
                // Task was cancelled, which is expected behavior
            }
        }
    }
    
    private func predictURLs(for input: String) async {
        let predictions = await ollamaService.predictURLs(for: input)
        
        predictedURLs = predictions
        showPredictions = !predictions.isEmpty
    }
    
    private func selectPredictedURL(_ url: String) {
        urlString = url
        showPredictions = false
        predictedURLs = []
        navigateToURL()
    }
    
    private func navigateToURL() {
        showPredictions = false
        predictedURLs = []
        
        var urlToLoad = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Add https:// if no protocol is specified
        if !urlToLoad.hasPrefix("http://") && !urlToLoad.hasPrefix("https://") {
            urlToLoad = "https://" + urlToLoad
        }
        
        if let url = URL(string: urlToLoad) {
            currentURL = url
        }
    }
}

struct PredictionRow: View {
    let url: String
    let action: () -> Void
    @State private var isHovered = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                isPressed = false
            }
        }) {
            HStack {
                Text(url)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                backgroundColor
                    .animation(.easeInOut(duration: 0.15), value: isHovered)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
    }
    
    private var backgroundColor: Color {
        if isPressed {
            return Color(NSColor.selectedControlColor).opacity(0.8)
        } else if isHovered {
            return Color(NSColor.controlAccentColor).opacity(0.15)
        } else {
            return Color.clear
        }
    }
}

#Preview {
    ContentView()
}
