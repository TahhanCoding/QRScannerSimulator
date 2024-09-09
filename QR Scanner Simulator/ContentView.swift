//
//  ContentView.swift
//  QR Scanner Simulator
//
//  Created by Ahmed Shaban on 21/07/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var urlString: String = ""
    @State private var urlLabel: String = ""
    @State private var savedUrls: [(label: String, url: String)] = []
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(savedUrls, id: \.url) { item in
                        HStack {
                            Text(item.label)
                            Spacer()
                            Text(item.url)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    simulateScan(url: item.url)
                                }
                        }
                    }
                    .onDelete(perform: deleteUrl)
                }
                
                VStack(spacing: 10) {
                    TextField("Enter URL", text: $urlString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Enter Label", text: $urlLabel)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    HStack(spacing: 20) {
                        Button(action: saveUrl) {
                            Text("Save URL")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: { simulateScan(url: urlString) }) {
                            Text("Simulate Scan")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("QR Scanner Simulator")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear(perform: loadSavedUrls)
        }
    }

    private func loadSavedUrls() {
        if let savedData = UserDefaults.standard.object(forKey: "SavedURLs") as? [[String: String]] {
            self.savedUrls = savedData.compactMap { dict in
                guard let label = dict["label"], let url = dict["url"] else { return nil }
                return (label: label, url: url)
            }
        }
    }

    private func saveUrl() {
        guard !urlString.isEmpty, let _ = URL(string: urlString) else {
            showAlert(title: "Invalid URL", message: "Please enter a valid URL.")
            return
        }

        guard !urlLabel.isEmpty else {
            showAlert(title: "Missing Label", message: "Please enter a label for the URL.")
            return
        }

        if !savedUrls.contains(where: { $0.url == urlString }) {
            savedUrls.append((label: urlLabel, url: urlString))
            saveToPersistentStorage()
            urlString = ""
            urlLabel = ""
        } else {
            showAlert(title: "Duplicate URL", message: "This URL already exists in the list.")
        }
    }

    private func deleteUrl(at offsets: IndexSet) {
        savedUrls.remove(atOffsets: offsets)
        saveToPersistentStorage()
    }

    private func simulateScan(url: String) {
        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else {
            showAlert(title: "Invalid URL", message: "The URL is not valid or cannot be opened.")
            return
        }
        UIApplication.shared.open(url)
    }

    private func saveToPersistentStorage() {
        let savedDicts = savedUrls.map { ["label": $0.label, "url": $0.url] }
        UserDefaults.standard.set(savedDicts, forKey: "SavedURLs")
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
