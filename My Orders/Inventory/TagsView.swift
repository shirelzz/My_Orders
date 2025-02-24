//
//  TagsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 27/04/2024.
//

import SwiftUI

struct TagsView: View {
    
    @ObservedObject var tagManager: TagManager
    @State private var newTag: String = ""

    var body: some View {
        Form{
            Section {
                HStack{
                    TextField("Enter a tag", text: $newTag)
//                    TextField("Enter a tag", text: $newTag, onCommit: {
//                        tagManager.addTag(newTag)
//                        newTag = ""
//                    })
                    
                    Button("Add") {
                        tagManager.addTag(newTag)
                        newTag = ""
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newTag.isEmpty)
                }

            }
                
//                ScrollView {
                    List(tagManager.tags, id: \.self) { tag in
                        HStack{
                            Text(tag)
                            
                            Spacer()
                            
                            Button(action: {
                                tagManager.removeTag(tag)
                            }) {
                                Image(systemName: "trash")
                                    .resizable()
                                    .foregroundColor(.red)
                                    .frame(width: 14,height: 14)
//                                    .background(Color.clear)
                            }
                            .buttonStyle(.borderless)
//                            .background(Color.clear)
                            .padding(4)
                        }

                    }
                }
            
//        }
         .navigationTitle("Tags")
    }
}

#Preview {
    TagsView(tagManager: TagManager.shared)
}
