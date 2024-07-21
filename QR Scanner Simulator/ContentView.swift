//
//  ContentView.swift
//  QR Scanner Simulator
//
//  Created by Ahmed Shaban on 21/07/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var urlString: String = ""
    @State private var savedUrls: [String] = UserDefaults.standard.stringArray(forKey: "SavedURLs") ?? []
    @State private var selectedUrl: String = ""
    @State private var showingAlert = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            HStack {
                Picker("Select URL", selection: $selectedUrl) {
                    ForEach(savedUrls, id: \.self) { url in
                        Text(url)
                    }
                }
                .onChange(of: selectedUrl) { oldValue, newValue in
                    urlString = newValue
                }
                .pickerStyle(MenuPickerStyle())
            }

            TextField("Enter URL", text: $urlString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                Button(action: saveUrl) {
                    Text("Save URL")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Spacer().frame(width: 10)
                
                Button(action: simulateScan) {
                    Text("Simulate Scan")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .padding()
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Invalid URL"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    func saveUrl() {
        guard !urlString.isEmpty, URL(string: urlString) != nil else {
            errorMessage = "Please enter a valid URL to save."
            showingAlert = true
            return
        }
        if !savedUrls.contains(urlString) {
            savedUrls.append(urlString)
            UserDefaults.standard.set(savedUrls, forKey: "SavedURLs")
        }
        urlString = ""
    }

    func simulateScan() {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            errorMessage = "The URL entered is not valid."
            showingAlert = true
            return
        }
        UIApplication.shared.open(url)
    }
}


#Preview {
    ContentView()
}
