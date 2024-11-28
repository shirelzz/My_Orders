//
//  CustomPopUpWindow.swift
//  My Orders
//
//  Created by שיראל זכריה on 24/01/2024.
//

import SwiftUI

struct CustomPopUpWindow: View {
    @Binding var isActive: Bool
    @Binding var item: InventoryItem
    
    let title: String
    let buttonTitle: String
    @State private var offset: CGFloat = 1000
    
    func shortFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }

        var body: some View {

            ZStack {
                Color(.black)
                    .opacity(0.4)

                VStack()  {
                    Text(title)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(.gray)
                    Form{
                        HStack {
                            Text("Name")
                                .foregroundStyle(.black.opacity(0.8))
                            Spacer()
                            Text(item.name)
                        }
                        
                        HStack {
                            Text("Quantity")
                                .foregroundStyle(.black.opacity(0.7))
                            Spacer()
                            Text(item.itemQuantity.description)
                        }
                        
                        HStack {
                            Text("Price")
                                .foregroundStyle(.black.opacity(0.7))
                            Spacer()
                            Text("\(item.itemPrice, specifier: "%.2f")")
                        }
                        
                        HStack {
                            Text("Date")
                                .foregroundStyle(.black.opacity(0.7))
                            Spacer()
                            Text(shortFormat(date: item.AdditionDate))
                            
                        }
                        
                        if !item.itemNotes.isEmpty {
                            HStack {
                                Text("Notes")
                                    .foregroundStyle(.black.opacity(0.7))
                                Spacer()
                                Text(item.itemNotes)
                                
                            }
                        }
                        
                        if !item.size.isEmpty {
                            
                            HStack {
                                Text("Size")
                                    .foregroundStyle(.black.opacity(0.7))
                                
                                Spacer()
                                
                                Text(item.size)
                            }
                        }
                        
                        if item.tags != nil {
                            
                            Section {
                                if let tags = item.tags {
                                    ForEach(tags, id: \.self) { tag in
                                        Text(tag.localized)
                                    }
                                }
                            } header: {
                                Text("tags")
                            }
                        }
                    }
                    
                    Button {
                        action()
                        close()
                    } label: {
                        
                        Text(buttonTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(height: 50)
                }
                .padding()
                .background(.white)
                .frame(maxHeight: 450)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(alignment: .topTrailing) {
                    Button {
                        close()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    .tint(.black)
                    .padding()
                }
                .shadow(radius: 20)
                .padding(20) //30
                .offset(x: 0, y: offset)
                .onAppear {
                    withAnimation(.spring()) {
                        offset = 0
                    }
                }
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)  // For full-screen coverage
        }
        
        func action() {
            
        }

        func close() {
            withAnimation(.spring()) {
                offset = 1000
                isActive = false

            }
        }
    }
