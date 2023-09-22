//
//  SettingsView.swift
//  YomiYomi
//
//  Created by Tenzin Norden on 9/18/23.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink("Catagories") {
                        CatagorySettingsView()
                    }
                } header: {
                    Text("Catagories")
                }
            }
                .navigationTitle("Settings")
        }
    }
}

struct CatagorySettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Catagory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Catagory.pos, ascending: true)],
        animation: .default) private var catagories: FetchedResults<Catagory>
    var body: some View {
        List {
            ForEach(catagories) { catagory in
                HStack {
//                        DEBUG
//                    Text("\(catagory.name!) pos: \(catagory.pos)")
                    TextField("Catagory Name", text: Binding(
                        get: { catagory.name ?? "" },
                        set: { newValue in
                            catagory.name = newValue
                            try? viewContext.save()
                        }
                        ), onEditingChanged: { (editingChanged) in
                            if !editingChanged {
                                if catagory.name!.isEmpty {
                                    viewContext.delete(catagory)
                                    try? viewContext.save()
                                }
                            }
                        })
                }
            }
                .onMove(perform: moveItems)
                .onDelete(perform: deleteItem)
        }
            .environment(\.editMode, .constant(.active))
            .onDisappear() {
            var revisedItems: [Catagory] = catagories.map { cat in
                return cat
            }
            for cat in revisedItems {
                if cat.name!.isEmpty {
                    viewContext.delete(cat)
                }
            }
            revisedItems.removeAll { cat in
                cat.name!.isEmpty
            }
            for reverseIndex in stride(from: revisedItems.count, through: 1, by: -1) {
                revisedItems[reverseIndex - 1].pos = Int64(reverseIndex)
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
            .navigationTitle("Catagories")
            .navigationBarItems(trailing:
                Button(action: { addCatagory() }, label: {
                    Image(systemName: "plus")
                })
        )
    }

    func addCatagory() {
        func getLastPos() -> Int64 {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Catagory")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "pos", ascending: false)]
            fetchRequest.fetchLimit = 1
            do {
                let result = try viewContext.fetch(fetchRequest) as! [Catagory]
                return result.first!.pos
            } catch {
                return 1
            }
        }
        withAnimation {
            do {
                let newCatagory = Catagory(name: "", context: viewContext)
                newCatagory.pos = getLastPos() + 1
                viewContext.insert(newCatagory)
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    func deleteItem(from source: IndexSet) {
        var revisedItems: [Catagory] = catagories.map { cat in
            return cat
        }
        viewContext.delete(revisedItems.remove(at: source.first!))
        for reverseIndex in stride(from: revisedItems.count, through: 1, by: -1) {
            revisedItems[reverseIndex - 1].pos = Int64(reverseIndex)
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func moveItems(from source: IndexSet, to destination: Int) {
        var revisedItems: [Catagory] = catagories.map { cat in
            return cat
        }
        revisedItems.move(fromOffsets: source, toOffset: destination)

        for reverseIndex in stride(from: revisedItems.count, through: 1, by: -1) {
            revisedItems[reverseIndex - 1].pos = Int64(reverseIndex)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    SettingsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

struct FocusedTextField: UIViewRepresentable {
    @Binding var text: String
    var isFirstResponder: Bool = true
    var onCommit: () -> Void

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.text = text
        textField.becomeFirstResponder()
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if isFirstResponder {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FocusedTextField

        init(_ textField: FocusedTextField) {
            self.parent = textField
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onCommit()
        }
    }
}
