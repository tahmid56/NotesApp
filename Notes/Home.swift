//
//  ContentView.swift
//  Notes
//
//  Created by Tahmid Akter on 7/3/23.
//

import SwiftUI

struct Home: View {
    @State var notes = [Note]()
    @State var showAdd: Bool = false
    @State var showAlert = false
    @State var deleteItem: Note?
    @State var updateNote = ""
    @State var updateNoteId = ""
    @State var isEditMode: EditMode = .inactive
    
    
    var alert: Alert {
        Alert(title: Text("Delete"), message: Text("Are you sure you want to delete this note ?"), primaryButton: .destructive(Text("Delete"), action: {deleteNote()}), secondaryButton: .cancel(Text("Cancel")))
    }
    var body: some View {
        NavigationView{
            List(self.notes){ note in
                if (self.isEditMode == .inactive){
                    Text("\(note.note)")
                        .onLongPressGesture{
                            self.showAlert.toggle()
                            deleteItem = note
                        }
                }else{
                    HStack{
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.yellow)
                        Text("\(note.note)")
                    }.onTapGesture {
                        self.updateNote = note.note
                        self.updateNoteId = note.id
                        self.showAdd.toggle()
                    }
                }
            }
            .alert( isPresented: $showAlert, content: {
                alert
            })
            .sheet(isPresented: $showAdd,onDismiss: fetchNotes, content: {
                if(self.isEditMode == .inactive){
                    AddNoteView()
                }else{
                    UpdateNoteView(text: $updateNote, id: $updateNoteId)
                }
            })
            .onAppear(perform: {
                fetchNotes()
            })
            .navigationTitle("Notes")
            .toolbar{
                ToolbarItem(placement: .automatic){
                    Button(action: {
                        self.showAdd.toggle()
                    }, label: {
                        Text("Add")
                    })
                }
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button(action: {
                        if (self.isEditMode == .inactive){
                            self.isEditMode = .active
                        }else{
                            self.isEditMode = .inactive
                        }
                    }, label: {
                        Text(self.isEditMode == .inactive ? "Edit" : "Done")
                    })
                })
            }
        }
    }
    
    func deleteNote(){
        guard let id = deleteItem?._id else {return}
        let url = URL(string: "http://localhost:3000/notes/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request){ data, res, err in
            guard err == nil else {return}
            guard let data = data else {return}
            
            do{
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]{
                    print(json)
                }
            }catch let error{
                print(error)
            }
        }
        task.resume()
        fetchNotes()
    }
    
    func fetchNotes(){
        let url = URL(string: "http://localhost:3000/notes")!
        let task = URLSession.shared.dataTask(with: url){ data, res, err in
            guard let data = data else {return}
            do {
                let notes = try JSONDecoder().decode([Note].self, from: data)
                self.notes = notes
            }catch{
                print(error)
            }
        }
        task.resume()
        if(self.isEditMode == .active){
            self.isEditMode = .inactive
        }
    }
}

struct Note: Identifiable, Codable {
    var id: String{ _id }
    var _id: String
    var note: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
