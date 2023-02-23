//
//  ContentView.swift
//  PDRClient
//
//  Created by 蒋艺 on 2023/2/23.
//

import SwiftUI
import Charts

struct ContentView: View {
    @State var batchs: [Int] = []
    @State var pdrStep: [PDRStep] = []
    @State var positions: [Position] = []
    @State var runings: [Running] = []
    @State var batch: Int = 0
    
    var body: some View {
        VStack {
            
            List {
                Section{
                    Picker("batch", selection: $batch) {
                        ForEach(batchs, id: \.self) { ibatch in
                            Text("\(ibatch)").tag(ibatch)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                }
                
                Section {
                    NavigationLink {
                        Table(pdrStep) {
                            TableColumn("accx") { step in
                                Text(step.accx.formatted())
                            }
                            TableColumn("accy") { step in
                                Text(step.accy.formatted())
                            }
                            TableColumn("accz") { step in
                                Text(step.accz.formatted())
                            }
                            TableColumn("theta") { step in
                                Text(step.theta.formatted())
                            }
                        }
                    } label: {
                        Label("PDRStep", systemImage: "list.bullet")
                    }
                }
            }
        }
        .padding()
        .onChange(of: batch, perform: { newValue in
            Task{
                let client = MyClient()
                positions = try await client.loadposition(with: newValue)
                pdrStep = try await client.loadPDR(with: newValue)
                runings = try await client.loadRunnings(with: newValue)
            }
        })
        .onAppear {
            Task {
                let client = MyClient()
                batchs = try await client.loadbatchs()
                batch = batchs.first!
                positions = try await client.loadposition(with: batch)
                pdrStep = try await client.loadPDR(with: batch)
                runings = try await client.loadRunnings(with: batch)

            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
