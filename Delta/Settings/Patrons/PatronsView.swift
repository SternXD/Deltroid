//
//  PatronsView.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/17/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI
import SafariServices

private extension NavigationLink where Label == EmptyView, Destination == EmptyView
{
    // Copied from https://stackoverflow.com/a/66891173
    static var empty: NavigationLink {
        self.init(destination: EmptyView(), label: { EmptyView() })
    }
}

extension PatronsView
{
    fileprivate class ViewModel: ObservableObject
    {
        @Published
        var patrons: [Patron]?
        
        @Published
        var error: Error?
        
        @Published
        var webViewURL: URL?
        
        weak var hostingController: UIViewController?
        
        func loadPatrons()
        {
            guard self.patrons == nil else { return }
            
            do
            {
                let fileURL = Bundle.main.url(forResource: "Patrons", withExtension: "plist")!
                let data = try Data(contentsOf: fileURL)
                
                let patrons = try PropertyListDecoder().decode([Patron].self, from: data)
                self.patrons = patrons
            }
            catch
            {
                self.error = error
            }
        }
    }
    
    static func makeViewController() -> UIHostingController<some View>
    {
        let viewModel = ViewModel()
        let contributorsView = PatronsView(viewModel: viewModel)
        
        let hostingController = UIHostingController(rootView: contributorsView)
        hostingController.title = NSLocalizedString("Patrons", comment: "")
        
        viewModel.hostingController = hostingController
                
        return hostingController
    }
}

struct PatronsView: View
{
    @StateObject
    private var viewModel: ViewModel
    
    @State
    private var showErrorAlert: Bool = false
    
    var body: some View {
        List {
            Section(content: {}, footer: {
                Text("These individuals have become patrons of the highest tier. Their monetary contributions help make the continued development of this app possible. ❤️‍🔥")
                    .font(.subheadline)
            })
            
            ForEach(viewModel.patrons ?? []) { patron in
                Section {
                    // First row = contributor
                    PatronCell(name: Text(patron.name).bold(), url: patron.url, linkName: patron.linkName) { webViewURL in
                        viewModel.webViewURL = webViewURL
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .environmentObject(viewModel)
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Unable to Load Patrons"), message: Text(viewModel.error?.localizedDescription ?? ""), dismissButton: .default(Text("OK")) {
                guard let hostingController = viewModel.hostingController else { return }
                hostingController.navigationController?.popViewController(animated: true)
            })
        }
        .onReceive(viewModel.$error) { error in
            guard error != nil else { return }
            showErrorAlert = true
        }
        .onReceive(viewModel.$webViewURL) { webViewURL in
            guard let webViewURL else { return }
            openURL(webViewURL)
        }
        .onAppear {
            viewModel.loadPatrons()
        }
    }
    
    fileprivate init(patrons: [Patron]? = nil, viewModel: ViewModel = ViewModel())
    {
        if let patrons
        {
            // Don't overwrite passed-in viewModel.contributors if contributors is nil.
            viewModel.patrons = patrons
        }
        
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

struct PatronCell: View
{
    var name: Text
    var url: URL?
    var linkName: String?
    
    var action: (URL) -> Void
    
    var body: some View {
        
        let body = Button {
            guard let url else { return }
            
            Task { @MainActor in
                // Dispatch Task to avoid "Publishing changes from within view updates is not allowed, this will cause undefined behavior." runtime error on iOS 16.
                self.action(url)
            }
            
        } label: {
            HStack {
                Text("🔥")
                
                self.name
                    .font(.system(size: 17)) // Match Settings screen
                
                Spacer()
                
                if let linkName
                {
                    Text(linkName)
                        .font(.system(size: 17)) // Match Settings screen
                        .foregroundColor(.gray)
                }
                
                if url != nil
                {
                    NavigationLink.empty
                        .fixedSize()
                }
            }
        }
        .accentColor(.primary)
        
        if url != nil
        {
            body
        }
        else
        {
            // No URL to open, so disable cell highlighting.
            body.buttonStyle(.plain)
        }
    }
}

private extension PatronsView
{
    func openURL(_ url: URL)
    {
        guard let hostingController = viewModel.hostingController else { return }
        
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = UIColor.themeColor
        hostingController.present(safariViewController, animated: true)
    }
}

