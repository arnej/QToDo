import QtQuick 1.1
import com.nokia.symbian 1.1
import "../delegates"
import "../js/core.js" as Core

Page
{
    id: todoPage

    property int todoId

    Label {
        id: titleLabel
        text: "Title:"
        font.pixelSize: platformStyle.fontSizeLarge
        anchors
        {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 8
        }
    }

    CheckBox
    {
        id: doneField
        anchors { top: titleLabel.bottom; left: parent.left }
    }

    TextField
    {
        id: titleField
        readOnly: true
        anchors { top: doneField.top; left: doneField.right; right: parent.right }
    }

    Label
    {
        id: noteLabel
        text: "Note:"
        font.pixelSize: platformStyle.fontSizeLarge
        anchors
        {
            top: doneField.bottom
            left: parent.left
            right: parent.right
            margins: 8
        }
    }

    TextArea
    {
        id: noteField

        readOnly: true

        anchors
        {
            top: noteLabel.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
    }

    onStatusChanged:
    {
        var item
        if(status == PageStatus.Activating)
        {
            item = todoPage.state == "details" ? Core.readTodoItem(todoId) : Core.readArchiveItem(todoId)
            doneField.checked = item.done
            titleField.text = item.title
            noteField.text = item.note
            header.text = "Details"
        }
        else if(status == PageStatus.Deactivating)
        {
            item = Core.readTodoItem(todoId)
            item.done = doneField.checked
            Core.updateTodo(item)
        }
    }

    tools: ToolBarLayout {
        ToolButton
        {
            id: backTool
            iconSource: "toolbar-back"

            onClicked:
            {
                update()
                pageStack.pop()
            }
        }

        ButtonRow
        {
            exclusive: false
            anchors.top: parent.top
            anchors.margins: 8

            Button
            {
                id: editTool

                text: "Edit"
                onClicked: todoPage.state = "edit"
            }

            Button
            {
                id: doneTool

                text: "Done"
                onClicked: todoPage.state = "details"
            }
        }

        ToolButton
        {
            id: deleteTool

            iconSource: "toolbar-delete"

            onClicked:
            {
                yesNoDialog.open()
            }
        }
    }

    YesNoDialog
    {
        id: yesNoDialog

        titleText: "Really delete " + ( todoPage.state == "archive" ? "archive item?" : "item?" )

        onAccepted:
        {
            deleteItem()
            pageStack.pop()
        }
    }

    states: [
        State {
            name: "archive"
            PropertyChanges { target: backTool; visible: true }
            PropertyChanges { target: doneTool; visible: false }
            PropertyChanges { target: editTool; visible: false }
            PropertyChanges { target: doneField; width: 0 }
            PropertyChanges { target: titleLabel; height: 0; opacity: 0.0 }
            PropertyChanges { target: noteLabel; height: 0; opacity: 0.0 }
            PropertyChanges { target: header; text: "Details" }
        },
        State {
            name: "details"
            PropertyChanges { target: editTool; visible: true }
            PropertyChanges { target: backTool; visible: true }
            PropertyChanges { target: doneTool; visible: false }
            PropertyChanges { target: titleLabel; height: 0; opacity: 0.0 }
            PropertyChanges { target: noteLabel; height: 0; opacity: 0.0 }
            PropertyChanges { target: header; text: "Details" }
        },
        State {
            name: "edit"
            PropertyChanges { target: backTool; visible: false }
            PropertyChanges { target: editTool; visible: false }
            PropertyChanges { target: doneTool; visible: true }
            PropertyChanges { target: deleteTool; visible: false }
            PropertyChanges { target: doneField; width: 0 }
            PropertyChanges { target: noteField; readOnly: false }
            PropertyChanges { target: titleField; readOnly: false }
            PropertyChanges { target: titleLabel; height: 30; opacity: 1.0 }
            PropertyChanges { target: noteLabel; height: 30; opacity: 1.0 }
            PropertyChanges { target: header; text: "Edit" }
        }
    ]

    transitions: [
        Transition
        {
            NumberAnimation
            {
                properties: "width,height"
                duration: 250
            }
        }
    ]

    function update()
    {
        var item = Core.readTodoItem(todoId)
        item.title = titleField.text
        item.note = noteField.text
        item.modified = new Date()
        Core.updateTodo(item)
    }

    function deleteItem()
    {
        if(todoPage.state == "details") Core.deleteTodo(todoId)
        else if(todoPage.state == "archive") Core.deleteArchiveItem(todoId)
    }
}
